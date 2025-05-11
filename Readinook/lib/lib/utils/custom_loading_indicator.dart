import 'package:flutter/material.dart';
import 'package:reedinook/utils/app_assets%20.dart';

class CustomLoadingIndicator extends StatelessWidget {
  final double width;
  final double height;

  const CustomLoadingIndicator({
    super.key,
    this.width = 100,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        AppAssets.loadingAnimationLight,
        width: width,
        height: height,
      ),
    );
  }
}
