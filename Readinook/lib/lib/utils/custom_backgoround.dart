import 'package:flutter/material.dart';
import 'package:reedinook/utils/colors.dart';

class CustomBackground extends StatelessWidget {
  const CustomBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          // color: const Color(0xFF131A22), // Full screen background color (cut part)
          height: MediaQuery.of(context).size.height, // Full screen height
          width: MediaQuery.of(context).size.width, // Full screen width
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.13, // 20% cut from the top
          child: Container(
            // Remove color here, move it to decoration
            decoration: const BoxDecoration(
              color: AppColor.bgcolor, // Background color for the remaining 80%
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), // Top-left corner radius
                topRight: Radius.circular(25), // Top-right corner radius
              ),
            ),
            height: MediaQuery.of(context).size.height , // Cover the bottom 80% of the screen
            width: MediaQuery.of(context).size.width, // Full screen width
          ),
        ),
      ],
    );
  }
}
