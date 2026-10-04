import 'dart:convert';

import 'package:flutter/material.dart';

import 'graphics.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../data/product_api.dart';
import '../integration/api_controller.dart';
import 'components.dart';
import '../data/city_locator.dart';
import 'navigation.dart';
import 'review_survey.dart';
import 'theme.dart';
import 'api_forms.dart';
import 'api_extra.dart';
import 'api_personalization.dart';

import 'package:flutter/services.dart';

class ConnectedKindSpotApp extends StatefulWidget {
  const ConnectedKindSpotApp({
    super.key,
    required this.controller,
    this.onChangeServer,
  });
  final ApiController controller;
  final VoidCallback? onChangeServer;
  @override
  State<ConnectedKindSpotApp> createState() => _ConnectedKindSpotAppState();
}

class _ConnectedKindSpotAppState extends State<ConnectedKindSpotApp> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final c = widget.controller;
      final ui = c.effectiveUi;
      return MaterialApp(
        key: ValueKey(c.sessionRevision),
        title: 'KindSpot',
        debugShowCheckedModeBanner: false,
        locale: const Locale('pl'),
        supportedLocales: const [Locale('pl')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: kindSpotTheme(c.profile),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.textScalerOf(context).scale(1) *
                  ((ui['textScale'] as num?)?.toDouble() ?? 1),
            ),
            highContrast:
                c.profile.highContrast || MediaQuery.of(context).highContrast,
            disableAnimations:
                c.profile.reduceMotion ||
                MediaQuery.of(context).disableAnimations,
          ),
          child: KindSpotBackdrop(themeId: c.profile.theme, child: child!),
        ),
        home: c.loading
            ? const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: 'Ładowanie aplikacji',
                  ),
                ),
              )
            : c.loadError != null
            ? Scaffold(
                body: pageBody([
                  const KindSpotGraphic(
                    'illustration_connection_problem',
                    height: 130,
                  ),
                  const SectionTitle('Nie można połączyć aplikacji'),
                  Notice(c.loadError!),
                  FilledButton(
                    onPressed: c.load,
                    child: const Text('Spróbuj ponownie'),
                  ),
                  if (widget.onChangeServer != null)
                    OutlinedButton(
                      onPressed: widget.onChangeServer,
                      child: const Text('Zmień adres API'),
                    ),
                ]),
              )
            : c.isDemoSignedIn
            ? ApiHome(controller: c)
            : ApiLogin(controller: c, onChangeServer: widget.onChangeServer),
      );
    },
  );
}

/// A route owns loading/error/empty/pagination states and never substitutes demo data.
class CancelledApiAction implements Exception {
  const CancelledApiAction();
}

class RemotePage extends StatefulWidget {
  const RemotePage({
    super.key,
    required this.title,
    required this.load,
    required this.content,
    this.next,
  });
  final String title;
  final Future<Json> Function() load;
  final Future<Json> Function(String cursor)? next;
  final List<Widget> Function(BuildContext, RemotePageState, Json) content;
  @override
  State<RemotePage> createState() => RemotePageState();
}

class RemotePageState extends State<RemotePage> {
  Json? data;
  String? error, message;
  bool busy = false;
  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final result = await widget.load();
      if (mounted) setState(() => data = result);
    } catch (e) {
      if (mounted) setState(() => error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> act(
    Future<void> Function() action, {
    String success = 'Zapisano.',
  }) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
      message = null;
    });
    try {
      await action();
      if (mounted) setState(() => message = success);
    } on CancelledApiAction {
      // No mutation or success message for a dismissed confirmation.
    } catch (e) {
      if (mounted) setState(() => error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void replaceData(Json value) {
    if (mounted) setState(() => data = value);
  }

  Future<void> more() => act(() async {
    final result = await widget.next!(data!['nextCursor'] as String);
    if (mounted) {
      setState(
        () => data = {
          ...data!,
          'items': [...items(data!), ...items(result)],
          'nextCursor': result['nextCursor'],
        },
      );
    }
  }, success: 'Wczytano kolejne pozycje.');
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: adaptiveAppBar(
      context,
      widget.title,
      actions: [
        IconButton(
          tooltip: 'Odśwież dane',
          onPressed: busy ? null : reload,
          icon: const KindSpotSymbol(Icons.refresh),
        ),
      ],
    ),
    body: pageBody([
      if (error != null) ...[
        if (data == null)
          const KindSpotGraphic('illustration_connection_problem', height: 130),
        Notice(error!, icon: Icons.error_outline),
        FilledButton(
          onPressed: busy ? null : reload,
          child: const Text('Odśwież dane'),
        ),
      ],
      if (message != null) Semantics(liveRegion: true, child: Notice(message!)),
      if (busy)
        const LinearProgressIndicator(semanticsLabel: 'Trwa połączenie'),
      if (data != null) ...widget.content(context, this, data!),
      if (data?['nextCursor'] != null && widget.next != null)
        OutlinedButton(
          onPressed: busy ? null : more,
          child: const Text('Wczytaj więcej'),
        ),
    ]),
  );
}

String apiErrorMessage(Object e) => e is ProductApiError
    ? e.message
    : 'Nie udało się wykonać czynności. Spróbuj ponownie.';
void apiOpen(BuildContext context, Widget page) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
String apiStatus(dynamic value) => switch (value) {
  'visible' => 'Widoczna',
  'held' => 'Wstrzymana',
  'pending' => 'Oczekuje na sprawdzenie',
  'accepted' => 'Zaakceptowana',
  'rejected' => 'Odrzucona',
  'processing' => 'W przygotowaniu',
  'ready' => 'Gotowa do odebrania',
  'fulfilled' => 'Zrealizowana',
  'failed' => 'Nie udało się zrealizować',
  'expired' => 'Wygasła',
  'granted' => 'Przyznane',
  'not_granted' => 'Nie przyznano',
  'reserved' => 'Zarezerwowane',
  'charged' => 'Pobrane',
  'released' => 'Zwrócone',
  'refunded' => 'Zwrócone',
  'verified' => 'Potwierdzona',
  'present' => 'Występuje',
  'absent' => 'Brak funkcji',
  'unknown' => 'Brak danych',
  'disputed' => 'Sprzeczne informacje',
  'working' => 'Działa',
  'not_working' => 'Nie działa',
  'limited' => 'Działa częściowo',
  'matches' => 'Spełnia wymagania',
  'insufficient_data' => 'Za mało danych do dopasowania',
  'not_evaluated' => 'Bez oceny dopasowania',
  'does_not_match' => 'Nie spełnia wymagań',
  _ => 'Brak potwierdzonego statusu',
};
String apiFeatureLabel(ApiController c, String id) {
  for (final f in (c.configuration['features'] as List).cast<Json>()) {
    if (f['id'] == id) return f['label'] as String;
  }
  return 'Cecha bez opisu';
}

class ApiHome extends StatefulWidget {
  const ApiHome({super.key, required this.controller});
  final ApiController controller;
  @override
  State<ApiHome> createState() => _ApiHomeState();
}

class _ApiHomeState extends State<ApiHome> {
  int selected = 2;
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) async {
      if (didPop) return;
      if (selected != 2) {
        setState(() => selected = 2);
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          scrollable: true,
          title: const Text('Wyjść z KindSpot?'),
          content: const Text(
            'Możesz zamknąć aplikację. Dane konta pozostaną na serwerze.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Zostań'),
            ),
            FilledButton(
              onPressed: () => SystemNavigator.pop(),
              child: const Text('Wyjdź'),
            ),
          ],
        ),
      );
    },
    child: Scaffold(
      body: KeyedSubtree(
        key: ValueKey(selected),
        child: switch (selected) {
          0 => apiSaved(widget.controller),
          1 => apiRewards(widget.controller),
          3 => ApiPreferences(controller: widget.controller),
          4 => apiProfile(widget.controller),
          _ => ApiBrowse(controller: widget.controller),
        },
      ),
      bottomNavigationBar: KindSpotNavigation(
        selected: selected,
        onSelect: (value) => setState(() => selected = value),
      ),
    ),
  );
}

class ApiBrowse extends StatefulWidget {
  const ApiBrowse({super.key, required this.controller});
  final ApiController controller;
  @override
  State<ApiBrowse> createState() => _ApiBrowseState();
}

class _ApiBrowseState extends State<ApiBrowse> {
  final query = TextEditingController();
  String submitted = '';
  bool map = false, locating = false;
  String? locationMessage;
  Future<void> locate() async {
    if (locating) return;
    setState(() {
      locating = true;
      locationMessage = null;
    });
    try {
      final legacy = await widget.controller.cityLocator.locateCity();
      final canonical = 'city_$legacy';
      final supported = (widget.controller.configuration['cities'] as List)
          .cast<Json>()
          .any((city) => city['id'] == canonical);
      if (mounted) {
        setState(() {
          if (supported) widget.controller.selectedCity = canonical;
          locationMessage = supported
              ? 'Miasto ustawione. Współrzędnych nie zapisujemy.'
              : 'Miasto nie jest obsługiwane. Wybierz je ręcznie.';
        });
      }
    } on CityLocationException catch (e) {
      if (mounted) setState(() => locationMessage = e.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => locationMessage =
              'Nie udało się ustalić miasta. Wybierz je ręcznie.',
        );
      }
    } finally {
      if (mounted) setState(() => locating = false);
    }
  }

  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final body = c.searchBody(submitted);
    return RemotePage(
      key: ValueKey(jsonEncode(body)),
      title: 'Znajdź swoje miejsce',
      load: () => c.api.search(body),
      next: (cursor) => c.api.search({...body, 'cursor': cursor}),
      content: (context, state, data) => [
        DropdownButtonFormField<String>(
          initialValue: c.selectedCity,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Miasto',
            prefixIcon: Padding(
              padding: EdgeInsets.all(12),
              child: KindSpotGraphic('city', width: 24, height: 24),
            ),
          ),
          items: [
            for (final city in (c.configuration['cities'] as List).cast<Json>())
              DropdownMenuItem(
                value: city['id'] as String,
                child: Text(city['label'] as String),
              ),
          ],
          onChanged: state.busy
              ? null
              : (value) => setState(() => c.selectedCity = value),
        ),
        OutlinedButton(
          onPressed: locating || state.busy ? null : locate,
          child: Text(
            locating ? 'Ustalanie miasta…' : 'Użyj lokalizacji telefonu',
          ),
        ),
        if (locationMessage != null) Notice(locationMessage!),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: c.placeSort,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Kolejność miejsc',
            prefixIcon: Padding(
              padding: EdgeInsets.all(12),
              child: KindSpotGraphic('sort', width: 24, height: 24),
            ),
          ),
          items: const [
            DropdownMenuItem(
              value: 'best_rated',
              child: Text('Najlepsza średnia ocen'),
            ),
            DropdownMenuItem(
              value: 'review_count',
              child: Text('Najwięcej recenzji'),
            ),
          ],
          onChanged: state.busy
              ? null
              : (value) => setState(() => c.placeSort = value!),
        ),
        TextField(
          controller: query,
          decoration: const InputDecoration(
            labelText: 'Nazwa lub adres',
            prefixIcon: Padding(
              padding: EdgeInsets.all(12),
              child: KindSpotGraphic('search', width: 24, height: 24),
            ),
          ),
          onSubmitted: (_) => setState(() => submitted = query.text),
        ),
        FilledButton(
          onPressed: state.busy
              ? null
              : () => setState(() => submitted = query.text),
          child: const Text('Szukaj'),
        ),
        OutlinedButton(
          onPressed: () => setState(() => map = !map),
          child: Text(map ? 'Pokaż listę miejsc' : 'Pokaż mapę'),
        ),
        if (items(data).isEmpty)
          const KindSpotEmptyState(
            'illustration_empty_results',
            'Brak miejsc dla tych filtrów.',
          ),
        if (map && items(data).isNotEmpty) ...[
          const Notice(
            'Podkład mapy: OpenStreetMap. Lista poniżej zapewnia te same przejścia.',
          ),
          SizedBox(
            height: 300,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(
                  (items(data).first['location']['lat'] as num).toDouble(),
                  (items(data).first['location']['lon'] as num).toDouble(),
                ),
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.uspace',
                ),
                MarkerLayer(
                  markers: [
                    for (final place in items(data))
                      Marker(
                        width: 48,
                        height: 48,
                        point: LatLng(
                          (place['location']['lat'] as num).toDouble(),
                          (place['location']['lon'] as num).toDouble(),
                        ),
                        child: IconButton(
                          tooltip: 'Otwórz: ${place['name']}',
                          icon: const KindSpotSymbol(Icons.location_on),
                          onPressed: () => apiOpen(
                            context,
                            apiPlaceDetails(c, place['id'] as String),
                          ),
                        ),
                      ),
                  ],
                ),
                const SimpleAttributionWidget(
                  source: Text('© OpenStreetMap contributors'),
                ),
              ],
            ),
          ),
        ],
        for (final place in items(data)) apiPlaceTile(context, c, place),
      ],
    );
  }
}

Widget apiPlaceTile(BuildContext context, ApiController c, Json place) => Card(
  child: ListTile(
    leading: KindSpotCategoryIcon(
      (place['categoryId'] ?? place['category'] ?? 'other') as String,
    ),
    title: Text(place['name'] as String),
    subtitle: Text(
      '${place['address']}\n${apiStatus(place['match']?['status'])}\n${place['aggregateRating'] == null ? 'Brak średniej oceny' : 'Średnia: ${(place['aggregateRating'] as num).toStringAsFixed(2)}'} · Recenzje: ${place['reviewCount'] ?? 0}',
    ),
    trailing: const KindSpotSymbol(Icons.chevron_right),
    onTap: () => apiOpen(context, apiPlaceDetails(c, place['id'] as String)),
  ),
);

Widget apiSaved(ApiController c) => RemotePage(
  title: 'Zapisane miejsca',
  load: () => c.api.call('GET', 'me/saved-places'),
  next: (cursor) =>
      c.api.call('GET', 'me/saved-places', query: {'cursor': cursor}),
  content: (context, state, data) => [
    if (items(data).isEmpty)
      const KindSpotEmptyState(
        'illustration_empty_saved',
        'Nie masz zapisanych miejsc.',
      ),
    for (final place in items(data)) ...[
      apiPlaceTile(context, c, place),
      OutlinedButton(
        onPressed: state.busy
            ? null
            : () => state.act(() async {
                await c.api.call('DELETE', 'me/saved-places/${place['id']}');
                final result = await c.api.call('GET', 'me/saved-places');
                if (state.mounted) state.replaceData(result);
              }, success: 'Usunięto z zapisanych.'),
        child: Text('Usuń: ${place['name']}'),
      ),
    ],
  ],
);

Widget apiPlaceDetails(ApiController c, String id) => RemotePage(
  title: 'Szczegóły miejsca',
  load: () => c.api.place(id),
  content: (context, state, place) => [
    SectionTitle(place['name'] as String),
    Text(place['address'] as String),
    Text(apiStatus(place['match']?['status'])),
    FilledButton(
      onPressed: state.busy
          ? null
          : () => state.act(() async {
              await c.api.call('PUT', 'me/saved-places/$id');
            }, success: 'Miejsce zapisane.'),
      child: const Text('Zapisz miejsce'),
    ),
    const SectionTitle('Utrudnienia i aktualność'),
    Text(
      place['lastVerifiedAt'] == null
          ? 'Brak daty potwierdzenia.'
          : 'Ostatnie sprawdzenie: ${place['lastVerifiedAt']}',
    ),
    for (final issue in (place['temporaryIssues'] as List? ?? []).cast<Json>())
      Text('${issue['description']} · ${issue['reportedAt'] ?? ''}'),
    if ((place['temporaryIssues'] as List? ?? []).isEmpty)
      const Text('Brak zgłoszonych utrudnień. To nie potwierdza dostępności.'),
    const SectionTitle('Wejścia i części miejsca'),
    for (final part in (place['parts'] as List? ?? []).cast<Json>())
      Text(part['name'] as String),
    const SectionTitle('Cechy'),
    for (final feature in (place['features'] as List? ?? []).cast<Json>())
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  KindSpotFeatureIcon(feature['featureId'] as String, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      apiFeatureLabel(c, feature['featureId'] as String),
                    ),
                  ),
                ],
              ),
              Text(apiStatus(feature['presence'])),
              if (feature['operationalState'] != null)
                Text(apiStatus(feature['operationalState'])),
              Text(
                feature['rating']?['average_rating'] == null
                    ? 'Brak średniej oceny.'
                    : 'Ocena: ${feature['rating']['average_rating']}',
              ),
              if (feature['sourceLabel'] != null)
                Text(feature['sourceLabel'] as String),
            ],
          ),
        ),
      ),
    const SectionTitle('Recenzje'),
    OutlinedButton(
      onPressed: () => apiOpen(context, apiReviews(c, id)),
      child: const Text('Pokaż recenzje'),
    ),
    FilledButton(
      onPressed: state.busy
          ? null
          : () => apiOpen(
              context,
              ReviewSurveyScreen(
                controller: c,
                place: apiPlace(place),
                providedQuestions: c.apiQuestions,
                providedWantedFeatures: c.wantedSurveyFeatures,
              ),
            ),
      child: const Text('Otwórz ankietę'),
    ),
  ],
);

Widget apiReviews(ApiController c, String placeId) => RemotePage(
  title: 'Recenzje miejsca',
  load: () => c.api.call('GET', 'places/$placeId/reviews'),
  next: (cursor) =>
      c.api.call('GET', 'places/$placeId/reviews', query: {'cursor': cursor}),
  content: (context, state, data) => [
    if (items(data).isEmpty)
      const KindSpotEmptyState('illustration_empty_reviews', 'Brak recenzji.'),
    for (final review in items(data))
      ListTile(
        title: Text(review['author']['displayName'] as String),
        leading: const KindSpotGraphic('review', width: 28, height: 28),
        subtitle: Text(
          '${review['visitedOn']} · ${apiStatus(review['verificationStatus'])}',
        ),
        trailing: const KindSpotSymbol(Icons.chevron_right),
        onTap: () =>
            apiOpen(context, apiReviewDetails(c, review['id'] as String)),
      ),
  ],
);

Widget apiReviewDetails(ApiController c, String id) => RemotePage(
  title: 'Recenzja',
  load: () => c.api.call('GET', 'reviews/$id'),
  content: (context, state, review) => [
    SectionTitle(review['author']['displayName'] as String),
    if (review['author']['title'] != null)
      Text('Tytuł: ${review['author']['title']['label']}'),
    Text('Wizyta: ${review['visitedOn']}'),
    Text('Publikacja: ${apiStatus(review['publicationStatus'])}'),
    Text('Sprawdzanie: ${apiStatus(review['verificationStatus'])}'),
    if (review['pointAward'] != null)
      Text('Punkty: ${apiStatus(review['pointAward']['status'])}'),
    OutlinedButton(
      onPressed: () => apiOpen(
        context,
        apiPublicProfile(c, review['author']['id'] as String),
      ),
      child: const Text('Profil autora'),
    ),
    for (final answer in (review['answers'] as List).cast<Json>())
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  KindSpotFeatureIcon(answer['featureId'] as String, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      apiFeatureLabel(c, answer['featureId'] as String),
                    ),
                  ),
                ],
              ),
              Text(apiStatus(answer['presence'])),
              if (answer['comment'] != null) Text(answer['comment'] as String),
              Text(
                'Zgadzają się: ${answer['communitySummary']['confirmedCount']}. '
                'Nie zgadzają się: ${answer['communitySummary']['disputedCount']}.',
              ),
              if ((review['allowedActions'] as List).contains('vote'))
                for (final verdict in ['confirm', 'dispute'])
                  OutlinedButton(
                    onPressed: state.busy
                        ? null
                        : () => state.act(() async {
                            // Keep the key stable while retrying this exact answer/verdict.
                            final key = c.voteKeys.putIfAbsent(
                              '$id/${answer['id']}/$verdict',
                              operationKey,
                            );
                            await c.api.call(
                              'POST',
                              'reviews/$id/answers/${answer['id']}/votes',
                              body: {'verdict': verdict},
                              key: key,
                            );
                            final result = await c.api.call(
                              'GET',
                              'reviews/$id',
                            );
                            if (state.mounted) {
                              state.replaceData(result);
                            }
                          }, success: 'Głos zapisany.'),
                    child: Text(
                      verdict == 'confirm' ? 'Zgadzam się' : 'Nie zgadzam się',
                    ),
                  ),
            ],
          ),
        ),
      ),
    if ((review['allowedActions'] as List).contains('report'))
      OutlinedButton(
        onPressed: () =>
            apiOpen(context, ApiReport(controller: c, reviewId: id)),
        child: const Text('Zgłoś recenzję'),
      ),
  ],
);

Widget apiPublicProfile(ApiController c, String id) => RemotePage(
  title: 'Publiczny profil',
  load: () => c.api.call('GET', 'users/$id/public-profile'),
  content: (context, state, data) => [
    ApiProfileIdentity(data: data),
    Text(
      'Recenzje: ${data['stats']['reviewCount']}. Weryfikacje: ${data['stats']['verificationCount']}.',
    ),
    if (data['needs'] == null)
      const Text('Potrzeby są prywatne.')
    else
      for (final need in data['needs'] as List)
        Text(apiNeedLabel(c, need as String)),
  ],
);
String apiNeedLabel(ApiController c, String id) {
  for (final need in (c.configuration['needs'] as List).cast<Json>()) {
    if (need['id'] == id) return need['label'] as String;
  }
  return 'Potrzeba bez opisu';
}

Widget apiRewards(ApiController c) => RemotePage(
  title: 'Nagrody',
  load: () => c.api.call('GET', 'rewards'),
  next: (cursor) => c.api.call('GET', 'rewards', query: {'cursor': cursor}),
  content: (context, state, data) => [
    FilledButton(
      onPressed: () => apiOpen(context, ApiOwnedRewards(controller: c)),
      child: const Text('Moje nagrody'),
    ),
    OutlinedButton(
      onPressed: () => apiOpen(context, apiPoints(c)),
      child: const Text('Saldo i historia punktów'),
    ),
    if (items(data).isEmpty)
      const KindSpotEmptyState(
        'illustration_empty_rewards',
        'Brak nagród w katalogu.',
      ),
    for (final category in cosmeticCategories.entries)
      if (items(data).any(
        (r) =>
            (r['categoryId'] ??
                (r['kind'] == 'city_benefit' ? 'city' : 'other')) ==
            category.key,
      )) ...[
        SectionTitle(category.value),
        for (final reward in items(data).where(
          (r) =>
              (r['categoryId'] ??
                  (r['kind'] == 'city_benefit' ? 'city' : 'other')) ==
              category.key,
        ))
          Card(
            child: ListTile(
              leading: reward['cosmetic'] == null
                  ? const KindSpotSymbol(Icons.redeem_outlined)
                  : cosmeticPreview(reward['cosmetic'] as Json),
              title: Text(reward['name'] as String),
              subtitle: Text(
                '${reward['costPoints']} pkt · ${reward['owned'] == true ? 'Na Twoim koncie' : reward['description']}',
              ),
              trailing: const KindSpotSymbol(Icons.chevron_right),
              onTap: () => apiOpen(
                context,
                ApiReward(controller: c, id: reward['id'] as String),
              ),
            ),
          ),
      ],
    OutlinedButton(
      onPressed: () => apiOpen(
        context,
        Scaffold(
          appBar: adaptiveAppBar(context, 'Jak działają punkty'),
          body: pageBody([
            const SectionTitle('Punkty z konta'),
            const Text(
              'Saldo pochodzi z serwera. Punkty otrzymasz po sprawdzeniu recenzji.',
            ),
            const Text('Historia pokazuje przyznane punkty i koszty nagród.'),
            const Text('Zakup rezerwuje punkty. Odbiór może wymagać czasu.'),
            const Text('W razie nieudanej realizacji serwer rozlicza zwrot.'),
            const Text(
              'Konto testowe ma 1000 punktów na start. Reset wykonujemy ręcznie.',
            ),
            const Text(
              'Nie przekazujemy punktów. Dobrowolne zwroty są wyłączone.',
            ),
          ]),
        ),
      ),
      child: const Text('Jak działają punkty'),
    ),
  ],
);

Widget apiPoints(ApiController c) => RemotePage(
  title: 'Punkty',
  load: () async => {
    ...await c.api.call('GET', 'me/points'),
    ...await c.api.call('GET', 'me/points/history'),
  },
  next: (cursor) =>
      c.api.call('GET', 'me/points/history', query: {'cursor': cursor}),
  content: (context, state, data) => [
    SectionTitle('Saldo: ${data['balance']} pkt'),
    Text(
      data['pendingAmount'] == null
          ? 'Punkty oczekujące: kwota jeszcze nieznana.'
          : 'Oczekujące: ${data['pendingAmount']} pkt',
    ),
    for (final entry in items(data))
      ListTile(
        title: Text('${entry['delta']} pkt'),
        subtitle: Text(
          '${pointReason(entry['reasonCode'])}\n${entry['createdAt']}',
        ),
      ),
  ],
);
String pointReason(dynamic code) => switch (code) {
  'test_account_initial' => 'Saldo startowe konta testowego',
  'reward_reserved' => 'Rezerwacja nagrody',
  'reward_purchased' => 'Zakup elementu wyglądu',
  'observation_confirmed' => 'Obserwacja potwierdzona',
  'observation_disputed' => 'Obserwacja zakwestionowana',
  _ => 'Rozliczenie punktów przez system',
};
Widget apiRedemption(ApiController c, String id) => RemotePage(
  title: 'Odbiór nagrody',
  load: () => c.api.call('GET', 'me/redemptions/$id'),
  content: (context, state, data) => [
    SectionTitle(data['rewardName'] as String),
    Text(apiStatus(data['status'])),
    Text('Punkty: ${apiStatus(data['pointsStatus'])}'),
    if (data['cosmetic'] != null && data['status'] == 'fulfilled')
      OutlinedButton(
        onPressed: () => apiOpen(context, ApiCosmeticPicker(controller: c)),
        child: const Text('Wybierz w profilu'),
      ),
    if (data['code'] != null) SelectableText('Kod: ${data['code']}'),
    if (data['instructions'] != null) Text(data['instructions'] as String),
    if (data['expiresAt'] != null) Text('Ważność: ${data['expiresAt']}'),
    OutlinedButton(
      onPressed: state.busy ? null : state.reload,
      child: const Text('Sprawdź status'),
    ),
  ],
);

Widget apiProfile(ApiController c) => RemotePage(
  title: 'Profil',
  load: c.api.me,
  content: (context, state, me) => [
    ApiProfileIdentity(data: me),
    if (me['displayName'] == 'Test Hackaton') const Text('Konto testowe'),
    Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saldo: ${me['pointsBalance']} pkt'),
            Text(
              'Recenzje: ${me['stats']['reviewCount']}. Weryfikacje: ${me['stats']['verificationCount']}.',
            ),
          ],
        ),
      ),
    ),
    apiAchievements(c, me, context),
    for (final member in (me['memberships'] as List).cast<Json>())
      Text(apiStatus(member['status'])),
    SwitchListTile(
      title: const Text('Pokaż publicznie moje potrzeby'),
      subtitle: const Text('Domyślnie potrzeby są prywatne.'),
      value: me['privacy']['needsVisibility'] == 'public',
      onChanged: state.busy
          ? null
          : (value) => state.act(() async {
              await c.api.call(
                'PATCH',
                'me/privacy',
                body: {'needsVisibility': value ? 'public' : 'private'},
              );
              await c.refreshMe();
              if (state.mounted) state.replaceData(c.account);
            }),
    ),
    for (final item in <(String, Widget)>[
      ('Nazwa konta', ApiProfileName(controller: c)),
      ('Wygląd konta', apiCosmetics(c)),
      ('Karta miejska', ApiCard(controller: c)),
      ('Ustawienia dostępności', ApiAccessibility(controller: c)),
      ('Mój publiczny profil', apiPublicProfile(c, me['id'] as String)),
      ('Punkty', apiPoints(c)),
      ('Zadania weryfikacji', apiTasks(c)),
    ])
      ListTile(
        title: Text(item.$1),
        trailing: const KindSpotSymbol(Icons.chevron_right),
        onTap: () => apiOpen(context, item.$2),
      ),
    OutlinedButton(
      onPressed: state.busy ? null : () => state.act(c.logout),
      child: const Text('Wyloguj'),
    ),
  ],
);
Widget apiCosmetics(ApiController c) => ApiCosmeticPicker(controller: c);
Widget apiTasks(ApiController c) => RemotePage(
  title: 'Zadania weryfikacji',
  load: () => c.api.call('GET', 'me/verification-tasks'),
  next: (cursor) =>
      c.api.call('GET', 'me/verification-tasks', query: {'cursor': cursor}),
  content: (context, state, data) => [
    if (items(data).isEmpty)
      const KindSpotEmptyState(
        'illustration_helping',
        'Brak dostępnych zadań.',
      ),
    for (final task in items(data))
      ListTile(
        title: Text(apiFeatureLabel(c, task['featureId'] as String)),
        trailing: const KindSpotSymbol(Icons.chevron_right),
        onTap: () => apiOpen(
          context,
          apiReviewDetails(c, task['review']['id'] as String),
        ),
      ),
  ],
);
