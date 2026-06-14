// lib/screens/missions_page.dart

import 'package:convoyeur_mobile/features/missions/data/models/mission_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mission_providers.dart';
import '../widgets/mission_list.dart';
import '../widgets/search_bar.dart';
import '../widgets/search_filter_modal.dart';
import '../widgets/search_position_modal.dart';

class MissionsPage extends ConsumerWidget {
  const MissionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchMode       = ref.watch(searchModeProvider);
    final displayedMissions = ref.watch(displayedMissionsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Barre de recherche sticky ──────────────────────────
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.black,
              elevation: 0,
              toolbarHeight: 100,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      SearchBarWidget(onSearch: (query) {
                        ref.read(searchModeProvider.notifier).state = SearchMode.text;
                        ref.read(searchQueryProvider.notifier).state = query;
                        ref.read(currentPageProvider.notifier).state = 1;
                      }),
                    ],
                  ),
                ),
              ),
            ),

            // ── Badges de recherche active ─────────────────────────
            if (searchMode == SearchMode.position)
              _buildPositionBadge(ref),
            if (searchMode == SearchMode.trajet)
              _buildTrajetBadge(ref),

            // ── Contenu principal ──────────────────────────────────
            displayedMissions.when(
              loading: () => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: MissionList(missions: const [], loading: true),
                ),
              ),

              // ✅ CORRECTION : SliverFillRemaining remplit tout
              // l'espace disponible au lieu d'un petit widget flottant
              error: (error, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: _buildErrorWidget(error, ref),
              ),

              data: (response) => SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Compteur de résultats
                    Text(
                      '${response.total} mission${response.total > 1 ? 's' : ''} '
                      'trouvée${response.total > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Liste des missions
                    MissionList(
                      missions: response.missions,
                      onMissionTap: (missionId) {
                        debugPrint('🎯 Mission tapée: $missionId');
                      },
                    ),
                    // Pagination
                    if (response.totalPages > 1) ...[
                      const SizedBox(height: 24),
                      _buildPagination(ref, response),
                    ],
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFilterFAB(ref),
    );
  }

  // ── Badge position ───────────────────────────────────────
  Widget _buildPositionBadge(WidgetRef ref) {
    final city   = ref.watch(selectedPositionCityProvider);
    final radius = ref.watch(positionRadiusProvider);

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.orange, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Missions près de ${city?.name} (${radius.toInt()} km)',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            GestureDetector(
              onTap: () {
                ref.read(selectedPositionCityProvider.notifier).state = null;
                ref.read(searchModeProvider.notifier).state = SearchMode.text;
              },
              child: const Icon(Icons.close, color: Colors.orange, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  // ── Badge trajet ─────────────────────────────────────────
  Widget _buildTrajetBadge(WidgetRef ref) {
    final depart  = ref.watch(selectedTrajetDepartProvider);
    final arrivee = ref.watch(selectedTrajetArriveeProvider);
    final radius  = ref.watch(trajetRadiusProvider);

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.route, color: Colors.blue, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Trajet ${depart?.name} → ${arrivee?.name} (${radius.toInt()} km)',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            GestureDetector(
              onTap: () {
                ref.read(selectedTrajetDepartProvider.notifier).state = null;
                ref.read(selectedTrajetArriveeProvider.notifier).state = null;
                ref.read(searchModeProvider.notifier).state = SearchMode.text;
              },
              child: const Icon(Icons.close, color: Colors.blue, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  // ── Pagination ───────────────────────────────────────────
  Widget _buildPagination(WidgetRef ref, MissionsPaginatedResponse response) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: response.page > 1
              ? () => ref.read(currentPageProvider.notifier).state = response.page - 1
              : null,
          icon: const Icon(Icons.arrow_back),
          label: const Text('Précédent'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            disabledBackgroundColor: Colors.grey[900],
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Page ${response.page} sur ${response.totalPages}',
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: response.page < response.totalPages
              ? () => ref.read(currentPageProvider.notifier).state = response.page + 1
              : null,
          label: const Text('Suivant'),
          icon: const Icon(Icons.arrow_forward),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[600],
            disabledBackgroundColor: Colors.grey[900],
          ),
        ),
      ],
    );
  }

  // ── Erreur : occupe tout l'espace disponible ─────────────
  // ✅ CORRECTION : Center + Column centré verticalement
  // au lieu d'un petit container collé en haut
  Widget _buildErrorWidget(Object error, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red.withOpacity(0.3), width: 1.5),
              ),
              child: const Icon(Icons.wifi_off_rounded, color: Colors.red, size: 34),
            ),
            const SizedBox(height: 20),
            const Text(
              'Erreur de chargement',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            // ✅ Bouton réessayer qui invalide le provider
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(displayedMissionsProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── FAB filtres ──────────────────────────────────────────
  Widget _buildFilterFAB(WidgetRef ref) {
    // Capture le context via Builder pour showModalBottomSheet
    return Builder(
      builder: (context) => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'search-position',
            onPressed: () => showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (_) => const SearchPositionModal(),
            ),
            backgroundColor: Colors.orange[600],
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'search-filter',
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const SearchFilterModal(),
            ),
            backgroundColor: Colors.orange[600],
            child: const Icon(Icons.tune),
          ),
        ],
      ),
    );
  }
}