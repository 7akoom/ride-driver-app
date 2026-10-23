import '../l10n/l10n.dart';

/// A ride type's name in the captain's language. A type this build does not know is
/// shown as economy, the platform's base type.
String vehicleLabel(AppLocalizations l10n, String vehicleClass) => switch (vehicleClass) {
      'comfort' => l10n.vehicleComfort,
      _ => l10n.vehicleEconomy,
    };
