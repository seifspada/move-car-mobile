// lib/features/missions/presentation/pages/mission_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/graphql/graphql_client.dart';
import '../../../../core/config/mission_icons.dart'; // ← import icônes véhicule
import '../../data/graphql/mission_queries.dart';
import '../../data/models/mission_model.dart';
import '../../domain/entities/mission_entity.dart';
import '../../domain/entities/reservation_entity.dart';
import '../widgets/reservation_modal.dart';
import '../widgets/DynamicMissionsMap.dart';

// ─── Provider ────────────────────────────────────────────────────────────────

final missionDetailProvider =
    FutureProvider.family<MissionDetail, String>((ref, id) async {
  final client = ref.read(graphqlClientProvider);

  final result = await client.query(
    QueryOptions(
      document: gql(getMissionByIdQuery),
      variables: {'id': id},
      fetchPolicy: FetchPolicy.networkOnly,
    ),
  );

  if (result.hasException) throw result.exception!;

  final data = result.data?['getMissionById'] as Map<String, dynamic>?;
  if (data == null) throw Exception('Mission introuvable');

  return MissionDetailModel.fromJson(data);
});

// ─── Palette ──────────────────────────────────────────────────────────────────

const _kBg        = Color(0xFF0A0A0C);
const _kSurface   = Color(0xFF111318);
const _kSurface2  = Color(0xFF181B22);
const _kBorder    = Color(0xFF222530);
const _kOrange    = Color(0xFFF97316);
const _kOrangeGlow= Color(0x33F97316);
const _kMuted     = Color(0xFF5A6072);
const _kSubtext   = Color(0xFF8A93A8);
const _kText      = Color(0xFFF0F2F7);

// ─── Page ─────────────────────────────────────────────────────────────────────

class MissionDetailPage extends ConsumerWidget {
  final String missionId;

  const MissionDetailPage({super.key, required this.missionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionAsync = ref.watch(missionDetailProvider(missionId));

    return Scaffold(
      backgroundColor: _kBg,
      body: missionAsync.when(
        loading: () => const _LoadingView(),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onBack: () => context.pop(),
        ),
        data: (mission) => _MissionDetailBody(mission: mission),
      ),
    );
  }
}

// ─── Corps ───────────────────────────────────────────────────────────────────

class _MissionDetailBody extends StatelessWidget {
  final MissionDetail mission;
  const _MissionDetailBody({required this.mission});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── AppBar ────────────────────────────────────────────────────────
        SliverAppBar(
          backgroundColor: _kBg,
          foregroundColor: _kText,
          title: const Text(
            'Détail mission',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _kText,
              letterSpacing: 0.3,
            ),
          ),
          pinned: true,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  _kOrange,
                  Colors.transparent,
                ]),
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          sliver: SliverList(
            delegate: SliverChildListDelegate([

              // ── Hero véhicule ─────────────────────────────────────────────
              _VehicleHeroCard(mission: mission),

              const SizedBox(height: 16),

              // ── Trajet ────────────────────────────────────────────────────
              _SectionCard(
                title: 'Trajet',
                icon: Icons.alt_route_rounded,
                child: _TrajetWidget(mission: mission),
              ),

              const SizedBox(height: 12),

              // ── Carte ─────────────────────────────────────────────────────
              _SectionCard(
                title: 'Itinéraire',
                icon: Icons.map_rounded,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: DynamicMissionsMap(
                    mission: mission,
                    onDurationCalculated: (int durationMinutes) {
                      debugPrint('Durée calculée : $durationMinutes min');
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Stats ─────────────────────────────────────────────────────
              if (mission.calculs != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: _StatPill(
                        label: 'Montant total',
                        value: '${mission.calculs!.montantTotal.toStringAsFixed(2)} €',
                        icon: Icons.euro_rounded,
                        accent: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatPill(
                        label: 'Distance',
                        value: '${mission.calculs!.distanceKm.toStringAsFixed(0)} km',
                        icon: Icons.route_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatPill(
                        label: 'Péages',
                        value: '${mission.calculs!.fraisPeage.toStringAsFixed(2)} €',
                        icon: Icons.toll_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // ── Disponibilité ─────────────────────────────────────────────
              if (mission.disponibilite != null)
                _SectionCard(
                  title: 'Disponibilité',
                  icon: Icons.calendar_month_rounded,
                  child: _DispoGrid(dispo: mission.disponibilite!),
                ),

              const SizedBox(height: 12),

              // ── Conditions contractuelles ──────────────────────────────────
              _SectionCard(
                title: 'Conditions contractuelles',
                icon: Icons.gavel_rounded,
                child: _ContratsWidget(contrat: mission.contrat),
              ),

              const SizedBox(height: 28),

              // ── Bouton réserver ───────────────────────────────────────────
              _ReserveButton(mission: mission),
            ]),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero véhicule (remplace l'ancien bloc partenaire + véhicule)
// ─────────────────────────────────────────────────────────────────────────────

class _VehicleHeroCard extends StatelessWidget {
  final MissionDetail mission;
  const _VehicleHeroCard({required this.mission});

  @override
  Widget build(BuildContext context) {
    final vehicleConfig = getVehicleConfig(mission.vehicule!.typeVehicule);
    final fuelConfig    = getFuelConfig(mission.vehicule!.typeCarburant);

    final vehicleLabel = vehicleConfig['label'] as String? ?? '';
    final fuelLabel    = fuelConfig['label'] as String? ?? '';
    final iconAsset    = vehicleConfig['icon'] as String?;

    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x40000000), blurRadius: 24, offset: Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          // Accent triangle orange en haut à gauche
          Positioned(
            top: 0, left: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20)),
              child: CustomPaint(
                size: const Size(120, 80),
                painter: _AccentTrianglePainter(),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // ── Icône véhicule ──────────────────────────────────────────
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _kOrange.withOpacity(0.25),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: iconAsset != null
                        ? Image.asset(
                            iconAsset,
                            width: 44,
                            height: 44,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.directions_car_rounded,
                              size: 36,
                              color: Color(0xFF1F2937),
                            ),
                          )
                        : const Icon(
                            Icons.directions_car_rounded,
                            size: 36,
                            color: Color(0xFF1F2937),
                          ),
                  ),
                ),

                const SizedBox(width: 18),

                // ── Infos véhicule ──────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (mission.partenaire != null)
                        Text(
                          mission.partenaire!.entiteGroupe,
                          style: const TextStyle(
                            color: _kSubtext,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.8,
                          ),
                        ),
                      if (mission.vehicule != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          mission.vehicule!.marqueModele,
                          style: const TextStyle(
                            color: _kText,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _Chip(label: vehicleLabel.isNotEmpty ? vehicleLabel : mission.vehicule!.typeVehicule),
                            const SizedBox(width: 6),
                            if (mission.vehicule!.boiteVitesse != null)
                              _Chip(label: mission.vehicule!.boiteVitesse!),
                          ],
                        ),
                        if (fuelLabel.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.local_gas_station_rounded,
                                  color: Color(0xFF00C853), size: 13),
                              const SizedBox(width: 4),
                              Text(
                                fuelLabel,
                                style: const TextStyle(
                                  color: Color(0xFF00C853),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ],
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

class _AccentTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF7A00), Color(0xFFFF4B0B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _kSurface2,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _kBorder),
      ),
      child: Text(
        label,
        style: const TextStyle(color: _kSubtext, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section card
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _kOrangeGlow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: _kOrange, size: 15),
                ),
                const SizedBox(width: 10),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: _kSubtext,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(height: 1, color: _kBorder),
                const SizedBox(height: 14),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trajet
// ─────────────────────────────────────────────────────────────────────────────

class _TrajetWidget extends StatelessWidget {
  final MissionDetail mission;
  const _TrajetWidget({required this.mission});

  @override
  Widget build(BuildContext context) {
    final departCity  = mission.adresseDepart?.villeNom  ?? 'Inconnu';
    final arriveeCity = mission.adresseArrivee?.villeNom ?? 'Inconnu';
    final departAddr  = mission.adresseDepart?.adresseComplete  ?? '';
    final arriveeAddr = mission.adresseArrivee?.adresseComplete ?? '';

    return Column(
      children: [
        // ── Ligne principale : ville → flèche → ville ──────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Point départ
            Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(color: _kOrange, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            // Ville départ
            Expanded(
              child: Text(
                departCity,
                style: const TextStyle(
                  color: _kText,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Flèche + ligne centrale
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 18, height: 1.5, color: _kMuted),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_forward_rounded, color: _kOrange, size: 16),
                  const SizedBox(width: 2),
                  Container(width: 18, height: 1.5, color: _kMuted),
                ],
              ),
            ),
            // Ville arrivée
            Expanded(
              child: Text(
                arriveeCity,
                style: const TextStyle(
                  color: _kText,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 8),
            // Point arrivée
            Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle),
            ),
          ],
        ),

        // ── Labels & adresses ─────────────────────────────────────────────
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Départ
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Départ',
                      style: TextStyle(color: _kMuted, fontSize: 10, fontWeight: FontWeight.w500)),
                  if (departAddr.isNotEmpty)
                    Text(departAddr,
                        style: const TextStyle(color: _kSubtext, fontSize: 11),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            // Arrivée
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Arrivée',
                      style: TextStyle(color: _kMuted, fontSize: 10, fontWeight: FontWeight.w500)),
                  if (arriveeAddr.isNotEmpty)
                    Text(arriveeAddr,
                        style: const TextStyle(color: _kSubtext, fontSize: 11),
                        textAlign: TextAlign.right,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AddressBlock extends StatelessWidget {
  final String label;
  final String city;
  final String address;
  const _AddressBlock({required this.label, required this.city, required this.address});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _kMuted, fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(city, style: const TextStyle(color: _kText, fontSize: 15, fontWeight: FontWeight.w700)),
        if (address.isNotEmpty)
          Text(address, style: const TextStyle(color: _kSubtext, fontSize: 11)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat pill (3 en ligne)
// ─────────────────────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool accent;

  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: accent ? _kOrangeGlow : _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accent ? _kOrange.withOpacity(0.5) : _kBorder,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: accent ? _kOrange : _kSubtext, size: 16),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: accent ? _kOrange : _kText,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: _kMuted, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Disponibilité
// ─────────────────────────────────────────────────────────────────────────────

class _DispoGrid extends StatelessWidget {
  final dynamic dispo;
  const _DispoGrid({required this.dispo});

  String _format(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}\n'
          '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DispoCell(
            label: 'Début',
            value: _format(dispo.dateDebut),
            highlight: false,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _DispoCell(
            label: 'Fin',
            value: _format(dispo.dateFin),
            highlight: false,
          ),
        ),
        if (dispo.dateDepartMax != null) ...[
          const SizedBox(width: 10),
          Expanded(
            child: _DispoCell(
              label: 'Départ max',
              value: _format(dispo.dateDepartMax!),
              highlight: true,
            ),
          ),
        ],
      ],
    );
  }
}

class _DispoCell extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _DispoCell({required this.label, required this.value, required this.highlight});

  @override
  Widget build(BuildContext context) {
    final color = highlight ? const Color(0xFFFBBF24) : _kText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: _kSurface2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlight ? const Color(0xFFFBBF24).withOpacity(0.4) : _kBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: _kMuted, fontSize: 10, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700, height: 1.4)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Contrats
// ─────────────────────────────────────────────────────────────────────────────

class _ContratsWidget extends StatelessWidget {
  final dynamic contrat;
  const _ContratsWidget({this.contrat});

  @override
  Widget build(BuildContext context) {
    final rows = contrat != null
        ? [
            ('Prix par km',              '${contrat.prixParKm.toStringAsFixed(2)} €/km'),
            ('Dépassement kilométrage',  '${contrat.depassementKilometrage.toStringAsFixed(2)} €/km'),
            ('Retard sans avertissement','${contrat.retardSansAvertissement.toStringAsFixed(2)} €/h'),
            ('Restitution autre endroit','${contrat.restitutionAutreEndroit.toStringAsFixed(2)} €/km'),
          ]
        : [
            ('Dépassement kilométrage',  '0.50 €/km'),
            ('Retard sans avertissement','25.00 €/h'),
            ('Restitution autre endroit','1.20 €/km'),
          ];

    return Column(
      children: rows
          .map((r) => _CondRow(label: r.$1, value: r.$2))
          .toList(),
    );
  }
}

class _CondRow extends StatelessWidget {
  final String label;
  final String value;
  const _CondRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: _kSubtext, fontSize: 13),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _kSurface2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kBorder),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: _kText,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bouton réserver
// ─────────────────────────────────────────────────────────────────────────────

class _ReserveButton extends StatelessWidget {
  final MissionDetail mission;
  const _ReserveButton({required this.mission});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7A00), Color(0xFFF97316)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _kOrange.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => ReservationModal.show(
          context,
          mission: mission,
          onConfirm: (ReservationResponseEntity response) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Réservation envoyée — N° ${response.reservation?.numeroReservation ?? ""}',
                ),
                backgroundColor: const Color(0xFF22C55E),
                duration: const Duration(seconds: 4),
              ),
            );
          },
        ),
        icon: const Icon(Icons.arrow_forward_rounded, size: 20),
        label: const Text(
          'Réserver cette mission',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: const StadiumBorder(),
          elevation: 0,
        ),
      ),
    );
  }
}

// ─── Vues d'état ─────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: _kOrange,
            strokeWidth: 2.5,
          ),
          SizedBox(height: 20),
          Text(
            'Chargement de la mission...',
            style: TextStyle(color: _kSubtext, fontSize: 14),
          ),
          SizedBox(height: 6),
          Text(
            'Le serveur peut prendre jusqu\'à 30s au démarrage',
            style: TextStyle(color: _kMuted, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onBack;
  const _ErrorView({required this.message, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: const Icon(Icons.error_outline, color: Colors.red, size: 36),
            ),
            const SizedBox(height: 20),
            const Text(
              'Erreur de chargement',
              style: TextStyle(color: _kText, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: _kSubtext, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                foregroundColor: _kOrange,
                side: const BorderSide(color: _kOrange),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
              child: const Text('Retour', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}