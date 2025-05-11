import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reedinook/utils/colors.dart';

void customSnackbar({
  required String title,
  required String message,
}) {
  // Determine the color for the title based on its value
  Color titleColor = title == 'Success' ? AppColor.clickedbutton : Colors.red;

  // Show the snackbar with default styling
  Get.snackbar(
    title, // Snackbar title
    message, // Snackbar message
    backgroundColor: Colors.black.withOpacity(0.7), // Dark background
    colorText: AppColor.white, // White text color for title and message
    duration: const Duration(seconds: 3), // Duration for snackbar visibility
    snackPosition: SnackPosition.TOP, // Snackbar position
    icon: Icon(
      title == 'Success' ? Icons.check_circle : Icons.error,
      color: AppColor.clickedbutton, // Icon color
    ),
    borderRadius: 10, // Rounded corners
    margin: const EdgeInsets.all(10), // Margin around the snackbar
    isDismissible: true, // Make it dismissible
    animationDuration: const Duration(milliseconds: 300), // Animation duration
    forwardAnimationCurve: Curves.easeOutBack, // Animation curve for showing
    titleText: Text(
      title,
      style: TextStyle(
        fontSize: 16,
        color: titleColor, // Conditional color for title
        fontWeight: FontWeight.bold,
      ),
    ),
    messageText: Text(
      message,
      style: const TextStyle(
        fontSize: 14,
        color: AppColor.white, // Color for message text
      ),
    ),
  );
}
