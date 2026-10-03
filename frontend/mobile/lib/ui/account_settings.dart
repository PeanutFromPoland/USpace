import 'package:flutter/material.dart';

import '../app_controller.dart';
import 'components.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key, required this.controller});
  final AppController controller;
  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  String? message;
  bool failed = false;
  Future<void> reset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: const Text('Usuń lokalne dane demo?'),
        content: const Text(
          'Usuniesz lokalne dane, także nazwane filtry i ustawienia dostępności. Saldo wróci do 1000 pkt, a przykładowe miejsce wróci w wersji testowej. Nie jest to usunięcie konta na serwerze.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Usuń dane demo'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    await performReset();
  }

  Future<void> performReset() async {
    try {
      await widget.controller.reset();
      if (mounted)
        setState(() {
          message = 'Lokalne dane usunięte.';
          failed = false;
        });
    } catch (_) {
      if (mounted)
        setState(() {
          message = 'Nie udało się usunąć danych. Poprzedni stan pozostaje. Spróbuj ponownie.';
          failed = true;
        });
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) => Scaffold(
      appBar: adaptiveAppBar(context, 'Ustawienia konta'),
      body: pageBody([
        const SectionTitle('Sesja konta'),
        const Text(
          'Zamknięcie konta ukryje jego ekrany do ponownego wejścia. Nowe uruchomienie otworzy konto testowe od początku.',
        ),
        if (widget.controller.sessionError != null)
          Semantics(
            liveRegion: true,
            child: Notice(
              widget.controller.sessionError!,
              icon: Icons.error_outline,
            ),
          ),
        OutlinedButton(
          key: const ValueKey('demo-exit'),
          onPressed: widget.controller.saving
              ? null
              : widget.controller.closeDemoSession,
          child: const Text('Zamknij konto demonstracyjne'),
        ),
        const SectionTitle('Usuń dane z urządzenia'),
        const Text(
          'Ta opcja usuwa również nazwane filtry i ustawienia dostępności, które zwykle pozostają po restarcie.',
        ),
        TextButton(
          key: const ValueKey('account-reset'),
          onPressed: widget.controller.saving ? null : reset,
          child: const Text('Usuń dane demonstracyjne'),
        ),
        if (message != null)
          Semantics(liveRegion: true, child: Notice(message!)),
        if (failed)
          OutlinedButton(
            key: const ValueKey('account-reset-retry'),
            onPressed: widget.controller.saving ? null : performReset,
            child: const Text('Ponów usunięcie danych'),
          ),
      ]),
    ),
  );
}
