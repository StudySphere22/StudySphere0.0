import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/Dashboard/Profiles/my_profile/view/component/all_books/user_books/user_book.dart';
import 'package:reedinook/screens/Dashboard/Profiles/my_profile/view/component/uploaded_book/view/uploaded_books.dart';
import 'package:reedinook/screens/Dashboard/Profiles/user_profile/controller/user_profile_controller.dart';
import 'package:reedinook/screens/Dashboard/Profiles/user_profile/view/component/respond.dart';
import 'package:reedinook/screens/Dashboard/Profiles/user_profile/view/component/user_friend_list.dart';
import 'package:reedinook/utils/app_assets%20.dart';
import 'package:reedinook/utils/colors.dart';
import 'package:reedinook/utils/comments_section.dart';
import 'package:reedinook/utils/on_screen_picture.dart';
import 'package:reedinook/utils/post_time.dart';
import 'package:reedinook/utils/share_section.dart';

class UserProfile extends StatefulWidget {
  final bool isFriend; // Whether the user is a friend or not
  final String friendName;
  final String friendAbout;
  final String friendProfilepic;
  final String friendId;
  final String requestid;
  final String friendrole;

  const UserProfile({
    super.key,
    required this.isFriend,
    required this.friendName,
    required this.friendAbout,
    required this.friendProfilepic,
    required this.friendId,
    required this.requestid,
    required this.friendrole
  });

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  bool isPostsSelected = true; // To toggle between posts and books
  late final UserProfileController
      userprofileController; // Declare the controller
  bool friendRequestSent = false; // Track if the friend request has been sent

  @override
  void initState() {
    super.initState();
    // Initialize the listener for friends
    userprofileController = Get.put(UserProfileController(widget.friendId));
    userprofileController.listenToFriendRequestStatus(widget.friendId);
    userprofileController.listenToFriendshipStatus(widget.friendId);
    userprofileController.friendsBooks(widget.friendId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgcolor,
      appBar: AppBar(
        title: const Text(
          "User Profile",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: AppColor.bgcolor,
        iconTheme: const IconThemeData(
          color: AppColor.iconstext,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Profile Picture and Stats
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture with left padding
              Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0), // Add left padding here
                  child: GestureDetector(
    onTap: () {
      // Navigate to the Profile Picture Screen when the avatar is clicked
      Get.to(() => OnScreenPicture(profilePicUrl: widget.friendProfilepic));
    },
                  
                  child: CircleAvatar(
                    radius: 40,
                      backgroundColor: (widget.friendProfilepic.isEmpty)
                            ? AppColor
                                .iconstext // Replace with your desired background color
                            : Colors.transparent,
                    backgroundImage: widget.friendProfilepic.isNotEmpty
                        ? NetworkImage(widget
                            .friendProfilepic) // Use friend's profile picture
                        : null, // If no friend's profile picture, set backgroundImage to null
                    child: (widget.friendProfilepic
                            .isEmpty) // Check if the profile picture is empty
                        ? const Icon(Icons.person,
                            size:
                                40) // Show icon if friend has no profile picture
                        : null, // Do not show anything if the profile picture is available
                  )),),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Obx(() => _buildStatColumn(
                        'Posts',
                        userprofileController
                            .friendPosts.length)), // Example stats
                    GestureDetector(
                      onTap: () {
                       
                        Get.to(() => UserFriendList(
                              friendsList: userprofileController
                                  .friendsoffreindsList, // Passing the list
                            ));
                      },
                      child: Obx(() => _buildStatColumn(
                          'Friends',
                          userprofileController.friendsoffreindsList
                              .length)), // Show friends count
                    ),
                    if(widget.friendrole == 'auth')
                    GestureDetector(
                      onTap: () {
                       
                        Get.to(() => UploadedBooks(userid: widget.friendId, isOwnProfile: false,));
                      },
                      child: Obx(() => _buildStatColumn(
                          'Books',
                          userprofileController.uploadedbooksCount
                              .value)), // Show friends count
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 2),

          // Username and bio section
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0), // Add padding here
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Align text to the start (left)
              children: [
                // Username
                Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // Distribute space between elements
                  children: [
                    Expanded(
                      // Allows the text to take the available width
                      child: Text(
                        widget.friendName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColor.white,
                          fontSize: 18, // Adjust the font size as needed
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2), // Spacing between username and about
                // About Text
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.start, // Align to the start
                  children: [
                    Expanded(
                      // Allows the text to take the available width
                      child: Text(
                        widget.friendAbout,
                        style: const TextStyle(
                          color: AppColor.iconstext,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action buttons: Share Profile & Friend Action (Add/Unfriend)
          // Updated Friend Button Logic in the UserProfile widget
          Padding(
  padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add padding around the row
  child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // ElevatedButton(
              //   onPressed: () {
              //     // Share profile logic here
              //   },
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: AppColor.cardcolor,
              //   ),
              //   child: const Text(
              //     "Share profile",
              //     style: TextStyle(color: AppColor.textwhitecolor),
              //   ),
              // ),

              // Friend Request Button
                 Flexible(
              child: Obx(() {
                return ElevatedButton(
                  onPressed: () {
                    if (userprofileController.isFriend.value) {
                      // Unfriend logic
                      userprofileController.unfriendUser(widget.friendId);
                    } else if (userprofileController
                        .friendRequestReceived.value) {
                      // Respond to friend request logic
                      userprofileController
                          .listenForIncomingFriendRequest(widget.friendId);
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          return RespondToRequest(
                              friendId: widget.friendId,
                              requestid:
                                  widget.requestid); // Pass the friend's ID
                        },
                      );
                    } else if (userprofileController.friendRequestSent.value) {
                      // Cancel friend request logic
                      userprofileController
                          .cancelFriendRequest(widget.friendId);
                    } else {
                      // Send friend request logic
                      userprofileController.sendFriendRequest(widget.friendId);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.unselected,
                    minimumSize: const Size(
                        350, 40), // Set the width to 200 and height to 50
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        userprofileController.isFriend.value
                            ? Icons.person_remove // Unfriend icon
                            : userprofileController.friendRequestReceived.value
                                ? Icons
                                    .mark_email_unread // Respond to friend request icon
                                : userprofileController.friendRequestSent.value
                                    ? Icons
                                        .person_add_disabled // Cancel request icon
                                    : Icons.person_add, // Add friend icon
                        color: AppColor.iconstext,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        userprofileController.isFriend.value
                            ? "Unfriend"
                            : userprofileController.friendRequestReceived.value
                                ? "Respond"
                                : userprofileController.friendRequestSent.value
                                    ? "Cancel Request"
                                    : "Add Friend",
                        style: const TextStyle(color: AppColor.iconstext),
                      ),
                    ],
                  ),
                );
              }),
                 )
            ],
          ),),

          const SizedBox(height: 16),

          // Posts or Books Selection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isPostsSelected = true;
                  });
                },
                child: Column(
                  children: [
                    SvgPicture.asset(AppAssets.listBox, // Path to your SVG file
                        width: 30, // Match the size of the original icon
                        height: 30,
                        color: isPostsSelected
                            ? AppColor.clickedbutton
                            : AppColor.iconstext),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      height: 2,
                      width: 60,
                      color: isPostsSelected
                          ? AppColor.clickedbutton
                          : Colors.transparent,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isPostsSelected = false;
                  });
                },
                child: Column(
                  children: [
                    SvgPicture.asset(AppAssets.library, // Path to your SVG file
                        width: 30, // Match the size of the original icon
                        height: 30,
                        color: !isPostsSelected
                            ? AppColor.clickedbutton
                            : AppColor.iconstext),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      height: 2,
                      width: 60,
                      color: !isPostsSelected
                          ? AppColor.clickedbutton
                          : Colors.transparent,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Posts or Add Friend Message
          // Display friend's posts
          isPostsSelected
              ? widget.isFriend
                  ? Expanded(
                      child: Obx(() {
                        if (userprofileController.friendPosts.isEmpty) {
                          return const Center(
                              child: Text(
                            'No posts available',
                            style: TextStyle(color: AppColor.iconstext),
                          ));
                        }

                        return ListView.builder(
                          itemCount: userprofileController.friendPosts.length,
                          itemBuilder: (context, index) {
                            final post =
                                userprofileController.friendPosts[index];

                            return Card(
                              margin: const EdgeInsets.all(8.0),
                              color: AppColor.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Post details (same as before)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CircleAvatar(
                                              radius: 20.0,
                                              backgroundImage: widget
                                                      .friendProfilepic
                                                      .isNotEmpty
                                                  ? NetworkImage(
                                                      widget.friendProfilepic)
                                                  : null,
                                              child: widget
                                                      .friendProfilepic.isEmpty
                                                  ? const Icon(
                                                      Icons.account_circle,
                                                      size: 30,
                                                      color: Color(0xFF5e3e17))
                                                  : null,
                                            ),
                                            const SizedBox(width: 6.0),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  widget.friendName,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColor.bgcolor),
                                                ),
                                                const SizedBox(height: 4.0),
                                                Text(
                                                  PostTime.timeAgo(
                                                      post['postTimestamp']),
                                                  style: const TextStyle(
                                                      color:
                                                          AppColor.unselected,
                                                      fontSize: 12.0),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8.0),
                                    // Post Text
                                    Text(
                                      post['postText'],
                                      style: const TextStyle(
                                          color: AppColor.bgcolor),
                                    ),
                                    const SizedBox(height: 8.0),
                                    // Like, Comment, and Share buttons
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        // Like Button Section
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: SvgPicture.asset(
                                                AppAssets.likeHeart,
                                                color: userprofileController
                                                        .likedPosts
                                                        .contains(
                                                            post['postId'])
                                                    ? AppColor.clickedbutton
                                                    : AppColor.hinttextcolor,
                                                width:
                                                    20, // Set the size of the SVG
                                                height: 20,
                                              ),
                                              onPressed: () =>
                                                  userprofileController
                                                      .onLikeButtonPressed(
                                                          post['postId']),
                                            ),
                                            const SizedBox(width: 4.0),
                                            Text('${post['likes']} Likes',
                                                style: const TextStyle(
                                                    color:
                                                        AppColor.unselected)),
                                          ],
                                        ),
                                        const SizedBox(width: 12.0),
                                        // Comment Section
                                        CommentSection(postId: post['postId']),
                                        const SizedBox(width: 12.0),
                                        // Share Section
                                        ShareSection(
                                            postId: post['postId']), // Share
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    )
                  : const Expanded(
                      child: Center(
                        child: Text('Add friend to see posts or books',
                            style: TextStyle(color: AppColor.iconstext)),
                      ),
                    )
              : GetBuilder<UserProfileController>(builder: (_) {
                  // Check if the user is not a friend
                  if (!widget.isFriend) {
                    // If not a friend, display "No books or posts available"
                    return const Padding(
                      padding: EdgeInsets.only(top: 195),
                      child: Center(
                        child: Text(
                          'Add Friend to see books',
                          style: TextStyle(color: AppColor.iconstext),
                        ),
                      ),
                    );
                  }

                  // If the user is a friend, proceed to check for book availability
                  if (userprofileController.readingBooks.isEmpty &&
                      userprofileController.planToReadBooks.isEmpty &&
                      userprofileController.finishedBooks.isEmpty) {
                    // If all book lists are empty, show "No books available"
                    return const Padding(
                      padding: EdgeInsets.only(top: 195),
                      child: Center(
                        child: Text(
                          'No books',
                          style: TextStyle(
                            color: AppColor.iconstext,
                          ),
                        ),
                      ),
                    );
                  }

                  return Flexible(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        // "Reading" Books Section
                        if (userprofileController.readingBooks.isNotEmpty)
                          SizedBox(
                            width: double.infinity,
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              color: AppColor.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(
                                    MediaQuery.of(context).size.width *
                                        0.04), // Adjust padding dynamically
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Reading',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: AppColor.bgcolor,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Get.to(() => const ViewAllUserBooks(
                                                  sectionTitle: 'Reading',
                                                  isOwnProfile: false,
                                                ));
                                          },
                                          child: const Text(
                                            'View All',
                                            style: TextStyle(
                                                color: AppColor.bgcolor),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${userprofileController.readingBooksCount} books',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColor.bgcolor,
                                      ),
                                    ),
                                    const SizedBox(height: 12.0),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: userprofileController
                                            .readingBooks
                                            .map((book) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: GestureDetector(
                                              onTap: () {},
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4.0),
                                                child: book['img'] != null
                                                    ? Image.network(
                                                        book['img'],
                                                        width: 40,
                                                        height: 60,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Container(
                                                        width: 40,
                                                        height: 60,
                                                        color: Colors.grey,
                                                        child: const Icon(
                                                          Icons.book,
                                                          size: 24,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 6),

                        // "Plan to Read" Books Section
                        if (userprofileController.planToReadBooks.isNotEmpty)
                          SizedBox(
                            width: double.infinity,
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              color: AppColor.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(
                                    MediaQuery.of(context).size.width * 0.04),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Plan to Read',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: AppColor.bgcolor,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Get.to(() => const ViewAllUserBooks(
                                                  sectionTitle: 'Plan to Read',
                                                  isOwnProfile: false,
                                                ));
                                          },
                                          child: const Text(
                                            'View All',
                                            style: TextStyle(
                                                color: AppColor.bgcolor),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      '${userprofileController.planToReadBooks.length} books',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColor.bgcolor,
                                      ),
                                    ),
                                    const SizedBox(height: 12.0),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: userprofileController
                                            .planToReadBooks
                                            .map((book) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: GestureDetector(
                                              onTap: () {},
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4.0),
                                                child: book['img'] != null
                                                    ? Image.network(
                                                        book['img'],
                                                        width: 40,
                                                        height: 60,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Container(
                                                        width: 40,
                                                        height: 60,
                                                        color: Colors.grey,
                                                        child: const Icon(
                                                          Icons.book,
                                                          size: 24,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 6),

                        // "Finished" Books Section
                        if (userprofileController.finishedBooks.isNotEmpty)
                          SizedBox(
                            width: double.infinity,
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              color: AppColor.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(
                                    MediaQuery.of(context).size.width * 0.04),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Finished',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: AppColor.bgcolor,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Get.to(() => const ViewAllUserBooks(
                                                  sectionTitle: 'Finished',
                                                  isOwnProfile: false,
                                                ));
                                          },
                                          child: const Text(
                                            'View All',
                                            style: TextStyle(
                                                color: AppColor.bgcolor),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      '${userprofileController.finishedBooks.length} books',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColor.bgcolor,
                                      ),
                                    ),
                                    const SizedBox(height: 12.0),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: userprofileController
                                            .finishedBooks
                                            .map((book) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: GestureDetector(
                                              onTap: () {},
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4.0),
                                                child: book['img'] != null
                                                    ? Image.network(
                                                        book['img'],
                                                        width: 40,
                                                        height: 60,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Container(
                                                        width: 40,
                                                        height: 60,
                                                        color: Colors.grey,
                                                        child: const Icon(
                                                          Icons.book,
                                                          size: 24,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        // else (Container(),)
                      ],
                    ),
                  );
                })
        ]),
      ),
    );
  }

  // Reusable Stats Column
  Widget _buildStatColumn(String label, int count) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: AppColor.white),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppColor.iconstext),
        ),
      ],
    );
  }
}
