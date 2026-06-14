// lib/core/network/graphql/graphql_client_web.dart

/// Sur le web, on retourne null — graphql_flutter utilise son client HTTP interne
dynamic buildHttpClient() => null;