import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/product_api.dart';
import '../integration/api_controller.dart';
import 'api_app.dart';
import 'api_personalization.dart';
import 'components.dart';
import 'graphics.dart';
import 'filter_name_dialog.dart';

class ApiLogin extends StatefulWidget {
  const ApiLogin({super.key, required this.controller, this.onChangeServer});
  final VoidCallback? onChangeServer;
  final ApiController controller;
  @override
  State<ApiLogin> createState() => _ApiLoginState();
}

class _ApiLoginState extends State<ApiLogin> {
  final email = TextEditingController(),
      password = TextEditingController(),
      name = TextEditingController();
  bool register = false;
  String? error;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    name.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (widget.controller.saving) return;
    if (!email.text.contains('@') ||
        password.text.isEmpty ||
        (register && (password.text.length < 12 || name.text.trim().isEmpty))) {
      setState(
        () => error = register
            ? 'Podaj e-mail, nazwę i hasło mające co najmniej 12 znaków.'
            : 'Podaj e-mail i hasło.',
      );
      return;
    }
    setState(() => error = null);
    try {
      await widget.controller.authenticate(
        email.text.trim(),
        password.text,
        name: register ? name.text.trim() : null,
      );
    } catch (e) {
      if (mounted) setState(() => error = apiErrorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: adaptiveAppBar(context, 'KindSpot'),
    body: pageBody([
      SectionTitle(register ? 'Utwórz konto' : 'Zaloguj się'),
      if (widget.onChangeServer != null)
        OutlinedButton(
          onPressed: widget.onChangeServer,
          child: const Text('Zmień adres API'),
        ),
      if (widget.controller.notice != null) Notice(widget.controller.notice!),
      if (error != null) Semantics(liveRegion: true, child: Notice(error!)),
      AutofillGroup(
        child: Column(
          children: [
            TextField(
              key: const ValueKey('api-email'),
              controller: email,
              enabled: !widget.controller.saving,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [
                AutofillHints.username,
                AutofillHints.email,
              ],
              decoration: const InputDecoration(
                labelText: 'E-mail',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(12),
                  child: KindSpotGraphic('email', width: 24, height: 24),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (register) ...[
              TextField(
                controller: name,
                enabled: !widget.controller.saving,
                decoration: const InputDecoration(
                  labelText: 'Nazwa konta',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(12),
                    child: KindSpotGraphic('account', width: 24, height: 24),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              key: const ValueKey('api-password'),
              controller: password,
              enabled: !widget.controller.saving,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              autofillHints: [
                register ? AutofillHints.newPassword : AutofillHints.password,
              ],
              decoration: const InputDecoration(
                labelText: 'Hasło',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(12),
                  child: KindSpotGraphic('password', width: 24, height: 24),
                ),
              ),
              onSubmitted: (_) => submit(),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      FilledButton(
        key: const ValueKey('api-login'),
        onPressed: widget.controller.saving ? null : submit,
        child: Text(
          widget.controller.saving
              ? 'Łączenie…'
              : register
              ? 'Utwórz konto'
              : 'Zaloguj',
        ),
      ),
      OutlinedButton(
        onPressed: widget.controller.saving
            ? null
            : () => setState(() {
                register = !register;
                error = null;
              }),
        child: Text(register ? 'Mam konto — zaloguj' : 'Utwórz nowe konto'),
      ),
      OutlinedButton(
        onPressed: () =>
            apiOpen(context, ApiAccessibility(controller: widget.controller)),
        child: const Text('Ustawienia dostępności'),
      ),
    ]),
  );
}

class ApiPreferences extends StatefulWidget {
  const ApiPreferences({super.key, required this.controller});
  final ApiController controller;
  @override
  State<ApiPreferences> createState() => _ApiPreferencesState();
}

class _ApiPreferencesState extends State<ApiPreferences> {
  late Json preferences;
  late List<Json> rules;
  bool unknown = false, busy = false;
  String? error, message;
  @override
  void initState() {
    super.initState();
    final c = widget.controller;
    preferences = jsonDecode(
      jsonEncode(
        c.account['preferences'] ??
            {'needIds': [], 'presetIds': [], 'rules': []},
      ),
    ) as Json;
    rules =
        (c.temporarySearch?['rules'] as List? ??
                preferences['rules'] as List? ??
                [])
            .cast<Json>()
            .map((r) => {...r})
            .toList();
    unknown = c.temporarySearch?['includeUnknownRequired'] == true;
  }

  Json rule(String id) => rules.firstWhere(
    (r) => r['featureId'] == id,
    orElse: () => {'featureId': id, 'importance': 'ignored', 'minRating': null},
  );
  void change(Json r) => setState(() {
    rules.removeWhere((v) => v['featureId'] == r['featureId']);
    rules.add(r);
  });
  List<String> get needs =>
      List<String>.from(preferences['needIds'] as List? ?? []);
  Future<void> save({bool named = false}) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
      message = null;
    });
    try {
      final list = (preferences['namedFilters'] as List? ?? []).cast<Json>();
      String? name;
      if (named) {
        name = await showDialog<String>(
          context: context,
          builder: (_) => FilterNameDialog(
            existingNames: list.map((f) => f['name'] as String).toList(),
          ),
        );
        if (name == null) return;
      }
      final next = {
        ...preferences,
        if (name != null)
          'namedFilters': [
            ...list,
            {'name': name, 'rules': rules, 'includeUnknownRequired': unknown},
          ],
      };
      // Saving a named filter never applies the draft automatically.
      if (!named) next['rules'] = rules;
      next.remove('effectiveRules');
      await widget.controller.api.call('PUT', 'me/preferences', body: next);
      preferences = jsonDecode(jsonEncode(next)) as Json;
      await widget.controller.refreshMe();
      if (mounted) {
        setState(
          () => message = named
              ? 'Filtr zapisany. Wybierz Użyj filtru, aby go zastosować.'
              : 'Potrzeby zapisane.',
        );
      }
    } catch (e) {
      if (mounted) setState(() => error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Scaffold(
      appBar: adaptiveAppBar(context, 'Filtry i potrzeby'),
      body: pageBody([
        OutlinedButton(
          onPressed: () => apiOpen(
            context,
            Scaffold(
              appBar: adaptiveAppBar(context, 'Jak działają filtry'),
              body: pageBody([
                const Text(
                  'Wymagam: warunek konieczny. Preferencja: cecha mile widziana.',
                ),
                const Text(
                  'Brak danych nie oznacza dostępności. Możesz dołączyć takie miejsca do wyników.',
                ),
                const Text(
                  'Zapisz filtr zachowuje go pod nazwą. Użyj filtru działa w bieżącej sesji.',
                ),
              ]),
            ),
          ),
          child: const Text('Jak działają filtry'),
        ),
        if (error != null) Notice(error!),
        if (message != null) Notice(message!),
        if (busy) const LinearProgressIndicator(semanticsLabel: 'Zapisywanie'),
        const SectionTitle('Twoje potrzeby'),
        const Text('Domyślnie prywatne. Możesz wskazać kilka potrzeb.'),
        for (final need in (c.configuration['needs'] as List).cast<Json>())
          CheckboxListTile(
            secondary: KindSpotNeedIcon(need['id'] as String),
            title: Text(need['label'] as String),
            value: needs.contains(need['id']),
            onChanged: busy
                ? null
                : (value) => setState(() {
                    final chosen = needs;
                    if (value == true) {
                      chosen.add(need['id'] as String);
                    } else {
                      chosen.remove(need['id']);
                    }
                    preferences['needIds'] = chosen;
                  }),
          ),
        OutlinedButton(
          onPressed: busy ? null : () => save(),
          child: const Text('Zapisz potrzeby i domyślne reguły'),
        ),
        const SectionTitle('Zapisane filtry'),
        for (final f
            in (preferences['namedFilters'] as List? ?? []).cast<Json>())
          ListTile(
            title: Text(f['name'] as String),
            subtitle: const Text('Wczytaj do formularza'),
            onTap: busy
                ? null
                : () => setState(() {
                    rules = (f['rules'] as List)
                        .cast<Json>()
                        .map((r) => {...r})
                        .toList();
                    unknown = f['includeUnknownRequired'] == true;
                  }),
          ),
        const SectionTitle('Reguły'),
        for (final preset in (c.configuration['presets'] as List).cast<Json>())
          OutlinedButton(
            onPressed: busy
                ? null
                : () => setState(
                    () => rules = (preset['rules'] as List)
                        .cast<Json>()
                        .map((r) => {...r})
                        .toList(),
                  ),
            child: Text(preset['label'] as String),
          ),
        for (final f in (c.configuration['features'] as List).cast<Json>())
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    key: ValueKey('${f['id']}-${rule(f['id'])['importance']}'),
                    isExpanded: true,
                    initialValue: rule(f['id'])['importance'] as String,
                    decoration: InputDecoration(
                      labelText: f['label'] as String,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: KindSpotFeatureIcon(f['id'] as String, size: 24),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'ignored',
                        child: Text('Bez znaczenia'),
                      ),
                      DropdownMenuItem(
                        value: 'preferred',
                        child: Text('Preferencja'),
                      ),
                      DropdownMenuItem(
                        value: 'required',
                        child: Text('Wymagam'),
                      ),
                    ],
                    onChanged: busy
                        ? null
                        : (v) => change({
                            'featureId': f['id'],
                            'importance': v,
                            'minRating':
                                v == 'required' && f['supportsRating'] == true
                                ? 3
                                : null,
                          }),
                  ),
                  if (rule(f['id'])['importance'] == 'required' &&
                      f['supportsRating'] == true)
                    DropdownButtonFormField<int>(
                      key: ValueKey('${f['id']}-${rule(f['id'])['minRating']}'),
                      initialValue: rule(f['id'])['minRating'] as int? ?? 3,
                      decoration: const InputDecoration(
                        labelText: 'Minimalna ocena',
                      ),
                      items: [
                        for (var n = 1; n <= 5; n++)
                          DropdownMenuItem(value: n, child: Text('$n')),
                      ],
                      onChanged: busy
                          ? null
                          : (n) => change({...rule(f['id']), 'minRating': n}),
                    ),
                ],
              ),
            ),
          ),
        SwitchListTile(
          title: const Text('Pokaż też miejsca z brakiem danych'),
          value: unknown,
          onChanged: busy ? null : (v) => setState(() => unknown = v),
        ),
        FilledButton(
          onPressed: busy ? null : () => save(named: true),
          child: const Text('Zapisz filtr'),
        ),
        OutlinedButton(
          onPressed: busy
              ? null
              : () {
                  c.applySearch({
                    'rules': rules,
                    'includeUnknownRequired': unknown,
                  });
                  setState(
                    () => message =
                        'Filtr użyty. Otwórz Mapę, aby zobaczyć wyniki.',
                  );
                },
          child: const Text('Użyj filtru'),
        ),
      ]),
    );
  }
}

class ApiReward extends StatefulWidget {
  const ApiReward({super.key, required this.controller, required this.id});
  final ApiController controller;
  final String id;
  @override
  State<ApiReward> createState() => _ApiRewardState();
}

class _ApiRewardState extends State<ApiReward> {
  String? method, requestKey, fingerprint;
  @override
  Widget build(BuildContext context) => RemotePage(
    title: 'Nagroda',
    load: () => widget.controller.api.call('GET', 'rewards/${widget.id}'),
    content: (context, state, reward) {
      final methods = List<String>.from(reward['deliveryMethods'] as List);
      method ??= methods.firstOrNull;
      final eligible =
          reward['availability'] == 'available' &&
          reward['eligibility']['eligible'] == true;
      return [
        if (reward['cosmetic'] != null)
          Center(child: cosmeticPreview(reward['cosmetic'] as Json, size: 104)),
        SectionTitle(reward['name'] as String),
        Text(reward['description'] as String),
        Text('Koszt: ${reward['costPoints']} pkt'),
        if (!eligible)
          Notice(switch (reward['eligibility']['reasonCode']) {
            'ALREADY_OWNED' => 'Ten element jest już na Twoim koncie.',
            'PURCHASE_PENDING' => 'Ten zakup jest już przetwarzany.',
            _ => 'Nagroda jest niedostępna lub wymaga potwierdzonej karty.',
          }),
        if (reward['owned'] == true)
          OutlinedButton(
            onPressed: () => apiOpen(
              context,
              ApiCosmeticPicker(controller: widget.controller),
            ),
            child: const Text('Wybierz w profilu'),
          ),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: method,
          decoration: const InputDecoration(labelText: 'Sposób odbioru'),
          items: [
            for (final m in methods)
              DropdownMenuItem(
                value: m,
                child: Text(switch (m) {
                  'account_item' => 'Na koncie',
                  'pickup_code' => 'Kod odbioru',
                  _ => 'Karta miejska',
                }),
              ),
          ],
          onChanged: state.busy ? null : (v) => setState(() => method = v),
        ),
        FilledButton(
          onPressed: !eligible || state.busy || method == null
              ? null
              : () => state.act(() async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      scrollable: true,
                      title: Text('Kup za ${reward['costPoints']} pkt?'),
                      content: Text(reward['name'] as String),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Anuluj'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Kupuję'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true) throw const CancelledApiAction();
                  final body = <String, dynamic>{
                    'rewardId': widget.id,
                    'expectedCostPoints': reward['costPoints'],
                    'deliveryMethod': method,
                  };
                  final encoded = jsonEncode(body);
                  if (encoded != fingerprint) {
                    fingerprint = encoded;
                    requestKey = operationKey();
                  }
                  final result = await widget.controller.api.redeem(
                    body,
                    requestKey!,
                  );
                  // Purchase is already confirmed. A refresh failure must not suggest buying again.
                  try {
                    await widget.controller.refreshMe();
                  } catch (_) {}
                  if (!context.mounted || !widget.controller.isDemoSignedIn) {
                    return;
                  }
                  apiOpen(
                    context,
                    apiRedemption(widget.controller, result['id'] as String),
                  );
                }, success: 'Sprawdź zakup w Moich nagrodach.'),
          child: const Text('Kup nagrodę'),
        ),
      ];
    },
  );
}

class ApiReport extends StatefulWidget {
  const ApiReport({
    super.key,
    required this.controller,
    required this.reviewId,
  });
  final ApiController controller;
  final String reviewId;
  @override
  State<ApiReport> createState() => _ApiReportState();
}

class _ApiReportState extends State<ApiReport> {
  String reason = 'suspected_false';
  final description = TextEditingController();
  bool submitted = false;
  @override
  void dispose() {
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RemotePage(
    title: 'Zgłoś recenzję',
    load: () async => {'ready': true},
    content: (context, state, data) => [
      DropdownButtonFormField<String>(
        initialValue: reason,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Powód'),
        items: const [
          DropdownMenuItem(
            value: 'suspected_false',
            child: Text('Może być fałszywa'),
          ),
          DropdownMenuItem(value: 'offensive', child: Text('Obraźliwa')),
          DropdownMenuItem(value: 'spam', child: Text('Spam')),
          DropdownMenuItem(value: 'other', child: Text('Inny powód')),
        ],
        onChanged: state.busy || submitted
            ? null
            : (v) => setState(() => reason = v!),
      ),
      TextField(
        controller: description,
        enabled: !state.busy && !submitted,
        maxLength: 1000,
        decoration: const InputDecoration(labelText: 'Opis — opcjonalnie'),
      ),
      FilledButton(
        onPressed: state.busy || submitted
            ? null
            : () => state.act(() async {
                await widget.controller.api.call(
                  'POST',
                  'reviews/${widget.reviewId}/reports',
                  body: {
                    'reasonCode': reason,
                    'description': description.text.trim().isEmpty
                        ? null
                        : description.text.trim(),
                  },
                );
                if (mounted) setState(() => submitted = true);
              }, success: 'Zgłoszenie odebrane przez serwer.'),
        child: const Text('Wyślij zgłoszenie'),
      ),
    ],
  );
}

class ApiCard extends StatefulWidget {
  const ApiCard({super.key, required this.controller});
  final ApiController controller;
  @override
  State<ApiCard> createState() => _ApiCardState();
}

class _ApiCardState extends State<ApiCard> {
  String? type, verification;
  @override
  Widget build(BuildContext context) => RemotePage(
    title: 'Karta miejska',
    load: () async => {'ready': true},
    content: (context, state, data) => [
      const Notice(
        'Weryfikacja demonstracyjna. Backend nie łączy się z operatorem karty.',
      ),
      DropdownButtonFormField<String>(
        initialValue: type,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Rodzaj karty'),
        items: [
          for (final card
              in (widget.controller.configuration['cardTypes'] as List)
                  .cast<Json>())
            DropdownMenuItem(
              value: card['id'] as String,
              child: Text(card['label'] as String),
            ),
        ],
        onChanged: state.busy ? null : (v) => setState(() => type = v),
      ),
      FilledButton(
        onPressed: state.busy || type == null
            ? null
            : () => state.act(() async {
                final card =
                    (widget.controller.configuration['cardTypes'] as List)
                        .cast<Json>()
                        .firstWhere((c) => c['id'] == type);
                final result = await widget.controller.api.call(
                  'POST',
                  'me/card-verifications',
                  body: {'cityId': card['cityId'], 'cardTypeId': type},
                );
                verification = result['id'] as String;
                if (state.mounted) state.replaceData(result);
              }, success: 'Przyjęto prośbę o sprawdzenie.'),
        child: const Text('Połącz kartę testową'),
      ),
      if (data['status'] != null) Text(apiStatus(data['status'])),
      if (verification != null)
        OutlinedButton(
          onPressed: state.busy
              ? null
              : () => state.act(() async {
                  final result = await widget.controller.api.call(
                    'GET',
                    'me/card-verifications/$verification',
                  );
                  if (state.mounted) state.replaceData(result);
                }, success: 'Status odświeżony.'),
          child: const Text('Sprawdź status'),
        ),
    ],
  );
}

class ApiAccessibility extends StatefulWidget {
  const ApiAccessibility({super.key, required this.controller});
  final ApiController controller;
  @override
  State<ApiAccessibility> createState() => _ApiAccessibilityState();
}

class _ApiAccessibilityState extends State<ApiAccessibility> {
  late Json settings;
  @override
  void initState() {
    super.initState();
    settings = {
      ...widget.controller.account['uiSettings'] as Json? ?? {},
      'colorThemeId':
          ![
            'green',
            'orange',
            'pink',
            'blue',
            'explorer',
            'gardener',
          ].contains(widget.controller.profile.theme)
          ? 'green'
          : widget.controller.profile.theme,
      'darkMode': widget.controller.profile.darkMode,
      'highContrast': widget.controller.profile.highContrast,
      'reduceMotion': widget.controller.profile.reduceMotion,
    };
  }

  @override
  Widget build(BuildContext context) => RemotePage(
    title: 'Ustawienia dostępności',
    load: () async => {'ready': true},
    content: (context, state, data) => [
      DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: settings['colorThemeId'] as String,
        decoration: const InputDecoration(labelText: 'Kolor'),
        items: [
          if (settings['colorThemeId'] == 'explorer')
            const DropdownMenuItem(value: 'explorer', child: Text('Odkrywca')),
          if (settings['colorThemeId'] == 'gardener')
            const DropdownMenuItem(value: 'gardener', child: Text('Ogrodnik')),
          const DropdownMenuItem(
            value: 'green',
            child: Text('Pastelowy zielony'),
          ),
          const DropdownMenuItem(
            value: 'orange',
            child: Text('Pastelowy pomarańczowy'),
          ),
          const DropdownMenuItem(
            value: 'pink',
            child: Text('Pastelowy różowy'),
          ),
          const DropdownMenuItem(value: 'blue', child: Text('Jasnoniebieski')),
        ],
        onChanged: state.busy
            ? null
            : (v) => setState(() => settings['colorThemeId'] = v),
      ),
      for (final field in [
        ('darkMode', 'Czarny motyw'),
        ('highContrast', 'Wysoki kontrast'),
        ('reduceMotion', 'Ogranicz animacje'),
      ])
        SwitchListTile(
          title: Text(field.$2),
          value: settings[field.$1] == true,
          onChanged: state.busy
              ? null
              : (v) => setState(() => settings[field.$1] = v),
        ),
      DropdownButtonFormField<double>(
        initialValue: (settings['textScale'] as num?)?.toDouble() ?? 1,
        decoration: const InputDecoration(
          labelText: 'Dodatkowe powiększenie tekstu',
        ),
        items: [
          for (final v in [1.0, 1.25, 1.5, 2.0])
            DropdownMenuItem(value: v, child: Text('${(v * 100).round()}%')),
        ],
        onChanged: state.busy
            ? null
            : (v) => setState(() => settings['textScale'] = v),
      ),
      FilledButton(
        onPressed: state.busy
            ? null
            : () => state.act(() async {
                if (widget.controller.isDemoSignedIn) {
                  await widget.controller.api.call(
                    'PUT',
                    'me/ui-settings',
                    body: settings,
                  );
                  await widget.controller.refreshMe();
                } else {
                  // Available before authentication. No declaration of disability needed.
                  await widget.controller.setLocalAccessibility(settings);
                }
              }, success: 'Ustawienia zastosowane.'),
        child: const Text('Zastosuj'),
      ),
    ],
  );
}
