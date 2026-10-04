import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'graphics_catalog.dart';

/// Preserves Icon's semantics and sizing while using the themed SVG where known.
class KindSpotSymbol extends Icon {
  const KindSpotSymbol(
    super.icon, {
    super.key,
    super.size,
    super.color,
    super.semanticLabel,
    this.filled = false,
    super.textDirection,
  });

  final bool filled;

  static final _ids = <IconData, String>{
    Icons.map_outlined: 'nav_map',
    Icons.map: 'nav_map',
    Icons.bookmark_outline: 'nav_saved',
    Icons.bookmark: 'nav_saved_filled',
    Icons.redeem_outlined: 'nav_rewards',
    Icons.tune: 'nav_filters',
    Icons.person_outline: 'nav_profile',
    Icons.search: 'search',
    Icons.clear: 'close',
    Icons.close: 'close',
    Icons.add: 'add',
    Icons.remove: 'remove',
    Icons.chevron_right: 'forward',
    Icons.chevron_left: 'back',
    Icons.expand_more: 'chevron_down',
    Icons.expand_less: 'chevron_up',
    Icons.delete_outline: 'delete',
    Icons.edit_outlined: 'edit',
    Icons.refresh: 'refresh',
    Icons.settings: 'settings',
    Icons.settings_outlined: 'settings',
    Icons.info_outline: 'status_info',
    Icons.error_outline: 'status_error',
    Icons.help_outline: 'unknown',
    Icons.warning_amber: 'status_warning',
    Icons.check_circle_outline: 'status_success',
    Icons.cancel_outlined: 'status_error',
    Icons.history: 'history',
    Icons.hourglass_empty: 'status_pending',
    Icons.pending_outlined: 'status_pending',
    Icons.science_outlined: 'demo',
    Icons.accessibility_new: 'accessibility',
    Icons.palette_outlined: 'palette',
    Icons.manage_accounts_outlined: 'account_settings',
    Icons.my_location: 'recenter',
    Icons.location_on_outlined: 'map_pin',
    Icons.location_on: 'map_pin_selected',
    Icons.format_list_bulleted: 'view_list',
    Icons.near_me_outlined: 'places_nearby',
    Icons.explore_outlined: 'current_location',
    Icons.place_outlined: 'map_pin',
    Icons.park_outlined: 'category_park',
    Icons.local_library_outlined: 'category_library',
    Icons.arrow_forward: 'forward',
    Icons.rate_review_outlined: 'review_add',
    Icons.public_off: 'hidden',
    Icons.stars_outlined: 'points',
    Icons.menu_book_outlined: 'view_list',
    Icons.lock_outline: 'private',
    Icons.visibility_outlined: 'password_show',
    Icons.visibility_off_outlined: 'password_hide',
    Icons.star: 'star_filled',
    Icons.star_outline: 'star_outline',
    Icons.thumb_up_outlined: 'thumb_up',
    Icons.thumb_down_outlined: 'thumb_down',
    Icons.flag_outlined: 'report',
    Icons.content_copy: 'copy',
    Icons.logout: 'logout',
    Icons.light_mode_outlined: 'theme_light',
    Icons.dark_mode_outlined: 'theme_dark',
    Icons.search_off: 'search',
  };

  @override
  Widget build(BuildContext context) {
    final id = _ids[icon];
    if (id == null) return super.build(context);
    final theme = IconTheme.of(context);
    final resolved =
        color ?? theme.color ?? Theme.of(context).colorScheme.onSurface;
    final dimension = size ?? theme.size ?? 24;
    return SvgPicture.asset(
      kindSpotGraphics[filled && kindSpotGraphics.containsKey('${id}_filled')
          ? '${id}_filled'
          : id]!,
      width: dimension,
      height: dimension,
      colorFilter: ColorFilter.mode(
        resolved.withValues(alpha: resolved.a * (theme.opacity ?? 1)),
        BlendMode.srcIn,
      ),
      semanticsLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
    );
  }
}

class KindSpotGraphic extends StatelessWidget {
  const KindSpotGraphic(
    this.id, {
    super.key,
    this.width,
    this.height,
    this.label,
    this.calm = false,
    this.monochrome = false,
  });
  final String id;
  final double? width, height;
  final String? label;
  final bool calm, monochrome;

  @override
  Widget build(BuildContext context) {
    final quiet =
        calm ||
        MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context);
    final candidate = monochrome
        ? '${id}_mono'
        : quiet
        ? '${id}_calm'
        : id;
    final resolved = kindSpotGraphics.containsKey(candidate) ? candidate : id;
    return SvgPicture.asset(
      kindSpotGraphics[resolved]!,
      width: width,
      height: height,
      colorMapper: KindSpotPalette(Theme.of(context).colorScheme),
      semanticsLabel: label,
      excludeFromSemantics: label == null,
    );
  }
}

/// Placeholder colours identify palette roles, never product accents.
class KindSpotPalette extends ColorMapper {
  const KindSpotPalette(this.scheme);
  final ColorScheme scheme;
  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) => switch (color.toARGB32()) {
    0xFF112233 => scheme.onSurface,
    0xFF445566 => scheme.primary,
    0xFF778899 => scheme.primaryContainer,
    0xFFAABBCC => scheme.surface,
    0xFFDDEEFF => scheme.outline,
    0xFF000000 => scheme.onSurface,
    _ => color,
  };
}

/// Shared reviewed feature assets, including canonical backend aliases.
class KindSpotFeatureIcon extends StatelessWidget {
  const KindSpotFeatureIcon(this.featureId, {super.key, this.size = 40});
  final String featureId;
  final double size;
  static const ids = <String, String>{
    'step_free_entrance': 'feature_step_free_entrance',
    'ramp': 'feature_ramp',
    'lift': 'feature_lift',
    'elevator': 'feature_lift',
    'accessible_toilet': 'feature_accessible_toilet',
    'rest': 'feature_rest',
    'quiet': 'feature_quiet',
    'quiet_environment': 'feature_quiet',
    'low_crowd': 'feature_low_crowd',
    'gentle_light': 'feature_gentle_light',
    'guide_dog': 'feature_guide_dog',
    'orientation': 'feature_orientation',
    'hearing_loop': 'feature_hearing_loop',
    'easy_controls': 'feature_easy_controls',
  };
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: KindSpotGraphic(
      ids[featureId] ?? 'unknown',
      width: size,
      height: size,
      monochrome: true,
    ),
  );
}
