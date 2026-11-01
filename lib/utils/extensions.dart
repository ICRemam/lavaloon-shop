import 'dart:math';

extension DoubleConversions on double {
  double roundToDecimal([int decimal = 2]) {
    final factor = pow(10, decimal).toDouble();
    final shifted = this * factor;
    final nudge = shifted.isNegative ? -1e-9 : 1e-9;

    return (shifted + nudge).roundToDouble() / factor;
  }

  String doubleToFormattedString([int decimal = 2]) {
    return roundToDecimal(decimal).toStringAsFixed(decimal);
  }
}

extension StringX on String? {
  bool get isBlank => this == null || this!.trim().isEmpty;

  bool get isNotBlank => !isBlank;
}
