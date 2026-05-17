// lib/screens/missions_page.dart

import 'package:convoyeur_mobile/features/missions/data/models/mission_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../providers/mission_providers.dart';
import '../widgets/mission_list.dart';
import '../widgets/search_bar.dart';
import '../widgets/search_filter_modal.dart';
import '../widgets/search_position_modal.dart';

class MissionsPage extends ConsumerWidget {
  const MissionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchMode = ref.watch(searchModeProvider);
    final currentPage = ref.watch(currentPageProvider);
    final displayedMissions = ref.watch(displayedMissionsProvider);
    final isSearchActive = ref.watch(isSearchActiveProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 📌 Barre de recherche sticky
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.black,
              elevation: 0,
              toolbarHeight: 100,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      SizedBox(height: 12),
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
            // 🔍 Badges de recherche active
            if (searchMode == SearchMode.position)
              _buildPositionBadge(context, ref),
            if (searchMode == SearchMode.trajet)
              _buildTrajetBadge(context, ref),
            // 📋 Contenu principal
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: displayedMissions.when(
                  loading: () => MissionList(
                    missions: [],
                    loading: true,
                  ),
                  error: (error, stackTrace) => _buildErrorWidget(error),
                  data: (response) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Compteur de résultats
                      Text(
                        '${response.total} mission${response.total > 1 ? 's' : ''} trouvée${response.total > 1 ? 's' : ''}',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 16),
                      // Liste des missions
                      MissionList(
                        missions: response.missions,
                        onMissionTap: (missionId) {
                          // Naviguer vers détails
                          print('🎯 Mission tapée: $missionId');
                        },
                      ),
                      // Pagination
                      if (response.totalPages > 1) ...[
                        SizedBox(height: 24),
                        _buildPagination(context, ref, response),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // 🎁 Bouton flottant pour filtres
      floatingActionButton: _buildFilterFAB(context, ref),
    );
  }

  /// Widget pour le badge de recherche par position
  Widget _buildPositionBadge(BuildContext context, WidgetRef ref) {
    final city = ref.watch(selectedPositionCityProvider);
    final radius = ref.watch(positionRadiusProvider);

    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          border: Border.all(
            color: Colors.orange.withOpacity(0.3),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on, color: Colors.orange, size: 16),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Missions près de ${city?.name} (${radius.toInt()} km)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                ref.read(selectedPositionCityProvider.notifier).state = null;
                ref.read(searchModeProvider.notifier).state = SearchMode.text;
              },
              child: Icon(Icons.close, color: Colors.orange, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget pour le badge de recherche par trajet
  Widget _buildTrajetBadge(BuildContext context, WidgetRef ref) {
    final depart = ref.watch(selectedTrajetDepartProvider);
    final arrivee = ref.watch(selectedTrajetArriveeProvider);
    final radius = ref.watch(trajetRadiusProvider);

    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          border: Border.all(
            color: Colors.blue.withOpacity(0.3),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.route, color: Colors.blue, size: 16),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Trajet ${depart?.name} → ${arrivee?.name} (${radius.toInt()} km)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                ref.read(selectedTrajetDepartProvider.notifier).state = null;
                ref.read(selectedTrajetArriveeProvider.notifier).state = null;
                ref.read(searchModeProvider.notifier).state = SearchMode.text;
              },
              child: Icon(Icons.close, color: Colors.blue, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget de pagination
  Widget _buildPagination(
    BuildContext context,
    WidgetRef ref,
    MissionsPaginatedResponse response,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Bouton précédent
        ElevatedButton.icon(
          onPressed: response.page > 1
              ? () {
                  ref.read(currentPageProvider.notifier).state =
                      response.page - 1;
                }
              : null,
          icon: Icon(Icons.arrow_back),
          label: Text('Précédent'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            disabledBackgroundColor: Colors.grey[900],
          ),
        ),
        SizedBox(width: 16),
        // Numéros de page
        Text(
          'Page ${response.page} sur ${response.totalPages}',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
        SizedBox(width: 16),
        // Bouton suivant
        ElevatedButton.icon(
          onPressed: response.page < response.totalPages
              ? () {
                  ref.read(currentPageProvider.notifier).state =
                      response.page + 1;
                }
              : null,
          label: Text('Suivant'),
          icon: Icon(Icons.arrow_forward),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[600],
            disabledBackgroundColor: Colors.grey[900],
          ),
        ),
      ],
    );
  }

  /// Widget d'erreur
  Widget _buildErrorWidget(Object error) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.error, color: Colors.red, size: 32),
          SizedBox(height: 8),
          Text(
            'Erreur de chargement',
            style: TextStyle(
              color: Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            error.toString(),
            style: TextStyle(
              color: Colors.red[300],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// FAB pour ouvrir les filtres
  Widget _buildFilterFAB(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Bouton position
        FloatingActionButton.small(
          heroTag: 'search-position',
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (_) => SearchPositionModal(),
              isScrollControlled: true,
            );
          },
          backgroundColor: Colors.orange[600],
          child: Icon(Icons.my_location),
        ),
        SizedBox(height: 12),
        // Bouton filtre
        FloatingActionButton(
          heroTag: 'search-filter',
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => SearchFilterModal(),
            );
          },
          backgroundColor: Colors.orange[600],
          child: Icon(Icons.tune),
        ),
      ],
    );
  }
}
