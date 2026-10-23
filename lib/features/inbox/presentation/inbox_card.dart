import 'package:flutter/material.dart';

import '../../../core/format/time_format.dart';
import '../../../core/l10n/l10n.dart';
import '../../../design/design_context.dart';
import '../../../design/tokens/metrics.dart';
import '../domain/entities/inbox_item.dart';

/// One notification: its icon, title and text, how long ago, and whether it is unread.
class InboxCard extends StatelessWidget {
  const InboxCard({super.key, required this.item, required this.onTap});

  final InboxItem item;
  final VoidCallback onTap;

  static IconData iconOf(InboxGroup group) => switch (group) {
        InboxGroup.trips => Icons.local_taxi_outlined,
        InboxGroup.wallet => Icons.account_balance_wallet_outlined,
        InboxGroup.documents => Icons.badge_outlined,
        InboxGroup.account => Icons.person_outline,
        InboxGroup.other => Icons.notifications_none,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = context.typo;

    return Material(
      color: item.read ? p.surface : p.surface2,
      borderRadius: const BorderRadius.all(Radius.circular(Radii.card)),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(Radii.card)),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(Space.x4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: Sizes.avatar,
                height: Sizes.avatar,
                decoration: BoxDecoration(
                  color: item.read ? p.surface2 : p.brandSoft,
                  borderRadius: const BorderRadius.all(Radius.circular(Radii.card)),
                ),
                child: Icon(iconOf(item.group), color: p.textPrimary, size: Sizes.icon),
              ),
              const SizedBox(width: Space.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(item.title, style: t.bodyStrong, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: Space.x2),
                        Text(formatAgo(l10n, item.at.toLocal(), DateTime.now()), style: t.micro.copyWith(color: p.textSecondary)),
                        if (!item.read) ...[
                          const SizedBox(width: Space.x1),
                          Icon(Icons.circle, size: Space.x2, color: p.brandStrong, semanticLabel: l10n.inboxUnread),
                        ],
                      ],
                    ),
                    if (item.body.isNotEmpty) ...[
                      const SizedBox(height: Space.x1),
                      Text(item.body, style: t.body.copyWith(color: p.textSecondary)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
