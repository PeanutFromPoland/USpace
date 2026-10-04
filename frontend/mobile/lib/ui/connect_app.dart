import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../data/product_api.dart';
import '../domain/models.dart';
import '../integration/api_controller.dart';
import 'api_app.dart';
import 'components.dart';
import 'theme.dart';

class ConnectKindSpot extends StatefulWidget {
  const ConnectKindSpot({super.key});
  @override
  State<ConnectKindSpot> createState() => _ConnectKindSpotState();
}

class _ConnectKindSpotState extends State<ConnectKindSpot> {
  final url = TextEditingController();
  ApiController? controller;
  bool local = false;
  String? error;
  @override
  void initState() {
    super.initState();
    const explicit = String.fromEnvironment('KINDSPOT_API_URL');
    final configured = explicit.isNotEmpty
        ? explicit
        : kIsWeb
        ? Uri.base.resolve('/api/v1/').toString()
        : '';
    if (configured.isNotEmpty) {
      url.text = configured;
      local = kDebugMode && const bool.fromEnvironment('KINDSPOT_LOCAL_HTTP');
      connect();
    }
  }

  void connect() {
    try {
      final api = ProductApi(
        Uri.parse(url.text.trim()),
        localHttp: kDebugMode && local,
      );
      controller = ApiController(
        api,
        SecureApiSessionStore(api.base.toString()),
        uiStore: ApiAccessibilityStore(),
      );
      error = null;
    } on ArgumentError {
      error =
          'Podaj adres HTTPS zakończony /api/v1/. Lokalne HTTP włącz osobno.';
    }
  }

  @override
  void dispose() {
    url.dispose();
    controller?.api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller != null) {
      return ConnectedKindSpotApp(
        controller: controller!,
        onChangeServer: () => setState(() {
          controller?.api.close();
          controller = null;
        }),
      );
    }
    return MaterialApp(
      title: 'KindSpot',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pl'),
      supportedLocales: const [Locale('pl')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: kindSpotTheme(const DemoProfile()),
      home: Scaffold(
        appBar: AppBar(title: const Text('Połącz KindSpot')),
        body: pageBody([
          const SectionTitle('Adres backendu'),
          const Text(
            'Wpisz adres API otrzymany od zespołu. Potem zaloguj się na konto.',
          ),
          if (error != null) Notice(error!),
          TextField(
            controller: url,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Adres API',
              hintText: 'https://serwer/api/v1/',
            ),
          ),
          if (kDebugMode)
            SwitchListTile(
              title: const Text('Lokalny backend HTTP'),
              subtitle: const Text(
                'Tylko localhost lub 10.0.2.2. Do testów na emulatorze.',
              ),
              value: local,
              onChanged: (v) => setState(() => local = v),
            ),
          FilledButton(
            onPressed: () => setState(connect),
            child: const Text('Połącz'),
          ),
        ]),
      ),
    );
  }
}
