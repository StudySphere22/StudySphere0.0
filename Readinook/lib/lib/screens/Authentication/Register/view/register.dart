import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Make sure to import GetX
import 'package:reedinook/screens/Authentication/Login/view/login.dart';
import 'package:reedinook/screens/Authentication/Register/controller/register_controller.dart';
import 'package:reedinook/utils/app_assets%20.dart';
import 'package:reedinook/utils/colors.dart';
import 'package:reedinook/utils/custom_loading_indicator.dart';

class MyRegister extends StatefulWidget {
  const MyRegister({super.key});

  @override
  _MyRegisterState createState() => _MyRegisterState();
}

class _MyRegisterState extends State<MyRegister> with TickerProviderStateMixin {
  final RegistrationController registrationController =
      Get.put(RegistrationController());
  late TabController _tabController2;
  bool _obscureCurrentPassword = true;
  bool _obscureCurrentPassword1 = true;

  @override
  void initState() {
    super.initState();
    _tabController2 =
        TabController(length: 2, vsync: this); // 2 tabs: User and Auth
    _tabController2.addListener(_tabChanged); // Add listener for tab changes
  }

  void _tabChanged() {
    setState(() {
      // Set role based on selected tab
      if (_tabController2.index == 0) {
        registrationController.roleController.text = 'user';
      } else {
        registrationController.roleController.text = 'auth';
      }
    });
  }

  @override
  void dispose() {
    _tabController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.bgcolor,
        body: Stack(children: [
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width >= 600 ? 100 : 35,
              ),
              child: Form(
                key: registrationController.formKeyRegister,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                        height:
                            60), // Adjust this value to control space above the
                    Image.asset(
                      AppAssets.readinookTextWhiteTransparent,
                      width:
                          MediaQuery.of(context).size.width >= 600 ? 200 : 400,
                      height:
                          MediaQuery.of(context).size.width >= 600 ? 200 : 120,
                    ),
                    const SizedBox(height: 50),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          TabBar(
                            controller: _tabController2,
                            //isScrollable: true,
                            tabs: const [
                              Tab(text: 'User'),
                              Tab(text: 'Author'),
                            ],
                            labelColor: AppColor.clickedbutton,
                            unselectedLabelColor: AppColor.iconstext,
                            indicatorColor: AppColor.white,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 432,
                            child: TabBarView(
                                controller: _tabController2,
                                children: [
                                  // User Tab: Email and Password Fields

                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter a name';
                                            }
                                            // Check if the first character is a negative sign or a digit
                                            if (RegExp(r'^[-\d]')
                                                .hasMatch(value)) {
                                              return 'Username cannot start with a negative sign or a number';
                                            }
                                            return null;
                                          },
                                          controller: registrationController
                                              .userNameController,
                                          decoration: InputDecoration(
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: AppColor.clickedbutton,
                                                width: 2,
                                              ),
                                            ),
                                            hintText: 'Username',
                                            hintStyle: const TextStyle(
                                              color: AppColor.hinttextcolor,
                                            ),
                                            fillColor: AppColor.white,
                                            filled: true,
                                            prefixIcon: const Icon(
                                              Icons.person,
                                              color: AppColor.bgcolor,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: TextFormField(
                                          controller: registrationController
                                              .emailController,
                                          decoration: InputDecoration(
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: AppColor.clickedbutton,
                                                  width:
                                                      2), // Border when focused
                                            ),
                                            hintText: 'Email',
                                            hintStyle: const TextStyle(
                                              color: AppColor
                                                  .hinttextcolor, // Change this to your desired color
                                            ),
                                            fillColor: AppColor.white,
                                            filled: true,
                                            prefixIcon: const Icon(Icons.email,
                                                color: AppColor.bgcolor),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter an email address';
                                            }
                                            final emailRegex = RegExp(
                                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
                                            if (!emailRegex.hasMatch(value)) {
                                              return 'Please enter a valid email address';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: TextFormField(
                                          controller: registrationController
                                              .passwordController,
                                          obscureText: _obscureCurrentPassword,
                                          decoration: InputDecoration(
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: AppColor.clickedbutton,
                                                  width:
                                                      2), // Border when focused
                                            ),
                                            hintText: 'Password',
                                            hintStyle: const TextStyle(
                                              color: AppColor
                                                  .hinttextcolor, // Change this to your desired color
                                            ),
                                            fillColor: AppColor.white,
                                            filled: true,
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscureCurrentPassword
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                color: AppColor.dropdown,
                                              ),
                                              onPressed: () {
                                                // Toggle the obscure text value when the icon is clicked
                                                setState(() {
                                                  _obscureCurrentPassword =
                                                      !_obscureCurrentPassword;
                                                });
                                              },
                                            ),
                                            prefixIcon: const Icon(Icons.lock,
                                                color: AppColor.bgcolor),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty ||
                                                value.length < 8) {
                                              return 'Please enter at least 8 characters';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      // Sign Up and Forgot Password Buttons in Auth Tab
                                      // Sign Up and Forgot Password Buttons in Auth Tab
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .end, // Aligns the button to the right
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              registrationController
                                                  .userNameController
                                                  .clear();
                                              registrationController
                                                  .emailController
                                                  .clear();
                                              registrationController
                                                  .passwordController
                                                  .clear();
                                              registrationController
                                                  .linkcontroller
                                                  .clear();
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const MyLogin()),
                                              );
                                            },
                                            child: const Text(
                                              'Sign In',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: AppColor.iconstext,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  // Auth Tab: Email and Password Fields with Sign Up and Forgot Password

                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter a name';
                                            }
                                            // Check if the first character is a negative sign or a digit
                                            if (RegExp(r'^[-\d]')
                                                .hasMatch(value)) {
                                              return 'Username cannot start with a negative sign or a number';
                                            }
                                            return null;
                                          },
                                          controller: registrationController
                                              .userNameController,
                                          decoration: InputDecoration(
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: AppColor.clickedbutton,
                                                width: 2,
                                              ),
                                            ),
                                            hintText: 'Username',
                                            hintStyle: const TextStyle(
                                              color: AppColor.hinttextcolor,
                                            ),
                                            fillColor: AppColor.white,
                                            filled: true,
                                            prefixIcon: const Icon(
                                              Icons.person,
                                              color: AppColor.bgcolor,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: TextFormField(
                                          controller: registrationController
                                              .emailController,
                                          decoration: InputDecoration(
                                            hintText: 'Email',
                                            hintStyle: const TextStyle(
                                              color: AppColor
                                                  .hinttextcolor, // Change this to your desired color
                                            ),
                                            fillColor: AppColor.white,
                                            filled: true,
                                            prefixIcon: const Icon(Icons.email,
                                                color: AppColor.bgcolor),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter an email address';
                                            }
                                            final emailRegex = RegExp(
                                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
                                            if (!emailRegex.hasMatch(value)) {
                                              return 'Please enter a valid email address';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: TextFormField(
                                          controller: registrationController
                                              .passwordController,
                                          obscureText: _obscureCurrentPassword1,
                                          decoration: InputDecoration(
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: AppColor.clickedbutton,
                                                  width:
                                                      2), // Border when focused
                                            ),
                                            hintText: 'Password',
                                            hintStyle: const TextStyle(
                                              color: AppColor
                                                  .hinttextcolor, // Change this to your desired color
                                            ),
                                            fillColor: AppColor.white,
                                            filled: true,
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscureCurrentPassword1
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                color: AppColor.dropdown,
                                              ),
                                              onPressed: () {
                                                // Toggle the obscure text value when the icon is clicked
                                                setState(() {
                                                  _obscureCurrentPassword1 =
                                                      !_obscureCurrentPassword1;
                                                });
                                              },
                                            ),
                                            prefixIcon: const Icon(Icons.lock,
                                                color: AppColor.bgcolor),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty ||
                                                value.length < 8) {
                                              return 'Please enter at least 8 characters';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: TextFormField(
                                          controller: registrationController
                                              .linkcontroller,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter a link';
                                            }
                                            final urlRegex = RegExp(
                                                r'^(https?:\/\/)?([\w\-]+\.)+([a-zA-Z]{2,63})(\/[\w\-.~:?#[\]@!$&\()*+,;=]*)?$');
                                            if (!urlRegex.hasMatch(value)) {
                                              return 'Please enter a valid URL';
                                            }

                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: AppColor.clickedbutton,
                                                  width: 2),
                                            ),
                                            hintText: 'Link for Published Work',
                                            hintStyle: const TextStyle(
                                              color: AppColor.hinttextcolor,
                                            ),
                                            fillColor: AppColor.white,
                                            filled: true,
                                            prefixIcon: const Icon(
                                              Icons.link,
                                              color: AppColor.bgcolor,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Sign Up and Forgot Password Buttons in Auth Tab
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .end, // Aligns the button to the right
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              registrationController
                                                  .userNameController
                                                  .clear();
                                              registrationController
                                                  .emailController
                                                  .clear();
                                              registrationController
                                                  .passwordController
                                                  .clear();
                                              registrationController
                                                  .linkcontroller
                                                  .clear();
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const MyLogin()),
                                              );
                                            },
                                            child: const Text(
                                              'Sign In',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: AppColor.iconstext,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Align(
                              alignment:
                                  Alignment.center, // Align it at the center
                              child: Transform.translate(
                                offset: const Offset(0,
                                    -25), // Move it up by 20 units (adjust as needed)
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: AppColor.clickedbutton,
                                  child: IconButton(
                                    onPressed: () async {
                                      if (registrationController
                                          .formKeyRegister.currentState!
                                          .validate()) {
                                        registrationController
                                            .isLoading(true); // Show loading
                                        await registrationController
                                            .checkUsernameAndSendOtp(context);
                                        registrationController.isLoading(
                                            false); // Hide loading after completion
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.arrow_forward,
                                      color: AppColor.white,
                                    ),
                                  ),
                                ),
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
          Obx(() {
            return registrationController.isLoading.value
                ? Center(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                        alignment: Alignment.center,
                        child:
                            const CustomLoadingIndicator(), // Use your custom loading widget
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          })
        ]));
  }
}
