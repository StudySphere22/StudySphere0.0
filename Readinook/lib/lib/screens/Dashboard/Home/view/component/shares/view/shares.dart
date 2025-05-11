import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/Dashboard/Home/view/component/shares/controller/share_controller.dart';
import 'package:reedinook/utils/app_assets%20.dart';
import 'package:reedinook/utils/colors.dart';

class ShareScreen extends StatefulWidget {
  final String postId;

  const ShareScreen({super.key, required this.postId});

  @override
  _ShareScreenState createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  late final ShareController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ShareController(widget.postId));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Close the keyboard when tapped outside
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.3, // Cover 30% of the screen height
          decoration: const BoxDecoration(
            color: Color(0xFF131A22),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Share with Friends',
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
              ),
              // Horizontal List of Friends
              SizedBox(
                height: 100, // Adjust height as needed
                child: Obx(() {
                  if (controller.friends.isEmpty) {
                    return const Center(
                      child: Text('No friends found.', style: TextStyle(color: AppColor.white)),
                    );
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.friends.length,
                    itemBuilder: (context, index) {
                      final friend = controller.friends[index];
                      final isSelected = controller.selectedFriends.contains(friend['id']);
                      return GestureDetector(
                        onTap: () {
                          controller.toggleFriendSelection(friend['id']); // Toggle selection on tap
                          setState(() {}); // Update the UI immediately
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0), // Add horizontal spacing
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Add a shadow effect and change avatar shape
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blueAccent.withOpacity(0.2), // Background color
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3), // Shadow position
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      backgroundColor: (friend[
                                                      'profilePicUrl'] ==
                                                  null ||
                                              friend['profilePicUrl'].isEmpty)
                                          ? AppColor
                                              .iconstext // Replace with your desired background color
                                          : Colors.transparent,
                                      backgroundImage: friend['profilePicUrl'] != null
                                          ? NetworkImage(friend['profilePicUrl'])
                                          : null,
                                      radius: 30,
                                      child: friend['profilePicUrl'].isEmpty
                                          ? const Icon(Icons.person, color: AppColor.bgcolor)
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    friend['username'] ?? 'Unknown',
                                    style: TextStyle(
                                      color: AppColor.white,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, // Change font weight based on selection
                                    ),
                                  ),
                                ],
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle, color: AppColor.clickedbutton, size: 24), // Show tick when selected
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),

              // Send Button
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    icon: SvgPicture.asset(AppAssets.send, color: AppColor.white),
                    onPressed: () {
                      if (controller.selectedFriends.isNotEmpty) {
                        controller.sendPost();

               Get.delete<ShareController>();
                        Navigator.of(context).pop(); // Close after sending
                      }
                    },
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
