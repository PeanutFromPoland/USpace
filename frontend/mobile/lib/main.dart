import 'package:flutter/material.dart';

import 'ui/connect_app.dart';
import 'ui/introduction.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KindSpotIntroduction(child: ConnectKindSpot()));
}
