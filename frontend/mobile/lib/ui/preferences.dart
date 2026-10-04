import 'package:flutter/material.dart';

import 'graphics.dart';

import '../app_controller.dart';
import '../data/catalog.dart';
import '../domain/models.dart';
import 'components.dart';
import 'filter_help.dart';
import 'filter_name_dialog.dart';

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
  bool busy = false;
  String? saveError;
  final saveFocus = FocusNode();
  @override
  void dispose() {
    saveFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    selected = widget.controller.profile.needIds.toSet();
  }

  Future<void> save() async {
    if (busy) return;
    setState(() {
      busy = true;
      saveError = null;
    });
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
          rules: rules,
          onboarded: true,
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(
          () => saveError = 'Nie udało się zapisać potrzeb. Twoje wybory pozostają w formularzu. Spróbuj ponownie.',
        );
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
                  secondary: KindSpotNeedIcon(need.id),
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
      const SizedBox(height: 24),
      if (saveError != null) _SaveError(saveError!),
      FilledButton(
        key: const ValueKey('needs-save'),
        focusNode: saveFocus,
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
  String? saveError;
  final saveFocus = FocusNode();
  @override
  void dispose() {
    saveFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    rules = {
      for (final rule in widget.controller.activeRules) rule.featureId: rule,
    };
    includeUnknown = widget.controller.activeIncludeUnknown;
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
  String? status;
  String? pendingName;
  bool nameDialogOpen = false;
  Future<void> save() async {
    if (busy) return;
    if (nameDialogOpen) return;
    nameDialogOpen = true;
    final name = await showDialog<String>(
      context: context,
      builder: (_) => FilterNameDialog(
        initialName: pendingName,
        existingNames: widget.controller.profile.namedFilters
            .map((f) => f.name)
            .toList(),
      ),
    );
    nameDialogOpen = false;
    if (name == null || !mounted) return;
    pendingName = name;
    setState(() {
      busy = true;
      saveError = null;
      status = null;
    });
    try {
      await widget.controller.saveNamedFilter(
        name,
        rules.values.toList(),
        includeUnknown,
      );
      if (mounted) {
        setState(() {
          status =
              'Zapisano filtr „$name”. Wybierz Użyj filtru, aby pokazać wyniki.';
          pendingName = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => saveError = 'Nie udało się zapisać filtrów. Twoje wybory pozostają w formularzu. Spróbuj ponownie.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void use() {
    if (busy || nameDialogOpen) return;
    try {
      widget.controller.useFilter(rules.values.toList(), includeUnknown);
      Navigator.pop(context);
    } catch (_) {
      setState(
        () => saveError = 'Nie udało się użyć filtru. Twoje wybory pozostają w formularzu. Spróbuj ponownie.',
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: adaptiveAppBar(context, 'Filtry miejsc'),
    body: pageBody([
      OutlinedButton.icon(
        key: const ValueKey('filter-help'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const FilterHelpScreen()),
        ),
        icon: const KindSpotSymbol(Icons.menu_book_outlined),
        label: const Text('Jak działają filtry'),
      ),
      if (widget.controller.profile.namedFilters.isNotEmpty) ...[
        const SectionTitle('Zapisane filtry'),
        for (final filter in widget.controller.profile.namedFilters)
          ListTile(
            title: Text(filter.name),
            subtitle: const Text('Wczytaj do formularza'),
            trailing: const KindSpotSymbol(Icons.chevron_right),
            onTap: busy
                ? null
                : () => setState(() {
                    rules = {
                      for (final rule in filter.rules) rule.featureId: rule,
                    };
                    includeUnknown = filter.includeUnknown;
                    status =
                        'Wczytano filtr „${filter.name}”. Wybierz Użyj filtru.';
                  }),
          ),
      ],
      const SizedBox(height: 12),
      OutlinedButton(
        key: const ValueKey('filters-clear'),
        onPressed: busy
            ? null
            : () => setState(() {
                rules.clear();
                includeUnknown = false;
              }),
        child: const Text('Wyczyść wybory w formularzu'),
      ),
      const SectionTitle(
        'Szybki wybór',
        subtitle: 'Przykładowy preset zastępuje wybory w formularzu. Możesz je zmienić przed zapisaniem.',
      ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: busy ? null : () => preset('wheelchair'),
            icon: const KindSpotSymbol(Icons.accessible),
            label: const Text('Na wózku'),
          ),
          OutlinedButton.icon(
            onPressed: busy ? null : () => preset('calm'),
            icon: const KindSpotSymbol(Icons.spa_outlined),
            label: const Text('Spokojnie'),
          ),
          OutlinedButton.icon(
            onPressed: busy ? null : () => preset('family'),
            icon: const KindSpotSymbol(Icons.family_restroom),
            label: const Text('Z dzieckiem'),
          ),
        ],
      ),
      const SectionTitle(
        'Dopasuj szczegóły',
        subtitle: 'Wymagam: warunek konieczny. Preferencja: bez progu oceny. Bez znaczenia: pomijamy cechę. Dopasowanie jest demonstracyjne.',
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
                  Row(
                    children: [
                      KindSpotFeatureIcon(feature.id, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature.label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Semantics(
                    label: 'Znaczenie cechy: ${feature.label}',
                    child: DropdownButtonFormField<Importance>(
                      initialValue:
                          rules[feature.id]?.importance ?? Importance.ignored,
                      key: ValueKey(
                        '${feature.id}-${rules[feature.id]?.importance.name}',
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Znaczenie cechy',
                      ),
                      isExpanded: true,
                      itemHeight: null,
                      selectedItemBuilder: (context) => [
                        for (final label in [
                          'Bez znaczenia',
                          'Preferencja',
                          'Wymagam',
                        ])
                          Text(
                            label,
                            semanticsLabel:
                                '$label. Znaczenie cechy: ${feature.label}',
                          ),
                      ],
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
                          child: Text('Warunek konieczny', softWrap: true),
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
                  ),
                  if (rules[feature.id]?.importance == Importance.required &&
                      feature.ratable) ...[
                    const SizedBox(height: 12),
                    Semantics(
                      label: 'Minimalna ocena: ${feature.label}',
                      child: DropdownButtonFormField<int>(
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
                            DropdownMenuItem(
                              value: i,
                              child: Text(
                                '$i / 5',
                                semanticsLabel:
                                    '$i z 5. Minimalna ocena: ${feature.label}',
                              ),
                            ),
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
      if (saveError != null) _SaveError(saveError!),
      FilledButton(
        key: const ValueKey('filters-save'),
        focusNode: saveFocus,
        onPressed: busy ? null : save,
        child: Text(busy ? 'Zapisywanie…' : 'Zapisz filtr'),
      ),
      const SizedBox(height: 12),
      FilledButton(
        key: const ValueKey('filters-use'),
        onPressed: busy ? null : use,
        child: const Text('Użyj filtru'),
      ),
      if (status != null) Semantics(liveRegion: true, child: Notice(status!)),
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
                'green': 'Pastelowy zielony',
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

class _SaveError extends StatelessWidget {
  const _SaveError(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Semantics(
      liveRegion: true,
      child: Notice(message, icon: Icons.error_outline),
    ),
  );
}
