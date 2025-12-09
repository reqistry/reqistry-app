import 'package:flutter/material.dart';

class FavoritesCounter extends StatelessWidget {
  const FavoritesCounter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '0',
        style: TextStyle(
          fontFamily: 'Roboto',
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
