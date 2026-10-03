import 'package:flutter/material.dart';

import '../domain/models.dart';

const ink = Color(0xFF192F2A);
const muted = Color(0xFF52645F);
const paper = Color(0xFFF7F8F4);

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.subtitle, this.action});
  final String title;
  final String? subtitle;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            ?action,
          ],
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(subtitle!, style: const TextStyle()),
          ),
      ],
    ),
  );
}

class Notice extends StatelessWidget {
  const Notice(
    this.text, {
    super.key,
    this.icon = Icons.info_outline,
    this.color,
  });
  final String text;
  final IconData icon;
  final Color? color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color ?? Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 13, height: 1.5)),
        ),
      ],
    ),
  );
}

class StatusTag extends StatelessWidget {
  const StatusTag(this.status, {super.key});
  final MatchStatus status;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground, icon) = switch (status) {
      MatchStatus.matches => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        Icons.check_circle_outline,
      ),
      MatchStatus.doesNotMatch => (
        scheme.errorContainer,
        scheme.onErrorContainer,
        Icons.cancel_outlined,
      ),
      MatchStatus.insufficientData => (
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
        Icons.help_outline,
      ),
      MatchStatus.notEvaluated => (
        scheme.surfaceContainerHighest,
        scheme.onSurface,
        Icons.info_outline,
      ),
    };
    return Semantics(
      label: matchLabel(status),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: foreground, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                matchLabel(status),
                style: TextStyle(
                  color: foreground,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> perform(
  BuildContext context,
  Future<void> Function() action, {
  String? success,
}) async {
  try {
    await action();
    if (context.mounted && success != null) toast(context, success);
  } catch (_) {
    if (context.mounted) {
      toast(
        context,
        'Nie udało się zapisać. Twoje dane pozostają w formularzu. Spróbuj ponownie.',
      );
    }
  }
}

void toast(BuildContext context, String message) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Semantics(liveRegion: true, child: Text(message)),
        behavior: SnackBarBehavior.floating,
      ),
    );

Widget pageBody(
  List<Widget> children, {
  Key? key,
  ScrollController? controller,
}) => ListView(
  key: key,
  controller: controller,
  padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
  children: children,
);

Widget demoNotice() => const Notice(
  'Wersja demonstracyjna. Miejsca i nagrody są przykładowe.',
  icon: Icons.science_outlined,
);

AppBar adaptiveAppBar(
  BuildContext context,
  String title, {
  List<Widget>? actions,
}) {
  final style = Theme.of(context).textTheme.titleLarge!;
  final width =
      (MediaQuery.sizeOf(context).width - 96 - (actions?.length ?? 0) * 96)
          .clamp(100.0, double.infinity);
  final painter = TextPainter(
    text: TextSpan(text: title, style: style),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
  )..layout(maxWidth: width);
  final height = (painter.height + 24).clamp(64.0, double.infinity);
  final lines = painter.computeLineMetrics().length;
  painter.dispose();
  return AppBar(
    toolbarHeight: height,
    title: Text(
      title,
      softWrap: true,
      maxLines: lines,
      overflow: TextOverflow.visible,
      style: style,
    ),
    actions: actions,
  );
}
