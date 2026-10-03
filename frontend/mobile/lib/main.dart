import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'data/demo_repository.dart';
import 'ui/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    KindSpotApp(
      controller: AppController(
        DemoRepository(SecureDemoStore()),
        resetAccountOnLaunch: true,
      ),
    ),
  );
}
