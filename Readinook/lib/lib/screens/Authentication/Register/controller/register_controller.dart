import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:reedinook/screens/Authentication/Register/view/component/otp.dart';
import 'package:reedinook/utils/custom_snackbar.dart';


class RegistrationController extends GetxController {
  final GlobalKey<FormState> formKeyRegister = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController linkcontroller= TextEditingController();
 

RxBool isLoading =  false.obs;
 final RxString generatedOtp = ''.obs; // Observable for OTP
  // Function to generate a 4-digit OTP
  String generateSecureOtp() { 
    final random = Random();
    return (random.nextInt(9000) + 1000).toString(); // Generates a 4-digit OTP
  }

  // Step 1: Check if username exists
  Future<void> checkUsernameAndSendOtp(BuildContext context) async {
    isLoading.value = true;

    // Validate the form first
    if (formKeyRegister.currentState!.validate()) {
      try {
        final querySnapshot = await _firestore
            .collection('users')
            .where('username', isEqualTo: userNameController.text)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Username already exists
          _showDialog(context, "Registration Failed", "Username already exists. Please choose a different one.");
          isLoading.value = false;
          return;
        }

         final querySnapshots = await _firestore
            .collection('users')
            .where('email', isEqualTo: emailController.text)
            .get();

        if (querySnapshots.docs.isNotEmpty) {
          // Username already exists
          _showDialog(context, "Registration Failed", "Email already exists. Please choose a different one.");
          isLoading.value = false;
          return;
        }

         if (roleController.text == 'auth')  {
         bool isReachable = await isValidUrl(linkcontroller.text);

    if (!isReachable) {
      customSnackbar(title: "Invalid URL", message: "This URL is not reachable.");
      return;
    }
        }

        // Username is available; proceed to send OTP
        await sendOtp();
      } catch (e) {
        _showDialog(context, "Error", "An error occurred while checking username. Please try again.");
      } finally {
        isLoading.value = false;
      }
    } else {
      isLoading.value = false;
    }
  }

  // Step 2: Send OTP
  Future<void> sendOtp() async {
   String otp = generateSecureOtp();
    generatedOtp.value = otp; // Update OTP using GetX

      isLoading.value = true;
    // Send the OTP via email
    await sendOtpEmail(emailController.text, otp);

     // Hide loading dialog
       isLoading.value = false;

    // Show a snackbar message
    customSnackbar(title: "Success", message: "Please check your email for the OTP.");

    // Navigate to the OTP screen, passing the generated OTP
    Get.to(() => const EmailOtpScreen());

  }

  // Function to send OTP via email
  Future<void> sendOtpEmail(String recipientEmail, String otp) async {
    final smtpServer = gmail('readinook.app@gmail.com', 'sjow yedp okro osmy'); // Update with correct credentials

    final message = Message()
      ..from = const Address('readinook.app@gmail.com', 'Readinook') // Update with correct details
      ..recipients.add(recipientEmail)
      ..subject = 'Your OTP Code'
      ..text = 'Your OTP code is: $otp';


    try {
      await send(message, smtpServer);
    } on MailerException catch (e) {
      print('Failed to send OTP: $e');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

Future<void> registerUser(BuildContext context) async {
  isLoading.value = true;

  try {
    // Create user with email and password
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    );

    // Determine the role (if roleController is empty, default to 'user')
    String role = roleController.text.isNotEmpty ? roleController.text : 'user';

    // Prepare user data
    Map<String, dynamic> userData = {
      'username': userNameController.text,
      'email': emailController.text,
      'profilePicUrl': '',
      'role': role, // Store the selected role (either 'user' or 'auth')
    };

    // Add 'link' if the role is 'auth'
    if (role == 'auth') {
      userData['link'] = linkcontroller.text; // Only add link for 'auth' role
    } else {
      // Remove the link field if the role is not 'auth'
      userData.remove('link');
    }

    // Store user data in Firestore
    await _firestore.collection('users').doc(userCredential.user!.uid).set(userData);

    // Clear fields after registration
    userNameController.clear();
    emailController.clear();
    passwordController.clear();
    otpController.clear();
    linkcontroller.clear(); // Clear the link field
    roleController.clear(); // Clear the link field

    // Show success message
    customSnackbar(title: "Registration Successful", message: "You have successfully registered.");
    Get.offAllNamed('login');  // Navigate to the login screen
  } on FirebaseAuthException catch (e) {
    String message;
    if (e.code == 'weak-password') {
      message = "Provided password is too weak";
    } else if (e.code == 'email-already-in-use') {
      message = "Email is already in use";
    } else {
      message = "An error occurred during registration";
    }

    customSnackbar(title: "Success",message:  message);
  } finally {
    isLoading.value = false;
  }
}



  // Helper function to show dialogs
  void _showDialog(BuildContext? context, String title, String message) {
    showDialog(
      context: context!,
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

    // Function to check if URL is reachable
  Future<bool> isValidUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      // If the status code is 200, it's a valid URL
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('Error: $e');
    }
    return false;
  }

}
