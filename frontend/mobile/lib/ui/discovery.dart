import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_controller.dart';
import '../data/catalog.dart';
import '../domain/models.dart';
import 'components.dart';
import 'preferences.dart';
import 'place_details.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key, required this.controller});
  final AppController controller;
  @override
  State<DiscoveryScreen> createState() => DiscoveryScreenState();
}

class DiscoveryScreenState extends State<DiscoveryScreen> {
  final scroll = ScrollController();
  void showMapView() {
    setState(() => showMap = true);
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  String query = '';
  bool showMap = true;
  @override
  Widget build(BuildContext context) {
    final hits = widget.controller.search(query);
    final profile = widget.controller.profile;
    final active = profile.rules
        .where((r) => r.importance != Importance.ignored)
        .length;
    return pageBody(
      [
        Row(
          children: [
            Icon(
              Icons.explore_outlined,
              color: Theme.of(context).colorScheme.primary,
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
              icon: const Icon(Icons.accessibility_new),
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
          key: ValueKey(profile.cityId),
          initialValue: profile.cityId,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Miasto',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          items: const [
            DropdownMenuItem(value: 'krakow', child: Text('Kraków')),
            DropdownMenuItem(value: 'warsaw', child: Text('Warszawa')),
          ],
          onChanged: widget.controller.saving
              ? null
              : (v) => perform(
                  context,
                  () => widget.controller.saveProfile(
                    profile.copyWith(cityId: v),
                  ),
                ),
        ),
        const SizedBox(height: 12),
        TextField(
          onChanged: (value) => setState(() => query = value),
          decoration: const InputDecoration(
            hintText: 'Szukaj miejsca lub rodzaju',
            labelText: 'Szukaj miejsc',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(
              value: false,
              label: Text('Lista'),
              icon: Icon(Icons.format_list_bulleted),
            ),
            ButtonSegment(
              value: true,
              label: Text('Mapa'),
              icon: Icon(Icons.map_outlined),
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
            key: ValueKey(profile.cityId),
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
              icon: const Icon(Icons.tune),
              label: Text(active == 0 ? 'Dopasuj filtry' : 'Filtry · $active'),
            ),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => NeedsScreen(controller: widget.controller),
                ),
              ),
              icon: const Icon(Icons.person_outline),
              label: const Text('Moje potrzeby'),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Proponowane miejsca')),
                body: pageBody([
                  const SectionTitle('Proponowane miejsca w okolicy'),
                  const Notice(
                    'Ranking i promień okolicy czekają na ustalenie. Nie pobieramy lokalizacji telefonu i nie udajemy rekomendacji z API. Miejsca demonstracyjne możesz obejrzeć na mapie i liście.',
                  ),
                ]),
              ),
            ),
          ),
          icon: const Icon(Icons.near_me_outlined),
          label: const Text('Proponowane miejsca'),
        ),
        const SizedBox(height: 20),
        demoNotice(),
        SectionTitle(
          '${hits.length} ${hits.length == 1 ? 'miejsce' : 'miejsc'} dla Ciebie',
          subtitle: 'Dopasowanie do filtrów · dane przykładowe',
        ),
        const SizedBox(height: 16),
        if (hits.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.search_off, size: 36),
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
      builder: (_) =>
          PlaceDetailsScreen(controller: widget.controller, place: hit.place),
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
                    child: Icon(
                      place.category.startsWith('Park')
                          ? Icons.park_outlined
                          : place.category.startsWith('Kultura')
                          ? Icons.local_library_outlined
                          : Icons.place_outlined,
                      color: Theme.of(context).colorScheme.primary,
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
                      color: const Color(0xFFF3F1FA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Miejsce przykładowe',
                      style: TextStyle(fontSize: 12, color: ink),
                    ),
                  ),
                ],
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
                      style: const TextStyle(fontSize: 12, color: muted),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Obserwacja: ${dateLabel(place.observedOn)}',
                      style: const TextStyle(fontSize: 11, color: muted),
                    ),
                  ),
                  const Icon(Icons.arrow_forward, size: 20),
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
  @override
  void dispose() {
    map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (failed) ...[
        const Notice(
          'Podkład mapy jest niedostępny. Lista miejsc nadal działa.',
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
                    urlTemplate: const String.fromEnvironment(
                      'MAP_TILE_URL',
                      defaultValue:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    userAgentPackageName: 'com.example.uspace',
                    maxNativeZoom: 19,
                    errorTileCallback: (tile, error, stack) {
                      if (!failed) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) setState(() => failed = true);
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
                            icon: Icon(
                              Icons.location_on,
                              color: Theme.of(context).colorScheme.primary,
                              size: 32,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Material(
                      color: Theme.of(context).colorScheme.surface,
                      child: TextButton(
                        onPressed: () => launchUrl(
                          Uri.parse('https://www.openstreetmap.org/copyright'),
                        ),
                        child: const Text(
                          '© OpenStreetMap contributors',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
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
                        tooltip: 'Przybliż mapę',
                        onPressed: () => map.move(
                          map.camera.center,
                          (map.camera.zoom + 1).clamp(10, 18),
                        ),
                        icon: const Icon(Icons.add),
                      ),
                      IconButton(
                        tooltip: 'Oddal mapę',
                        onPressed: () => map.move(
                          map.camera.center,
                          (map.camera.zoom - 1).clamp(10, 18),
                        ),
                        icon: const Icon(Icons.remove),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
    ],
  );
}
