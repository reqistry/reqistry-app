import 'package:flutter/material.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';

class LoadingScaffold extends StatelessWidget {
  const LoadingScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Scaffold(
      backgroundColor: c.background,
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
