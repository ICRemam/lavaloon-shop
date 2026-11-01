import 'package:flutter/material.dart';

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFFED3E37),
  onPrimary: Colors.white,
  primaryContainer: Color(0xFFFDE8C8),
  onPrimaryContainer: Color(0xFF1B1B1F),
  secondary: Color(0xFFED3E37),
  onSecondary: Colors.white,
  secondaryContainer: Color(0xFFFCB857),
  onSecondaryContainer: Color(0xFF1B1B1F),
  tertiary: Color(0xFFF7F1EA),
  onTertiary: Color(0xFF6B6158),
  tertiaryContainer: Color(0xFFFCB857),
  onTertiaryContainer: Color(0xFF1B1B1F),
  error: Colors.red,
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  surface: Color(0xFFFEFBFF),
  onSurface: Color(0xFF1B1B1F),
  onSurfaceVariant: Color(0xFF6B7588),
  outline: Color(0xFF757780),
  onInverseSurface: Color(0xFFF2F0F4),
  inverseSurface: Color(0xFF303034),
  inversePrimary: Color(0xFFFCB857),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFFED3E37),
  outlineVariant: Color(0xFFE4D5C8),
  scrim: Color(0xFF000000),
);

extension ColorSchemeBackground on ColorScheme {
  Color get appBackground => const Color(0xFFFFF8F4);

  Color get appOnBackground => const Color(0xFF303030);

  Color get appSurfaceVariant => const Color(0xFFFFFFFF);
}
