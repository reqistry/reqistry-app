import 'package:flutter/material.dart';
import 'package:api_scout/app/modules/views/auth/widgets/auth_view_body.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key, this.returnTo});

  final String? returnTo;

  @override
  Widget build(BuildContext context) {
    return AuthViewBody(returnTo: returnTo);
  }
}
