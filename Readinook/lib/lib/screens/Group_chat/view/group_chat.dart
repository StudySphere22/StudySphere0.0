import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/ChatList/controller/chat_lists_controller.dart';
import 'package:reedinook/screens/Dashboard/Home/controller/home_controller.dart';
import 'package:reedinook/screens/Dashboard/Profiles/my_profile/view/profile.dart';
import 'package:reedinook/screens/Dashboard/Profiles/user_profile/controller/user_profile_controller.dart';
import 'package:reedinook/screens/Dashboard/Profiles/user_profile/view/user_profile.dart';
import 'package:reedinook/screens/Group_chat/controller/group_chat_controller.dart';
import 'package:reedinook/utils/app_assets%20.dart';
import 'package:reedinook/utils/colors.dart';

class GroupChat extends StatefulWidget {
  final List<dynamic> members;
  final String groupId;
  final String currentUserId;

  const GroupChat(
      {super.key,
      required this.members,
      required this.groupId,
      required this.currentUserId});

  @override
  State<GroupChat> createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  late final GroupChatController groupChatController;
  final HomeController homeController = Get.find<HomeController>();

  String currentUser = '';

  @override
  void initState() {
    super.initState();
    groupChatController = Get.put(GroupChatController(groupId: widget.groupId));
    groupChatController.fetchGroupMembers();

    currentUser = homeController.username;
    print("current suer $currentUser");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgcolor,
      appBar: AppBar(
        backgroundColor: AppColor.bgcolor,
        iconTheme: const IconThemeData(color: AppColor.iconstext),
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.members.map((member) {
              return GestureDetector(
                onTap: () async {
                  //   print("Group Members: ${groupChatController.groupMembers}");
                  // print("Clicked Member UserId: ${member['userId']}");
                  // Get.delete<UserProfileController>();
                  // Get full details from `membersfullydetails`
                  final memberFullyDetails =
                      groupChatController.groupMembers.firstWhere(
                    (m) => m['id'] == member['userId'], // Match userId
                    orElse: () => {}, // Default empty map if not found
                  );

                  final currentUserId =
                      FirebaseAuth.instance.currentUser?.uid ??
                          "defaultUserId"; // Provide a fallback ID
                  bool isFriend = await groupChatController.checkIfFriend(
                      currentUserId, member['userId']);

                  if (memberFullyDetails['id'] == currentUserId){
                     Get.delete<
                            ChatListsController>(); // Remove the controller
                     Get.to(() => const Profile());
                  } else{
                     Get.delete<
                            UserProfileController>(); // Remove the controller

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfile(
                        friendId: memberFullyDetails['id'],
                        friendName: memberFullyDetails['name'],
                        friendAbout: memberFullyDetails['about'],
                        friendProfilepic: memberFullyDetails['profilePicUrl'],
                        friendrole: memberFullyDetails['role'],
                        isFriend: isFriend,
                        requestid: '',
                      ),
                    ),
                  );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: (member['profilePicUrl'] == null ||
                                member['profilePicUrl'].isEmpty)
                            ? AppColor
                                .iconstext // Replace with your desired background color
                            : Colors.transparent,
                        backgroundImage: (member['profilePicUrl'] != null &&
                                member['profilePicUrl'] != '')
                            ? NetworkImage(member['profilePicUrl'])
                            : null,
                        child: (member['profilePicUrl'] == null ||
                                member['profilePicUrl'] == '')
                            ? const Icon(Icons.account_circle,
                                size: 20, color: AppColor.bgcolor)
                            : null,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        member['userName'] ?? '',
                        style: const TextStyle(
                            color: AppColor.white, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          IconButton(
            icon:
                SvgPicture.asset(AppAssets.callicon, color: AppColor.iconstext),
            onPressed: () {
              // Handle call action
            },
          ),
          IconButton(
            icon: SvgPicture.asset(AppAssets.videoicon,
                color: AppColor.iconstext),
            onPressed: () {
              // Handle video call action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Message List Section
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: groupChatController.getMessages(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text(
                    "No messages yet",
                    style: TextStyle(
                      color: AppColor.iconstext,
                    ),
                  ));
                }
                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var messageData = snapshot.data!.docs[index];
                    bool isCurrentUser =
                        messageData['senderId'] == widget.currentUserId;

                    return Align(
                      alignment: isCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isCurrentUser
                              ? AppColor.clickedbutton
                              : AppColor.unselected,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display the sender's name for both current user and others
                            Text(
                              messageData['senderName'],
                              style: const TextStyle(
                                  color: AppColor.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              messageData['message'],
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColor.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Message Input Section
          Container(
            margin: const EdgeInsets.only(
                left: 4,
                right: 4,
                bottom: 5), // Add horizontal margin and bottom margin
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8), // Padding inside the container
            decoration: const BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20), // Rounded top corners
                bottom: Radius.circular(20), // Rounded bottom corners
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: groupChatController.messageController,
                    style: const TextStyle(color: AppColor.bgcolor),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: const TextStyle(color: AppColor.hinttextcolor),
                      filled: true,
                      fillColor: AppColor.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: SvgPicture.asset(AppAssets.sendicon,
                      color: AppColor.bgcolor),
                  onPressed: () {
                    final message =
                        groupChatController.messageController.text.trim();
                    if (message.isNotEmpty) {
                      groupChatController.sendMessage(
                          widget.currentUserId, currentUser, message);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
