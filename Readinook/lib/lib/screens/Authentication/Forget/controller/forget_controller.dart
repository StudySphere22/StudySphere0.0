import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';




class ForgetPasswordController extends GetxController {
  
  final TextEditingController forgetController = TextEditingController();
  final GlobalKey<FormState> formKeyforget = GlobalKey<FormState>();
var isLoading = false.obs;

  

   Future<void> sendPasswordResetEmail(BuildContext context) async {
    if (formKeyforget.currentState!.validate()) {
      var forgotEmail = forgetController.text.trim();
    
      isLoading.value = true;

      // Check if the email exists in Firestore 'users' collection
      var userSnapshot = await FirebaseFirestore.instance
          .collection('users') // Ensure the collection name is correct
          .where('email', isEqualTo: forgotEmail)

          .get();

      if (userSnapshot.docs.isEmpty) {
        // Show error dialog if email is not found
            isLoading.value = false;
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("No Account Found"),
              content: const Text("No account found for this email. Please check the email address or register a new account."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        try {
          // If email is found in Firestore, proceed to send the reset email
          await FirebaseAuth.instance.sendPasswordResetEmail(email: forgotEmail);
              isLoading.value = false;

          // Show success dialog
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Email Sent!"),
                content: Text("A password reset email has been sent to $forgotEmail."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      forgetController.clear();
                      Get.offAllNamed('login'); // Redirect to login screen
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
        } on FirebaseAuthException catch (e) {
          // Handle any errors from Firebase Authentication
             isLoading.value = false;
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Error"),
                content: Text("Failed to send email: ${e.message}"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
        }
      }
    }
     @override
  void onClose() {
    super.onClose();
    forgetController.dispose();
  }
   }
}