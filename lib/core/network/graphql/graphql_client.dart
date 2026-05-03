// lib/core/network/graphql/graphql_client.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../config/app_config.dart';
import 'auth_link.dart';

final graphqlClientProvider = Provider<GraphQLClient>((ref) {
  // HTTP Link
  final httpLink = HttpLink(
    AppConfig.graphqlUrl,
    defaultHeaders: {
      'Content-Type': 'application/json',
    },
  );

  // WebSocket Link pour subscriptions
  final wsLink = WebSocketLink(
    AppConfig.graphqlWsUrl,
    config: const SocketClientConfig(
      autoReconnect: true,
      inactivityTimeout: Duration(seconds: 30),
    ),
  );

  // Auth Link (injecte le JWT automatiquement)
  final authLink = AppAuthLink();

  // Lien final : auth → http ou ws selon opération
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
    defaultPolicies: DefaultPolicies(
      query: Policies(
        fetch: FetchPolicy.networkOnly,
      ),
    ),
  );
});