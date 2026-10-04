import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

typedef Json = Map<String, dynamic>;

class ProductApiError implements Exception {
  const ProductApiError(this.message, {this.status, this.code});
  final String message;
  final int? status;
  final String? code;
  @override
  String toString() => message;
}

/// A server operation owns its key; a retry of the same payload reuses it.
String operationKey() => List.generate(
  24,
  (_) => Random.secure().nextInt(256),
).map((b) => b.toRadixString(16).padLeft(2, '0')).join();

class ProductApi {
  ProductApi(
    Uri base, {
    http.Client? client,
    bool localHttp = false,
    this.timeout = const Duration(seconds: 15),
  }) : base = validateBase(base, localHttp),
       client = client ?? http.Client();
  final Uri base;
  final http.Client client;
  final Duration timeout;
  String? token;
  void Function()? onUnauthorized;

  static Uri validateBase(Uri base, bool localHttp) {
    const localHosts = ['localhost', '127.0.0.1', '10.0.2.2', '::1', '[::1]'];
    if (!base.path.replaceAll(RegExp(r'/+$'), '').endsWith('/api/v1') ||
        !base.hasAuthority ||
        base.userInfo.isNotEmpty ||
        base.hasQuery ||
        base.hasFragment ||
        (base.scheme != 'https' &&
            !(localHttp &&
                base.scheme == 'http' &&
                localHosts.contains(base.host))) ||
        base.pathSegments.any(
          (p) => p == '..' || p == '.' || p.contains('\\'),
        )) {
      throw ArgumentError(
        'Podaj adres HTTPS API. Lokalne HTTP wymaga trybu developerskiego.',
      );
    }
    return base.replace(
      path: base.path.endsWith('/') ? base.path : '${base.path}/',
    );
  }

  Future<Json> call(
    String method,
    String path, {
    Json? body,
    Map<String, String>? query,
    String? key,
    bool authenticated = true,
  }) async {
    if (!RegExp(r'^[a-zA-Z0-9_-]+(/[a-zA-Z0-9_-]+)*$').hasMatch(path)) {
      throw ArgumentError('Niepoprawna ścieżka API.');
    }
    try {
      return await _send(
        method,
        path,
        body,
        query,
        key,
        authenticated,
      ).timeout(timeout);
    } on ProductApiError {
      rethrow;
    } on TimeoutException {
      throw const ProductApiError('Serwer nie odpowiedział. Spróbuj ponownie.');
    } on http.ClientException {
      throw const ProductApiError(
        'Brak połączenia z serwerem. Spróbuj ponownie.',
      );
    } on FormatException {
      throw const ProductApiError('Serwer zwrócił niepoprawne dane.');
    }
  }

  Future<Json> _send(
    String method,
    String path,
    Json? body,
    Map<String, String>? query,
    String? key,
    bool authenticated,
  ) async {
    final sentToken = token;
    final request =
        http.Request(method, base.resolve(path).replace(queryParameters: query))
          ..followRedirects = false
          ..headers['Accept'] = 'application/json';
    if (authenticated && token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    if (key != null) request.headers['Idempotency-Key'] = key;
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    final response = await client.send(request);
    final bytes = <int>[];
    await for (final chunk in response.stream) {
      if (bytes.length + chunk.length > 2 * 1024 * 1024) {
        throw const ProductApiError('Odpowiedź serwera jest zbyt duża.');
      }
      bytes.addAll(chunk);
    }
    if (response.statusCode == 401 && authenticated && sentToken == token) {
      onUnauthorized?.call();
    }
    Json decoded = {};
    if (bytes.isNotEmpty &&
        (response.headers['content-type'] ?? '').contains('application/json')) {
      final value = jsonDecode(utf8.decode(bytes));
      if (value is! Json) throw const FormatException('Expected object');
      decoded = value;
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = decoded['error'] as Json?;
      // Fixed, user-facing messages; never expose bodies, tokens or personal data.
      final code = error?['code'] as String?;
      final message = switch (code) {
        'INVALID_CREDENTIALS' => 'Nieprawidłowy e-mail lub hasło.',
        'EMAIL_TAKEN' => 'Ten e-mail ma już konto. Wybierz logowanie.',
        'INSUFFICIENT_POINTS' => 'Za mało punktów.',
        'ALREADY_OWNED' => 'Ten element jest już na Twoim koncie.',
        'PURCHASE_PENDING' => 'Ten zakup jest już przetwarzany.',
        'PRICE_CHANGED' => 'Cena się zmieniła. Odśwież nagrodę.',
        'NOT_ELIGIBLE' => 'Ta czynność jest teraz niedostępna dla konta.',
        'ALREADY_VERIFIED' => 'Ta obserwacja ma już Twój głos.',
        'IDEMPOTENCY_CONFLICT' =>
          'Dane operacji się zmieniły. Sprawdź formularz.',
        _ => switch (response.statusCode) {
          401 => 'Sesja wygasła. Zaloguj się ponownie.',
          403 => 'Brak uprawnień do tej czynności.',
          422 => 'Sprawdź pola formularza i wybrane odpowiedzi.',
          429 => 'Za dużo prób. Spróbuj później.',
          >= 500 => 'Serwer jest niedostępny. Spróbuj ponownie.',
          _ => 'Nie udało się wykonać czynności. Spróbuj ponownie.',
        },
      };
      throw ProductApiError(message, status: response.statusCode, code: code);
    }
    if (response.statusCode != 204 && decoded.isEmpty) {
      throw const ProductApiError('Serwer zwrócił niepoprawne dane.');
    }
    return decoded;
  }

  Future<Json> configuration() =>
      call('GET', 'configuration', authenticated: false);
  Future<Json> login(String email, String password) => call(
    'POST',
    'auth/login',
    body: {'email': email, 'password': password},
    authenticated: false,
  );
  Future<Json> register(String email, String password, String name) => call(
    'POST',
    'auth/register',
    body: {'email': email, 'password': password, 'displayName': name},
    authenticated: false,
  );
  Future<Json> me() => call('GET', 'me');
  Future<Json> search(Json body) => call('POST', 'places/search', body: body);
  Future<Json> place(String id) => call('GET', 'places/$id');
  Future<Json> submit(String id, Json body, String key) =>
      call('POST', 'places/$id/reviews', body: body, key: key);
  Future<Json> redeem(Json body, String key) =>
      call('POST', 'me/redemptions', body: body, key: key);
  void close() => client.close();
}

List<Json> items(Json page) => (page['items'] as List? ?? []).cast<Json>();
