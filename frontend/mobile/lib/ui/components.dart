import 'package:flutter/material.dart';

import 'graphics.dart';

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
  const Notice(this.text, {super.key, this.icon, this.color});
  final String text;
  final IconData? icon;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final error = icon == Icons.error_outline;
    final warning = icon == Icons.warning_amber;
    final success = icon == Icons.check_circle_outline;
    final background =
        color ??
        (error
            ? scheme.errorContainer
            : warning
            ? scheme.tertiaryContainer
            : success
            ? scheme.primaryContainer
            : scheme.surfaceContainerHigh);
    final foreground = color != null
        ? scheme.onSurface
        : error
        ? scheme.onErrorContainer
        : warning
        ? scheme.onTertiaryContainer
        : success
        ? scheme.onPrimaryContainer
        : scheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: error ? scheme.error : scheme.outline),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            KindSpotSymbol(icon, size: 24, color: foreground),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: foreground, fontSize: 16, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
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
            KindSpotSymbol(icon, color: foreground, size: 18),
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
