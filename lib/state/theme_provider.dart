import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Light, dark, or following the phone. The saved choice replaces this at start.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
