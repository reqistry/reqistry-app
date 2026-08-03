import 'package:flutter/material.dart';
import 'package:api_scout/app/modules/views/general/loading/spin_kit.dart';

class LoadingWidget extends StatelessWidget {
  final double? height;
  final bool isSliverChild;
  final double spinnerSize;

  const LoadingWidget({
    super.key,
    this.height,
    this.isSliverChild = true,
    this.spinnerSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    return isSliverChild
        ? SliverToBoxAdapter(
            child: SizedBox(
              height: height,
              child: Center(
                child: SpinKit(size: spinnerSize),
              ),
            ),
          )
        : SizedBox(
            height: height,
            child: Center(
              child: SpinKit(size: spinnerSize),
            ),
          );
  }
}
