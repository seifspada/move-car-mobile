// lib/features/home/presentation/pages/home_page.dart

import 'package:convoyeur_mobile/features/missions/presentation/pages/missions_page.dart';
import 'package:convoyeur_mobile/features/reservations/presentation/pages/reservations_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../providers/nav_provider.dart';
import '../widgets/top_bar.dart';
import '../widgets/bottom_nav_bar.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Dashboard'));
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navIndexProvider);

    const pages = [
      DashboardPage(),
      MissionsPage(),
      ReservationsPage(),  // ← vraie page
      ProfilePage(),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: const TopBar(),
      ),
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}