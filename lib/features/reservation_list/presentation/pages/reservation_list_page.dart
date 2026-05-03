// lib/features/reservations/presentation/pages/reservation_list_page.dart

import 'package:flutter/material.dart';

class ReservationListPage extends StatelessWidget {
  const ReservationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                child: Text('${index + 1}'),
              ),
              title: Text('Réservation #${1000 + index}'),
              subtitle: const Text('En attente'),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}