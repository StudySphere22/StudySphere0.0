import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/ChatList/controller/chat_lists_controller.dart';
import 'package:reedinook/screens/ChatList/view/component/group/controller/group_controller.dart';
import 'package:reedinook/screens/Dashboard/Profiles/user_profile/controller/user_profile_controller.dart';
import 'package:reedinook/screens/Dashboard/Profiles/user_profile/view/user_profile.dart';
import 'package:reedinook/utils/app_assets%20.dart';
import 'package:reedinook/utils/colors.dart';
import 'package:reedinook/utils/custom_snackbar.dart';

class Group extends StatefulWidget {
  const Group({super.key});

  @override
  State<Group> createState() => _GroupState();
}

class _GroupState extends State<Group> {
  final ChatListsController chatlistcontroller = Get.put(ChatListsController());
  TextEditingController searchController = TextEditingController();
  TextEditingController groupNameController = TextEditingController();
  String searchQuery = '';
  final List<Map<String, dynamic>> selectedFriends = [];
  final GroupController groupController = Get.put(GroupController());

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: Get.height * 0.8,
          decoration: const BoxDecoration(
            color: Color(0xFF131A22),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Stack(
            children: [
              // Main content (friend list, search bar, etc.)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Create Group',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColor.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: AppColor.iconstext),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),

                  // Display selected friends
                  if (selectedFriends.isNotEmpty)
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (var friend in selectedFriends)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Chip(
                                    label: Text(
                                      friend['friendName'],
                                      style: const TextStyle(
                                          color: AppColor.white),
                                    ),
                                    backgroundColor: AppColor.clickedbutton,
                                  ),
                                  Positioned(
                                    top: 1,
                                    right: 2,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedFriends.remove(friend);
                                        });
                                      },
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: TextField(
                      controller: searchController,
                      onChanged: (query) {
                        setState(() {
                          searchQuery = query.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search Friends...',
                        hintStyle:
                            const TextStyle(color: AppColor.hinttextcolor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 8.0, top: 14),
                          child: Text(
                            'To :',
                            style: TextStyle(
                              color: AppColor.iconstext,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        color: AppColor
                            .white, // Set the color of the text typed by the user
                      ),
                    ),
                  ),
                  const Divider(
                    color: AppColor.iconstext,
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                  ),

                  Expanded(
                    child: Obx(() {
                      if (chatlistcontroller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (chatlistcontroller.friends.isEmpty) {
                        return const Center(child: Text('No friends found.'));
                      } else {
                        var filteredFriends = chatlistcontroller.friends
                            .where((friend) => friend['friendName']
                                .toLowerCase()
                                .contains(searchQuery))
                            .toList();

                        return ListView.builder(
                          itemCount: filteredFriends.length,
                          padding: const EdgeInsets.only(top: 4.0),
                          itemBuilder: (context, index) {
                            final friend = filteredFriends[index];

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 3.0),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(0),
                                leading: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: GestureDetector(
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
                                      radius: 25,
                                      backgroundColor: (friend[
                                                      'profilePicUrl'] ==
                                                  null ||
                                              friend['profilePicUrl'].isEmpty)
                                          ? AppColor
                                              .iconstext // Replace with your desired background color
                                          : Colors.transparent,
                                      backgroundImage:
                                          (friend['profilePicUrl'] != null &&
                                                  friend['profilePicUrl'] != '')
                                              ? NetworkImage(
                                                  friend['profilePicUrl'])
                                              : null,
                                      child: (friend['profilePicUrl'] == null ||
                                              friend['profilePicUrl'] == '')
                                          ? const Icon(Icons.person,
                                              size: 30, color: AppColor.bgcolor)
                                          : null,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  friend['friendName'] ?? 'Unknown',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.white),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (selectedFriends.contains(friend))
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedFriends.remove(friend);
                                          });
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.only(
                                              right:
                                                  17.0), // Add padding to the close icon
                                          child: Icon(
                                            Icons.close,
                                            color: AppColor.clickedbutton,
                                            size: 24,
                                          ),
                                        ),
                                      )
                                    else
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 17.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedFriends.add(friend);
                                            });
                                          },
                                          child: SvgPicture.asset(
                                            AppAssets.plusSquare,
                                            color: AppColor.iconstext,
                                            //size: 24,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    }),
                  ),
                ],
              ),

              // Create Group Button - Positioned at the bottom
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.clickedbutton,
                  ),
                  onPressed: () {
                    if (selectedFriends.isNotEmpty) {
                      // Show dialog to enter group name
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: AppColor.bgcolor,
                            title: const Text(
                              "Enter Group Name",
                              style: TextStyle(color: AppColor.white),
                            ),
                            content: TextField(
                                controller: groupNameController,
                                decoration: const InputDecoration(
                                  hintStyle: TextStyle(color: AppColor.white),
                                  hintText: "Group Name",
                                ),
                                style: const TextStyle(color: AppColor.white)),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(color: AppColor.iconstext),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  String groupName =
                                      groupNameController.text.trim();
                                  if (groupName.isNotEmpty) {
                                    groupController.createGroupChat(
                                        groupName, selectedFriends);
                                    Navigator.pop(context); // Close dialog
                                    Navigator.pop(
                                        context); // Close GroupChat screen
                                  } else {
                                    customSnackbar(title: "Group Name Required",
                                        message: "Please enter a name for the group.");
                                  }
                                },
                                child: const Text(
                                  "OK",
                                  style:
                                      TextStyle(color: AppColor.clickedbutton),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      customSnackbar(title: "No Friends Selected",
                         message:  "Please select at least one friend to create a group.");
                    }
                  },
                  child: const Text(
                    'Create Group',
                    style: TextStyle(color: AppColor.white),
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
