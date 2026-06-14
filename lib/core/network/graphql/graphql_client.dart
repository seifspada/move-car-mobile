// lib/core/network/graphql/graphql_client.dart

import 'package:flutter/foundation.dart'; // ✅ kIsWeb
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../config/app_config.dart';
import 'auth_link.dart';

// ✅ IOClient uniquement sur mobile/desktop — jamais sur web
import 'graphql_client_io.dart'
    if (dart.library.html) 'graphql_client_web.dart';

final graphqlClientProvider = Provider<GraphQLClient>((ref) {
  final httpLink = HttpLink(
    AppConfig.graphqlUrl,
    defaultHeaders: {'Content-Type': 'application/json'},
    httpClient: kIsWeb ? null : buildHttpClient(), // ✅ null sur web = client par défaut
  );

  final authLink = AppAuthLink();
  final link = authLink.concat(httpLink);

  return GraphQLClient(
    link: link,
    cache: GraphQLCache(store: InMemoryStore()),
    defaultPolicies: DefaultPolicies(
      query: Policies(fetch: FetchPolicy.networkOnly),
      mutate: Policies(fetch: FetchPolicy.networkOnly),
    ),
  );
});

final graphqlWsClientProvider = Provider<GraphQLClient>((ref) {
  final httpLink = HttpLink(
    AppConfig.graphqlUrl,
    httpClient: kIsWeb ? null : buildHttpClient(),
  );
  final authLink = AppAuthLink();

  final wsLink = WebSocketLink(
    AppConfig.graphqlWsUrl,
    config: const SocketClientConfig(
      autoReconnect: true,
      inactivityTimeout: Duration(seconds: 60),
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
    defaultPolicies: DefaultPolicies(
      query: Policies(fetch: FetchPolicy.networkOnly),
      mutate: Policies(fetch: FetchPolicy.networkOnly),
    ),
  );
});