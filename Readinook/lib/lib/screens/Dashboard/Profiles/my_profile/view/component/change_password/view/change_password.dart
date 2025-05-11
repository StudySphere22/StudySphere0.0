
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/Dashboard/Profiles/my_profile/view/component/change_password/controller/change_password_controller.dart';
import 'package:reedinook/utils/colors.dart';
import 'package:reedinook/utils/custom_loading_indicator.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  // Get the controller instance
  final ChangePasswordController _changePasswordController = Get.put(ChangePasswordController());
    bool _obscureCurrentPassword = true; // Variable to toggle password visibility
    bool _obscureNewPassword = true; // Variable to toggle password visibility

  @override
  void dispose() {
    // Dispose of controllers managed by the ChangePasswordController
    _changePasswordController.onClose();
    super.dispose();
  }

   @override
  Widget build(BuildContext context) {
    return Obx(() { // Use Obx to listen to loading state changes
      return Stack(
        children: [
          // Main content
          Container(
            padding: const EdgeInsets.all(16.0), // Padding around the content
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row for "Change Password" text and close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColor.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColor.iconstext),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the bottom sheet
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 40), // Spacing between elements

                // Current Password Field
                TextField(
                  controller: _changePasswordController.currentPasswordController,
                  obscureText: _obscureCurrentPassword,
                  style: const TextStyle(color: AppColor.white),
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColor
                              .iconstext,
                        ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColor.unselected),
                    ),
                    focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColor
                                .clickedbutton, // Border color when focused
                            width: 2, // Border width
                          ),
                        ),
                     filled: true, // This enables the fill
                        fillColor:
                            AppColor.unselected, // Set the background color to white
                            suffixIcon: IconButton(
          icon: Icon(
            _obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
            color: AppColor.iconstext,
          ),
          onPressed: () {
            // Toggle the obscure text value when the icon is clicked
            setState(() {
              _obscureCurrentPassword = !_obscureCurrentPassword;
            });
          },
        ),
                  ),
                ),
                const SizedBox(height: 30), // Spacing between fields

                // New Password Field
                TextField(
                  controller: _changePasswordController.newPasswordController,
                  obscureText: _obscureNewPassword,
                  style: const TextStyle(color: AppColor.white),
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColor
                              .iconstext,
                        ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColor.unselected),
                    ),
                    focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColor
                                .clickedbutton, // Border color when focused
                            width: 2, // Border width
                          ),
                        ),
                     filled: true, // This enables the fill
                        fillColor:
                            AppColor.unselected, // Set the background color to white
                    suffixIcon: IconButton(
          icon: Icon(
            _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
            color: AppColor.iconstext,
          ),
          onPressed: () {
            // Toggle the obscure text value when the icon is clicked
            setState(() {
              _obscureNewPassword = !_obscureNewPassword;
            });
          },
        ),
                  ),
                ),

                const SizedBox(height: 30), // Spacing between field and button

                // Save Button centered
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _changePasswordController.handleChangePassword(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.clickedbutton,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(color: AppColor.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading indicator overlay
          if (_changePasswordController.isLoading.value)
  Center(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                        alignment: Alignment.center,
                        child: const CustomLoadingIndicator(),
                      ),
                    ),
                  )


        ],
      );
    });
  }
}