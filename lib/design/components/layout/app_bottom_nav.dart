import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';

/// The captain's four main tabs, in order.
enum CaptainTab { home, earnings, wallet, account }

/// The bottom navigation bar (ink background, the active tab in the brand colour; the
/// look comes from the theme). Hidden during a trip and on pushed screens.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.current, required this.onSelected});

  final CaptainTab current;
  final ValueChanged<CaptainTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return NavigationBar(
      selectedIndex: current.index,
      onDestinationSelected: (index) => onSelected(CaptainTab.values[index]),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: l10n.navHome,
        ),
        NavigationDestination(
          icon: const Icon(Icons.bar_chart_outlined),
          selectedIcon: const Icon(Icons.bar_chart),
          label: l10n.navEarnings,
        ),
        NavigationDestination(
          icon: const Icon(Icons.account_balance_wallet_outlined),
          selectedIcon: const Icon(Icons.account_balance_wallet),
          label: l10n.navWallet,
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person),
          label: l10n.navAccount,
        ),
      ],
    );
  }
}
