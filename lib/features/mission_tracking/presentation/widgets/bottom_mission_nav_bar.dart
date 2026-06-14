import 'package:flutter/material.dart';

class BottomMissionNavBar extends StatelessWidget {
  final double distanceKm;
  final int dureeMinutes;
  final String heureArrivee;
  final String villeArrivee;
  final VoidCallback onExit;

  const BottomMissionNavBar({
    super.key,
    required this.distanceKm,
    required this.dureeMinutes,
    required this.heureArrivee,
    required this.villeArrivee,
    required this.onExit,
  });

  String get _dureeFormatee {
    final h = dureeMinutes ~/ 60;
    final m = dureeMinutes % 60;
    if (h > 0) return '$h h $m min';
    return '$m min';
  }

  String get _dureeNumber {
    final h = dureeMinutes ~/ 60;
    final m = dureeMinutes % 60;
    if (h > 0) return '$h';
    return '$m';
  }

  String get _dureeUnit {
    final h = dureeMinutes ~/ 60;
    final m = dureeMinutes % 60;
    if (h > 0) return 'h $m min';
    return 'min';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Row(
              children: [
                // ETA
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$_dureeNumber ',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1a7a6e),
                              ),
                            ),
                            TextSpan(
                              text: _dureeUnit,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${distanceKm.toStringAsFixed(0)} km  ·  $heureArrivee  ·  $villeArrivee',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Bouton itinéraires alternatifs
                Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Icon(
                    Icons.alt_route,
                    color: Colors.black54,
                    size: 22,
                  ),
                ),

                // Bouton quitter navigation
                ElevatedButton(
                  onPressed: onExit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE05555),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Quitter',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}