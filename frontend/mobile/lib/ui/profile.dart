import 'package:flutter/material.dart';

import 'graphics.dart';

import '../app_controller.dart';
import '../data/catalog.dart';

import 'components.dart';
import 'preferences.dart';
import 'card_connection.dart';
import 'points_history.dart';
import 'account_settings.dart';
import 'customization.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onOpenSection;
  const ProfileScreen({
    super.key,
    required this.controller,
    this.onOpenSection,
  });
  final AppController controller;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AppController get controller => widget.controller;
  VoidCallback? get onOpenSection => widget.onOpenSection;
  String? error;
  String? successMessage;
  Future<void> Function()? retry;
  Future<void> _save(
    Future<void> Function() action, {
    String? success,
    bool preview = false,
  }) async {
    setState(() {
      error = null;
      successMessage = null;
      retry = null;
    });
    try {
      await action();
      if (!mounted) return;
      setState(
        () => successMessage = success ?? 'Zmiana zapisana w lokalnym demo.',
      );
      if (preview) _preview();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = 'Nie udało się zapisać zmiany. Nadal obowiązuje ostatni potwierdzony stan. Spróbuj ponownie.';
        retry = () => _save(action, success: success, preview: preview);
      });
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) => pageBody([
      const SectionTitle('Twój profil'),
      const CircleAvatar(
        radius: 36,
        child: KindSpotSymbol(Icons.person_outline, size: 40),
      ),
      const SizedBox(height: 16),
      Text(demoAccountName, style: Theme.of(context).textTheme.headlineMedium),
      Text(
        'Turysta · ${cityLabel(controller.profile.cityId)} · status demonstracyjny',
      ),
      const SizedBox(height: 16),

      const SectionTitle('Potrzeby i wygląd'),
      ListTile(
        leading: const KindSpotSymbol(Icons.accessibility_new),
        title: const Text('Moje potrzeby'),
        subtitle: Text(
          controller.profile.publicNeeds ? 'Widoczne w podglądzie' : 'Prywatne',
        ),
        trailing: const KindSpotSymbol(Icons.chevron_right),
        onTap: () {
          onOpenSection?.call();
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => NeedsScreen(controller: controller),
            ),
          );
        },
      ),
      ListTile(
        leading: const KindSpotSymbol(Icons.palette_outlined),
        title: const Text('Wygląd i dostępność'),
        trailing: const KindSpotSymbol(Icons.chevron_right),
        onTap: () {
          onOpenSection?.call();
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => AccessibilityScreen(controller: controller),
            ),
          );
        },
      ),
      const SectionTitle('Personalizacja konta'),
      for (final category in const ['Awatar', 'Obramowanie', 'Tło profilu'])
        ListTile(
          title: Text(category),
          subtitle: const Text('W przygotowaniu'),
          trailing: const KindSpotSymbol(Icons.chevron_right),
          onTap: () {
            onOpenSection?.call();
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => CustomizationScreen(
                  category: category,
                  controller: controller,
                ),
              ),
            );
          },
        ),
      SwitchListTile(
        title: const Text('Pokaż potrzeby w publicznym profilu'),
        subtitle: const Text('Widoczność potrzeb w podglądzie profilu.'),
        value: controller.profile.publicNeeds,
        onChanged: controller.saving
            ? null
            : (value) async {
                if (value) {
                  final agree = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      scrollable: true,
                      title: const Text('Udostępnić potrzeby?'),
                      content: const Text(
                        'W docelowej aplikacji inni zobaczą wybrane potrzeby. Obecnie zmieniasz wyłącznie lokalny podgląd demonstracyjny.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Anuluj'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Potwierdzam'),
                        ),
                      ],
                    ),
                  );
                  if (agree != true) return;
                }
                if (context.mounted) {
                  await _save(
                    () => controller.saveProfile(
                      controller.profile.copyWith(publicNeeds: value),
                    ),
                    success: value
                        ? 'Potrzeby są widoczne w lokalnym podglądzie demo.'
                        : 'Potrzeby są ponownie prywatne.',
                    preview: value,
                  );
                }
              },
      ),
      OutlinedButton(
        onPressed: _preview,
        child: const Text('Podgląd publicznego profilu'),
      ),
      if (error != null) ...[
        Semantics(
          liveRegion: true,
          child: Notice(error!, icon: Icons.error_outline),
        ),
        TextButton(
          key: const ValueKey('profile-retry'),
          onPressed: controller.saving ? null : retry,
          child: const Text('Ponów zapis zmiany'),
        ),
      ],
      if (successMessage != null)
        Semantics(liveRegion: true, child: Notice(successMessage!)),
      const SectionTitle('Karta miejska'),
      ListTile(
        title: const Text('Stan karty miejskiej'),
        trailing: const KindSpotSymbol(Icons.chevron_right),
        onTap: () {
          onOpenSection?.call();
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) =>
                  CardConnectionScreen(cityId: controller.profile.cityId),
            ),
          );
        },
      ),
      ListTile(
        title: const Text('Saldo i historia punktów'),
        trailing: const KindSpotSymbol(Icons.chevron_right),
        onTap: () {
          onOpenSection?.call();
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => PointsHistoryScreen(controller: controller),
            ),
          );
        },
      ),
      const SizedBox(height: 16),
      ListTile(
        key: const ValueKey('account-settings'),
        leading: const KindSpotSymbol(Icons.manage_accounts_outlined),
        title: const Text('Ustawienia konta'),
        subtitle: const Text('Sesja i lokalne dane'),
        trailing: const KindSpotSymbol(Icons.chevron_right),
        onTap: () {
          onOpenSection?.call();
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => AccountSettingsScreen(controller: controller),
            ),
          );
        },
      ),
    ]),
  );
  void _preview() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Publiczny profil — podgląd'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lokalny przykład. Nie jest publikowany w sieci.'),
            const Text(demoAccountName),
            if (controller.profile.publicNeeds &&
                controller.profile.needIds.isEmpty)
              const Text('Nie wskazano potrzeb.'),
            if (controller.profile.publicNeeds)
              ...needs
                  .where((n) => controller.profile.needIds.contains(n.id))
                  .map((n) => Text(n.label))
            else
              const Text('Potrzeby prywatne'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Zamknij'),
        ),
      ],
    ),
  );
}
