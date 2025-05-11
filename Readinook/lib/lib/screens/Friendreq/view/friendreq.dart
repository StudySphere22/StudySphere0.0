import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/Dashboard/Profiles/user_profile/controller/user_profile_controller.dart';
import 'package:reedinook/screens/Dashboard/Profiles/user_profile/view/user_profile.dart';
import 'package:reedinook/screens/Friendreq/controller/friendreq_controller.dart';
import 'package:reedinook/utils/appbar.dart';
import 'package:reedinook/utils/colors.dart';

class Friendreq extends StatelessWidget {
  const Friendreq({super.key});

  @override
  Widget build(BuildContext context) {
    final FriendRequestController controller = Get.put(FriendRequestController());

    return Scaffold(
      backgroundColor: AppColor.bgcolor,
      body: Column(
         children: [
       const CustomAppBar(title: "Friend Requests", role: '',), // Only the title is used
  Expanded(
      
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.friendRequests.isEmpty) {
          return const Center(child: Text("No friend requests found.",style: TextStyle(color: AppColor.iconstext)));
        }

        return ListView(
             padding: const EdgeInsets.only(top: 4.0), // Adjust this to control spacing
          children: controller.friendRequests.map((item) {
            var profilePicUrl = item['profilePicUrl'] ?? '';
            var senderName = item['senderName'] ?? 'Unknown User';
            String requestId = item['requestId'] ?? '';
            String senderId = item['senderId'] ?? '';
             String about = item['about'] ?? '';
             String role = item['role'] ?? '';

            

            return Padding(
         
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                color: AppColor.white,
                child: ListTile(

                   leading: GestureDetector(
                    onTap: () {
          
                        Get.delete<UserProfileController>(); // Remove the controller

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserProfile(
                              friendName: senderName,
                              friendAbout: about,
                              friendProfilepic: profilePicUrl ?? '',
                              friendId: senderId,
                              friendrole: role,
                              isFriend: false,
                              requestid: requestId,
                            ),
                          ),
                        );
                      },
                    
                  child: CircleAvatar(
                     backgroundColor: (profilePicUrl ==
                                              null ||
                                         profilePicUrl.isEmpty)
                                      ? AppColor
                                          .iconstext // Replace with your desired background color
                                      : Colors.transparent,
                    backgroundImage: profilePicUrl.isNotEmpty
                        ? NetworkImage(profilePicUrl)
                        : null,
                    child: profilePicUrl.isEmpty
                        ? const Icon(Icons.person,color: AppColor.unselected)
                        : null,
                  ),

                   ),
                  title: Text(senderName,
                  style: const TextStyle(color: AppColor.bgcolor),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          controller.acceptFriendRequest(requestId, senderId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.clickedbutton,
                        ),
                        child: const Text("Accept", style: TextStyle(color: AppColor.white)),
                      ),
                      const SizedBox(width: 15),
                      ElevatedButton(
                        onPressed: () {
                          // print("requets id $requestId");
                          controller.rejectFriendRequest(requestId, senderId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.unselected,
                        ),
                        child: const Text("Reject", style: TextStyle(color: AppColor.white)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }),
  ),
         ],
      ),
    );
  }
}
