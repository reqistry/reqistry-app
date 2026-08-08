import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/shared/widgets/app_empty_state.dart';
import 'package:api_scout/shared/widgets/app_error_state.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';

class AsyncStateHandler extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final bool isEmpty;
  final Widget child;
  final String loadingMessage;
  final String errorTitle;
  final String emptyTitle;
  final String emptyMessage;
  final IconData emptyIcon;
  final VoidCallback? onRetry;

  const AsyncStateHandler({
    super.key,
    required this.isLoading,
    this.errorMessage,
    required this.isEmpty,
    required this.child,
    this.loadingMessage = 'Loading...',
    this.errorTitle = 'Something went wrong',
    required this.emptyTitle,
    required this.emptyMessage,
    this.emptyIcon = PhosphorIconsRegular.bracketsCurly,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return AppLoading(
        message: loadingMessage,
        compact: true,
      );
    }

    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return AppErrorState(
        title: errorTitle,
        message: errorMessage!,
        onRetry: onRetry,
        compact: true,
      );
    }

    if (isEmpty) {
      return AppEmptyState(
        title: emptyTitle,
        message: emptyMessage,
        icon: emptyIcon,
        compact: true,
      );
    }

    return child;
  }
}
