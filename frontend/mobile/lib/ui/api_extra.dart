import 'package:flutter/material.dart';

import '../data/product_api.dart';
import '../integration/api_controller.dart';
import 'api_app.dart';

class ApiOwnedRewards extends StatefulWidget {
  const ApiOwnedRewards({super.key, required this.controller});
  final ApiController controller;
  @override
  State<ApiOwnedRewards> createState() => _ApiOwnedRewardsState();
}

class _ApiOwnedRewardsState extends State<ApiOwnedRewards> {
  bool history = false;
  @override
  Widget build(BuildContext context) => RemotePage(
    title: 'Moje nagrody',
    load: () => widget.controller.api.call('GET', 'me/redemptions'),
    next: (cursor) => widget.controller.api.call(
      'GET',
      'me/redemptions',
      query: {'cursor': cursor},
    ),
    content: (context, state, data) {
      final list = items(data)
          .where(
            (item) =>
                history || ['processing', 'ready'].contains(item['status']),
          )
          .toList();
      return [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ChoiceChip(
              label: const Text('Do odebrania'),
              selected: !history,
              onSelected: (_) => setState(() => history = false),
            ),
            ChoiceChip(
              label: const Text('Historia zakupów'),
              selected: history,
              onSelected: (_) => setState(() => history = true),
            ),
          ],
        ),
        if (list.isEmpty)
          Text(history ? 'Brak zakupów.' : 'Brak nagród do odebrania.'),
        for (final item in list)
          ListTile(
            title: Text(item['rewardName'] as String),
            subtitle: Text(
              '${apiStatus(item['status'])} · ${item['costPoints']} pkt',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => apiOpen(
              context,
              apiRedemption(widget.controller, item['id'] as String),
            ),
          ),
      ];
    },
  );
}

class ApiProfileName extends StatefulWidget {
  const ApiProfileName({super.key, required this.controller});
  final ApiController controller;
  @override
  State<ApiProfileName> createState() => _ApiProfileNameState();
}

class _ApiProfileNameState extends State<ApiProfileName> {
  late final name = TextEditingController(
    text: widget.controller.account['displayName'] as String?,
  );
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RemotePage(
    title: 'Nazwa konta',
    load: () async => {'ready': true},
    content: (context, state, _) => [
      TextField(
        controller: name,
        maxLength: 80,
        enabled: !state.busy,
        decoration: const InputDecoration(labelText: 'Nazwa konta'),
      ),
      FilledButton(
        onPressed: state.busy
            ? null
            : () => state.act(() async {
                if (name.text.trim().isEmpty) {
                  throw const ProductApiError('Wpisz nazwę konta.');
                }
                await widget.controller.api.call(
                  'PATCH',
                  'me/profile',
                  body: {'displayName': name.text.trim()},
                );
                await widget.controller.refreshMe();
              }),
        child: const Text('Zapisz nazwę'),
      ),
    ],
  );
}
