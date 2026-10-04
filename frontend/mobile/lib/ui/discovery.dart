import 'dart:async';

import 'package:flutter/material.dart';

import 'graphics.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_controller.dart';
import '../data/catalog.dart';
import '../data/city_locator.dart';
import '../domain/models.dart';
import 'components.dart';
import 'preferences.dart';
import 'place_details.dart';
import 'review_navigation.dart';
import 'survey_entry.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({
    super.key,
    required this.controller,
    this.surveyBuilder,
  });
  final AppController controller;
  final SurveyBuilder? surveyBuilder;
  @override
  State<DiscoveryScreen> createState() => DiscoveryScreenState();
}

class DiscoveryScreenState extends State<DiscoveryScreen> {
  final scroll = ScrollController();
  final searchField = TextEditingController();
  final searchFocus = FocusNode();
  final cityFocus = FocusNode();
  final sortFocus = FocusNode();
  String? pendingCity, cityError, cityStatus, locationMessage;
  bool locating = false;
  PlaceSort? pendingSort;
  String? sortError;

  Future<void> selectSort(PlaceSort value) async {
    setState(() {
      pendingSort = value;
      sortError = null;
    });
    try {
      await widget.controller.saveProfile(
        widget.controller.profile.copyWith(placeSort: value),
      );
      if (mounted) setState(() => pendingSort = null);
    } catch (_) {
      if (mounted) {
        setState(
          () => sortError = 'Nie udało się zapisać kolejności. Lista nadal używa poprzedniego ustawienia. Ponów zapis.',
        );
      }
    }
  }

  int locationRequest = 0;

  Future<void> selectCity(String city) async {
    setState(() {
      pendingCity = city;
      cityError = null;
      cityStatus = null;
    });
    try {
      await widget.controller.saveProfile(
        widget.controller.profile.copyWith(cityId: city),
      );
      if (!mounted) return;
      setState(() {
        pendingCity = null;
        cityStatus = 'Wybrano miasto: ${cityLabel(city)}.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(
        () => cityError =
            'Nie udało się zapisać miasta. Wyniki nadal dotyczą ${cityLabel(widget.controller.profile.cityId)}. Ponów zapis lub wybierz inne miasto.',
      );
    }
  }

  Future<void> locateCity() async {
    if (locating || widget.controller.saving) return;
    final request = ++locationRequest;
    setState(() {
      locating = true;
      locationMessage = null;
      cityStatus = null;
    });
    try {
      final city = await widget.controller.cityLocator.locateCity();
      if (!mounted || request != locationRequest) return;
      await selectCity(city);
    } on CityLocationException catch (error) {
      if (mounted && request == locationRequest) {
        setState(() => locationMessage = error.message);
      }
    } catch (_) {
      if (mounted && request == locationRequest) {
        setState(
          () => locationMessage = const CityLocationException(
            CityLocationProblem.unavailable,
          ).message,
        );
      }
    } finally {
      if (mounted && request == locationRequest) {
        setState(() => locating = false);
      }
    }
  }

  void showMapView() {
    setState(() => showMap = true);
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  @override
  void dispose() {
    locationRequest++;
    searchField.dispose();
    searchFocus.dispose();
    cityFocus.dispose();
    sortFocus.dispose();
    scroll.dispose();
    super.dispose();
  }

  String query = '';
  bool showMap = true;
  @override
  Widget build(BuildContext context) {
    final hits = widget.controller.search(query);
    final profile = widget.controller.profile;
    final active = widget.controller.activeRules
        .where((r) => r.importance != Importance.ignored)
        .length;
    return pageBody(
      [
        Row(
          children: [
            KindSpotSymbol(
              Icons.explore_outlined,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: 30,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'KindSpot',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            IconButton(
              tooltip: 'Dostępność interfejsu',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) =>
                      AccessibilityScreen(controller: widget.controller),
                ),
              ),
              icon: const KindSpotSymbol(Icons.accessibility_new),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Znajdź swoje miejsce.',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        const Text(
          '$demoAccountName · konto testowe. Fikcyjne miejsca.',
          style: TextStyle(),
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          key: ValueKey('city-choice-${pendingCity ?? profile.cityId}'),
          initialValue: pendingCity ?? profile.cityId,
          focusNode: cityFocus,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Miasto',
            prefixIcon: KindSpotSymbol(Icons.location_on_outlined),
          ),
          items: const [
            DropdownMenuItem(value: 'krakow', child: Text('Kraków')),
            DropdownMenuItem(value: 'warsaw', child: Text('Warszawa')),
          ],
          onChanged: widget.controller.saving
              ? null
              : (v) {
                  if (v == null) return;
                  // A manual choice supersedes an outstanding GPS result.
                  locationRequest++;
                  setState(() {
                    locating = false;
                    locationMessage = null;
                  });
                  selectCity(v);
                },
        ),
        if (cityError != null) ...[
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            child: Notice(cityError!, icon: Icons.error_outline),
          ),
          OutlinedButton(
            key: const ValueKey('city-retry'),
            onPressed: widget.controller.saving
                ? null
                : () => selectCity(pendingCity!),
            child: const Text('Ponów zapis miasta'),
          ),
        ],
        if (cityStatus != null)
          Semantics(liveRegion: true, child: Text(cityStatus!)),
        const SizedBox(height: 12),
        const Text(
          'Możesz ustalić miasto z lokalizacji na żądanie. Usługa systemowa może użyć internetu. W demo zapisujemy tylko miasto, bez współrzędnych.',
          style: TextStyle(fontSize: 13),
        ),
        OutlinedButton.icon(
          key: const ValueKey('locate-city'),
          onPressed: locating || widget.controller.saving ? null : locateCity,
          icon: const KindSpotSymbol(Icons.my_location),
          label: Text(
            locating ? 'Ustalanie miasta…' : 'Użyj lokalizacji telefonu',
          ),
        ),
        if (locating)
          Semantics(
            liveRegion: true,
            child: const Text(
              'Trwa ustalanie miasta. Możesz wybrać je ręcznie.',
            ),
          ),
        if (locationMessage != null)
          Semantics(liveRegion: true, child: Notice(locationMessage!)),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey('place-search'),
          controller: searchField,
          focusNode: searchFocus,
          textInputAction: TextInputAction.search,
          onChanged: (value) => setState(() => query = value),
          decoration: InputDecoration(
            hintText: 'Nazwa, rodzaj lub adres',
            labelText: 'Szukaj miejsc',
            prefixIcon: const KindSpotSymbol(Icons.search),
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Wyczyść wyszukiwanie',
                    onPressed: () {
                      searchField.clear();
                      setState(() => query = '');
                      searchFocus.requestFocus();
                    },
                    icon: const KindSpotSymbol(Icons.clear),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<PlaceSort>(
          key: ValueKey(
            'place-sort-${(pendingSort ?? profile.placeSort).name}',
          ),
          initialValue: pendingSort ?? profile.placeSort,
          focusNode: sortFocus,
          isExpanded: true,
          itemHeight: null,
          decoration: const InputDecoration(labelText: 'Kolejność miejsc'),
          items: [
            for (final sort in PlaceSort.values)
              DropdownMenuItem(value: sort, child: Text(placeSortLabel(sort))),
          ],
          onChanged: widget.controller.saving
              ? null
              : (value) {
                  if (value != null) selectSort(value);
                },
        ),
        if (sortError != null) ...[
          Semantics(liveRegion: true, child: Notice(sortError!)),
          OutlinedButton(
            key: const ValueKey('sort-retry'),
            onPressed: widget.controller.saving
                ? null
                : () => selectSort(pendingSort!),
            child: const Text('Ponów zapis kolejności'),
          ),
        ],
        const SizedBox(height: 12),
        const Text(
          'Najlepsza ocena: najpierw średnia, przy remisie liczba recenzji. Średnie i liczby recenzji w demo są fikcyjne.',
          style: TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 12),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(
              value: false,
              label: Text('Lista'),
              icon: KindSpotSymbol(Icons.format_list_bulleted),
            ),
            ButtonSegment(
              value: true,
              label: Text('Mapa'),
              icon: KindSpotSymbol(Icons.map_outlined),
            ),
          ],
          selected: {showMap},
          onSelectionChanged: (value) => setState(() => showMap = value.single),
          style: const ButtonStyle(
            minimumSize: WidgetStatePropertyAll(Size(48, 52)),
          ),
        ),
        const SizedBox(height: 12),
        if (showMap && hits.isNotEmpty)
          PlacesMap(
            key: ValueKey('map-city-${profile.cityId}'),
            hits: hits,
            cityId: profile.cityId,
            onSelect: (hit) => _open(context, hit),
            onList: () => setState(() => showMap = false),
          ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.tonalIcon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => FiltersScreen(controller: widget.controller),
                ),
              ),
              icon: const KindSpotSymbol(Icons.tune),
              label: Text(active == 0 ? 'Dopasuj filtry' : 'Filtry · $active'),
            ),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => NeedsScreen(controller: widget.controller),
                ),
              ),
              icon: const KindSpotSymbol(Icons.person_outline),
              label: const Text('Moje potrzeby'),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => ProposedPlacesScreen(
                controller: widget.controller,
                surveyBuilder: widget.surveyBuilder,
              ),
            ),
          ),
          icon: const KindSpotSymbol(Icons.near_me_outlined),
          label: const Text('Proponowane miejsca'),
        ),
        const SizedBox(height: 20),

        ResultsSummary(
          count: hits.length,
          cityId: profile.cityId,
          query: query,
          order: placeSortLabel(profile.placeSort),
        ),
        const SizedBox(height: 16),
        if (hits.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const KindSpotGraphic(
                    'illustration_empty_results',
                    height: 110,
                  ),
                  const SectionTitle('Brak pasujących miejsc'),
                  const Text(
                    'Zmień miasto, tekst wyszukiwania lub filtry. Brak wyników nie oznacza awarii.',
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            FiltersScreen(controller: widget.controller),
                      ),
                    ),
                    child: const Text('Zmień filtry'),
                  ),
                ],
              ),
            ),
          ),
        for (final hit in hits)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: PlaceCard(hit: hit, onTap: () => _open(context, hit)),
          ),
        const SizedBox(height: 8),
        const Text(
          'Brak informacji nie jest potwierdzeniem dostępności. Sprawdź aktualność obserwacji przed wizytą.',
          style: TextStyle(fontSize: 13),
        ),
      ],
      key: const PageStorageKey('discovery-list'),
      controller: scroll,
    );
  }

  void _open(BuildContext context, SearchHit hit) => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (routeContext) => PlaceDetailsScreen(
        controller: widget.controller,
        place: hit.place,
        surveyBuilder: widget.surveyBuilder,
        onOpenReviews: () =>
            openDemoReviews(routeContext, hit.place, widget.controller),
      ),
    ),
  );
}

class PlaceCard extends StatelessWidget {
  const PlaceCard({super.key, required this.hit, required this.onTap});
  final SearchHit hit;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final place = hit.place;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: KindSpotSymbol(
                      place.category.startsWith('Park')
                          ? Icons.park_outlined
                          : place.category.startsWith('Kultura')
                          ? Icons.local_library_outlined
                          : Icons.place_outlined,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          place.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          place.address,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatusTag(hit.match.status),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Miejsce przykładowe',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${place.aggregateRating == null ? "Brak średniej ocen" : "Średnia: ${place.aggregateRating!.toStringAsFixed(1).replaceAll('.', ',')} / 5"} · ${place.reviewCount == null ? "Liczba recenzji nieznana" : "Recenzje: ${place.reviewCount}"}',
                style: const TextStyle(fontSize: 13),
              ),
              if (place.issue != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Utrudnienie: ${place.issue}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  for (final fact
                      in place.features
                          .where(
                            (f) =>
                                f.presence == Presence.present &&
                                f.state != OperationalState.notWorking &&
                                f.state != OperationalState.limited,
                          )
                          .take(3))
                    Text(
                      featureById(fact.featureId).label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Obserwacja: ${dateLabel(place.observedOn)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const KindSpotSymbol(Icons.arrow_forward, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlacesMap extends StatefulWidget {
  const PlacesMap({
    super.key,
    required this.hits,
    required this.cityId,
    required this.onSelect,
    required this.onList,
  });
  final List<SearchHit> hits;
  final String cityId;
  final void Function(SearchHit) onSelect;
  final VoidCallback onList;
  @override
  State<PlacesMap> createState() => _PlacesMapState();
}

class _PlacesMapState extends State<PlacesMap> {
  final map = MapController();
  bool failed = false;
  bool failureScheduled = false;
  int tileAttempt = 0;
  String? attributionError;

  Future<void> openAttribution() async {
    try {
      final opened = await launchUrl(
        Uri.parse('https://www.openstreetmap.org/copyright'),
      );
      if (!opened) throw StateError('No link handler');
      if (mounted) setState(() => attributionError = null);
    } catch (_) {
      if (mounted) {
        setState(
          () => attributionError = 'Nie udało się otworzyć informacji o autorach. Adres: https://www.openstreetmap.org/copyright',
        );
      }
    }
  }

  @override
  void dispose() {
    map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final renderingAttempt = tileAttempt;
    return Column(
      children: [
        if (failed) ...[
          Semantics(
            liveRegion: true,
            child: const Notice(
              'Podkład mapy jest niedostępny. Lista miejsc nadal działa.',
            ),
          ),
          OutlinedButton(
            key: const ValueKey('map-retry'),
            onPressed: () => setState(() {
              failed = false;
              failureScheduled = false;
              tileAttempt++;
            }),
            child: const Text('Ponów wczytanie mapy'),
          ),
          TextButton(
            onPressed: widget.onList,
            child: const Text('Pokaż listę miejsc'),
          ),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            height: 360,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: map,
                  options: MapOptions(
                    initialCenter: widget.cityId == 'warsaw'
                        ? const LatLng(52.233, 21.01)
                        : const LatLng(50.0615, 19.941),
                    initialZoom: 14,
                    maxZoom: 18,
                    minZoom: 10,
                    interactionOptions: const InteractionOptions(
                      flags:
                          InteractiveFlag.drag |
                          InteractiveFlag.pinchZoom |
                          InteractiveFlag.doubleTapZoom,
                    ),
                  ),
                  children: [
                    TileLayer(
                      key: ValueKey(tileAttempt),
                      urlTemplate: const String.fromEnvironment(
                        'MAP_TILE_URL',
                        defaultValue:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      ),
                      userAgentPackageName: 'com.example.uspace',
                      maxNativeZoom: 19,
                      errorTileCallback: (tile, error, stack) {
                        if (renderingAttempt != tileAttempt) return;
                        if (!failed && !failureScheduled) {
                          failureScheduled = true;
                          final attempt = renderingAttempt;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted && attempt == tileAttempt) {
                              setState(() => failed = true);
                            }
                          });
                        }
                      },
                    ),
                    MarkerLayer(
                      markers: [
                        for (final hit in widget.hits)
                          Marker(
                            point: LatLng(hit.place.lat, hit.place.lon),
                            width: 52,
                            height: 52,
                            child: IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerLow,
                              ),
                              tooltip: 'Otwórz ${hit.place.name}',
                              onPressed: () => widget.onSelect(hit),
                              icon: KindSpotSymbol(
                                Icons.location_on,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                                size: 28,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Material(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    child: Column(
                      children: [
                        IconButton(
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                          tooltip: 'Przybliż mapę',
                          onPressed: () => map.move(
                            map.camera.center,
                            (map.camera.zoom + 1).clamp(10, 18),
                          ),
                          icon: const KindSpotSymbol(Icons.add),
                        ),
                        IconButton(
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                          tooltip: 'Oddal mapę',
                          onPressed: () => map.move(
                            map.camera.center,
                            (map.camera.zoom - 1).clamp(10, 18),
                          ),
                          icon: const KindSpotSymbol(Icons.remove),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: openAttribution,
          child: const Text(
            '© Autorzy OpenStreetMap — informacje i licencja',
            textAlign: TextAlign.center,
          ),
        ),
        if (attributionError != null)
          Semantics(liveRegion: true, child: Notice(attributionError!)),
        const SizedBox(height: 16),
      ],
    );
  }
}

// Result counts are spoken after a short pause instead of on every keystroke.
class ResultsSummary extends StatefulWidget {
  const ResultsSummary({
    super.key,
    required this.count,
    required this.cityId,
    required this.query,
    this.order = '',
  });
  final int count;
  final String cityId, query, order;
  @override
  State<ResultsSummary> createState() => _ResultsSummaryState();
}

class _ResultsSummaryState extends State<ResultsSummary> {
  Timer? timer;
  late String announcement;
  String get summary =>
      'Wyniki: ${widget.count}. Miasto: ${cityLabel(widget.cityId)}. ${widget.order}. Dopasowanie do filtrów, dane przykładowe.';
  @override
  void initState() {
    super.initState();
    announcement = summary;
  }

  @override
  void didUpdateWidget(covariant ResultsSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count ||
        oldWidget.cityId != widget.cityId ||
        oldWidget.query != widget.query ||
        oldWidget.order != widget.order) {
      timer?.cancel();
      timer = Timer(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => announcement = summary);
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    header: true,
    label: announcement,
    excludeSemantics: true,
    child: SectionTitle(
      '${widget.count} ${widget.count == 1 ? 'miejsce' : 'miejsc'} dla Ciebie',
      subtitle: 'Dopasowanie do filtrów · dane przykładowe',
    ),
  );
}

class ProposedPlacesScreen extends StatelessWidget {
  const ProposedPlacesScreen({
    super.key,
    required this.controller,
    this.surveyBuilder,
  });
  final AppController controller;
  final SurveyBuilder? surveyBuilder;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final hits = controller.search('');
      return Scaffold(
        appBar: adaptiveAppBar(context, 'Proponowane miejsca'),
        body: pageBody([
          SectionTitle(
            'Miejsca w okolicy: ${cityLabel(controller.profile.cityId)}',
          ),
          const Notice(
            'W tym demo okolica obejmuje całe wybrane miasto. Lista uwzględnia zapisane filtry; lokalizacja służy wyborowi miasta. Średnie i liczby recenzji są fikcyjne.',
          ),
          Text('Kolejność: ${placeSortLabel(controller.profile.placeSort)}'),
          ResultsSummary(
            count: hits.length,
            cityId: controller.profile.cityId,
            query: '',
            order: placeSortLabel(controller.profile.placeSort),
          ),
          if (hits.isEmpty)
            const Notice(
              'Brak pasujących miejsc. Wróć na mapę i zmień miasto lub filtry.',
            ),
          for (final hit in hits)
            PlaceCard(
              hit: hit,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (routeContext) => PlaceDetailsScreen(
                    controller: controller,
                    place: hit.place,
                    surveyBuilder: surveyBuilder,
                    onOpenReviews: () =>
                        openDemoReviews(routeContext, hit.place, controller),
                  ),
                ),
              ),
            ),
        ]),
      );
    },
  );
}
