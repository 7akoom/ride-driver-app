import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../design/components/components.dart';
import '../../trip_providers.dart';

/// The rider's photo of the pickup's entrance, full screen and zoomable.
Future<void> openPickupPhoto(BuildContext context, String tripId) => Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => PickupPhotoView(tripId: tripId)),
    );

final _pickupPhotoProvider = FutureProvider.autoDispose.family<Result<String>, String>(
  (ref, tripId) => ref.watch(tripRepositoryProvider).pickupPhoto(tripId),
);

class PickupPhotoView extends ConsumerWidget {
  const PickupPhotoView({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photo = ref.watch(_pickupPhotoProvider(tripId));
    void retry() => ref.invalidate(_pickupPhotoProvider(tripId));

    return AppScaffold(
      topBar: AppTopBar(title: context.l10n.tripEntrancePhoto),
      padded: false,
      body: switch (photo.valueOrNull) {
        null => const SkeletonView(child: SkeletonBox(height: double.infinity)),
        Err(:final failure) => FailureView(failure: failure, onRetry: retry),
        Ok(:final value) => InteractiveViewer(
            child: Center(
              child: Image.network(
                value,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : const SkeletonView(child: SkeletonBox(height: double.infinity)),
                errorBuilder: (_, __, ___) => FailureView(failure: const NetworkFailure(), onRetry: retry),
              ),
            ),
          ),
      },
    );
  }
}
