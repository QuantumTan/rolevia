import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Semantic icons enum mapping to Cupertino icons on iOS and Material symbols on Android
enum AppSemanticIcon {
  search,
  home,
  discover,
  bookmark,
  bookmarkFilled,
  profile,
  settings,
  share,
  edit,
  delete,
  close,
  back,
  forward,
  filter,
  sort,
  more,
  document,
  briefcase,
  location,
  notification,
  check,
  add,
  match,
  tracker,
  dashboard,
  copy,
  eye,
  eyeOff,
  calendar,
  error,
  info,
  reset,
  science,
}

class AppIcons {
  const AppIcons._();

  static IconData resolve(
    AppSemanticIcon semantic,
    BuildContext context, {
    bool filled = false,
  }) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return isIOS ? _iosIcon(semantic, filled) : _androidIcon(semantic, filled);
  }

  static IconData _iosIcon(AppSemanticIcon semantic, bool filled) {
    switch (semantic) {
      case AppSemanticIcon.search:
        return CupertinoIcons.search;
      case AppSemanticIcon.home:
        return filled ? CupertinoIcons.house_fill : CupertinoIcons.house;
      case AppSemanticIcon.discover:
        return filled ? CupertinoIcons.compass_fill : CupertinoIcons.compass;
      case AppSemanticIcon.bookmark:
        return CupertinoIcons.bookmark;
      case AppSemanticIcon.bookmarkFilled:
        return CupertinoIcons.bookmark_fill;
      case AppSemanticIcon.profile:
        return filled
            ? CupertinoIcons.person_crop_circle_fill
            : CupertinoIcons.person_crop_circle;
      case AppSemanticIcon.settings:
        return filled ? CupertinoIcons.gear_alt_fill : CupertinoIcons.gear_alt;
      case AppSemanticIcon.share:
        return CupertinoIcons.share;
      case AppSemanticIcon.edit:
        return CupertinoIcons.pencil;
      case AppSemanticIcon.delete:
        return CupertinoIcons.trash;
      case AppSemanticIcon.close:
        return CupertinoIcons.xmark;
      case AppSemanticIcon.back:
        return CupertinoIcons.back;
      case AppSemanticIcon.forward:
        return CupertinoIcons.forward;
      case AppSemanticIcon.filter:
        return CupertinoIcons.slider_horizontal_3;
      case AppSemanticIcon.sort:
        return CupertinoIcons.arrow_up_arrow_down;
      case AppSemanticIcon.more:
        return CupertinoIcons.ellipsis;
      case AppSemanticIcon.document:
        return filled ? CupertinoIcons.doc_text_fill : CupertinoIcons.doc_text;
      case AppSemanticIcon.briefcase:
        return filled
            ? CupertinoIcons.briefcase_fill
            : CupertinoIcons.briefcase;
      case AppSemanticIcon.location:
        return filled ? CupertinoIcons.location_fill : CupertinoIcons.location;
      case AppSemanticIcon.notification:
        return filled ? CupertinoIcons.bell_fill : CupertinoIcons.bell;
      case AppSemanticIcon.check:
        return CupertinoIcons.checkmark;
      case AppSemanticIcon.add:
        return CupertinoIcons.plus;
      case AppSemanticIcon.match:
        return CupertinoIcons.arrow_right_arrow_left;
      case AppSemanticIcon.tracker:
        return filled
            ? CupertinoIcons.square_grid_2x2_fill
            : CupertinoIcons.square_grid_2x2;
      case AppSemanticIcon.dashboard:
        return filled
            ? CupertinoIcons.chart_bar_alt_fill
            : CupertinoIcons.chart_bar;
      case AppSemanticIcon.copy:
        return CupertinoIcons.doc_on_doc;
      case AppSemanticIcon.eye:
        return CupertinoIcons.eye;
      case AppSemanticIcon.eyeOff:
        return CupertinoIcons.eye_slash;
      case AppSemanticIcon.calendar:
        return CupertinoIcons.calendar;
      case AppSemanticIcon.error:
        return CupertinoIcons.exclamationmark_circle;
      case AppSemanticIcon.info:
        return CupertinoIcons.info_circle;
      case AppSemanticIcon.reset:
        return CupertinoIcons.arrow_counterclockwise;
      case AppSemanticIcon.science:
        return CupertinoIcons.lab_flask;
    }
  }

  static IconData _androidIcon(AppSemanticIcon semantic, bool filled) {
    switch (semantic) {
      case AppSemanticIcon.search:
        return Icons.search;
      case AppSemanticIcon.home:
        return filled ? Icons.home : Icons.home_outlined;
      case AppSemanticIcon.discover:
        return filled ? Icons.explore : Icons.explore_outlined;
      case AppSemanticIcon.bookmark:
        return Icons.bookmark_outline;
      case AppSemanticIcon.bookmarkFilled:
        return Icons.bookmark;
      case AppSemanticIcon.profile:
        return filled ? Icons.account_circle : Icons.account_circle_outlined;
      case AppSemanticIcon.settings:
        return filled ? Icons.settings : Icons.settings_outlined;
      case AppSemanticIcon.share:
        return Icons.share_outlined;
      case AppSemanticIcon.edit:
        return Icons.edit_outlined;
      case AppSemanticIcon.delete:
        return Icons.delete_outline;
      case AppSemanticIcon.close:
        return Icons.close;
      case AppSemanticIcon.back:
        return Icons.arrow_back;
      case AppSemanticIcon.forward:
        return Icons.arrow_forward;
      case AppSemanticIcon.filter:
        return Icons.tune;
      case AppSemanticIcon.sort:
        return Icons.sort;
      case AppSemanticIcon.more:
        return Icons.more_vert;
      case AppSemanticIcon.document:
        return filled ? Icons.description : Icons.description_outlined;
      case AppSemanticIcon.briefcase:
        return filled ? Icons.work : Icons.work_outline;
      case AppSemanticIcon.location:
        return filled ? Icons.place : Icons.place_outlined;
      case AppSemanticIcon.notification:
        return filled ? Icons.notifications : Icons.notifications_outlined;
      case AppSemanticIcon.check:
        return Icons.check;
      case AppSemanticIcon.add:
        return Icons.add;
      case AppSemanticIcon.match:
        return Icons.compare_arrows;
      case AppSemanticIcon.tracker:
        return filled ? Icons.view_kanban : Icons.view_kanban_outlined;
      case AppSemanticIcon.dashboard:
        return filled ? Icons.space_dashboard : Icons.space_dashboard_outlined;
      case AppSemanticIcon.copy:
        return Icons.copy_outlined;
      case AppSemanticIcon.eye:
        return Icons.visibility_outlined;
      case AppSemanticIcon.eyeOff:
        return Icons.visibility_off_outlined;
      case AppSemanticIcon.calendar:
        return Icons.event_outlined;
      case AppSemanticIcon.error:
        return Icons.error_outline;
      case AppSemanticIcon.info:
        return Icons.info_outline;
      case AppSemanticIcon.reset:
        return Icons.restart_alt;
      case AppSemanticIcon.science:
        return Icons.science_outlined;
    }
  }
}

class AppIcon extends StatelessWidget {
  const AppIcon(
    this.icon, {
    super.key,
    this.size = 20,
    this.color,
    this.filled = false,
  });

  final AppSemanticIcon icon;
  final double size;
  final Color? color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Icon(
      AppIcons.resolve(icon, context, filled: filled),
      size: size,
      color: color,
    );
  }
}
