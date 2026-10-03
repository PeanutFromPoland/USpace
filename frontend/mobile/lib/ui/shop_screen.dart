import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../domain/demo_shop.dart';
import 'components.dart';

class ShopRewardsScreen extends StatefulWidget {
  const ShopRewardsScreen({
    super.key,
    required this.controller,
    this.onOpenSection,
  });
  final AppController controller;
  final VoidCallback? onOpenSection;
  @override
  State<ShopRewardsScreen> createState() => _ShopRewardsScreenState();
}

class _ShopRewardsScreenState extends State<ShopRewardsScreen> {
  bool mine = false;
  bool history = false;
  bool dialogOpen = false;
  String? message;

  Future<void> buy(String id) async {
    if (dialogOpen) return;
    final reward = demoShopCatalog.singleWhere((r) => r.id == id);
    final revision = widget.controller.sessionRevision;
    dialogOpen = true;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text('Kup za ${reward.exampleCost} pkt?'),
        content: Text(
          '${reward.name}\nSaldo po zakupie: ${widget.controller.shop.balance - reward.exampleCost} pkt.\nZakup testowy. Nowe uruchomienie odnowi punkty i ofertę.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          FilledButton(
            key: const ValueKey('shop-confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Kupuję'),
          ),
        ],
      ),
    );
    dialogOpen = false;
    if (!mounted || confirm != true) return;
    if (revision != widget.controller.sessionRevision) return;
    try {
      widget.controller.buyDemoReward(id);
      setState(
        () => message =
            'Kupiono: ${reward.name}. Nagroda czeka w zakładce Moje nagrody.',
      );
    } on StateError catch (error) {
      setState(() => message = '${error.message}');
    }
  }

  Future<void> redeem(DemoPurchase purchase) async {
    if (dialogOpen) return;
    final revision = widget.controller.sessionRevision;
    dialogOpen = true;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: const Text('Zrealizować nagrodę testową?'),
        content: Text(
          '${purchase.reward.name}\nTo oznaczy nagrodę jako zrealizowaną w tej sesji. Nie wydaje prawdziwego biletu ani nie łączy karty.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          FilledButton(
            key: const ValueKey('shop-redeem-confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Zrealizuj'),
          ),
        ],
      ),
    );
    dialogOpen = false;
    if (!mounted ||
        confirm != true ||
        revision != widget.controller.sessionRevision)
      return;
    try {
      widget.controller.redeemDemoReward(purchase.id);
      setState(
        () => message =
            'Nagroda testowa zrealizowana. Zakup pozostaje w historii.',
      );
    } on StateError catch (error) {
      setState(() => message = '${error.message}');
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final shop = widget.controller.shop;
      final purchases = shop.purchases
          .where((p) => history || !p.redeemed)
          .toList();
      return pageBody([
        const SectionTitle('Nagrody'),
        Semantics(
          liveRegion: true,
          child: Text(
            'Saldo: ${shop.balance} pkt',
            key: const ValueKey('shop-balance'),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const Text(
          'Punkty testowe · 1000 pkt przy nowym uruchomieniu aplikacji.',
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              key: const ValueKey('shop-tab'),
              label: const Text('Sklep'),
              selected: !mine,
              onSelected: (_) => setState(() => mine = false),
            ),
            ChoiceChip(
              key: const ValueKey('my-rewards-tab'),
              label: const Text('Moje nagrody'),
              selected: mine,
              onSelected: (_) => setState(() => mine = true),
            ),
          ],
        ),
        if (message != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Semantics(liveRegion: true, child: Notice(message!)),
          ),
        if (!mine) ...[
          const SectionTitle('Sklep'),
          for (final reward in demoShopCatalog)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      reward.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(reward.description),
                    Text('${reward.exampleCost} pkt'),
                    const SizedBox(height: 12),
                    FilledButton(
                      key: ValueKey('shop-buy-${reward.id}'),
                      onPressed:
                          widget.controller.loading ||
                              !widget.controller.isDemoSignedIn ||
                              shop.owns(reward.id) ||
                              shop.balance < reward.exampleCost
                          ? null
                          : () => buy(reward.id),
                      child: Text(
                        shop.owns(reward.id)
                            ? 'Kupiono w tej sesji'
                            : shop.balance < reward.exampleCost
                            ? 'Za mało punktów'
                            : 'Kup: ${reward.name}',
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ] else ...[
          const SectionTitle('Moje nagrody'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                key: const ValueKey('unredeemed-tab'),
                label: const Text('Do odebrania'),
                selected: !history,
                onSelected: (_) => setState(() => history = false),
              ),
              ChoiceChip(
                key: const ValueKey('purchase-history-tab'),
                label: const Text('Historia zakupów'),
                selected: history,
                onSelected: (_) => setState(() => history = true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (purchases.isEmpty)
            Text(
              history
                  ? 'Nie masz jeszcze zakupów w tej sesji.'
                  : 'Nie masz nagród do odebrania.',
            ),
          for (final purchase in purchases)
            Card(
              key: ValueKey('purchase-${purchase.id}'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      purchase.reward.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text('${purchase.reward.exampleCost} pkt · ${purchase.id}'),
                    Text('Zakup: ${_time(purchase.boughtAt)}'),
                    Text(
                      purchase.redeemed
                          ? 'Zrealizowana testowo: ${_time(purchase.redeemedAt!)}'
                          : 'Kupiona · niezrealizowana',
                    ),
                    if (!purchase.redeemed)
                      FilledButton(
                        key: ValueKey('redeem-${purchase.id}'),
                        onPressed: () => redeem(purchase),
                        child: Text('Zrealizuj: ${purchase.reward.name}'),
                      ),
                  ],
                ),
              ),
            ),
        ],
        const SizedBox(height: 24),
        OutlinedButton.icon(
          key: const ValueKey('points-guide'),
          onPressed: () {
            widget.onOpenSection?.call();
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const PointsGuideScreen(),
              ),
            );
          },
          icon: const Icon(Icons.menu_book_outlined),
          label: const Text('Punkty: poradnik i mini regulamin'),
        ),
      ]);
    },
  );
}

String _time(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

class PointsGuideScreen extends StatelessWidget {
  const PointsGuideScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: adaptiveAppBar(context, 'Punkty: poradnik i mini regulamin'),
    body: pageBody([
      const SectionTitle('Jak zdobywać punkty?'),
      const Text(
        'W docelowej aplikacji punkty będą nagrodą za zaakceptowane recenzje i potwierdzone wartościowe weryfikacje. Przyzna je system. Konkretne stawki nie zostały jeszcze ustalone.',
      ),
      const Text(
        'Teraz konto Test Hackaton dostaje 1000 punktów testowych przy każdym nowym uruchomieniu. Ankieta i naliczanie punktów za aktywność są w przygotowaniu.',
      ),
      const SectionTitle('Jak wydawać punkty?'),
      const Text(
        '1. Otwórz Sklep w Nagrodach i sprawdź koszt.\n2. Wybierz Kup i potwierdź zakup.\n3. Koszt zmniejszy saldo, a nagroda trafi do Moich nagród.\n4. W Do odebrania wybierz Zrealizuj. Zakup pozostanie w Historii zakupów.',
      ),
      const SectionTitle('Mini regulamin'),
      const Text(
        'Punkty są nieprzekazywalne. Zakup wymaga wystarczającego salda i potwierdzenia kosztu. Dobrowolne zwroty nie są dostępne. W razie awarii produkcyjnej wynik realizacji i ewentualny zwrot musi potwierdzić system.',
      ),
      const Text(
        'W tej wersji zakupy i realizacje są testowe: nie wydają prawdziwych biletów ani benefitów. Każdy element można kupić raz w sesji. Nowe uruchomienie aplikacji czyści zakupy i historię, odnawia ofertę oraz przywraca 1000 punktów. Przejście do innego ekranu lub powrót z tła nie odnawia salda.',
      ),
    ]),
  );
}
