import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:api_scout/app/blocs/auth/auth_cubit.dart';
import 'package:api_scout/app/blocs/auth/auth_state.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/app/modules/views/auth/widgets/loading_scaffold.dart';
import 'package:api_scout/app/modules/views/auth/widgets/onboarding_scaffold.dart';

class AuthViewBody extends StatelessWidget {
  const AuthViewBody({super.key, this.returnTo});

  final String? returnTo;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          AppSnackBarHelper.error(title: 'ERROR', message: state.message);
        }
        if (state is Authenticated) {
          final destination = returnTo;
          context.go(
            destination != null && destination.startsWith('/')
                ? destination
                : AppRoutes.home,
          );
        }
      },
      builder: (context, state) {
        if (state is AuthInitial ||
            state is AuthLoading ||
            state is Authenticated) {
          return const LoadingScaffold();
        }
        return const OnboardingScaffold();
      },
    );
  }
}
