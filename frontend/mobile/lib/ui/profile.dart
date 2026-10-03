import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../data/catalog.dart';

import 'components.dart';
import 'preferences.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key, required this.controller});
  final AppController controller;
  @override
  Widget build(BuildContext context) => pageBody([
    const SectionTitle('Nagrody', subtitle: 'Pomaganie ma znaczenie'),
    demoNotice(),
    const SizedBox(height: 20),
    const Notice(
      'Saldo niedostępne — API punktów nie jest podłączone. Recenzje i głosy demonstracyjne nie zmieniają salda.',
    ),
    const SectionTitle('Katalog — przykładowy wygląd'),
    for (final entry in [
      (
        'Motyw profilu „Odkrywca”',
        'Element wizualny na koncie',
        Icons.palette_outlined,
      ),
      (
        'Bilet do muzeum',
        'Benefit miejski; dostępność i koszt z API',
        Icons.confirmation_number_outlined,
      ),
    ])
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(entry.$3, size: 36),
                const SizedBox(height: 12),
                Text(entry.$1, style: Theme.of(context).textTheme.titleLarge),
                Text(entry.$2),
                const SizedBox(height: 12),
                const Text('Przykład · cena i uprawnienia nieustalone'),
                const SizedBox(height: 8),
                const FilledButton(
                  onPressed: null,
                  child: Text('Wymaga połączenia z API'),
                ),
              ],
            ),
          ),
        ),
      ),
    const SectionTitle('Moje nagrody'),
    const Text('Nie wydano żadnych nagród w trybie demonstracyjnym.'),
    const SectionTitle('Historia punktów'),
    const Text('Brak potwierdzonych operacji. Punkty i historia wymagają API.'),
    const SectionTitle('Jak będzie działał odbiór?'),
    const Notice(
      'Przebieg teoretyczny: po potwierdzeniu kosztu system rozpocznie realizację. Dopiero wynik API pozwoli pokazać kod lub benefit na karcie. Przy awarii pokażemy potwierdzony status zwolnienia albo zwrotu punktów.',
    ),
  ]);
}

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onOpenSection;
  const ProfileScreen({
    super.key,
    required this.controller,
    this.onOpenSection,
  });
  final AppController controller;
  @override
  Widget build(BuildContext context) => pageBody([
    const SectionTitle('Twój profil'),
    const CircleAvatar(radius: 36, child: Icon(Icons.person_outline, size: 40)),
    const SizedBox(height: 16),
    Text(demoAccountName, style: Theme.of(context).textTheme.headlineMedium),
    Text(
      'Turysta · ${cityLabel(controller.profile.cityId)} · status demonstracyjny',
    ),
    const SizedBox(height: 16),
    demoNotice(),
    const SectionTitle('Potrzeby i wygląd'),
    ListTile(
      leading: const Icon(Icons.accessibility_new),
      title: const Text('Moje potrzeby'),
      subtitle: Text(
        controller.profile.publicNeeds
            ? 'Widoczne w podglądzie demo'
            : 'Prywatne',
      ),
      trailing: const Icon(Icons.chevron_right),
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
      leading: const Icon(Icons.palette_outlined),
      title: const Text('Wygląd i dostępność'),
      trailing: const Icon(Icons.chevron_right),
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
    SwitchListTile(
      title: const Text('Pomocnik'),
      subtitle: const Text('Dobrowolnie, niezależnie od potrzeb i karty.'),
      value: controller.profile.helper,
      onChanged: controller.saving
          ? null
          : (value) => perform(
              context,
              () => controller.saveProfile(
                controller.profile.copyWith(helper: value),
              ),
            ),
    ),
    SwitchListTile(
      title: const Text('Pokaż potrzeby w publicznym profilu'),
      subtitle: const Text('Tryb demo: tylko podgląd na tym urządzeniu.'),
      value: controller.profile.publicNeeds,
      onChanged: controller.saving
          ? null
          : (value) async {
              if (value) {
                final agree = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
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
                await perform(
                  context,
                  () => controller.saveProfile(
                    controller.profile.copyWith(publicNeeds: value),
                  ),
                );
              }
            },
    ),
    OutlinedButton(
      onPressed: () => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Publiczny profil — podgląd'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(demoAccountName),
                if (controller.profile.helper) const Text('Pomocnik'),
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
      ),
      child: const Text('Podgląd publicznego profilu'),
    ),
    const SectionTitle('Karta miejska'),
    const Notice(
      'Nie podłączono operatora kart. Połączenie i potwierdzenie uprawnień wymagają API; nie pobieramy numeru karty w demonstracji.',
    ),
    const SizedBox(height: 16),
    if (!controller.autoDemoLogin)
      OutlinedButton(
        onPressed: controller.saving
            ? null
            : () => perform(
                context,
                () => controller.saveProfile(
                  controller.profile.copyWith(onboarded: false),
                ),
              ),
        child: const Text('Zamknij konto demonstracyjne'),
      ),
    if (controller.autoDemoLogin)
      const Notice(
        'Testowy start: konto Test Hackaton jest otwierane automatycznie. Logowanie do backendu nie jest podłączone.',
      ),
    TextButton(
      onPressed: controller.saving
          ? null
          : () async {
              final agree = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Usuń lokalne dane demo?'),
                  content: const Text(
                    'Usunięte zostaną potrzeby i filtry z tego urządzenia.',
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
              if (agree == true && context.mounted) {
                await perform(context, controller.reset);
              }
            },
      child: const Text('Usuń dane demonstracyjne'),
    ),
  ]);
}

class SavedPlacesScreen extends StatelessWidget {
  const SavedPlacesScreen({super.key});
  @override
  Widget build(BuildContext context) => pageBody([
    const SectionTitle('Zapisane miejsca'),
    const Notice(
      'Sekcja zatwierdzona. Sposób dodawania i usuwania miejsc czeka na ustalenie w UC-18. W tej wersji nie zapisujemy miejsc automatycznie.',
    ),
  ]);
}
