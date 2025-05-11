import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/Dashboard/Profiles/my_profile/view/profile.dart';
import 'package:reedinook/screens/Dashboard/Profiles/user_profile/controller/user_profile_controller.dart';
import 'package:reedinook/screens/Dashboard/Profiles/user_profile/view/user_profile.dart';
import 'package:reedinook/screens/Dashboard/Searchfriend/controller/searchfriend_controller.dart';
import 'package:reedinook/utils/appbar.dart';
import 'package:reedinook/utils/colors.dart';
import 'package:reedinook/utils/custom_snackbar.dart'; // Import the CustomAppBar

class SearchFriend extends StatelessWidget {
  SearchFriend({super.key});

  final TextEditingController _searchController = TextEditingController();
  final SearchFriendController _controller = Get.put(SearchFriendController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgcolor,
      appBar: PreferredSize(
        //  color: AppColor.bgcolor,
        preferredSize: Size.fromHeight(Get.height * .12),
        child: CustomAppBar(
          hintText: "Search by username...", // Use hintText for the app bar
          searchController: _searchController, // Pass the search controller
          onSearchChanged:
              _controller.performSearch, role: '', // Pass the search function
        ),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.searchResults.isEmpty) {
          return const Center(child: Text("No users found."));
        }

        return ListView.builder(
          itemCount: _controller.searchResults.length,

          padding:
              const EdgeInsets.only(top: 4.0), // Adjust this to control spacing
          itemBuilder: (context, index) {
            var user =
                _controller.searchResults[index].data() as Map<String, dynamic>;
            String receiverId = _controller.searchResults[index].id;
            String? profilePicUrl = user['profilePicUrl'];
            String username = user['username'];

            bool friendRequestSent =
                _controller.checkIfFriendRequestSent(receiverId);
            bool isFriend = _controller.friendsMap.containsKey(receiverId);

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
                      // Get the current user's ID from Firebase Auth
                      String currentUserId =
                          FirebaseAuth.instance.currentUser!.uid;

                      if (receiverId == currentUserId) {
                        // Navigate to the user's own profile
                        Get.to(() => const Profile());
                      } else {
                        print("proiufle pic url ${user['profilePicUrl']}");
                        Get.delete<
                            UserProfileController>(); // Remove the controller

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserProfile(
                              friendName: user['username'],
                              friendAbout: user['about'] ?? '',
                              friendProfilepic: user['profilePicUrl'] ?? '',
                              friendId: receiverId,
                              friendrole: user['role'],
                              isFriend: isFriend,
                               requestid: '',
                            ),
                          ),
                        );
                      }
                    },
                    child: CircleAvatar(
                        backgroundColor: (profilePicUrl ==
                                              null ||
                                         profilePicUrl.isEmpty)
                                      ? AppColor
                                          .iconstext // Replace with your desired background color
                                      : Colors.transparent,
                      backgroundImage: profilePicUrl != null
                          ? NetworkImage(profilePicUrl)
                          : null,
                      child: profilePicUrl == null ||
                                         profilePicUrl.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                  ),
                  title: Text(
                    username,
                    style: const TextStyle(color: AppColor.bgcolor),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isFriend) // Show friend icon if they are a friend
                        const Icon(Icons.person,
                            color: AppColor.hinttextcolor), // Friend icon
                      if (!isFriend) // If not a friend
                        IconButton(
                          icon: friendRequestSent
                              ? const Icon(Icons.done,
                                  color: AppColor
                                      .iconstext) // Indicate friend request sent
                              : const Icon(Icons.person_add,
                                  color:
                                      AppColor.unselected), // Add friend icon
                          onPressed: () {
                            if (_controller
                                .isFriendRequestReceived(receiverId)) {
                              customSnackbar(title: 
                                "Success",
                                message: "This user has already sent you a friend request.",
                              );
                            } else if (!friendRequestSent) {
                              _controller.sendFriendRequest(receiverId);
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
