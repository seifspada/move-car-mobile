import 'package:convoyeur_mobile/features/missions/presentation/pages/missions_page.dart';
import 'package:convoyeur_mobile/features/reservations/presentation/pages/reservations_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:convoyeur_mobile/app/theme/app_colors.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../providers/nav_provider.dart';
import '../widgets/top_bar.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/side_bar.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Dashboard'));
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navIndexProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    const pages = [
      DashboardPage(),
      MissionsPage(),
      ReservationsPage(),
      ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      extendBody: true,
      // ✅ supprimé : extendBodyBehindAppBar: true
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70), // ✅ hauteur fixe simple
        child: const TopBar(),
      ),
      body: Stack(
        children: [
          // ✅ plus de padding top — Flutter le gère via l'appBar
          Padding(
            padding: EdgeInsets.only(
              bottom: 62 + 16 + (bottomPadding > 0 ? bottomPadding + 4 : 16),
            ),
            child: IndexedStack(index: currentIndex, children: pages),
          ),
          const Positioned(left: 0, right: 0, bottom: 0, child: BottomNavBar()),
          const SideBar(),
        ],
      ),
    );
  }
}
