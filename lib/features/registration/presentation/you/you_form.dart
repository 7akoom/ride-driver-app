import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/time/calendar_date.dart';
import '../../../../design/components/components.dart';
import '../../../../design/design_context.dart';
import '../../../../design/tokens/metrics.dart';
import '../../domain/entities/captain_details.dart';
import '../../domain/entities/registration_draft.dart';
import '../../domain/values/you_problems.dart';
import '../car/car_step_screen.dart';
import '../registration_controller.dart';
import '../widgets/nationality_field.dart';
import '../widgets/registration_messages.dart';

class YouForm extends ConsumerStatefulWidget {
  const YouForm({super.key, required this.initial});

  final RegistrationDraft initial;

  @override
  ConsumerState<YouForm> createState() => _YouFormState();
}

class _YouFormState extends ConsumerState<YouForm> {
  late final TextEditingController _name = TextEditingController(text: widget.initial.name);

  /// Problems show once the captain has tried to go on.
  bool _tried = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _edit(RegistrationDraft Function(RegistrationDraft draft) change) =>
      ref.read(registrationFormProvider.notifier).edit(change);

  void _next(RegistrationDraft draft) {
    setState(() => _tried = true);

    if (YouProblems.of(draft, CalendarDate.today()).none) {
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CarStepScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = ref.watch(registrationFormProvider).valueOrNull?.draft ?? widget.initial;
    final problems = _tried ? YouProblems.of(draft, CalendarDate.today()) : const YouProblems();

    return AppScaffold(
      topBar: AppTopBar(title: l10n.registerTitle),
      bottomAction: AppButton(label: l10n.actionNext, onPressed: () => _next(draft)),
      body: ListView(
        children: [
          const StepDots(current: 1, count: 3),
          const SizedBox(height: Space.x6),
          Text(l10n.registerYouTitle, style: context.typo.h1),
          const SizedBox(height: Space.x6),
          AppTextField(
            controller: _name,
            label: l10n.registerName,
            helper: l10n.registerNameLocked,
            error: l10n.nameProblem(problems.name),
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.name],
            onChanged: (value) => _edit((d) => d.copyWith(name: value)),
          ),
          const SizedBox(height: Space.x5),
          Text(l10n.registerGender, style: context.typo.caption.copyWith(color: context.palette.textSecondary)),
          const SizedBox(height: Space.x2),
          AppChoiceChips<Gender?>(
            options: [(Gender.male, l10n.genderMale), (Gender.female, l10n.genderFemale)],
            selected: draft.gender,
            onSelected: (gender) => _edit((d) => d.copyWith(gender: gender)),
          ),
          if (problems.genderMissing) ...[
            const SizedBox(height: Space.x1),
            Text(l10n.fieldRequired, style: context.typo.caption.copyWith(color: context.palette.danger)),
          ],
          const SizedBox(height: Space.x5),
          DateFields(
            label: l10n.registerBirthDate,
            initial: widget.initial.dateOfBirth,
            error: l10n.birthDateProblem(problems.birthDate),
            onChanged: (date) => _edit((d) => d.withDateOfBirth(date)),
          ),
          const SizedBox(height: Space.x5),
          NationalityField(
            code: draft.nationality,
            error: problems.nationalityMissing ? l10n.fieldRequired : null,
            onChanged: (code) => _edit((d) => d.copyWith(nationality: code)),
          ),
        ],
      ),
    );
  }
}
