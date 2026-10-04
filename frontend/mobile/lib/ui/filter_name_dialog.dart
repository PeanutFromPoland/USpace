import 'package:flutter/material.dart';

class FilterNameDialog extends StatefulWidget {
  const FilterNameDialog({
    super.key,
    this.initialName,
    required this.existingNames,
  });
  final String? initialName;
  final List<String> existingNames;
  @override
  State<FilterNameDialog> createState() => _FilterNameDialogState();
}

class _FilterNameDialogState extends State<FilterNameDialog> {
  late final text = TextEditingController(text: widget.initialName);
  String? error;
  bool confirmed = false;
  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  void confirm() {
    if (confirmed) return;
    final value = text.text.trim();
    if (value.isEmpty || value.length > 60) {
      setState(() => error = 'Wpisz nazwę od 1 do 60 znaków.');
      return;
    }
    if (widget.existingNames.any(
      (name) => name.toLowerCase() == value.toLowerCase(),
    )) {
      setState(() => error = 'Ta nazwa już istnieje. Wpisz inną.');
      return;
    }
    confirmed = true;
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: const Text('Nazwa filtru'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          key: const ValueKey('filter-name'),
          controller: text,
          autofocus: true,
          maxLength: 60,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'Nazwa filtru',
            errorText: error,
          ),
          onSubmitted: (_) => confirm(),
        ),
        if (error != null) Semantics(liveRegion: true, child: Text(error!)),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Anuluj'),
      ),
      FilledButton(
        key: const ValueKey('filter-name-confirm'),
        onPressed: confirm,
        child: const Text('Zapisz filtr'),
      ),
    ],
  );
}
