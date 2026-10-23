import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/media/image_picking.dart';
import '../../../../core/security/secure_screen.dart';
import '../../../../core/time/calendar_date.dart';
import '../../../../design/components/components.dart';
import '../../../../design/design_context.dart';
import '../../../../design/tokens/metrics.dart';
import '../../domain/entities/document_requirement.dart';
import '../../domain/entities/document_type.dart';
import '../../domain/values/document_expiry.dart';
import '../../domain/values/document_number.dart';
import 'photo_frame.dart';
import 'upload_controller.dart';
import 'upload_messages.dart';

/// 08: one document: its photo (camera or gallery) and, when its type asks, its number
/// and last valid day. Pops with true once handed in. Screenshots are blocked.
class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key, required this.requirement});

  final DocumentRequirement requirement;

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  final _number = TextEditingController();
  CalendarDate? _expiresOn;
  bool _tried = false;

  DocumentType get _type => widget.requirement.type;

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  Future<void> _choosePhoto() async {
    final choice = await showPhotoChoiceSheet(context);

    if (choice != null && choice != PhotoChoice.remove) {
      await ref
          .read(uploadControllerProvider(widget.requirement).notifier)
          .pick(choice == PhotoChoice.camera ? PhotoSource.camera : PhotoSource.gallery);
    }
  }

  Future<void> _send() async {
    setState(() => _tried = true);

    final numberProblem = _type.requiresNumber ? DocumentNumber.check(_number.text) : null;
    final expiryProblem = _type.requiresExpiry ? checkDocumentExpiry(_expiresOn, CalendarDate.today()) : null;
    if (numberProblem != null || expiryProblem != null) {
      return;
    }

    final sent = await ref
        .read(uploadControllerProvider(widget.requirement).notifier)
        .send(number: _number.text, expiresOn: _expiresOn);

    if (sent && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(uploadControllerProvider(widget.requirement));
    final controller = ref.read(uploadControllerProvider(widget.requirement).notifier);
    final face = _type.media == DocumentMedia.profilePhoto;
    final failure = state.failure;
    final today = CalendarDate.today();

    return SecureScreen(
      child: AppScaffold(
        topBar: AppTopBar(title: _type.name.of(Localizations.localeOf(context).languageCode)),
        bottomAction: AppButton(
          label: l10n.documentUpload,
          loading: state.sending,
          onPressed: state.photo == null ? null : _send,
        ),
        body: ListView(
          children: [
            PhotoFrame(face: face, photo: state.photo, progress: state.sending ? state.progress : null),
            const SizedBox(height: Space.x3),
            if (state.photo == null)
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: l10n.photoTake,
                      icon: Icons.photo_camera_outlined,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => controller.pick(PhotoSource.camera),
                    ),
                  ),
                  const SizedBox(width: Space.x2),
                  Expanded(
                    child: AppButton(
                      label: l10n.photoChoose,
                      icon: Icons.photo_library_outlined,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => controller.pick(PhotoSource.gallery),
                    ),
                  ),
                ],
              )
            else
              Center(
                child: AppButton(
                  label: l10n.documentRetake,
                  variant: AppButtonVariant.text,
                  expand: false,
                  onPressed: state.sending ? null : _choosePhoto,
                ),
              ),
            const SizedBox(height: Space.x2),
            Text(
              face ? l10n.documentFaceHint : l10n.documentPhotoHint,
              style: context.typo.caption.copyWith(color: context.palette.textSecondary),
            ),
            if (_type.requiresNumber) ...[
              const SizedBox(height: Space.x5),
              AppTextField(
                controller: _number,
                label: l10n.documentNumber,
                error: _tried ? l10n.documentNumberProblem(DocumentNumber.check(_number.text)) : null,
                onChanged: (_) => controller.clearFailure(),
              ),
            ],
            if (_type.requiresExpiry) ...[
              const SizedBox(height: Space.x5),
              DateFields(
                label: l10n.documentExpiry,
                error: _tried ? l10n.documentExpiryProblem(checkDocumentExpiry(_expiresOn, today)) : null,
                onChanged: (date) => setState(() => _expiresOn = date),
              ),
            ],
            if (failure != null) ...[
              const SizedBox(height: Space.x4),
              StatusBanner(tone: Tone.danger, message: l10n.uploadFailure(failure)),
            ],
          ],
        ),
      ),
    );
  }
}
