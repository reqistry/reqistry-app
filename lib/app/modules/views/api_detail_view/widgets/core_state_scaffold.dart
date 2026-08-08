import 'package:flutter/material.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/shared/widgets/app_error_state.dart';

class CoreStateScaffold extends StatelessWidget {
  const CoreStateScaffold({
    super.key,
    required this.isLoading,
    required this.message,
    required this.onRetry,
  });

  final bool isLoading;
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Scaffold(
      backgroundColor: c.background,
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(pinned: true),
          SliverFillRemaining(
            hasScrollBody: false,
            child: isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : AppErrorState(
                    title: 'API unavailable',
                    message: message ?? 'Failed to load this API',
                    onRetry: onRetry,
                  ),
          ),
        ],
      ),
    );
  }
}
