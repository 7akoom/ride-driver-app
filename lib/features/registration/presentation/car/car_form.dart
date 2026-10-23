import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_messages.dart';
import '../../../../core/error/result.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/time/calendar_date.dart';
import '../../../../design/components/components.dart';
import '../../../../design/design_context.dart';
import '../../../../design/tokens/metrics.dart';
import '../../../onboarding/domain/entities/next_step.dart';
import '../../../onboarding/presentation/onboarding_navigation.dart';
import '../../domain/entities/registration_draft.dart';
import '../../domain/values/car_problems.dart';
import '../../domain/values/text_rules.dart';
import '../registration_controller.dart';
import '../widgets/car_color_picker.dart';
import '../widgets/registration_messages.dart';
import '../widgets/vehicle_class_options.dart';

class CarForm extends ConsumerStatefulWidget {
  const CarForm({super.key, required this.initial});

  final RegistrationDraft initial;

  @override
  ConsumerState<CarForm> createState() => _CarFormState();
}

class _CarFormState extends ConsumerState<CarForm> {
  late final _make = TextEditingController(text: widget.initial.make);
  late final _model = TextEditingController(text: widget.initial.model);
  late final _year = TextEditingController(text: widget.initial.year);
  late final _color = TextEditingController(text: widget.initial.color);
  late final _plate = TextEditingController(text: widget.initial.plate);

  bool _tried = false;
  bool _sending = false;
  Failure? _failure;

  @override
  void dispose() {
    for (final controller in [_make, _model, _year, _color, _plate]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _edit(RegistrationDraft Function(RegistrationDraft draft) change) {
    setState(() => _failure = null);
    ref.read(registrationFormProvider.notifier).edit(change);
  }

  Future<void> _send(RegistrationDraft draft) async {
    setState(() => _tried = true);

    if (!CarProblems.of(draft, CalendarDate.today()).none || _sending) {
      return;
    }

    setState(() => _sending = true);
    final result = await ref.read(registrationFormProvider.notifier).submit();

    if (!mounted) {
      return;
    }

    switch (result) {
      case Ok():
        openStep(context, NextStep.documents);
      case Err(:final failure):
        setState(() {
          _sending = false;
          _failure = failure;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = ref.watch(registrationFormProvider).valueOrNull?.draft ?? widget.initial;
    final problems = _tried ? CarProblems.of(draft, CalendarDate.today()) : const CarProblems();
    final failure = _failure;
    final plateTaken = failure is ConflictFailure;
    final plate = normalizePlate(draft.plate);

    return AppScaffold(
      topBar: AppTopBar(title: l10n.registerTitle),
      bottomAction: AppButton(label: l10n.actionNext, loading: _sending, onPressed: () => _send(draft)),
      body: ListView(
        children: [
          const StepDots(current: 2, count: 3),
          const SizedBox(height: Space.x6),
          Text(l10n.registerCarTitle, style: context.typo.h1),
          const SizedBox(height: Space.x6),
          AppTextField(
            controller: _make,
            label: l10n.registerMake,
            hint: l10n.registerMakeHint,
            error: l10n.fieldProblem(problems.make),
            textInputAction: TextInputAction.next,
            onChanged: (value) => _edit((d) => d.copyWith(make: value)),
          ),
          const SizedBox(height: Space.x5),
          AppTextField(
            controller: _model,
            label: l10n.registerModel,
            hint: l10n.registerModelHint,
            error: l10n.fieldProblem(problems.model),
            textInputAction: TextInputAction.next,
            onChanged: (value) => _edit((d) => d.copyWith(model: value)),
          ),
          const SizedBox(height: Space.x5),
          AppTextField(
            controller: _year,
            label: l10n.registerYear,
            error: l10n.yearProblem(problems.year),
            keyboardType: TextInputType.number,
            fieldDirection: TextDirection.ltr,
            inputFormatters: const [WesternDigitsFormatter(maxLength: 4)],
            onChanged: (value) => _edit((d) => d.copyWith(year: value)),
          ),
          const SizedBox(height: Space.x5),
          AppTextField(
            controller: _color,
            label: l10n.registerColor,
            error: l10n.fieldProblem(problems.color),
            onChanged: (value) => _edit((d) => d.copyWith(color: value)),
          ),
          const SizedBox(height: Space.x3),
          CarColorPicker(
            selectedName: draft.color,
            onPicked: (name) {
              _color.text = name;
              _edit((d) => d.copyWith(color: name));
            },
          ),
          const SizedBox(height: Space.x5),
          if (plate.isNotEmpty) ...[
            Align(alignment: AlignmentDirectional.centerStart, child: PlateBadge(number: plate)),
            const SizedBox(height: Space.x2),
          ],
          AppTextField(
            controller: _plate,
            label: l10n.registerPlate,
            error: plateTaken ? l10n.registerPlateTaken : l10n.fieldProblem(problems.plate),
            fieldDirection: TextDirection.ltr,
            onChanged: (value) => _edit((d) => d.copyWith(plate: value)),
          ),
          const SizedBox(height: Space.x5),
          VehicleClassOptions(
            selected: draft.vehicleClass,
            onSelected: (option) => _edit((d) => d.copyWith(vehicleClass: option)),
          ),
          if (failure != null && !plateTaken) ...[
            const SizedBox(height: Space.x4),
            StatusBanner(tone: Tone.danger, message: failure.message(l10n)),
          ],
        ],
      ),
    );
  }
}
