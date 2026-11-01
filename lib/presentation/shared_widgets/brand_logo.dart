import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  final double width;

  const BrandLogo({super.key, this.width = 180});

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/lavaloon_logo.png', width: width, fit: BoxFit.contain);
  }
}
