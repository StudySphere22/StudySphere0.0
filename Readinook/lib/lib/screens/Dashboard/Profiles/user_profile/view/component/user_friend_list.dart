import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/Dashboard/Profiles/user_profile/controller/user_profile_controller.dart';
import 'package:reedinook/utils/appbar.dart';
import 'package:reedinook/utils/colors.dart';

class UserFriendList extends StatefulWidget {
  final List<Map<String, dynamic>> friendsList; // Declare the list
  const UserFriendList({super.key, required this.friendsList});

  @override
  State<UserFriendList> createState() => _UserFriendListState();
}

class _UserFriendListState extends State<UserFriendList> {
   late final UserProfileController
      userprofileController; 
  @override
  void initState() {
    super.initState();
    // Initialize the listener for friends
    userprofileController = Get.put(UserProfileController(''));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgcolor,
      appBar: const CustomAppBar(
          title: "Friends", showBackButton: true, role: '',), // Set the app bar here
      body: Obx(() {
        if (widget.friendsList.isEmpty) {
          return const Center(
              child: Text('No friends found.',
                  style: TextStyle(color: AppColor.iconstext)));
        } else {
          return ListView.builder(
            itemCount: widget.friendsList.length,
            padding: const EdgeInsets.only(top: 4.0),
            itemBuilder: (context, index) {
              final friend =
                  widget.friendsList[index]; // Access friend data directly
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
                          // userprofileController.checkIfFriend(friend['id']);
                        // if(userprofileController.currentUserId == friend['id'] ){
                        //    Get.to(() => const Profile());
                      
                        // Get.delete<UserProfileController>(); 
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => UserProfile(
                        //       friendName: friend['friendName'],
                        //       friendAbout: friend['friendsabout'],
                        //       friendProfilepic: friend['friendProfilePicUrl'],
                        //       friendId: friend['id'],
                        //        isFriend: userprofileController.isFriend.value, // Use isFriend value
                        //       requestid: '',
                        //     ),
                        //   ),
                        // );
                      
                      },
                      child: CircleAvatar(
                        backgroundColor: (friend['friendProfilePicUrl'] ==
                                    null ||
                                friend['friendProfilePicUrl'].isEmpty)
                            ? AppColor
                                .iconstext // Replace with your desired background color
                            : Colors.transparent,
                        backgroundImage:
                            (friend['friendProfilePicUrl'] != null &&
                                    friend['friendProfilePicUrl'] != '')
                                ? NetworkImage(friend['friendProfilePicUrl'])
                                : null,
                        child: (friend['friendProfilePicUrl'] == null ||
                                friend['friendProfilePicUrl'] == '')
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
                    // trailing: IconButton(
                    //   icon: const Icon(
                    //     Icons.person_remove,
                    //     color: AppColor.hinttextcolor,
                    //   ),
                    //   onPressed: () {
                    //     // final UserProfileController userprofilecontroller =
                    //     //     Get.put(UserProfileController(friend['friendId']));

                    //     // Call the unfriend method
                    //     // userprofilecontroller.unfriendUser(friend['friendId']);
                    //   },
                    // ),
                    onTap: () {},
                  ),
                ),
              );
            },
          );
        }
      }),
    );

    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text('Friend List'),
    //   ),
    //   body: ListView.builder(
    //     itemCount: widget.friendsList.length, // Use friendsList here
    //     itemBuilder: (context, index) {
    //       return ListTile(
    //         title: Text(widget.friendsList[index]['friendName']), // Access friendsList
    //         subtitle: Text(widget.friendsList[index]['friendsabout'] ?? 'No about info'),
    //         leading: Image.network(widget.friendsList[index]['friendProfilePicUrl']),
    //       );
    //     },
    //   ),
    // );
  }
}
