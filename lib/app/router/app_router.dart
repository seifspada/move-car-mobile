// lib/core/router/app_router.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/mission_session/presentation/pages/active_mission_page.dart'; // 🆕
import '../../features/mission_session/presentation/pages/end_mission_page.dart';
import '../../features/mission_session/presentation/pages/start_mission_page.dart';
import '../../features/mission_session/domain/entities/mission_session_entity.dart';
import '../../features/mission_tracking/presentation/pages/mission_incident_page.dart';
import '../../features/mission_tracking/presentation/pages/navigation_screen.dart';
import '../../features/mission_tracking/presentation/pages/mission_tracking_page.dart';
import '../../features/missions/presentation/pages/mission_detail_page.dart';

double _extraDouble(Map<String, dynamic> extra, String key, double fallback) {
  final value = extra[key];
  return value is num ? value.toDouble() : fallback;
}

String _extraString(Map<String, dynamic> extra, String key, String fallback) {
  final value = extra[key];
  return value is String ? value : fallback;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      if (!authState.isInitialized) return null;

      final isAuthenticated = authState.isAuthenticated;
      final isLoginPage = state.matchedLocation == '/login';
      if (!isAuthenticated && !isLoginPage) return '/login';
      if (isAuthenticated && isLoginPage) return '/home';
      return null;
    },
    routes: [
      // ── Auth ──────────────────────────────────────────────
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),

      // ── Home ──────────────────────────────────────────────
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),

      // ── Mission détail ────────────────────────────────────
      GoRoute(
        path: '/mission/:id',
        builder: (context, state) =>
            MissionDetailPage(missionId: state.pathParameters['id']!),
      ),

      // ── Start mission ─────────────────────────────────────
      // Usage : context.push('/mission_session/RES_123', extra: {...})
      GoRoute(
        path: '/mission_session/:reservationId',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return StartMissionPage(
            reservationId: state.pathParameters['reservationId']!,
            latitudeArrivee: _extraDouble(extra, 'latitudeArrivee', 36.8189),
            longitudeArrivee: _extraDouble(extra, 'longitudeArrivee', 10.1658),
            villeArrivee: _extraString(extra, 'villeArrivee', 'Destination'),
          );
        },
      ),

      // ── Active mission (hub : incident / tracking / end) ──  🆕
      // Usage :
      //   context.push(
      //     '/mission_active/SESSION_ID',
      //     extra: {
      //       'reservationId': 'RES_123',
      //       'session': session,   // MissionSessionEntity
      //     },
      //   );
      GoRoute(
        path: '/mission_active/:sessionId',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ActiveMissionPage(
            reservationId: extra['reservationId'] as String,
            session: extra['session'] as MissionSessionEntity,
            latitudeArrivee: _extraDouble(extra, 'latitudeArrivee', 36.8189),
            longitudeArrivee: _extraDouble(extra, 'longitudeArrivee', 10.1658),
            villeArrivee: _extraString(extra, 'villeArrivee', 'Destination'),
          );
        },
      ),

      // ── End mission (accès direct si session déjà démarrée)
      // Usage :
      //   context.push(
      //     '/end_mission/RES_123',
      //     extra: session,   // MissionSessionEntity
      //   );
      GoRoute(
        path: '/mission_incident/:missionId/:sessionId',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return MissionIncidentPage(
            missionId: state.pathParameters['missionId']!,
            sessionId: state.pathParameters['sessionId']!,
            reservationId: _extraString(extra, 'reservationId', ''),
            fallbackLatitude: _extraDouble(extra, 'latitude', 36.8065),
            fallbackLongitude: _extraDouble(extra, 'longitude', 10.1955),
          );
        },
      ),

      GoRoute(
        path: '/end_mission/:reservationId',
        builder: (context, state) {
          final session = state.extra as MissionSessionEntity;
          return EndMissionPage(
            reservationId: state.pathParameters['reservationId']!,
            session: session,
          );
        },
      ),

      // ── Suivi GPS temps réel ──────────────────────────────
      // Usage :
      //   context.push(
      //     '/mission_tracking/MISSION_ID/SESSION_ID',
      //     extra: {
      //       'reservationId'   : 'RES_123',
      //       'latitudeArrivee' : 36.8189,
      //       'longitudeArrivee': 10.1658,
      //       'villeArrivee'    : 'Tunis',
      //     },
      //   );
      GoRoute(
        path: '/mission_tracking/:missionId/:sessionId',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return MissionTrackingPage(
            missionId: state.pathParameters['missionId']!,
            sessionId: state.pathParameters['sessionId']!,
            reservationId: extra['reservationId'] as String? ?? '',
            latitudeArrivee: _extraDouble(extra, 'latitudeArrivee', 36.8189),
            longitudeArrivee: _extraDouble(extra, 'longitudeArrivee', 10.1658),
            villeArrivee: _extraString(extra, 'villeArrivee', 'Destination'),
          );
        },
      ),

      // ── Navigation guidée OSRM ────────────────────────────
      GoRoute(
        path: '/navigation/:missionId/:sessionId',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return NavigationScreen(
            villeDepart: extra['villeDepart'] as String,
            villeArrivee: extra['villeArrivee'] as String,
            positionDepart: extra['positionDepart'] as LatLng,
            positionArrivee: extra['positionArrivee'] as LatLng,
          );
        },
      ),
    ],
  );
});
