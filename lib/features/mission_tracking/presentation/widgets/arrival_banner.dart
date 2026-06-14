import 'package:flutter/material.dart';

class ArrivalBanner extends StatelessWidget {
  final int distanceMetres;
  final String villeArrivee;
  final bool isArrived;

  const ArrivalBanner({
    super.key,
    required this.distanceMetres,
    required this.villeArrivee,
    required this.isArrived,
  });

  @override
  Widget build(BuildContext context) {
    if (isArrived) {
      return Container(
        width: double.infinity,
        color: Colors.green,
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Arrivé à $villeArrivee !',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      width: double.infinity,
      color: Colors.blue.shade50,
      padding: const EdgeInsets.all(8),
      child: Text(
        'Distance vers $villeArrivee : ${distanceMetres}m',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.blue.shade800, fontSize: 13),
      ),
    );
  }
}