import 'package:flutter/material.dart';

import 'graphics.dart';

import '../domain/models.dart';
import 'components.dart';

/// Builds a complete Flutter survey screen for the selected place.
///
/// The module owns its form, draft and result handling. This entry point does
/// not publish reviews, calculate points or assume a questionnaire schema.
typedef SurveyBuilder = Widget Function(BuildContext context, Place place);

class SurveyEntry extends StatefulWidget {
  const SurveyEntry({super.key, required this.place, this.builder});

  final Place place;
  final SurveyBuilder? builder;

  @override
  State<SurveyEntry> createState() => _SurveyEntryState();
}

class _SurveyEntryState extends State<SurveyEntry> {
  bool _opening = false;

  Future<void> _open() async {
    final builder = widget.builder;
    if (builder == null || _opening) return;
    setState(() => _opening = true);
    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          settings: RouteSettings(name: '/survey/${widget.place.id}'),
          builder: (context) => builder(context, widget.place),
        ),
      );
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (widget.builder == null) ...[
        const Notice(
          'Ankieta w przygotowaniu. Formularz przygotowuje inna osoba. '
          'Dodawanie recenzji jest teraz niedostępne.',
          icon: Icons.pending_outlined,
        ),
        const SizedBox(height: 12),
      ],
      OutlinedButton.icon(
        key: const ValueKey('survey-entry'),
        onPressed: widget.builder == null || _opening ? null : _open,
        style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
        icon: const KindSpotSymbol(Icons.rate_review_outlined),
        label: const Text('Otwórz ankietę'),
      ),
    ],
  );
}
