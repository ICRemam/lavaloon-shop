import 'package:flutter/material.dart';

class InfoBanner extends StatelessWidget {
  final String message;
  final IconData icon;

  const InfoBanner({super.key, required this.message, this.icon = Icons.cloud_off_rounded});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.orange.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.orange.shade900),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(fontSize: 13, color: Colors.orange.shade900)),
          ),
        ],
      ),
    );
  }
}
