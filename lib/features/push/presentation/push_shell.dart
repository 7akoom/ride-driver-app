import 'package:flutter/widgets.dart';

import 'push_opener.dart';
import 'push_registrar.dart';

/// Around every screen of a signed-in captain: the phone stays registered for their
/// notifications (PushRegistrar) and a tapped one opens what it is about (PushOpener).
class PushShell extends StatelessWidget {
  const PushShell({super.key, required this.recheckAccount, required this.child});

  final void Function(BuildContext context) recheckAccount;
  final Widget child;

  @override
  Widget build(BuildContext context) => PushRegistrar(
        child: PushOpener(recheckAccount: recheckAccount, child: child),
      );
}
