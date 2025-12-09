import 'package:flutter/material.dart';
import 'package:public_apis_desktop_client/app/utils/snackbar_helper.dart';

class BookmarkPageIcon extends StatelessWidget {
  const BookmarkPageIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          onPressed: () {
            AppSnackbar.show(
              title: 'Favorites',
              message: 'Favorites are currently empty.',
            );
          },
          icon: const Icon(
            Icons.bookmarks,
          ),
        ),
        Positioned(
          top: 10,
          left: 5,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 15,
                height: 15,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
                child: const Center(
                  child: Text(
                    '0',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
