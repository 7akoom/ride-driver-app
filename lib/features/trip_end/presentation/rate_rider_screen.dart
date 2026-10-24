import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure_messages.dart';
import '../../../core/error/result.dart';
import '../../../core/l10n/l10n.dart';
import '../../../design/components/components.dart';
import '../../../design/design_context.dart';
import '../../../design/tokens/metrics.dart';
import '../../trip/domain/entities/trip_people.dart';
import '../domain/entities/trip_settlement.dart';
import '../trip_end_providers.dart';

/// Replaces the collect screen: 25, rating the rider. Either way it ends on home.
Future<void> openRateRider(BuildContext context, String tripId, TripRider? rider) =>
    Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute(builder: (_) => RateRiderScreen(tripId: tripId, rider: rider)),
    );

class RateRiderScreen extends ConsumerStatefulWidget {
  const RateRiderScreen({super.key, required this.tripId, this.rider});

  final String tripId;
  final TripRider? rider;

  /// The backend's limit for the note.
  static const int noteLimit = 500;

  /// The tags are offered from this many stars.
  static const int tagsFrom = 4;

  @override
  ConsumerState<RateRiderScreen> createState() => _RateRiderScreenState();
}

class _RateRiderScreenState extends ConsumerState<RateRiderScreen> {
  int _stars = 0;
  final Set<RiderTag> _tags = {};
  final _note = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _home() => Navigator.of(context).popUntil((route) => route.isFirst);

  Future<void> _send() async {
    setState(() => _sending = true);
    final result = await ref.read(tripEndRepositoryProvider).rateRider(
          widget.tripId,
          stars: _stars,
          tags: _stars >= RateRiderScreen.tagsFrom ? _tags : const {},
          note: _note.text,
        );

    if (!mounted) {
      return;
    }

    setState(() => _sending = false);
    switch (result) {
      case Ok():
        showAppToast(context, context.l10n.rateThanks, tone: Tone.success);
        _home();
      case Err(:final failure):
        showAppToast(context, failure.message(context.l10n), tone: Tone.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = widget.rider?.firstName ?? '';

    return AppScaffold(
      topBar: AppTopBar(title: l10n.rateTitle, showBack: false),
      bottomAction: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(label: l10n.rateSend, loading: _sending, onPressed: _stars > 0 ? _send : null),
          AppButton(label: l10n.rateSkip, variant: AppButtonVariant.text, onPressed: _sending ? null : _home),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: Space.x5),
            Center(child: AppAvatar(name: name.isEmpty ? l10n.tripRider : name, size: Sizes.hero * 0.75)),
            const SizedBox(height: Space.x3),
            Text(name.isEmpty ? l10n.rateQuestionNoName : l10n.rateQuestion(name), textAlign: TextAlign.center, style: context.typo.h2),
            const SizedBox(height: Space.x4),
            Center(child: StarRating(value: _stars, onChanged: (stars) => setState(() => _stars = stars))),
            if (_stars >= RateRiderScreen.tagsFrom) ...[
              const SizedBox(height: Space.x4),
              AppMultiChips<RiderTag>(
                options: [(RiderTag.onTime, l10n.rateTagOnTime), (RiderTag.polite, l10n.rateTagPolite)],
                selected: _tags,
                onToggled: (tag) => setState(() => _tags.contains(tag) ? _tags.remove(tag) : _tags.add(tag)),
              ),
            ],
            const SizedBox(height: Space.x4),
            AppTextField(
              controller: _note,
              hint: l10n.rateNoteHint,
              inputFormatters: [LengthLimitingTextInputFormatter(RateRiderScreen.noteLimit)],
              maxLines: 4,
            ),
            const SizedBox(height: Space.x2),
            Text(l10n.rateNotePrivate, style: context.typo.caption.copyWith(color: context.palette.textSecondary)),
          ],
        ),
      ),
    );
  }
}
