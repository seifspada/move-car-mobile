// lib/features/missions/data/repositories/firebase_notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ==========================================
// 🔧 HANDLER BACKGROUND (doit être top-level)
// ==========================================
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('📨 Message reçu en background: ${message.notification?.title}');
  }
}

// ==========================================
// 🔔 SERVICE PRINCIPAL
// ==========================================
class FirebaseNotificationService {
  static final FirebaseNotificationService _instance =
      FirebaseNotificationService._internal();

  late FirebaseMessaging _firebaseMessaging;
  late FlutterLocalNotificationsPlugin _localNotifications;

  factory FirebaseNotificationService() => _instance;

  FirebaseNotificationService._internal();

  // ==========================================
  // ✅ INITIALISATION COMPLÈTE
  // ==========================================
  Future<void> initialize() async {
    if (kDebugMode) print('🔥 Initialisation Firebase Cloud Messaging...');

    _firebaseMessaging = FirebaseMessaging.instance;

    // Handler pour messages en background (app fermée)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Demander les permissions (iOS + Android 13+)
    // Note: 'carryForward' retiré — non supporté dans firebase_messaging ^15
    final NotificationSettings settings =
        await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
          print('✅ Permission notifications accordée');
          break;
        case AuthorizationStatus.provisional:
          print('⚠️ Permission provisoire');
          break;
        default:
          print('❌ Permission refusée');
      }
    }

    await _initLocalNotifications();
    await _setupFcmToken();

    // Écouter les messages en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) print('📨 Message reçu en foreground');
      _handleMessage(message);
    });

    // Tap sur notification (app en background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) print('📨 App ouverte via notification');
      _handleMessageClick(message);
    });

    // App lancée depuis notification (app fermée)
    final RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) print('📨 App lancée depuis notification');
      _handleMessageClick(initialMessage);
    }

    if (kDebugMode) print('✅ Firebase Cloud Messaging initialisé');
  }

  // ==========================================
  // 🔔 NOTIFICATIONS LOCALES
  // ==========================================
  Future<void> _initLocalNotifications() async {
    _localNotifications = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings);

    // Créer le canal Android haute importance
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'Missions importantes',
      description: 'Notifications pour les nouvelles missions',
      importance: Importance.max,
      enableVibration: true,
      enableLights: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    if (kDebugMode) print('✅ Notifications locales initialisées');
  }

  // ==========================================
  // 🔑 SETUP TOKEN FCM
  // ==========================================
  Future<void> _setupFcmToken() async {
    try {
      final String? token = await _firebaseMessaging.getToken();

      if (token == null || token.isEmpty) {
        if (kDebugMode) print('❌ Impossible de récupérer le token FCM');
        return;
      }

      if (kDebugMode) print('📱 Token FCM: ${token.substring(0, 30)}...');
      await _saveFcmToken(token);

      // Écouter le refresh du token
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        if (kDebugMode) {
          print('🔄 Token FCM rafraîchi: ${newToken.substring(0, 30)}...');
        }
        _saveFcmToken(newToken);
      });
    } catch (e) {
      if (kDebugMode) print('❌ Erreur setup FCM token: $e');
    }
  }

  Future<void> _saveFcmToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      if (kDebugMode) print('💾 Token FCM sauvegardé localement');
    } catch (e) {
      if (kDebugMode) print('❌ Erreur sauvegarde token: $e');
    }
  }

  // ==========================================
  // 📨 GESTION DES MESSAGES
  // ==========================================
  void _handleMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('📨 Titre: ${message.notification?.title}');
      print('   Corps: ${message.notification?.body}');
      print('   Data: ${message.data}');
    }
    _showLocalNotification(message);
  }

  void _handleMessageClick(RemoteMessage message) {
    if (kDebugMode) {
      print('🎯 Notification cliquée — Data: ${message.data}');
    }
    final String? missionId = message.data['missionId'];
    if (missionId != null && kDebugMode) {
      print('📲 Navigation vers mission: $missionId');
      // TODO: NavigationService.navigateTo('/mission/$missionId');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    // Note: pas de 'const' ici car Importance/Priority ne sont pas const
    await _localNotifications.show(
      notification.hashCode,
      notification.title ?? 'Nouvelle mission',
      notification.body ?? '',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'Missions importantes',
          channelDescription: 'Notifications pour les nouvelles missions',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          enableLights: true,
        ),
        iOS: const DarwinNotificationDetails(
          sound: 'default',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['missionId'],
    );
  }

  // ==========================================
  // 🌐 MÉTHODES PUBLIQUES
  // ==========================================

  /// Token FCM depuis SharedPreferences (stocké localement)
  Future<String?> getFcmToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('fcm_token');
      if (kDebugMode) {
        print(token != null
            ? '📱 Token FCM: ${token.substring(0, 30)}...'
            : '⚠️ Aucun token FCM stocké');
      }
      return token;
    } catch (e) {
      if (kDebugMode) print('❌ Erreur récupération token: $e');
      return null;
    }
  }

  /// Token frais directement depuis Firebase
  Future<String?> getFreshFcmToken() async {
    try {
      final String? token = await _firebaseMessaging.getToken();
      if (token != null) await _saveFcmToken(token);
      return token;
    } catch (e) {
      if (kDebugMode) print('❌ Erreur getFreshFcmToken: $e');
      return null;
    }
  }

  /// Désactive les notifications et supprime le token
  Future<void> disableNotifications() async {
    try {
      await _firebaseMessaging.deleteToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('fcm_token');
      if (kDebugMode) print('✅ Notifications désactivées, token supprimé');
    } catch (e) {
      if (kDebugMode) print('❌ Erreur désactivation: $e');
    }
  }
}

// ==========================================
// 🔧 RIVERPOD PROVIDERS
// ==========================================

final firebaseNotificationServiceProvider =
    Provider<FirebaseNotificationService>(
  (ref) => FirebaseNotificationService(),
);

final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final service = ref.watch(firebaseNotificationServiceProvider);
  return service.getFcmToken();
});