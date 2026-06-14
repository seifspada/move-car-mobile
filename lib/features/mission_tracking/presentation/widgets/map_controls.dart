import 'package:flutter/material.dart';

class MapControls extends StatelessWidget {
  final VoidCallback onAlerte;
  final VoidCallback onRecenter;

  const MapControls({
    super.key,
    required this.onAlerte,
    required this.onRecenter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ControlButton(
          icon: Icons.my_location,
          onTap: onRecenter,
          iconColor: const Color(0xFF1a7a6e),
        ),
        const SizedBox(height: 10),
        _ControlButton(icon: Icons.explore, onTap: () {}),
        const SizedBox(height: 10),
        _ControlButton(icon: Icons.volume_up, onTap: () {}),
        const SizedBox(height: 10),
        _ControlButton(
          icon: Icons.warning_amber_rounded,
          onTap: onAlerte,
          backgroundColor: const Color(0xFFF5A623),
          iconColor: Colors.white,
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;

  const _ControlButton({
    required this.icon,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.black54,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }
}