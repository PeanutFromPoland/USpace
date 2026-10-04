import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Standalone preparation for native mobile API integration. Not wired to demo.
enum ApiFailureKind {
  timeout,
  network,
  unauthorized,
  forbidden,
  rateLimited,
  unavailable,
  http,
  invalidResponse,
}

class ApiFailure implements Exception {
  const ApiFailure(this.kind, {this.statusCode});

  final ApiFailureKind kind;
  final int? statusCode;

  // Do not include response bodies, URLs, credentials or private data in errors.
  @override
  String toString() => 'ApiFailure(${kind.name}, status: $statusCode)';
}

class ApiConfiguration {
  ApiConfiguration(
    Uri baseUri, {
    this.allowLoopbackHttp = false,
    this.timeout = const Duration(seconds: 10),
    this.maxResponseBytes = 65536,
  }) : baseUri = _validate(baseUri, allowLoopbackHttp) {
    if (timeout <= Duration.zero || maxResponseBytes <= 0) {
      throw ArgumentError('Timeout and response limit must be positive.');
    }
  }

  final Uri baseUri;
  final bool allowLoopbackHttp;
  final Duration timeout;
  final int maxResponseBytes;

  static Uri _validate(Uri uri, bool allowLoopbackHttp) {
    final loopback = const [
      'localhost',
      '127.0.0.1',
      '[::1]',
      '::1',
    ].contains(uri.host.toLowerCase());
    if (!uri.hasAuthority ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        (uri.scheme != 'https' &&
            !(allowLoopbackHttp && uri.scheme == 'http' && loopback))) {
      throw ArgumentError('API requires HTTPS; local HTTP is explicit.');
    }
    if (uri.pathSegments.any(
      (part) =>
          part == '..' ||
          part == '.' ||
          part.contains('/') ||
          part.contains('\\'),
    )) {
      throw ArgumentError('API base path must not contain traversal.');
    }
    return uri.replace(
      path: uri.path.endsWith('/') ? uri.path : '${uri.path}/',
    );
  }

  Uri resolve(String relativePath) {
    // Product routes must first be approved; restrict requests to this origin.
    if (!RegExp(r'^[a-zA-Z0-9_-]+(/[a-zA-Z0-9_-]+)*$').hasMatch(relativePath)) {
      throw ArgumentError('Expected a relative API path without query.');
    }
    return baseUri.resolve(relativePath);
  }
}

abstract interface class ApiJsonTransport {
  Future<Map<String, dynamic>> getJson(String relativePath);
}

/// dart:io implementation for Android/iOS; not a browser transport.
/// No automatic retry: callers own retries after an explicit user action.
class NativeApiJsonTransport implements ApiJsonTransport {
  NativeApiJsonTransport(this.configuration);

  final ApiConfiguration configuration;

  @override
  Future<Map<String, dynamic>> getJson(String relativePath) async {
    final uri = configuration.resolve(relativePath);
    final client = HttpClient()..connectionTimeout = configuration.timeout;
    try {
      return await _read(client, uri).timeout(configuration.timeout);
    } on ApiFailure {
      rethrow;
    } on TimeoutException {
      throw const ApiFailure(ApiFailureKind.timeout);
    } on IOException {
      throw const ApiFailure(ApiFailureKind.network);
    } on FormatException {
      throw const ApiFailure(ApiFailureKind.invalidResponse);
    } finally {
      client.close(force: true);
    }
  }

  Future<Map<String, dynamic>> _read(HttpClient client, Uri uri) async {
    final request = await client.getUrl(uri);
    request.followRedirects = false;
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    final response = await request.close();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiFailure(
        _statusKind(response.statusCode),
        statusCode: response.statusCode,
      );
    }
    if (response.headers.contentType?.mimeType != 'application/json') {
      throw ApiFailure(
        ApiFailureKind.invalidResponse,
        statusCode: response.statusCode,
      );
    }
    final bytes = <int>[];
    await for (final chunk in response) {
      if (bytes.length + chunk.length > configuration.maxResponseBytes) {
        throw ApiFailure(
          ApiFailureKind.invalidResponse,
          statusCode: response.statusCode,
        );
      }
      bytes.addAll(chunk);
    }
    final value = jsonDecode(utf8.decode(bytes));
    if (value is! Map<String, dynamic>) {
      throw ApiFailure(
        ApiFailureKind.invalidResponse,
        statusCode: response.statusCode,
      );
    }
    return value;
  }

  static ApiFailureKind _statusKind(int status) => switch (status) {
    401 => ApiFailureKind.unauthorized,
    403 => ApiFailureKind.forbidden,
    429 => ApiFailureKind.rateLimited,
    >= 500 => ApiFailureKind.unavailable,
    _ => ApiFailureKind.http,
  };
}
