import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uspace/ui/graphics.dart';
import 'package:uspace/ui/graphics_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Every registered SVG decodes and paints visible pixels in Flutter',
    () async {
      final manifest = jsonDecode(
        await rootBundle.loadString('assets/graphics/manifest.json'),
      ) as List<dynamic>;
      expect(manifest.length, kindSpotGraphics.length);
      for (final entry in manifest) {
        final row = entry as Map<String, dynamic>;
        final id = row['id'] as String;
        expect(kindSpotGraphics[id], 'assets/graphics/${row['plik']}');
        final source = await rootBundle.loadString(kindSpotGraphics[id]!);
        final picture = await vg.loadPicture(SvgStringLoader(source), null);
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        canvas.scale(48 / picture.size.width, 48 / picture.size.height);
        canvas.drawPicture(picture.picture);
        final rendered = recorder.endRecording();
        final image = await rendered.toImage(48, 48);
        final bytes = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        var visible = false;
        for (var i = 3; i < bytes!.lengthInBytes; i += 4) {
          if (bytes.getUint8(i) > 0) {
            visible = true;
            break;
          }
        }
        expect(visible, isTrue, reason: '$id is empty in the Flutter renderer');
        image.dispose();
        rendered.dispose();
        picture.picture.dispose();
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );

  test(
    'Adding an unrelated seed maps the same illustration to the new theme',
    () {
      final light = ColorScheme.fromSeed(seedColor: const Color(0xFF7C3AED));
      final dark = ColorScheme.fromSeed(
        seedColor: const Color(0xFF7C3AED),
        brightness: Brightness.dark,
      );
      for (final scheme in [light, dark]) {
        final mapper = KindSpotPalette(scheme);
        expect(
          mapper.substitute(null, 'path', 'fill', const Color(0xFF445566)),
          scheme.primary,
        );
        expect(
          mapper.substitute(null, 'path', 'fill', const Color(0xFF778899)),
          scheme.primaryContainer,
        );
        expect(
          mapper.substitute(null, 'path', 'stroke', const Color(0xFF112233)),
          scheme.onSurface,
        );
      }
    },
  );

  testWidgets(
    'Graphic controls keep labels and fit narrow screens with large text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF7C3AED),
            ),
          ),
          home: Scaffold(
            body: ListView(
              children: const [
                ListTile(
                  leading: KindSpotSymbol(Icons.tune),
                  title: Text('Filtry'),
                ),
                KindSpotGraphic('illustration_empty_results', height: 120),
                Text('Brak wyników. Zmień filtry lub wybierz inne miasto.'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Filtry'), findsOneWidget);
      expect(find.byType(SvgPicture), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    },
  );
}
