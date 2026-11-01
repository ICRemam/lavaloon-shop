import 'package:flutter/material.dart';
import 'package:lavaloon_assessment/presentation/config/color_schemes.dart';

class AdvancedThemes {
  ThemeData lightTheme(BuildContext context) => ThemeData(
    colorScheme: lightColorScheme,
    scaffoldBackgroundColor: lightColorScheme.appBackground,
    textTheme: Theme.of(context).textTheme.apply(
      bodyColor: Colors.black,
      decorationColor: Colors.black,
      displayColor: Colors.black,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: lightColorScheme.appBackground,
      foregroundColor: Colors.black,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: lightColorScheme.secondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightColorScheme.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightColorScheme.appSurfaceVariant,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: lightColorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: lightColorScheme.secondary, width: 2),
      ),
    ),
    dividerTheme: DividerThemeData(color: Colors.grey.shade300),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: lightColorScheme.secondary),
  );
}
