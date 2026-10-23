import 'package:flutter/material.dart';

import '../widgets/registration_gate.dart';
import 'you_form.dart';

/// 05: registration step 1 of 3, the captain: the name as on the national ID, gender,
/// date of birth and nationality.
class YouStepScreen extends StatelessWidget {
  const YouStepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RegistrationGate(builder: (form) => YouForm(initial: form.draft));
  }
}
