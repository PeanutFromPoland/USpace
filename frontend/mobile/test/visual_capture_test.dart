import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uspace/app_controller.dart';
import 'package:uspace/data/demo_repository.dart';
import 'package:uspace/ui/app.dart';

import 'package:uspace/ui/introduction.dart';
import 'package:uspace/ui/theme.dart';
import 'package:uspace/domain/models.dart';

import 'domain_test.dart' show MemoryStore;

void main() {
  if (!const bool.fromEnvironment('CAPTURE_CP02')) return;
  testWidgets('Capture actual Flutter screens without an emulator', (
    tester,
  ) async {
    final root = Platform.environment['FLUTTER_ROOT']!;
    final loader = FontLoader('Roboto')
      ..addFont(
        Future.value(
          ByteData.sublistView(
            File('$root/bin/cache/artifacts/material_fonts/roboto-regular.ttf')
                .readAsBytesSync(),
          ),
        ),
      )
      ..addFont(
        Future.value(
          ByteData.sublistView(
            File('$root/bin/cache/artifacts/material_fonts/roboto-bold.ttf')
                .readAsBytesSync(),
          ),
        ),
      );
    await loader.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(
        Future.value(
          ByteData.sublistView(
            File(
              '$root/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
            ).readAsBytesSync(),
          ),
        ),
      );
    await icons.load();
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          channel,
          (call) async => Directory.systemTemp.path,
        );
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final controller = AppController(DemoRepository(MemoryStore()));
    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: KindSpotApp(controller: controller),
      ),
    );
    await tester.pumpAndSettle();
    Future<void> capture(String name) async {
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final dir = Directory('build/cp02')..createSync(recursive: true);
        File('${dir.path}/$name.png')
            .writeAsBytesSync(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    await tester.tap(find.byKey(const ValueKey('navigation-4')));
    await tester.pumpAndSettle();
    await capture('profile-blue-light');
    await controller.saveProfile(
      controller.profile.copyWith(theme: 'pink', darkMode: true),
    );
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    await tester.pumpAndSettle();
    await capture('profile-pink-dark-200');
    await tester.scrollUntilVisible(
      find.text('Wygląd i dostępność'),
      150,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wygląd i dostępność'));
    await tester.pumpAndSettle();
    await capture('settings-pink-dark-200');
    await tester.binding.handlePopRoute();
    await controller.saveProfile(
      controller.profile.copyWith(theme: 'green', darkMode: false),
    );
    tester.platformDispatcher.textScaleFactorTestValue = 1;
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('navigation-1')));
    await tester.pumpAndSettle();
    await capture('graphics-shop-green-light');
    await tester.tap(find.byKey(const ValueKey('navigation-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lista').first);
    await tester.pumpAndSettle();
    await capture('graphics-places-green-light');
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: kindSpotTheme(const DemoProfile()),
          home: IntroductionSlides(onFinish: () async {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zatrzymaj przewijanie'));
    await tester.pumpAndSettle();
    await capture('introduction-1');
    await tester.tap(find.text('Dalej'));
    await tester.pumpAndSettle();
    await capture('introduction-2');
    await tester.tap(find.text('Dalej'));
    await tester.pumpAndSettle();
    await capture('introduction-3');
    expect(tester.takeException(), isNull);
  });
}
