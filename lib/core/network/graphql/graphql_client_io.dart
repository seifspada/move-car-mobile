// lib/core/network/graphql/graphql_client_io.dart

import 'dart:io';
import 'package:http/io_client.dart';

/// Retourne un IOClient avec timeout — utilisé sur Android/iOS/Desktop
IOClient? buildHttpClient() {
  final client = HttpClient();
  client.connectionTimeout = const Duration(seconds: 30);
  client.idleTimeout = const Duration(seconds: 60);
  return IOClient(client);
}