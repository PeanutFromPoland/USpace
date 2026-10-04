import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:uspace/data/catalog.dart';
import 'package:uspace/domain/matching.dart';
import 'package:uspace/domain/models.dart';
import 'package:uspace/ui/discovery.dart';
import 'package:uspace/ui/theme.dart';

class FakeTile extends Fake implements TileImage {}

class TileClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => TileRequest();
  @override
  set autoUncompress(bool value) {}
  @override
  void close({bool force = false}) {}
}

class TileHeaders extends Fake implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class TileRequest extends Fake implements HttpClientRequest {
  @override
  HttpHeaders get headers => TileHeaders();
  @override
  Future<HttpClientResponse> close() async => TileResponse();
}

class TileResponse extends Stream<List<int>> implements HttpClientResponse {
  final bytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aG1cAAAAASUVORK5CYII=',
  );
  @override
  int get statusCode => 200;
  @override
  int get contentLength => bytes.length;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => Stream<List<int>>.value(bytes).listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TileOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => TileClient();
}

void main() {
  testWidgets(
    'Map error announces fallback; old attempt cannot fail retry; pins and zoom remain actionable',
    (tester) async {
      final previous = HttpOverrides.current;
      HttpOverrides.global = TileOverrides();
      addTearDown(() => HttpOverrides.global = previous);
      final hits = searchDemoPlaces(demoPlaces, const DemoProfile(), '');
      var listCalls = 0;
      String? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PlacesMap(
                hits: hits,
                cityId: 'krakow',
                onSelect: (hit) => selected = hit.place.id,
                onList: () => listCalls++,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final oldLayer = tester.widget<TileLayer>(find.byType(TileLayer));
      oldLayer.errorTileCallback!(
        FakeTile(),
        StateError('simulated old failure'),
        null,
      );
      tester.binding.scheduleFrame();
      await tester.pump();
      await tester.pump();
      final error = find.text(
        'Podkład mapy jest niedostępny. Lista miejsc nadal działa.',
      );
      expect(error, findsOneWidget);
      expect(
        tester
            .widgetList<Semantics>(
              find.ancestor(of: error, matching: find.byType(Semantics)),
            )
            .any((widget) => widget.properties.liveRegion == true),
        isTrue,
      );
      await tester.tap(find.text('Pokaż listę miejsc'));
      expect(listCalls, 1);
      await tester.tap(find.byKey(const ValueKey('map-retry')));
      tester.binding.scheduleFrame();
      await tester.pump();
      await tester.pump();
      final retryLayer = tester.widget<TileLayer>(find.byType(TileLayer));
      expect(retryLayer.key, isNot(oldLayer.key));
      oldLayer.errorTileCallback!(
        FakeTile(),
        StateError('late old failure'),
        null,
      );
      tester.binding.scheduleFrame();
      await tester.pump();
      await tester.pump();
      expect(error, findsNothing);
      for (final label in ['Przybliż mapę', 'Oddal mapę']) {
        final target = find.byTooltip(label);
        expect(tester.getSize(target).width, greaterThanOrEqualTo(48));
        expect(tester.getSize(target).height, greaterThanOrEqualTo(48));
        await tester.tap(target);
        await tester.pump();
      }
      final markers = tester
          .widget<MarkerLayer>(find.byType(MarkerLayer))
          .markers;
      expect(markers.length, hits.length);
      for (final marker in markers) {
        expect(marker.width, greaterThanOrEqualTo(48));
        expect(marker.height, greaterThanOrEqualTo(48));
        expect((marker.child as IconButton).onPressed, isNotNull);
      }
      (markers.first.child as IconButton).onPressed!();
      expect(selected, hits.first.place.id);
      retryLayer.errorTileCallback!(
        FakeTile(),
        StateError('current failure'),
        null,
      );
      tester.binding.scheduleFrame();
      await tester.pump();
      await tester.pump();
      expect(error, findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final palette in ['orange', 'pink', 'blue']) {
    for (final dark in [false, true]) {
      for (final high in [false, true]) {
        testWidgets(
          'Actual PlaceCard secondary text contrast $palette dark=$dark high=$high',
          (tester) async {
            final theme = uspaceTheme(
              DemoProfile(theme: palette, darkMode: dark, highContrast: high),
            );
            final hit = searchDemoPlaces(
              demoPlaces,
              const DemoProfile(),
              '',
            ).first;
            await tester.pumpWidget(
              MaterialApp(
                theme: theme,
                home: Scaffold(
                  body: SingleChildScrollView(
                    child: PlaceCard(hit: hit, onTap: () {}),
                  ),
                ),
              ),
            );
            final card = tester.widget<Card>(
              find.descendant(
                of: find.byType(PlaceCard),
                matching: find.byType(Card),
              ),
            );
            final background = card.color ?? theme.cardTheme.color!;
            final texts = tester
                .widgetList<Text>(
                  find.descendant(
                    of: find.byType(PlaceCard),
                    matching: find.byType(Text),
                  ),
                )
                .where(
                  (text) =>
                      text.style?.color == theme.colorScheme.onSurfaceVariant,
                )
                .toList();
            expect(texts.length, greaterThanOrEqualTo(2));
            for (final text in texts) {
              final foreground = text.style!.color!;
              final a = foreground.computeLuminance(),
                  b = background.computeLuminance();
              final contrast = a > b
                  ? (a + 0.05) / (b + 0.05)
                  : (b + 0.05) / (a + 0.05);
              expect(contrast, greaterThanOrEqualTo(4.5), reason: text.data);
            }
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}
