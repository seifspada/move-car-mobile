import 'package:flutter/material.dart';

class GpsStatusIndicator extends StatelessWidget {
  final bool isActive;
  final double? accuracy;

  const GpsStatusIndicator({
    super.key,
    required this.isActive,
    this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.green : Colors.red,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.gps_fixed : Icons.gps_off,
            color: isActive ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            isActive
                ? 'GPS actif${accuracy != null ? ' (±${accuracy!.toStringAsFixed(0)}m)' : ''}'
                : 'GPS inactif',
            style: TextStyle(
              color: isActive ? Colors.green.shade800 : Colors.red.shade800,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}