import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/Post/controller/posts_controller.dart';
import 'package:reedinook/utils/colors.dart';

class Posts extends StatefulWidget {
  final String? profilePicUrl;
  final String? username;

  const Posts({super.key, this.profilePicUrl, this.username});

  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  final TextEditingController _postController = TextEditingController();
  final PostsController _postsController = Get.put(PostsController());

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: Get.height * 0.8, // 80% of the screen height
          decoration: const BoxDecoration(
            color: AppColor.bgcolor, // Dark background color
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Posts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColor.white, // White text
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
              ),
              // Profile picture and username
              
              CircleAvatar(
                radius: 30.0,
                 backgroundColor: (widget.profilePicUrl ==
                                                  null ||
                                              widget.profilePicUrl!.isEmpty)
                                          ? AppColor
                                              .iconstext // Replace with your desired background color
                                          : Colors
                                              .transparent,
                backgroundImage: (widget.profilePicUrl != null &&
                        widget.profilePicUrl!.isNotEmpty)
                    ? NetworkImage(widget.profilePicUrl!)
                    : null,
                child: (widget.profilePicUrl == null ||
                        widget.profilePicUrl!.isEmpty)
                    ? const Icon(Icons.person,
                        size: 30, color: AppColor.unselected)
                    : null,
              ),

              const SizedBox(height: 30),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Stack(
                    children: [
                      // TextField for post content
                      Positioned.fill(
                        child: TextField(
  controller: _postController,
  decoration: const InputDecoration(
    hintText: 'What is happening...',
    hintStyle: TextStyle(color: AppColor.hinttextcolor), // Hint text color
    filled: true,
    fillColor: AppColor.white, // Background color for the TextField
    
    
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: AppColor.clickedbutton, width: 2), // Border when focused
    ),
  ),
  style: const TextStyle(color: AppColor.bgcolor), // Text color
  cursorColor: AppColor.bgcolor, // Cursor color
  maxLines: null, // Allow multiple lines
),

                      ),
                      // Positioned Post button at the bottom right
                      Positioned(
                        bottom: 10,
                        right: 0,
                        child: Obx(() => ElevatedButton(
                              onPressed: () {
                                _postsController.savePost(
                                  widget.profilePicUrl,
                                  widget.username,
                                  _postController.text,
                                );
                                _postController.clear();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.clickedbutton,
                              ),
                              child: _postsController.isLoading.value
                                  ? const CircularProgressIndicator(color: AppColor.white)
                                  : const Text("Post", style: TextStyle(color: AppColor.white)),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
