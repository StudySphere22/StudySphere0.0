import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/Dashboard/Home/view/home.dart';
import 'package:reedinook/utils/custom_snackbar.dart';

class LoginController extends GetxController {
  final GlobalKey<FormState> formKeylogin = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  RxBool isLoading = false.obs;

  Future<void> login(BuildContext context, int tabIndex) async {
    if (formKeylogin.currentState!.validate()) {
      isLoading.value = true; // Start loading
      try {
        try {
          // Sign in the user
          UserCredential userCredential =
              await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailController.text,
            password: passController.text,
          );

          // Fetch the user's role from Firestore
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

          if (userDoc.exists) {
            String role = userDoc['role'];

        if ((tabIndex == 0 && role == 'auth') || (tabIndex == 1 && role == 'user')) {
          String invalidRoleMessage =
              tabIndex == 0 ? "You cannot log in as a User." : "You cannot log in as an Author.";
          // _showDialog(context, "Invalid Role", invalidRoleMessage);
          customSnackbar(title: "Error", message: invalidRoleMessage);

        } else {
              // Also update the user's status in all their friends' collections
              await _updateStatusInFriendsCollection(
                  userCredential.user!.uid, 'online');
              // Allow login
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Home()),
              );
               customSnackbar(title: "Success", message: "Welcome back!");
            }
              
          }
        
        } on FirebaseAuthException catch (e) {
          print("FirebaseAuthException Code: ${e.code}");
          // if (e.code == 'user-not-found') {
          //   customSnackbar(
          //       title: "Error", message: "No user found with this email.");
          // } else if (e.code == 'wrong-password') {
          //   customSnackbar(
          //       title: "Error", message: "Invalid Email or password.");
          // } else {
            customSnackbar(
                title: "Error",
                message: "Malformed credentials. Input correct credentials.");
                //firebase error handling changed 15-sept-2023
        // }
          // else {
          //   _showDialog(context, "User Not Found", "User data not found in the database.");
          // }
        }
      } on FirebaseAuthException catch (e) {
        _showDialog(context, "Login Error", e.message ?? "An error occurred");
      } catch (e) {
        _showDialog(context, "Unexpected Error",
            "An unexpected error occurred. Please try again later.");
      }

      isLoading.value = false; // Stop loading
    }
  }

  Future<void> _updateStatusInFriendsCollection(
      String userId, String status) async {
    try {
      // Get all friends of the current user
      QuerySnapshot friendsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('friends')
          .get();

      for (var friendDoc in friendsSnapshot.docs) {
        // Update the status in each friend's collection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(friendDoc.id)
            .collection('friends')
            .doc(userId)
            .update({
          'status': status,
        });
      }
    } catch (e) {
      print('Error updating status in friends collection: $e');
    }
  }

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
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
