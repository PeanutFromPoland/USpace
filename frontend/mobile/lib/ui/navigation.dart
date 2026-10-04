import 'package:flutter/material.dart';

import 'graphics.dart';

class KindSpotNavigation extends StatelessWidget {
  const KindSpotNavigation({
    super.key,
    required this.selected,
    required this.onSelect,
  });
  final int selected;
  final ValueChanged<int> onSelect;
  static const items = [
    (0, 'Zapisane', Icons.bookmark_outline),
    (1, 'Nagrody', Icons.redeem_outlined),
    (2, 'Mapa', Icons.map_outlined),
    (3, 'Filtry', Icons.tune),
    (4, 'Profil', Icons.person_outline),
  ];
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Material(
        color: scheme.surfaceContainer,
        child: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: scheme.outlineVariant)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final expanded =
                  MediaQuery.textScalerOf(context).scale(12) > 18 ||
                  constraints.maxWidth < 360;
              if (expanded) {
                // Two rows keep whole labels while leaving the main map in the centre.
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          tile(context, items[0], textOnly: true),
                          tile(context, items[1], textOnly: true),
                        ],
                      ),
                    ),
                    SizedBox(width: 88, child: tile(context, items[2])),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          tile(context, items[3], textOnly: true),
                          tile(context, items[4], textOnly: true),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  for (final item in items)
                    Expanded(child: tile(context, item)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget tile(
    BuildContext context,
    (int, String, IconData) item, {
    bool textOnly = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final active = selected == item.$1;
    final primary = item.$1 == 2;
    return Semantics(
      selected: active,
      button: true,
      label: item.$2,
      excludeSemantics: true,
      child: InkWell(
        key: ValueKey('navigation-${item.$1}'),
        borderRadius: BorderRadius.circular(16),
        onTap: () => onSelect(item.$1),
        focusColor: scheme.primary.withValues(alpha: 0.18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: textOnly && active
                ? scheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 4,
                vertical: textOnly ? 12 : 10,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!textOnly)
                    Container(
                      padding: EdgeInsets.all(primary ? 12 : 8),
                      decoration: BoxDecoration(
                        color: primary || active
                            ? scheme.primaryContainer
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: active
                            ? Border.all(color: scheme.primary, width: 2)
                            : null,
                      ),
                      child: KindSpotSymbol(
                        item.$3,
                        filled: active,
                        color: primary || active
                            ? scheme.onPrimaryContainer
                            : scheme.onSurfaceVariant,
                        size: primary ? 28 : 24,
                      ),
                    ),
                  if (!textOnly) const SizedBox(height: 4),
                  Text(
                    item.$2,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
