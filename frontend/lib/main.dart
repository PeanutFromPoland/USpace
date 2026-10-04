import 'package:flutter/material.dart';

void main() => runApp(const KindSpotApp());

class KindSpotApp extends StatelessWidget {
  const KindSpotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KindSpot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF286F88)),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.accessible_forward, size: 64, semanticLabel: 'Dostępność'),
                  SizedBox(height: 16),
                  Text('KindSpot', style: TextStyle(fontSize: 32)),
                  SizedBox(height: 16),
                  Text(
                    'Środowisko demonstracyjne jest gotowe. '
                    'Funkcje aplikacji powstaną zgodnie z uzgodnionym kontraktem.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
