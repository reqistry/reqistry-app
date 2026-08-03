import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_shadows.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

enum AppSnackbarType { success, error, inform, info }

class AppSnackbarPayload {
  final int id;
  final String title;
  final String message;
  final AppSnackbarType type;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool persistent;

  const AppSnackbarPayload({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.duration,
    this.actionLabel,
    this.onAction,
    this.persistent = false,
  });
}

class AppSnackbar extends StatefulWidget {
  final String title;
  final String message;
  final AppSnackbarType type;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool persistent;
  final VoidCallback? onDismiss;

  const AppSnackbar({
    super.key,
    required this.title,
    required this.message,
    this.type = AppSnackbarType.inform,
    required this.duration,
    this.actionLabel,
    this.onAction,
    this.persistent = false,
    this.onDismiss,
  });

  @override
  State<AppSnackbar> createState() => _AppSnackbarState();
}

class _AppSnackbarState extends State<AppSnackbar>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _progressController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
    _progressController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void dismiss() {
    if (_controller.status == AnimationStatus.reverse) return;
    _controller.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  Color get _bgColor {
    switch (widget.type) {
      case AppSnackbarType.success:
        return AppColors.successBg;
      case AppSnackbarType.error:
        return AppColors.dangerBg;
      case AppSnackbarType.inform:
      case AppSnackbarType.info:
        return AppColors.infoBg;
    }
  }

  Color get _iconColor {
    switch (widget.type) {
      case AppSnackbarType.success:
        return AppColors.success;
      case AppSnackbarType.error:
        return AppColors.danger;
      case AppSnackbarType.inform:
      case AppSnackbarType.info:
        return AppColors.info;
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case AppSnackbarType.success:
        return PhosphorIconsRegular.checkCircle;
      case AppSnackbarType.error:
        return PhosphorIconsRegular.warningCircle;
      case AppSnackbarType.inform:
      case AppSnackbarType.info:
        return PhosphorIconsRegular.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.horizontal,
          confirmDismiss: (_) async {
            dismiss();
            return false;
          },
          child: Container(
            width: 380,
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 32,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: _iconColor, width: 1),
              boxShadow: AppShadows.modal,
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                    vertical: AppSpacing.s12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        color: _bgColor,
                        child: Icon(_icon, color: _iconColor, size: 16),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyMd.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s2),
                            Text(
                              widget.message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      if (widget.actionLabel != null) ...[
                        GestureDetector(
                          onTap: () {
                            widget.onAction?.call();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.s8,
                              vertical: AppSpacing.s4,
                            ),
                            child: Text(
                              widget.actionLabel!,
                              style: AppTextStyles.labelSmUpper.copyWith(
                                color: _iconColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s4),
                      ],
                      GestureDetector(
                        onTap: dismiss,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.s2),
                          child: Icon(
                            PhosphorIconsRegular.x,
                            size: 16,
                            color: AppColors.outline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!widget.persistent)
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, _) {
                      return LinearProgressIndicator(
                        value: 1 - _progressController.value,
                        minHeight: 3,
                        backgroundColor: AppColors.surfaceContainer,
                        valueColor: AlwaysStoppedAnimation<Color>(_iconColor),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppSnackbarManager {
  static final AppSnackbarManager _instance = AppSnackbarManager._();
  AppSnackbarManager._();
  factory AppSnackbarManager() => _instance;

  static final ValueNotifier<AppSnackbarPayload?> payload = ValueNotifier(null);
  static Timer? _dismissTimer;
  static int _nextId = 0;

  void show({
    required BuildContext context,
    required String title,
    required String message,
    AppSnackbarType type = AppSnackbarType.inform,
    Duration? duration,
    String overlayKey = 'global',
    String? actionLabel,
    VoidCallback? onAction,
    bool persistent = false,
  }) {
    _show(
      title: title,
      message: message,
      type: type,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
      persistent: persistent,
    );
  }

  void dismiss({String overlayKey = 'global'}) {
    _dismiss();
  }

  static void showSnackbar({
    required BuildContext context,
    required String title,
    required String message,
    AppSnackbarType type = AppSnackbarType.inform,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
    bool persistent = false,
  }) {
    AppSnackbarManager().show(
      context: context,
      title: title,
      message: message,
      type: type,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
      persistent: persistent,
    );
  }

  static void showGlobal({
    required String title,
    required String message,
    AppSnackbarType type = AppSnackbarType.inform,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
    bool persistent = false,
  }) {
    _show(
      title: title,
      message: message,
      type: type,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
      persistent: persistent,
    );
  }

  static void success({required String title, required String message}) {
    showGlobal(title: title, message: message, type: AppSnackbarType.success);
  }

  static void info({required String title, required String message}) {
    inform(title: title, message: message);
  }

  static void inform({required String title, required String message}) {
    showGlobal(title: title, message: message, type: AppSnackbarType.inform);
  }

  static void error({required String title, required String message}) {
    showGlobal(title: title, message: message, type: AppSnackbarType.error);
  }

  static void dismissGlobal() {
    _dismiss();
  }

  static void _show({
    required String title,
    required String message,
    required AppSnackbarType type,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
    bool persistent = false,
  }) {
    _dismissTimer?.cancel();
    final hideAfter = duration ??
        (type == AppSnackbarType.error
            ? const Duration(seconds: 5)
            : const Duration(seconds: 3));
    payload.value = AppSnackbarPayload(
      id: _nextId++,
      title: title,
      message: message,
      type: type,
      duration: persistent ? const Duration(days: 1) : hideAfter,
      actionLabel: actionLabel,
      onAction: onAction,
      persistent: persistent,
    );
    if (!persistent) {
      _dismissTimer = Timer(hideAfter, _dismiss);
    }
  }

  static void _dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    payload.value = null;
  }
}
