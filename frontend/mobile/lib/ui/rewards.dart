import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/rewards_demo.dart';
import 'components.dart';
import 'shop_screen.dart';

class RewardsScreen extends ShopRewardsScreen {
  const RewardsScreen({
    super.key,
    required super.controller,
    super.onOpenSection,
  });
}

final _buttonStyle = ButtonStyle(
  minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
  padding: const WidgetStatePropertyAll(EdgeInsets.all(12)),
);

class RewardPreviewScreen extends StatefulWidget {
  const RewardPreviewScreen({super.key, required this.reward});
  final RewardExample reward;
  @override
  State<RewardPreviewScreen> createState() => _RewardPreviewScreenState();
}

class _RewardPreviewScreenState extends State<RewardPreviewScreen> {
  RewardScenario scenario = RewardScenario.success;
  RewardPreview? preview;
  String? message;
  bool checking = false;
  int get cost =>
      widget.reward.exampleCost +
      (scenario == RewardScenario.priceChanged ? 50 : 0);
  Future<void> _start() async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: const Text('Potwierdź symulację'),
        content: Text(
          '${widget.reward.name}\nKoszt scenariusza: $cost pkt (fikcyjny).\n${scenario == RewardScenario.priceChanged ? 'Przykładowy koszt zmienił się z ${widget.reward.exampleCost} na $cost pkt. Wymagamy ponownego potwierdzenia nowego kosztu.\n' : ''}To wyłącznie prezentacja stanów. Nie pobierzemy punktów ani nie wydamy nagrody.',
        ),
        actions: [
          TextButton(
            style: _buttonStyle,
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          FilledButton(
            key: const ValueKey('reward-confirm'),
            style: _buttonStyle,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Uruchom symulację'),
          ),
        ],
      ),
    );
    if (!mounted || accepted != true) return;
    setState(() {
      message = null;
      preview = RewardPreview(
        widget.reward,
        scenario,
        RewardPreviewStatus.processing,
      );
    });
  }

  Future<void> _copy() async {
    if (checking) return;
    setState(() {
      checking = true;
      message = null;
    });
    try {
      await Clipboard.setData(const ClipboardData(text: 'TEST-NIEWAZNY'));
      if (mounted) {
        setState(
          () => message = 'Skopiowano przykładowy kod TEST-NIEWAZNY. Nie uprawnia do odbioru.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => message = 'Nie udało się skopiować kodu. Możesz go odczytać poniżej lub spróbować ponownie.',
        );
      }
    } finally {
      if (mounted) setState(() => checking = false);
    }
  }

  void _advance() => setState(() {
    message = null;
    preview = preview!.advance();
  });
  @override
  Widget build(BuildContext context) {
    final current = preview;
    return Scaffold(
      appBar: adaptiveAppBar(context, 'Podgląd nagrody'),
      body: pageBody([
        SectionTitle(widget.reward.name),
        const Notice(
          'Symulacja na tym urządzeniu. Nie jest zakupem, biletem, potwierdzeniem karty ani zmianą profilu. Saldo pozostaje bez zmian.',
        ),
        const SizedBox(height: 16),
        Text(widget.reward.description),
        Text(
          'Przykładowy koszt: ${widget.reward.exampleCost} pkt. Ceny i uprawnienia produkcyjne nieustalone.',
        ),
        if (current == null) ...[
          const SectionTitle('Wybierz stan do prezentacji'),
          RadioGroup<RewardScenario>(
            groupValue: scenario,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  scenario = value;
                  message = null;
                });
              }
            },
            child: Column(
              children: [
                for (final value in RewardScenario.values)
                  RadioListTile<RewardScenario>(
                    key: ValueKey('reward-scenario-${value.name}'),
                    title: Text(rewardScenarioLabel(value)),
                    value: value,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (scenario == RewardScenario.insufficientPoints)
            const Notice(
              'Przykład: saldo 50 pkt nie wystarcza na nagrodę. To fikcyjna wartość; rzeczywiste saldo jest niedostępne. Symulacja zakupu zablokowana.',
              icon: Icons.error_outline,
            )
          else if (scenario == RewardScenario.unavailable)
            const Notice(
              'Przykład: nagroda niedostępna lub brak uprawnień. Nie rozpoczęto realizacji ani pobrania punktów.',
              icon: Icons.error_outline,
            )
          else
            FilledButton(
              key: const ValueKey('reward-start'),
              style: _buttonStyle,
              onPressed: _start,
              child: const Text('Otwórz podgląd realizacji'),
            ),
        ] else ...[
          const SectionTitle('Stan realizacji — przykład'),
          Text(
            'Potwierdzony koszt scenariusza: $cost pkt — fikcyjny. Żadnych punktów nie pobrano.',
          ),
          Semantics(
            liveRegion: true,
            child: Notice(
              current.statusText,
              icon:
                  current.status == RewardPreviewStatus.failed ||
                      current.status == RewardPreviewStatus.unknown
                  ? Icons.error_outline
                  : Icons.info_outline,
            ),
          ),
          Text(
            'Identyfikator przykładu: ${current.operationId}. Nie utworzono zakupu.',
          ),
          const SizedBox(height: 16),
          if (current.status == RewardPreviewStatus.processing)
            FilledButton(
              key: const ValueKey('reward-advance'),
              style: _buttonStyle,
              onPressed: _advance,
              child: const Text('Pokaż przykładowy wynik'),
            ),
          if (current.status == RewardPreviewStatus.unknown)
            FilledButton(
              key: const ValueKey('reward-check'),
              style: _buttonStyle,
              onPressed: _advance,
              child: const Text('Sprawdź tę samą realizację — demo'),
            ),
          if (current.status == RewardPreviewStatus.failed)
            FilledButton(
              key: const ValueKey('reward-release'),
              style: _buttonStyle,
              onPressed: _advance,
              child: const Text(
                'Pokaż potwierdzenie zwolnienia punktów — demo',
              ),
            ),
          if (current.status == RewardPreviewStatus.ready) ...[
            const SectionTitle('Przykładowy odbiór'),
            ...switch (widget.reward.delivery) {
              RewardDelivery.code => [
                const SelectableText(
                  'TEST-NIEWAZNY',
                  semanticsLabel: 'Przykładowy nieważny kod: TEST NIEWAŻNY',
                ),
                const Text(
                  'Kod demonstracyjny — nie okazuj go do odbioru. Docelowo tutaj pojawi się punkt odbioru i instrukcja operatora. Termin ważności nieustalony; brak rzeczywistego biletu.',
                ),
                FilledButton(
                  key: const ValueKey('reward-copy'),
                  style: _buttonStyle,
                  onPressed: checking ? null : _copy,
                  child: Text(
                    checking ? 'Kopiowanie…' : 'Kopiuj nieważny kod demo',
                  ),
                ),
              ],
              RewardDelivery.profile => [
                const Notice(
                  'Przykład: motyw „Odkrywca” dostępny na koncie. Podgląd nie przypisuje go do profilu. Uprawnienie i wybór wymagają potwierdzenia systemu.',
                ),
              ],
              RewardDelivery.cityCard => [
                const Notice(
                  'Przykład: operator potwierdził zapis biletu na karcie. W PoC nie połączono karty i nie zapisano żadnego biletu. Nie jest to potwierdzenie do kontroli.',
                ),
              ],
            },
          ],
          OutlinedButton(
            key: const ValueKey('reward-read-error'),
            style: _buttonStyle,
            onPressed: () => setState(
              () => message = 'Przykład: odczyt stanu nie powiódł się. Zachowujemy ostatni wyświetlony stan i ten sam identyfikator. Ponowienie nie tworzy zakupu.',
            ),
            child: const Text('Pokaż błąd odczytu — demo'),
          ),
        ],
        if (message != null) ...[
          Semantics(liveRegion: true, child: Notice(message!)),
          if (message!.startsWith('Przykład: odczyt'))
            TextButton(
              key: const ValueKey('reward-read-retry'),
              style: _buttonStyle,
              onPressed: () => setState(
                () => message = 'Przykład: ponownie odczytano tę samą realizację. Stan poniżej jest niezmieniony; nie utworzono zakupu.',
              ),
              child: const Text('Ponów odczyt — demo'),
            ),
        ],
        if (current != null)
          TextButton(
            style: _buttonStyle,
            onPressed: () => setState(() {
              preview = null;
              message = null;
            }),
            child: const Text('Zakończ podgląd'),
          ),
      ]),
    );
  }
}
