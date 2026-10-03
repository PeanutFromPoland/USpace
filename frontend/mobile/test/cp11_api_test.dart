import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:uspace/data/api_health_repository.dart';
import 'package:uspace/data/api_transport.dart';

class FixtureTransport implements ApiJsonTransport {
  FixtureTransport(this.response);
  final Map<String, dynamic> response;
  String? path;
  @override
  Future<Map<String, dynamic>> getJson(String relativePath) async {
    path = relativePath;
    return response;
  }
}

void main() {
  test('configuration rejects credentials and unsafe origins', () {
    for (final url in [
      'http://example.test',
      'https://user:secret@example.test',
      'https://example.test?token=secret',
      'https://example.test#fragment',
      'file:///tmp/api',
    ]) {
      expect(() => ApiConfiguration(Uri.parse(url)), throwsArgumentError);
    }
    expect(
      () => ApiConfiguration(Uri.parse('http://127.0.0.1')),
      throwsArgumentError,
    );
    expect(
      () => ApiConfiguration(
        Uri.parse('http://10.0.2.2'),
        allowLoopbackHttp: true,
      ),
      throwsArgumentError,
    );
  });
  test('relative routes preserve prefix and cannot escape origin', () {
    final config = ApiConfiguration(Uri.parse('https://example.test/api/v1'));
    expect(
      config.resolve('health/live').toString(),
      'https://example.test/api/v1/health/live',
    );
    for (final path in [
      '/health/live',
      '../health',
      'https://other.test',
      '//other.test',
      'health?secret=x',
      'health/%2e%2e',
    ]) {
      expect(() => config.resolve(path), throwsArgumentError);
    }
  });
  test('health paths match backend and validate readiness fields', () async {
    final live = FixtureTransport({'status': 'ok'});
    await ApiHealthRepository(live).checkLive();
    expect(live.path, 'health/live');
    final ready = FixtureTransport({
      'status': 'ok',
      'database': 'ready',
      'pgvector': 'ready',
    });
    await ApiHealthRepository(ready).checkReady();
    expect(ready.path, 'health/ready');
    await expectLater(
      ApiHealthRepository(live).checkReady(),
      throwsA(isA<ApiFailure>()),
    );
  });

  group('native transport with controlled loopback server', () {
    late HttpServer server;
    late StreamSubscription<HttpRequest> subscription;
    var status = 200;
    var body = '{"status":"ok"}';
    var type = 'application/json';
    var delay = Duration.zero;
    var calls = 0;
    setUp(() async {
      status = 200;
      body = '{"status":"ok"}';
      type = 'application/json';
      delay = Duration.zero;
      calls = 0;
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      subscription = server.listen((request) async {
        calls++;
        await Future<void>.delayed(delay);
        try {
          request.response.statusCode = status;
          request.response.headers.set('content-type', type);
          if (status == 302) {
            request.response.headers.set('location', '/health/live');
          }
          request.response.write(body);
          await request.response.close();
        } on IOException {
          /* Intentional timeout disconnect. */
        }
      });
    });
    tearDown(() async {
      await subscription.cancel();
      await server.close(force: true);
    });
    NativeApiJsonTransport transport({
      Duration timeout = const Duration(seconds: 2),
      int maxBytes = 65536,
    }) => NativeApiJsonTransport(
      ApiConfiguration(
        Uri.parse('http://127.0.0.1:${server.port}'),
        allowLoopbackHttp: true,
        timeout: timeout,
        maxResponseBytes: maxBytes,
      ),
    );
    test('decodes JSON object', () async {
      expect(await transport().getJson('health/live'), {'status': 'ok'});
      expect(calls, 1);
    });
    for (final code in [401, 403, 429, 503]) {
      final kind = switch (code) {
        401 => ApiFailureKind.unauthorized,
        403 => ApiFailureKind.forbidden,
        429 => ApiFailureKind.rateLimited,
        _ => ApiFailureKind.unavailable,
      };
      test('HTTP $code remains distinct and excludes body secrets', () async {
        status = code;
        body = 'server-private-detail';
        await expectLater(
          transport().getJson('health/live'),
          throwsA(
            isA<ApiFailure>()
                .having((e) => e.kind, 'kind', kind)
                .having((e) => e.statusCode, 'status', code)
                .having(
                  (e) => e.toString().contains(body),
                  'secret excluded',
                  false,
                ),
          ),
        );
        expect(calls, 1);
      });
    }
    test('redirect not followed', () async {
      status = 302;
      await expectLater(
        transport().getJson('health/live'),
        throwsA(isA<ApiFailure>().having((e) => e.statusCode, 'status', 302)),
      );
      expect(calls, 1);
    });
    test('malformed JSON, array and HTML rejected', () async {
      for (final invalid in ['{', '[]']) {
        body = invalid;
        await expectLater(
          transport().getJson('health/live'),
          throwsA(
            isA<ApiFailure>().having(
              (e) => e.kind,
              'kind',
              ApiFailureKind.invalidResponse,
            ),
          ),
        );
      }
      type = 'text/html';
      await expectLater(
        transport().getJson('health/live'),
        throwsA(isA<ApiFailure>()),
      );
    });
    test('response bytes bounded before parsing', () async {
      await expectLater(
        transport(maxBytes: 8).getJson('health/live'),
        throwsA(
          isA<ApiFailure>().having(
            (e) => e.kind,
            'kind',
            ApiFailureKind.invalidResponse,
          ),
        ),
      );
    });
    test('whole request times out without retry', () async {
      delay = const Duration(milliseconds: 200);
      await expectLater(
        transport(timeout: const Duration(milliseconds: 50))
            .getJson('health/live'),
        throwsA(
          isA<ApiFailure>().having(
            (e) => e.kind,
            'kind',
            ApiFailureKind.timeout,
          ),
        ),
      );
      expect(calls, 1);
    });
  });
}
