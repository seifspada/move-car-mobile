import 'package:flutter/material.dart';

class TopNavBar extends StatelessWidget {
  final String villeArrivee;
  final String? prochainRoad;

  const TopNavBar({
    super.key,
    required this.villeArrivee,
    this.prochainRoad,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1a7a6e),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Flèche direction
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_upward, color: Colors.white, size: 28),
              ...List.generate(
                3,
                (_) => Container(
                  width: 2,
                  height: 4,
                  margin: const EdgeInsets.only(top: 2),
                  color: Colors.white38,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // Badge route ou ville
          if (prochainRoad != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE05555),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                prochainRoad!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            )
          else
            Flexible(
              child: Text(
                'Vers $villeArrivee',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

          const Spacer(),

          // Indicateur mission actif
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_shipping,
              color: Color(0xFF1a7a6e),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}