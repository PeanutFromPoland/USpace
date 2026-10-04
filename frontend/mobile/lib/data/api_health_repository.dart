import 'api_transport.dart';

/// These are the only API routes currently present in backend/uspace_api/main.py.
/// Health success says nothing about product routes, sign-in or city-card API.
class ApiHealthRepository {
  const ApiHealthRepository(this.transport);

  final ApiJsonTransport transport;

  Future<void> checkLive() async {
    final response = await transport.getJson('health/live');
    if (response['status'] != 'ok') {
      throw const ApiFailure(ApiFailureKind.invalidResponse);
    }
  }

  Future<void> checkReady() async {
    final response = await transport.getJson('health/ready');
    if (response['status'] != 'ok' ||
        response['database'] != 'ready' ||
        response['pgvector'] != 'ready') {
      throw const ApiFailure(ApiFailureKind.invalidResponse);
    }
  }
}
