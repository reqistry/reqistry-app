import 'package:flutter/material.dart';

void dismissTextInputRoute<T extends Object?>(
  BuildContext context, [
  T? result,
]) {
  FocusManager.instance.primaryFocus?.unfocus();
  Navigator.of(context).pop<T>(result);
}
