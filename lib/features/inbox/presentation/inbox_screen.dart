import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure_messages.dart';
import '../../../core/l10n/l10n.dart';
import '../../../design/components/components.dart';
import '../../../design/design_context.dart';
import '../../../design/tokens/metrics.dart';
import 'inbox_card.dart';
import 'inbox_controller.dart';

Future<void> openInbox(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const InboxScreen()));

/// 16: the captain's notifications, newest first; tapping one marks it read.
class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final state = ref.watch(inboxControllerProvider);
    final controller = ref.read(inboxControllerProvider.notifier);
    final failure = state.failure;
    final items = state.items;

    return AppScaffold(
      topBar: AppTopBar(
        title: l10n.inboxTitle,
        actions: [
          if (state.unread > 0)
            TextButton(onPressed: controller.markAllRead, child: Text(l10n.inboxMarkAllRead)),
        ],
      ),
      body: RefreshIndicator(
        color: p.brandStrong,
        onRefresh: controller.refresh,
        child: NotificationListener<ScrollNotification>(
          onNotification: (note) {
            if (note.metrics.extentAfter < Sizes.hero * 3) {
              controller.more();
            }
            return false;
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsetsDirectional.symmetric(vertical: Space.x4),
            children: [
              if (state.unread > 0)
                Text(l10n.inboxUnreadCount(state.unread), style: context.typo.caption.copyWith(color: p.textSecondary)),
              const SizedBox(height: Space.x3),
              if (state.loading && state.items.isEmpty)
                const SkeletonList(rows: 5)
              else if (items.isEmpty && failure == null)
                EmptyState(
                  icon: Icons.notifications_none,
                  message: l10n.inboxEmpty,
                  actionLabel: l10n.inboxRefresh,
                  onAction: controller.refresh,
                ),
              for (final item in items) ...[
                InboxCard(item: item, onTap: () => controller.markRead(item)),
                const SizedBox(height: Space.x3),
              ],
              if (failure != null)
                StatusBanner(
                  tone: Tone.danger,
                  message: failure.message(l10n),
                  actionLabel: l10n.actionRetry,
                  onAction: controller.retry,
                ),
              if (state.hasMore && failure == null)
                Padding(
                  padding: const EdgeInsetsDirectional.all(Space.x4),
                  child: Center(child: LoadingDots(color: p.brandStrong)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
