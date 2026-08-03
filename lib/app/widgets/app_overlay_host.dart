import 'package:flutter/material.dart';

import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/widgets/app_busy_overlay.dart';
import 'package:api_scout/app/widgets/app_snackbar.dart';

class AppOverlayHost extends StatelessWidget {
  const AppOverlayHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        child,
        ValueListenableBuilder<bool>(
          valueListenable: AppBusyOverlay.visible,
          builder: (context, visible, _) {
            return Positioned(
              top: safeTop + AppSpacing.s12,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 160),
                    child: visible
                        ? const AppBusyIndicator(key: ValueKey('busy'))
                        : const SizedBox.shrink(key: ValueKey('idle')),
                  ),
                ),
              ),
            );
          },
        ),
        ValueListenableBuilder<AppSnackbarPayload?>(
          valueListenable: AppSnackbarManager.payload,
          builder: (context, payload, _) {
            if (payload == null) return const SizedBox.shrink();
            final width = MediaQuery.of(context).size.width;
            final desktop = width > 600;
            return Positioned(
              top: safeTop + AppSpacing.s56,
              left: desktop ? null : AppSpacing.s16,
              right: AppSpacing.s16,
              child: AppSnackbar(
                key: ValueKey(payload.id),
                title: payload.title,
                message: payload.message,
                type: payload.type,
                duration: payload.duration,
                actionLabel: payload.actionLabel,
                onAction: payload.onAction,
                persistent: payload.persistent,
                onDismiss: AppSnackbarManager().dismiss,
              ),
            );
          },
        ),
      ],
    );
  }
}
