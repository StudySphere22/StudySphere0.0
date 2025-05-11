import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reedinook/screens/Dashboard/Home/controller/home_controller.dart';
import 'package:reedinook/screens/Dashboard/Profiles/my_profile/view/component/change_password/controller/change_password_controller.dart';
import 'package:reedinook/screens/Dashboard/Profiles/my_profile/view/component/change_password/view/change_password.dart';
import 'package:reedinook/screens/Dashboard/Profiles/my_profile/view/component/edit_profile/controller/edit_profile_controller.dart';
import 'package:reedinook/utils/colors.dart';
import 'package:reedinook/utils/custom_loading_indicator.dart';
import 'package:reedinook/utils/custom_snackbar.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final EditProfileController editProfileController =
      Get.put(EditProfileController());
  final HomeController homeController =
      Get.find<HomeController>(); // Using existing HomeController

  @override
  void initState() {
    super.initState();

    // Set initial values from homeController into edit profile fields
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Assign the values after the first frame to avoid build conflicts
      editProfileController.fullNameController.text = homeController.username;
      editProfileController.emailController.text = homeController.email;
      editProfileController.aboutController.text = homeController.about;
      editProfileController.setInitialValues(
          homeController.username, homeController.email, homeController.about);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgcolor,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColor.iconstext,
            fontSize: 20, // Set font size as required
            fontWeight: FontWeight.normal,
          ),
        ),
        backgroundColor: AppColor.bgcolor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColor.iconstext),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile picture section remains as is (no loading here)
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Obx(() {
                  return CircleAvatar(
                    radius: 40,
                      backgroundColor: (editProfileController
                                .profilePicUrl.value.isEmpty)
                            ? AppColor
                                .iconstext // Replace with your desired background color
                            : Colors.transparent,
                    backgroundImage:
                        editProfileController.profilePicUrl.isNotEmpty
                            ? NetworkImage(
                                editProfileController.profilePicUrl.value)
                            : null,
                    child: editProfileController.profilePicUrl.isEmpty
                        ? const Icon(Icons.person, size: 40,color:  AppColor.unselected)
                        : null,
                  );
                }),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.unselected,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt,
                          color: AppColor.iconstext),
                      iconSize: 20,
                      onPressed: editProfileController.pickImage,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Display username and email
            Obx(() => Text(
                  homeController.username,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColor.white,
                  ),
                )),

            const SizedBox(height: 50),

            // Content section wrapped in a Stack to handle loading
            Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Input fields with controllers
                    TextField(
                      controller: editProfileController.fullNameController,
                      style: const TextStyle(
                        color: AppColor.white, // Set the text color here
                      ),
                      decoration: InputDecoration(
                        labelText: 'Full name',
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColor
                              .iconstext, // Optional: Set the label color if needed
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColor
                                .unselected, // Border color when enabled
                            width: 2, // Border width
                          ),
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
                      ),
                    ),

                    const SizedBox(height: 20),
                    TextField(
                      controller: editProfileController.emailController,
                      style: const TextStyle(
                        color: AppColor.white, // Set the text color here
                      ),
                      enabled: false, // Disables the TextField (non-clickable)
                      decoration: InputDecoration(
                        labelText: 'Email', // Label text will still be shown
                        labelStyle: const TextStyle(
                          fontWeight:
                              FontWeight.bold, // Make the label text bold
                          color: AppColor
                              .iconstext, // Optional: Set the label color if needed
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                         enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColor
                                .unselected, // Border color when enabled
                            width: 2, // Border width
                          ),
                        ),
                        filled: true, // This enables the fill
                        fillColor: AppColor
                            .unselected, // Set the background color to white// Background color when disabled (optional)
                      ),
                    ),

                    const SizedBox(height: 20),
                    TextField(
                      controller: editProfileController.aboutController,
                      style: const TextStyle(
                        color: AppColor.white, // Set the text color here
                      ),
                      decoration: InputDecoration(
                        labelText: 'About',
                        labelStyle: const TextStyle(
                          fontWeight:
                              FontWeight.bold, // Make the label text bold
                          color: AppColor
                              .iconstext, // Optional: Set the label color if needed
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColor.unselected,
                            width: 2,
                          ),
                        ),
                         enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColor
                                .unselected, // Border color when enabled
                            width: 2, // Border width
                          ),
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
                      ),

                      maxLines:
                          null, // This allows the TextField to expand as needed
                      keyboardType:
                          TextInputType.multiline, // Allows multiline input
                    ),
                    const SizedBox(height: 20),

                    // Change password section
                    GestureDetector(
                      onTap: () async {
                        await Get.delete<ChangePasswordController>();
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled:
                              true, // Makes the bottom sheet take up custom height
                          backgroundColor: Colors
                              .transparent, // Allow the widget's background color to show
                          builder: (context) {
                            return FractionallySizedBox(
                              heightFactor:
                                  0.8, // Takes up 80% of the screen height
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFF131A22),
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                ),
                                child:
                                    const ChangePassword(), // Change Password screen
                              ),
                            );
                          },
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Change password',
                            style: GoogleFonts.poppins(
                              color: AppColor.iconstext,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Icon(Icons.arrow_forward,
                              color: AppColor.iconstext),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Save button
                    
                    ElevatedButton(
                      onPressed: () {
                        // Check for changes before updating
                        if (editProfileController.hasChanges()) {
                          editProfileController.updateUserData();
                        } else {
                          customSnackbar(title:'Info',message:  'Nothing to update');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.clickedbutton,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(color: AppColor.white),
                      ),
                    ),
                  ],
                ),

                // Loading overlay for saving action
                Obx(() {
                  return editProfileController.isLoading.value
                      ? Positioned.fill(
                          child: Center(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.black.withOpacity(0.1),
                        alignment: Alignment.center,
                        child: const CustomLoadingIndicator(),
                      ),
                    ),
                  )
                        )
                      : const SizedBox.shrink(); // Empty when not saving
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
