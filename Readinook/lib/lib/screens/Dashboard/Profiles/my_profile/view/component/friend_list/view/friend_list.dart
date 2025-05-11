import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/ChatList/controller/chat_lists_controller.dart';
import 'package:reedinook/screens/Dashboard/Profiles/user_profile/controller/user_profile_controller.dart';
import 'package:reedinook/screens/Dashboard/Profiles/user_profile/view/user_profile.dart';
import 'package:reedinook/utils/appbar.dart';
import 'package:reedinook/utils/colors.dart';

class FriendList extends StatefulWidget {
  
  const FriendList({super.key,});
  

  @override
  _FriendListState createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  final ChatListsController chatlistcontroller = Get.put(ChatListsController());

  @override
  void initState() {
    super.initState();
    chatlistcontroller
        .fetchFriends(); // Fetch friends when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgcolor,
      appBar: const CustomAppBar(
          title: "Friends", showBackButton: true, role: '',), // Set the app bar here
      body: Obx(() {
        if (chatlistcontroller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (chatlistcontroller.friends.isEmpty) {
          return const Center(
              child: Text('No friends found.',
                  style: TextStyle(color: AppColor.iconstext)));
        } else {
          return ListView.builder(
            itemCount: chatlistcontroller.friends.length,
            padding: const EdgeInsets.only(top: 4.0),
            itemBuilder: (context, index) {
              final friend = chatlistcontroller
                  .friends[index]; // Access friend data directly
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  color: AppColor.white,
                  child: ListTile(
                    leading: GestureDetector(
                                onTap: () {
                                  Get.delete<UserProfileController>();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserProfile(
                                        friendName: friend['friendName'],
                                        friendAbout: friend['about'],
                                        friendProfilepic:
                                            friend['profilePicUrl'],
                                        friendId: friend['friendId'],
                                        friendrole: friend['role'],
                                        isFriend: true,
                                         requestid: '',
                                      ),
                                    ),
                                  );
                                },
                    child: CircleAvatar(
                      backgroundColor: (friend['profilePicUrl'] == null ||
                              friend['profilePicUrl'].isEmpty)
                          ? AppColor
                              .iconstext // Replace with your desired background color
                          : Colors.transparent,
                      backgroundImage: (friend['profilePicUrl'] != null &&
                              friend['profilePicUrl'] != '')
                          ? NetworkImage(friend['profilePicUrl'])
                          : null,
                      child: (friend['profilePicUrl'] == null ||
                              friend['profilePicUrl'] == '')
                          ? const Icon(Icons.person,
                              size: 30, color: AppColor.unselected)
                          : null,
                     ),
                              ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          friend['friendName'] ??
                              'Unknown', // Use the fetched friend name
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColor.bgcolor,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.person_remove,
                        color: AppColor.hinttextcolor,
                      ),
                      onPressed: () {
                        final UserProfileController userprofilecontroller =
                            Get.put(UserProfileController(friend['friendId']));

                        // Call the unfriend method
                        userprofilecontroller.unfriendUser(friend['friendId']);
                      },
                    ),
                    onTap: () {},
                  ),
                ),
              );
            },
          );
        }
      }),
    );
  }
}
