import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/Authentication/Register/controller/register_controller.dart';
import 'package:reedinook/utils/colors.dart';
import 'package:reedinook/utils/custom_loading_indicator.dart';
import 'package:reedinook/utils/custom_snackbar.dart';

class EmailOtpScreen extends StatefulWidget {
  const EmailOtpScreen({
    super.key,
  });

  @override
  State<EmailOtpScreen> createState() => _EmailOtpScreenState();
}

class _EmailOtpScreenState extends State<EmailOtpScreen> {
  final RegistrationController registrationController =
      Get.put(RegistrationController());

  List<String> otp = ["", "", "", ""];
   RxBool isVerifyingOtp = false.obs; // Separate loading state for OTP verification

  Widget otpTextField(int index) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          otp[index],
          style: const TextStyle(
            fontSize: 24,
            color: AppColor.bgcolor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void handleKeypadInput(String value) {
    setState(() {
      for (int i = 0; i < otp.length; i++) {
        if (otp[i].isEmpty) {
          otp[i] = value;
          break;
        }
      }

      if (otp.every((element) => element.isNotEmpty)) {
        verifyOtp();
      }
    });
  }

  void deleteLastInput() {
    setState(() {
      for (int i = otp.length - 1; i >= 0; i--) {
        if (otp[i].isNotEmpty) {
          otp[i] = "";
          break;
        }
      }
    });
  }

  void verifyOtp() {
    String enteredOtp = otp.join();
    if (enteredOtp == registrationController.generatedOtp.value) {
       isVerifyingOtp.value = true; // Start verifying
      Get.dialog(
       const Center(
                child: CustomLoadingIndicator(), // Custom loading indicator
              ),
        barrierDismissible: false,
      );
      Future.delayed(const Duration(seconds: 2), () {
        Get.back(); // Hide the loading dialog
        customSnackbar(title: "Success", message: "OTP Verified!");
         isVerifyingOtp.value = false; // Stop verifying
        // Navigate to the next screen or perform further actions
        registrationController.registerUser(context);
      });
    } else {
      customSnackbar(title: "Error", message: "Invalid OTP. Please try again.",);
      setState(() {
        otp = ["", "", "", ""];
      });
    }
  }

  Widget buildKey(String value) {
    return InkWell(
      onTap: () => handleKeypadInput(value),
      child: Container(
        width: 70,
        height: 70,
        alignment: Alignment.center,
        child: Text(
          value,
          style: const TextStyle(fontSize: 24, color: AppColor.iconstext),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgcolor,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                const Icon(Icons.email, size: 80, color: AppColor.iconstext),
                const SizedBox(height: 20),
                const Text(
                  'Enter Verification Code',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColor.iconstext,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'OTP sent! Kindly check your Email',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  List.generate(otp.length, (index) => otpTextField(index)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive the OTP? ",
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
             TextButton(
  onPressed: () async {
    // Change the loading state when the button is pressed
    setState(() {
      registrationController.isLoading.value = true; // Start loading
    });

    // Trigger OTP resend functionality
    await registrationController.sendOtp();

    setState(() {
      registrationController.isLoading.value = false; // Stop loading
    });
  },
  child: registrationController.isLoading.value
      ? const CircularProgressIndicator() // Show loading indicator only when clicked
      : const Text(
          "RESEND OTP",
          style: TextStyle(color: AppColor.clickedbutton, fontSize: 16),
        ),
),



              ],
            ),
            const SizedBox(height: 40),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['1', '2', '3'].map(buildKey).toList(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['4', '5', '6'].map(buildKey).toList(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['7', '8', '9'].map(buildKey).toList(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(width: 70),
                    buildKey('0'),
                    InkWell(
                      onTap: deleteLastInput,
                      child: Container(
                        width: 70,
                        height: 70,
                        alignment: Alignment.center,
                        child: const Icon(Icons.backspace,
                            color: AppColor.white, size: 24),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
