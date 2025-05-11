import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/Authentication/Login/view/login.dart';
import 'package:reedinook/utils/app_assets%20.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
  

    // Navigate to the login screen after a delay (e.g., 5 seconds)
    Future.delayed(const Duration(milliseconds: 5500), () {
      Get.offAll(() => const MyLogin()); // Replace with your login page
    });

    return Scaffold(
     backgroundColor: const Color(0xFF131A22),
 // Transparent background
      body: Center(
        child: SizedBox(
          width: 150, // Adjust the width as needed
          height: 150, // Adjust the height as needed
          child: Image.asset(
           AppAssets.splashScreenWhite, // GIF asset
            fit: BoxFit.cover, // Ensure the GIF fits within the box
          ),
        ),
      ),
    );
  }
}
