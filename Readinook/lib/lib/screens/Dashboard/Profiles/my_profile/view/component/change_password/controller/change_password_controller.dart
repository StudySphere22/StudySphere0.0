import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/ChatList/controller/chat_lists_controller.dart';
import 'package:reedinook/screens/Dashboard/Home/view/home.dart';
import 'package:reedinook/utils/custom_snackbar.dart';


class ChangePasswordController extends GetxController {
  // Controllers for the text input
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final ChatListsController friendcontroller = Get.put(ChatListsController());
  final FirebaseAuth _auth = FirebaseAuth.instance;

    var isLoading = false.obs; // Observable for loading state
    

  
  // Function to validate the current password by re-authenticating the user
  Future<bool> validateCurrentPassword(String currentPassword) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        customSnackbar(title: 'Error',message:  'No user currently signed in.');
        return false;
      }

      // Debugging: Check if the email is null or empty
      if (currentUser.email == null || currentUser.email!.isEmpty) {
        customSnackbar(title: 'Error', message: 'Current user email is null or empty.');
        return false;
      }

  
      // print('Current User Email: ${currentUser.email}');
      // print('Current Password: $currentPassword');

      // Re-authenticate the user with current password
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser.email!, // Email should be valid
        password: currentPassword, // Ensure this is not empty
      );

      UserCredential authResult =
          await currentUser.reauthenticateWithCredential(credential);
      return authResult.user != null;
    } catch (e) {
      return false;
    }
  }

  // Function to update the new password
  Future<bool> updatePassword(String newPassword) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        customSnackbar(title: 'Error',message:  'No user currently signed in.');
        return false;
      }
      await currentUser.updatePassword(newPassword);
      customSnackbar(title: 'Success', message: 'Password updated');
      return true;
    } catch (e) {
      customSnackbar(title: 'Error',message:  'Failed to update password: ${e.toString()}');
      return false;
    }
  }

  // Main function to handle password update process
  Future<void> handleChangePassword(Null Function() param0) async {
    String currentPassword = currentPasswordController.text;
    String newPassword = newPasswordController.text;

    if (currentPassword.isEmpty) {
     customSnackbar(title: 'Error', message:  'Please enter your current password.');
      return;
    }

    if (newPassword.isEmpty) {
      customSnackbar(title: 'Error', message: 'Please enter a new password.');
      return;
    }
      isLoading.value = true; // Set loading state to true

    // Check if new password is greater than 8 characters
  if (newPassword.length <= 8) {
     isLoading.value = false; // Reset loading state
    customSnackbar(title: 'Error', message: 'New password must be more than 8 characters.');
    return;
  }
  
  

    bool isValid = await validateCurrentPassword(currentPassword);

    if (isValid) {
      bool isUpdated = await updatePassword(newPassword);
      if (isUpdated) {
        await Get.delete<ChatListsController>();
        Get.to(() => const Home());
      }
    } else {
      customSnackbar(title: 'Error', message: 'Current password is incorrect');
    }
       isLoading.value = false; // Reset loading state
  }
}
