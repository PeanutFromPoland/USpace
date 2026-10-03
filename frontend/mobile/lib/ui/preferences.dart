import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../data/catalog.dart';
import '../domain/models.dart';
import 'components.dart';

class NeedsScreen extends StatefulWidget {
  const NeedsScreen({
    super.key,
    required this.controller,
    this.onboarding = false,
  });
  final AppController controller;
  final bool onboarding;
  @override
  State<NeedsScreen> createState() => _NeedsScreenState();
}

class _NeedsScreenState extends State<NeedsScreen> {
  late Set<String> selected;
  late bool helper;
  bool busy = false;
  @override
  void initState() {
    super.initState();
    selected = widget.controller.profile.needIds.toSet();
    helper = widget.controller.profile.helper;
  }

  Future<void> save() async {
    setState(() => busy = true);
    try {
      final ids = selected.toList();
      // Needs suggest preferences only; explicit detailed rules always win.
      final existing = widget.controller.profile.rules;
      final rules = [
        ...existing,
        ...suggestedRules(ids)
            .where((r) => !existing.any((e) => e.featureId == r.featureId)),
      ];
      await widget.controller.saveProfile(
        widget.controller.profile.copyWith(
          needIds: ids,
          helper: helper,
          rules: rules,
          onboarded: true,
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        toast(context, 'Nie udało się zapisać potrzeb. Spróbuj ponownie.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: adaptiveAppBar(context, 'Twoje potrzeby'),
    body: pageBody([
      Text(
        'Co jest dla Ciebie ważne?',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 12),
      const Text(
        'Możesz wybrać kilka potrzeb. Ustawienia wyglądu aplikacji pozostają niezależne.',
      ),
      const SizedBox(height: 16),
      const Notice(
        'Prywatne na Twoim profilu demonstracyjnym. Te dane nie są wysyłane na serwer.',
        icon: Icons.lock_outline,
      ),
      for (final category in needs.map((e) => e.category).toSet()) ...[
        SectionTitle(category),
        Card(
          child: Column(
            children: [
              for (final need in needs.where((e) => e.category == category))
                CheckboxListTile(
                  value: selected.contains(need.id),
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(need.label),
                  onChanged: busy
                      ? null
                      : (value) => setState(() {
                          value == true
                              ? selected.add(need.id)
                              : selected.remove(need.id);
                        }),
                ),
            ],
          ),
        ),
      ],
      const SectionTitle('Pomagaj po swojemu'),
      Card(
        child: SwitchListTile(
          title: const Text('Chcę być Pomocnikiem'),
          subtitle: const Text('Niezależnie od wybranych potrzeb.'),
          value: helper,
          onChanged: busy ? null : (v) => setState(() => helper = v),
        ),
      ),
      const SizedBox(height: 24),
      FilledButton(
        onPressed: busy ? null : save,
        child: Text(
          busy
              ? 'Zapisywanie…'
              : widget.onboarding
              ? 'Odkrywaj miejsca'
              : 'Zapisz potrzeby',
        ),
      ),
    ]),
  );
}

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key, required this.controller});
  final AppController controller;
  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  late Map<String, FilterRule> rules;
  late bool includeUnknown;
  bool busy = false;
  @override
  void initState() {
    super.initState();
    rules = {
      for (final rule in widget.controller.profile.rules) rule.featureId: rule,
    };
    includeUnknown = widget.controller.profile.includeUnknown;
  }

  void preset(String preset) => setState(() {
    if (preset == 'wheelchair') {
      rules = {
        'step_free_entrance': const FilterRule(
          'step_free_entrance',
          Importance.required,
          4,
        ),
        'accessible_toilet': const FilterRule(
          'accessible_toilet',
          Importance.preferred,
        ),
      };
    }
    if (preset == 'calm') {
      rules = {
        'quiet': const FilterRule('quiet', Importance.required, 4),
        'gentle_light': const FilterRule('gentle_light', Importance.preferred),
        'low_crowd': const FilterRule('low_crowd', Importance.preferred),
      };
    }
    if (preset == 'family') {
      rules = {
        'step_free_entrance': const FilterRule(
          'step_free_entrance',
          Importance.required,
          3,
        ),
        'rest': const FilterRule('rest', Importance.preferred),
      };
    }
  });
  Future<void> save() async {
    setState(() => busy = true);
    try {
      await widget.controller.saveProfile(
        widget.controller.profile.copyWith(
          rules: rules.values.toList(),
          includeUnknown: includeUnknown,
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        toast(
          context,
          'Nie udało się zapisać filtrów. Twoje wybory pozostają w formularzu.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: adaptiveAppBar(
      context,
      'Filtry miejsc',
      actions: [
        TextButton(
          onPressed: busy ? null : () => setState(() => rules.clear()),
          child: const Text('Wyczyść'),
        ),
      ],
    ),
    body: pageBody([
      const SectionTitle(
        'Szybki wybór',
        subtitle: 'Preset zastępuje bieżące reguły. Możesz go zmienić poniżej.',
      ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: busy ? null : () => preset('wheelchair'),
            icon: const Icon(Icons.accessible),
            label: const Text('Na wózku'),
          ),
          OutlinedButton.icon(
            onPressed: busy ? null : () => preset('calm'),
            icon: const Icon(Icons.spa_outlined),
            label: const Text('Spokojnie'),
          ),
          OutlinedButton.icon(
            onPressed: busy ? null : () => preset('family'),
            icon: const Icon(Icons.family_restroom),
            label: const Text('Z dzieckiem'),
          ),
        ],
      ),
      const SectionTitle(
        'Dopasuj szczegóły',
        subtitle: 'Warunki konieczne muszą być spełnione. Preferencje pomagają porządkować miejsca.',
      ),
      for (final feature in features)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature.label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<Importance>(
                    initialValue:
                        rules[feature.id]?.importance ?? Importance.ignored,
                    key: ValueKey(
                      '${feature.id}-${rules[feature.id]?.importance.name}',
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Znaczenie cechy',
                    ),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: Importance.ignored,
                        child: Text('Bez znaczenia'),
                      ),
                      DropdownMenuItem(
                        value: Importance.preferred,
                        child: Text('Preferencja'),
                      ),
                      DropdownMenuItem(
                        value: Importance.required,
                        child: Text('Warunek konieczny'),
                      ),
                    ],
                    onChanged: busy
                        ? null
                        : (importance) => setState(
                            () => rules[feature.id] = FilterRule(
                              feature.id,
                              importance!,
                              importance == Importance.required &&
                                      feature.ratable
                                  ? 3
                                  : null,
                            ),
                          ),
                  ),
                  if (rules[feature.id]?.importance == Importance.required &&
                      feature.ratable) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      key: ValueKey(
                        '${feature.id}-${rules[feature.id]?.minRating}',
                      ),
                      initialValue: rules[feature.id]?.minRating ?? 3,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Minimalna ocena',
                      ),
                      items: [
                        for (var i = 1; i <= 5; i++)
                          DropdownMenuItem(value: i, child: Text('$i / 5')),
                      ],
                      onChanged: busy
                          ? null
                          : (v) => setState(
                              () => rules[feature.id] = FilterRule(
                                feature.id,
                                Importance.required,
                                v,
                              ),
                            ),
                    ),
                    Text(
                      feature.ratingLabels[(rules[feature.id]?.minRating ?? 3) -
                          1],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      Card(
        child: SwitchListTile(
          title: const Text('Uwzględnij miejsca z brakami danych'),
          subtitle: const Text(
            'Będą oznaczone „Za mało informacji”. Znane niespełnienie warunku nadal wyklucza miejsce.',
          ),
          value: includeUnknown,
          onChanged: busy ? null : (v) => setState(() => includeUnknown = v),
        ),
      ),
      const SizedBox(height: 24),
      FilledButton(
        onPressed: busy ? null : save,
        child: Text(busy ? 'Zapisywanie…' : 'Zapisz i pokaż miejsca'),
      ),
    ]),
  );
}

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key, required this.controller});
  final AppController controller;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) => Scaffold(
      appBar: adaptiveAppBar(context, 'Dostępność interfejsu'),
      body: pageBody([
        const Notice(
          'Wygląd aplikacji możesz zmieniać bez deklarowania potrzeb. Rozmiar tekstu dostosowuje się do ustawień telefonu.',
          icon: Icons.accessibility_new,
        ),
        const SectionTitle('Kolor akcentu'),
        RadioGroup<String>(
          groupValue: controller.profile.theme,
          onChanged: (v) {
            if (!controller.saving) {
              perform(
                context,
                () => controller.saveProfile(
                  controller.profile.copyWith(theme: v),
                ),
              );
            }
          },
          child: Column(
            children: [
              for (final entry in {
                'orange': 'Pastelowy pomarańczowy',
                'pink': 'Pastelowy różowy',
                'blue': 'Jasnoniebieski',
              }.entries)
                RadioListTile<String>(
                  value: entry.key,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  title: Text(
                    entry.value,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Czarny motyw'),
                subtitle: const Text(
                  'Każdy akcent z białym albo czarnym motywem.',
                ),
                value: controller.profile.darkMode,
                onChanged: controller.saving
                    ? null
                    : (v) => perform(
                        context,
                        () => controller.saveProfile(
                          controller.profile.copyWith(darkMode: v),
                        ),
                      ),
              ),
              SwitchListTile(
                title: const Text('Wyższy kontrast'),
                value: controller.profile.highContrast,
                onChanged: controller.saving
                    ? null
                    : (v) => perform(
                        context,
                        () => controller.saveProfile(
                          controller.profile.copyWith(highContrast: v),
                        ),
                      ),
              ),
              SwitchListTile(
                title: const Text('Ogranicz animacje'),
                value: controller.profile.reduceMotion,
                onChanged: controller.saving
                    ? null
                    : (v) => perform(
                        context,
                        () => controller.saveProfile(
                          controller.profile.copyWith(reduceMotion: v),
                        ),
                      ),
              ),
            ],
          ),
        ),
        const SectionTitle('Prostsza obsługa'),
        const Text(
          'Lista miejsc pozwala korzystać bez mapy. Przyciski mają opisy, statusy są zapisane tekstem, a oceny możesz wybrać z listy.',
        ),
      ]),
    ),
  );
}
