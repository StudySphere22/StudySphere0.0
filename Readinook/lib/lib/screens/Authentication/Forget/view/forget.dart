import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/Authentication/Forget/controller/forget_controller.dart';
import 'package:reedinook/screens/Authentication/Login/view/login.dart';
import 'package:reedinook/utils/app_assets%20.dart';
import 'package:reedinook/utils/colors.dart';

class Forget extends StatelessWidget {
  Forget({super.key});

  // Initialize the ForgetPasswordController using GetX
  final ForgetPasswordController forgetPasswordController =
      Get.put(ForgetPasswordController());

  @override
Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: true, // Ensures the screen resizes when the keyboard appears
    backgroundColor: AppColor.bgcolor,
    appBar: PreferredSize(
      preferredSize: const Size.fromHeight(60.0), // Set the height of the app bar
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColor.iconstext),
                onPressed: () {
                  // Clear the controller before navigating to the login screen
                  forgetPasswordController.forgetController.clear();
                  Get.off(() => const MyLogin());
                },
              ),
              const Text(
                'Forget Password',
                style: TextStyle(
                  color: AppColor.iconstext,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    body: Stack(
      children: [
        SafeArea(
          child: SingleChildScrollView( // Makes the content scrollable
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20), // Space below the title
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20), // Space above the image
                        Image.asset(
                          AppAssets.readinookTextWhiteTransparent,
                          width: MediaQuery.of(context).size.width >= 600 ? 200 : 400,
                          height: MediaQuery.of(context).size.width >= 600 ? 200 : 150,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(16.0), // Adds padding around the text
                          child: Text(
                            'Enter the registered Email to receive the Password Reset Link',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColor.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40), // Space above the TextFormField
                        
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,

                          child: Form(
                            key: forgetPasswordController.formKeyforget,
                               child: TextFormField(
                                      controller: forgetPasswordController.forgetController,

                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an email address';
                              }
                              final emailRegex = RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
                              if (!emailRegex.hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColor.clickedbutton,
                                  width: 2,
                                ), // Border when focused
                              ),
                              hintText: 'Email',
                              hintStyle: const TextStyle(
                                color: AppColor.hinttextcolor,
                              ),
                              fillColor: AppColor.white,
                              filled: true,
                              prefixIcon: const Icon(
                                Icons.email,
                                color: AppColor.bgcolor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        ),
                        const SizedBox(height: 20), // Space above the button
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              AppColor.clickedbutton,
                            ),
                          ),
                          onPressed: () async {
                            // Call the controller method to send the reset email
                            await forgetPasswordController.sendPasswordResetEmail(context);
                          },
                          child: const Text(
                            'Send Link',
                            style: TextStyle(
                              color: AppColor.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Loading indicator and blurred background
        Obx(() {
          if (forgetPasswordController.isLoading.value) {
            return const Positioned.fill(
              child: Stack(
                children: [
                  // BackdropFilter to blur the background
                  // BackdropFilter(
                  //   filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  //   child: Container(
                  //     color: Colors.black.withOpacity(0.5),
                  //   ),
                  // ),
                  // Centered loading indicator
                  Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }
          return Container(); // If not loading, return an empty container
        }),
      ],
    ),
  );
}
}