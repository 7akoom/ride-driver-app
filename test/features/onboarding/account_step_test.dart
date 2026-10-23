import 'package:driver_app/core/captain/captain_account.dart';
import 'package:driver_app/core/error/failure.dart';
import 'package:driver_app/core/error/result.dart';
import 'package:driver_app/core/l10n/localized_text.dart';
import 'package:driver_app/core/time/calendar_date.dart';
import 'package:driver_app/features/documents/domain/entities/document_checklist.dart';
import 'package:driver_app/features/documents/domain/entities/document_requirement.dart';
import 'package:driver_app/features/documents/domain/entities/document_type.dart';
import 'package:driver_app/features/documents/domain/entities/document_upload.dart';
import 'package:driver_app/features/documents/domain/repositories/documents_repository.dart';
import 'package:driver_app/features/onboarding/domain/entities/next_step.dart';
import 'package:driver_app/features/onboarding/domain/repositories/onboarding_preferences.dart';
import 'package:driver_app/features/onboarding/domain/use_cases/account_step.dart';
import 'package:driver_app/features/registration/domain/entities/captain_details.dart';
import 'package:driver_app/features/registration/domain/entities/registration_draft.dart';
import 'package:driver_app/features/registration/domain/repositories/registration_repository.dart';
import 'package:flutter_test/flutter_test.dart';

final class _Preferences implements OnboardingPreferences {
  final Set<String> welcomedIds = {};

  @override
  Future<bool> welcomed(String driverId) async => welcomedIds.contains(driverId);

  @override
  Future<void> markWelcomed(String driverId) async => welcomedIds.add(driverId);
}

final class _Registration implements RegistrationRepository {
  _Registration(this.answer);

  final Result<CaptainDetails> answer;

  @override
  Future<Result<CaptainDetails>> details(String driverId) async => answer;

  @override
  Future<Result<CaptainAccount>> submit(RegistrationDraft draft, {CaptainAccount? existing}) =>
      throw UnimplementedError();
}

final class _Documents implements DocumentsRepository {
  _Documents(this.answer);

  final Result<DocumentChecklist> answer;

  @override
  Future<Result<DocumentChecklist>> checklist() async => answer;

  @override
  Future<Result<void>> submit(DocumentUpload upload, {void Function(double sent)? onProgress}) =>
      throw UnimplementedError();
}

final CaptainDetails _complete = CaptainDetails(
  gender: Gender.male,
  dateOfBirth: CalendarDate.of(1990, 1, 1),
  nationality: 'IQ',
);

DocumentChecklist _checklist(RequirementState state) => DocumentChecklist(requirements: [
      DocumentRequirement(type: const DocumentType(code: 'x', name: LocalizedText(en: 'X')), state: state),
    ]);

CaptainAccount _account(CaptainStatus status) =>
    CaptainAccount(id: 'd1', displayName: 'Salim', status: status);

AccountStep _step({
  Result<CaptainDetails>? details,
  Result<DocumentChecklist>? documents,
  _Preferences? preferences,
}) =>
    AccountStep(
      preferences: preferences ?? _Preferences(),
      registration: _Registration(details ?? Ok(_complete)),
      documents: _Documents(documents ?? Ok(_checklist(RequirementState.pendingReview))),
    );

Future<NextStep?> _next(AccountStep step, CaptainAccount? account) async =>
    (await step.after(account)).fold((value) => value, (_) => null);

void main() {
  test('no captain profile yet: the intro', () async {
    expect(await _next(_step(), null), NextStep.join);
  });

  test('waiting for approval: the form, the documents, or the review screen', () async {
    final pending = _account(CaptainStatus.pending);

    expect(await _next(_step(details: const Ok(CaptainDetails())), pending), NextStep.finishRegistration);
    expect(
      await _next(_step(documents: Ok(_checklist(RequirementState.missing))), pending),
      NextStep.documents,
    );
    expect(await _next(_step(), pending), NextStep.underReview);
  });

  test('a failed check is returned, not guessed', () async {
    final result = await _step(documents: const Err(NetworkFailure())).after(_account(CaptainStatus.pending));

    expect(result, isA<Err<NextStep>>());
  });

  test('approved: the welcome once, then the app', () async {
    final preferences = _Preferences();
    final active = _account(CaptainStatus.active);

    expect(await _next(_step(preferences: preferences), active), NextStep.welcome);
    await preferences.markWelcomed('d1');
    expect(await _next(_step(preferences: preferences), active), NextStep.home);
  });

  test('rejected and suspended have their own screens', () async {
    expect(await _next(_step(), _account(CaptainStatus.rejected)), NextStep.rejected);
    expect(await _next(_step(), _account(CaptainStatus.suspended)), NextStep.suspended);
  });
}
