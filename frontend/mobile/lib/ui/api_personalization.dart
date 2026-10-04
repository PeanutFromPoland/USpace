import 'package:flutter/material.dart';

import '../data/product_api.dart';
import '../integration/api_controller.dart';
import 'api_app.dart';
import 'components.dart';
import 'graphics.dart';

const cosmeticCategories = <String, String>{
  'avatar': 'Profilowe',
  'frame': 'Ramka',
  'theme': 'Motywy aplikacji',
  'city': 'Nagrody miejskie',
  'other': 'Pozostałe nagrody',
};

String cosmeticLabel(String id) => switch (id) {
  'avatar_lemur' => 'Lemur',
  'avatar_cat' => 'Kot',
  'frame_bow' || 'frame_reward' => 'Obręcz z kokardą',
  'explorer' => 'Odkrywca',
  'gardener' => 'Ogrodnik',
  _ => id,
};

class ApiProfileIdentity extends StatelessWidget {
  const ApiProfileIdentity({super.key, required this.data});
  final Json data;
  @override
  Widget build(BuildContext context) {
    final appearance = data['appearance'] as Json? ?? {};
    final selected = appearance['titleId'];
    final earned = (data['achievements'] as List? ?? []).cast<Json>();
    final title =
        data['title'] as Json? ??
        earned.where((t) => t['id'] == selected).firstOrNull;
    final avatar = appearance['avatarId'] as String? ?? 'default';
    final frame = appearance['frameId'] == 'frame_reward'
        ? 'frame_bow'
        : appearance['frameId'] as String?;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            KindSpotAvatar(
              avatar,
              frameId: frame,
              size: 104,
              label:
                  'Profilowe: ${avatar == 'avatar_default' || avatar == 'default' ? 'domyślne' : cosmeticLabel(avatar)}${frame == 'frame_bow' ? ', obręcz z kokardą' : ''}',
            ),
            const SizedBox(height: 12),
            Text(
              data['displayName'] as String,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (title != null) ...[
              const SizedBox(height: 8),
              Text(
                title['label'] as String,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Widget cosmeticPreview(Json row, {double size = 48}) {
  final id = row['id'] as String;
  return switch (row['kind']) {
    'avatar' => KindSpotAvatar(id, size: size),
    'frame' => KindSpotAvatar(
      'default',
      frameId: id == 'frame_reward' ? 'frame_bow' : id,
      size: size,
    ),
    'theme' when id == 'explorer' || id == 'gardener' => KindSpotGraphic(
      'thumbnail_$id',
      width: size,
      height: size,
    ),
    'title' => KindSpotSymbol(Icons.emoji_events_outlined, size: size),
    _ => KindSpotSymbol(Icons.redeem_outlined, size: size),
  };
}

class ApiCosmeticPicker extends StatelessWidget {
  const ApiCosmeticPicker({
    super.key,
    required this.controller,
    this.titlesOnly = false,
  });
  final ApiController controller;
  final bool titlesOnly;

  Future<Json> load() async {
    final owned = await controller.api.call(
      'GET',
      'me/cosmetics',
      query: {'limit': '100'},
    );
    await controller.refreshMe();
    return {...owned, 'me': controller.account};
  }

  @override
  Widget build(BuildContext context) => RemotePage(
    title: titlesOnly ? 'Publiczny tytuł' : 'Wygląd konta',
    load: load,
    next: (cursor) async => {
      ...await controller.api.call(
        'GET',
        'me/cosmetics',
        query: {'cursor': cursor, 'limit': '100'},
      ),
      'me': controller.account,
    },
    content: (context, state, data) {
      final owned = items(data);
      final me = data['me'] as Json;
      final appearance = me['appearance'] as Json? ?? {};
      final groups = titlesOnly
          ? {'title': 'Zdobyte tytuły'}
          : {
              'avatar': 'Profilowe',
              'frame': 'Ramka',
              'theme': 'Motywy aplikacji',
            };
      return [
        ApiProfileIdentity(data: me),
        Text(
          titlesOnly
              ? 'Tylko wybrany, zdobyty tytuł będzie widoczny w publicznym profilu.'
              : 'Wybierz element należący do konta. Tło profilu korzysta z motywu aplikacji.',
        ),
        for (final category in groups.entries) ...[
          SectionTitle(category.value),
          if (!owned.any((r) => r['kind'] == category.key))
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  category.key == 'theme'
                      ? 'Nie masz jeszcze kupionych motywów.'
                      : 'Brak elementów w tej kategorii.',
                ),
              ),
            ),
          for (final row in owned.where((r) => r['kind'] == category.key))
            _CosmeticChoice(
              controller: controller,
              row: row,
              me: me,
              state: state,
            ),
        ],
        if (!titlesOnly) ...[
          SectionTitle('Podstawowy motyw'),
          for (final entry in const {
            'green': 'Pastelowy zielony',
            'orange': 'Pastelowy pomarańczowy',
            'pink': 'Pastelowy różowy',
            'blue': 'Jasnoniebieski',
          }.entries)
            _CosmeticChoice(
              controller: controller,
              row: {'id': entry.key, 'kind': 'theme', 'label': entry.value},
              me: me,
              state: state,
            ),
        ],
        if (titlesOnly &&
            owned
                .where(
                  (r) => r['kind'] == 'title' && r['id'] != 'title_default',
                )
                .isEmpty)
          const Text(
            'Nie masz jeszcze zdobytych tytułów. Pojawią się po potwierdzeniu ich przez system.',
          ),
        if (!titlesOnly)
          OutlinedButton(
            onPressed: () => apiOpen(context, apiRewards(controller)),
            child: const Text('Przejdź do sklepu'),
          ),
        if (appearance.isEmpty)
          const Text('Wygląd nie jest jeszcze ustawiony.'),
      ];
    },
  );
}

class _CosmeticChoice extends StatelessWidget {
  const _CosmeticChoice({
    required this.controller,
    required this.row,
    required this.me,
    required this.state,
  });
  final ApiController controller;
  final Json row, me;
  final RemotePageState state;
  @override
  Widget build(BuildContext context) {
    final kind = row['kind'] as String;
    final id = row['id'] as String;
    final field = switch (kind) {
      'avatar' => 'avatarId',
      'frame' => 'frameId',
      _ => 'titleId',
    };
    final equipped = kind == 'theme'
        ? (me['uiSettings'] as Json? ?? {})['colorThemeId'] == id
        : (me['appearance'] as Json? ?? {})[field] == id;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                cosmeticPreview(row),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    row['label'] as String,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: state.busy || equipped
                  ? null
                  : () => state.act(() async {
                      if (kind == 'theme') {
                        await controller.api.call(
                          'PUT',
                          'me/ui-settings',
                          body: {
                            ...controller.effectiveUi,
                            'colorThemeId': id,
                            if (id == 'gardener') 'darkMode': true,
                          },
                        );
                      } else {
                        await controller.api.call(
                          'PATCH',
                          'me/profile',
                          body: {
                            'appearance': {field: id},
                          },
                        );
                      }
                      await controller.refreshMe();
                      if (state.mounted) {
                        state.replaceData({
                          ...state.data!,
                          'me': controller.account,
                        });
                      }
                    }, success: 'Wybór zapisany.'),
              child: Text(
                equipped ? 'Wybrane' : 'Użyj',
                semanticsLabel:
                    '${equipped ? 'Wybrane' : 'Użyj'}: ${row['label']}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget apiAchievements(ApiController c, Json me, BuildContext context) => Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('Osiągnięcia'),
        if ((me['achievements'] as List? ?? []).isEmpty)
          const Text('Nie masz jeszcze zdobytych tytułów.'),
        for (final title in (me['achievements'] as List? ?? []).cast<Json>())
          Text(title['label'] as String),
        OutlinedButton(
          onPressed: () => apiOpen(
            context,
            ApiCosmeticPicker(controller: c, titlesOnly: true),
          ),
          child: const Text('Wybierz publiczny tytuł'),
        ),
      ],
    ),
  ),
);
