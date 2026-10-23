import 'package:flutter/material.dart';

import '../widgets/registration_gate.dart';
import 'car_form.dart';

/// 06: registration step 2 of 3, the car: make, model, year, colour, plate and class.
/// "Next" sends both steps; the documents come after.
class CarStepScreen extends StatelessWidget {
  const CarStepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RegistrationGate(builder: (form) => CarForm(initial: form.draft));
  }
}
