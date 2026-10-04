import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:uspace/data/product_api.dart';
import 'package:uspace/integration/api_controller.dart';
import 'package:uspace/ui/api_app.dart';
import 'package:uspace/ui/api_personalization.dart';
import 'package:uspace/ui/graphics.dart';
import 'package:uspace/ui/theme.dart';

import 'product_api_test.dart' show Sessions, me, config, jsonResponse;

void main() {
  if (!const bool.fromEnvironment('CAPTURE_API_GRAPHICS')) return;
  testWidgets('Capture connected profile, cosmetic picker and categorized shop', (
    tester,
  ) async {
    final flutter = Platform.environment['FLUTTER_ROOT']!;
    final fonts = FontLoader('Roboto');
    for (final weight in ['regular', 'bold']) {
      fonts.addFont(
        Future.value(
          ByteData.sublistView(
            File(
              '$flutter/bin/cache/artifacts/material_fonts/roboto-$weight.ttf',
            ).readAsBytesSync(),
          ),
        ),
      );
    }
    await fonts.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(
        Future.value(
          ByteData.sublistView(
            File(
              '$flutter/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
            ).readAsBytesSync(),
          ),
        ),
      );
    await icons.load();
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const owned = [
      {'id': 'avatar_default', 'kind': 'avatar', 'label': 'Domyślny awatar'},
      {'id': 'avatar_lemur', 'kind': 'avatar', 'label': 'Lemur'},
      {'id': 'avatar_cat', 'kind': 'avatar', 'label': 'Kot'},
      {'id': 'frame_bow', 'kind': 'frame', 'label': 'Obręcz z kokardą'},
      {'id': 'explorer', 'kind': 'theme', 'label': 'Odkrywca'},
      {'id': 'gardener', 'kind': 'theme', 'label': 'Ogrodnik'},
    ];
    var account = <String, dynamic>{
      ...me,
      'uiSettings': {'colorThemeId': 'explorer', 'darkMode': false},
      'appearance': {
        'avatarId': 'avatar_lemur',
        'frameId': 'frame_bow',
        'titleId': 'title_default',
      },
      'achievements': <dynamic>[],
    };
    final api = ProductApi(
      Uri.parse('https://api.example/api/v1/'),
      client: MockClient((r) async {
        if (r.url.path.endsWith('/configuration')) {
          return jsonResponse(config);
        }
        if (r.url.path.endsWith('/me')) {
          return jsonResponse(account);
        }
        if (r.url.path.endsWith('/me/cosmetics')) {
          return jsonResponse({'items': owned, 'nextCursor': null});
        }
        if (r.url.path.endsWith('/rewards')) {
          return jsonResponse({
            'items': [
              {
                'id': 'reward_avatar_lemur',
                'cosmetic': {'id': 'avatar_lemur', 'kind': 'avatar'},
                'name': 'Profilowe: Lemur',
                'description': 'Minimalistyczny lemur',
                'kind': 'cosmetic',
                'categoryId': 'avatar',
                'costPoints': 100,
                'status': 'available',
                'redemptionMethods': ['account_item'],
                'owned': false,
              },
              {
                'id': 'reward_avatar_cat',
                'cosmetic': {'id': 'avatar_cat', 'kind': 'avatar'},
                'name': 'Profilowe: Kot',
                'description': 'Minimalistyczny kot',
                'kind': 'cosmetic',
                'categoryId': 'avatar',
                'costPoints': 100,
                'status': 'available',
                'redemptionMethods': ['account_item'],
                'owned': false,
              },
              {
                'id': 'reward_frame',
                'cosmetic': {'id': 'frame_bow', 'kind': 'frame'},
                'name': 'Obręcz z kokardą',
                'description': 'Ramka profilu',
                'kind': 'cosmetic',
                'categoryId': 'frame',
                'costPoints': 100,
                'status': 'available',
                'redemptionMethods': ['account_item'],
                'owned': false,
              },
              {
                'id': 'reward_theme_explorer',
                'cosmetic': {'id': 'explorer', 'kind': 'theme'},
                'name': 'Motyw Odkrywca',
                'description': 'Pergamin, mapy i lupy',
                'kind': 'cosmetic',
                'categoryId': 'theme',
                'costPoints': 100,
                'status': 'available',
                'redemptionMethods': ['account_item'],
                'owned': false,
              },
              {
                'id': 'reward_theme_gardener',
                'cosmetic': {'id': 'gardener', 'kind': 'theme'},
                'name': 'Motyw Ogrodnik',
                'description': 'Ciemnozielona paleta, liście i kwiaty',
                'kind': 'cosmetic',
                'categoryId': 'theme',
                'costPoints': 100,
                'status': 'available',
                'redemptionMethods': ['account_item'],
                'owned': false,
              },
            ],
            'nextCursor': null,
          });
        }
        return jsonResponse({'items': [], 'nextCursor': null});
      }),
    );
    addTearDown(api.close);
    final controller = ApiController(api, Sessions());
    controller.configuration = config;
    await controller.refreshMe();
    final key = GlobalKey();
    Future<void> show(Widget page) async {
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: kindSpotTheme(controller.profile),
            builder: (context, child) => KindSpotBackdrop(
              themeId: controller.profile.theme,
              child: child!,
            ),
            home: KeyedSubtree(key: UniqueKey(), child: page),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> capture(String id) async {
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final dir = Directory('build/graphics-v4')..createSync(recursive: true);
        File('${dir.path}/$id.png')
            .writeAsBytesSync(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    await show(apiProfile(controller));
    await capture('profile-explorer');
    await show(ApiCosmeticPicker(controller: controller));
    await capture('cosmetics-explorer');
    await show(apiRewards(controller));
    await capture('shop-categories');
    account = {
      ...account,
      'uiSettings': {'colorThemeId': 'gardener', 'darkMode': true},
    };
    await controller.refreshMe();
    await show(apiProfile(controller));
    await capture('profile-gardener');
    expect(tester.takeException(), isNull);
  });
}
