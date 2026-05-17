// lib/core/network/graphql/graphql_client.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../config/app_config.dart';
import 'auth_link.dart';

final graphqlClientProvider = Provider<GraphQLClient>((ref) {
  final httpLink = HttpLink(
    AppConfig.graphqlUrl,
    defaultHeaders: {'Content-Type': 'application/json'},
    // ← Timeout explicite pour éviter le hang
    httpClient: null, // utilise le client par défaut avec timeout ci-dessous
  );

  final authLink = AppAuthLink();

  // HTTP link avec auth — SANS WebSocket par défaut
  final link = authLink.concat(httpLink);

  return GraphQLClient(
    link: link,
    cache: GraphQLCache(store: InMemoryStore()),
    defaultPolicies: DefaultPolicies(
      query: Policies(fetch: FetchPolicy.networkOnly),
    ),
  );
});

// Provider séparé pour les subscriptions WebSocket (uniquement si besoin)
final graphqlWsClientProvider = Provider<GraphQLClient>((ref) {
  final httpLink = HttpLink(AppConfig.graphqlUrl);
  final authLink = AppAuthLink();

  final wsLink = WebSocketLink(
    AppConfig.graphqlWsUrl,
    config: const SocketClientConfig(
      autoReconnect: true,
      inactivityTimeout: Duration(seconds: 30),
      // ← Délai de connexion plus long
      connectFn: null,
    ),
  );

  final link = authLink.concat(
    Link.split(
      (request) => request.isSubscription,
      wsLink,
      httpLink,
    ),
  );

  return GraphQLClient(
    link: link,
    cache: GraphQLCache(store: InMemoryStore()),
  );
});