import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/Books/view/component/books-details/controller/books_details_controller.dart';
import 'package:reedinook/screens/Books/view/component/books-details/view/books_details.dart';
import 'package:reedinook/screens/ChatList/controller/chat_lists_controller.dart';
import 'package:reedinook/screens/Dashboard/Home/controller/home_controller.dart';
import 'package:reedinook/screens/Dashboard/Profiles/my_profile/controller/profile_controller.dart';
import 'package:reedinook/screens/Dashboard/Profiles/my_profile/view/component/all_books/view/all_book.dart';
import 'package:reedinook/screens/Dashboard/Profiles/my_profile/view/component/edit_profile/controller/edit_profile_controller.dart';
import 'package:reedinook/screens/Dashboard/Profiles/my_profile/view/component/edit_profile/view/edit_proifle.dart';
import 'package:reedinook/screens/Dashboard/Profiles/my_profile/view/component/friend_list/view/friend_list.dart';
import 'package:reedinook/screens/Dashboard/Profiles/my_profile/view/component/uploaded_book/view/uploaded_books.dart';
import 'package:reedinook/utils/app_assets%20.dart';
import 'package:reedinook/utils/colors.dart';
import 'package:reedinook/utils/comments_section.dart';
import 'package:reedinook/utils/on_screen_picture.dart';
import 'package:reedinook/utils/post_time.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final HomeController homecontroller = Get.put(HomeController());
  final ProfileController profileController = Get.put(ProfileController());
  final EditProfileController editprofileController =
      Get.put(EditProfileController());
  final ChatListsController friendListController =
      Get.put(ChatListsController());

  List<Map<String, dynamic>> userPosts = [];
  Set<String> likedPosts = {};
  String currentUser = '';
  String role = '';
  bool isLoading = true;
  String aboutText = '';
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    currentUser = homecontroller.username;
    role = homecontroller.role;
    aboutText = homecontroller.about;
    friendListController.fetchFriends();
    _listenForUserPosts();
  }

  // Listen for real-time changes in user's posts
  void _listenForUserPosts() {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    // Listen to real-time changes in posts made by the current user
    var postsSubscription = _firestore
        .collection('posts')
        .where('username', isEqualTo: currentUser)
        .snapshots()
        .listen((postsSnapshot) {
      // print("Totla number of posts ${postsSnapshot.docs.length}");

      // Update the posts count in ProfileController
      profileController.updatePostsCount(postsSnapshot.docs.length);

      List<Map<String, dynamic>> fetchedPosts = [];

      for (final postDoc in postsSnapshot.docs) {
        // Listen to each post document for real-time updates (likes and comments)
        var postSubscription =
            postDoc.reference.snapshots().listen((updatedPostDoc) {
          List<dynamic> likedBy = updatedPostDoc.data()!.containsKey('likedBy')
              ? updatedPostDoc['likedBy']
              : []; // Initialize to empty list if it doesn't exist

          // Check if current user liked this post
          if (likedBy.contains(currentUser)) {
            likedPosts.add(updatedPostDoc.id); // Add to liked posts set
          } else {
            likedPosts.remove(updatedPostDoc.id); // Remove if unliked
          }

          // Update the local state with real-time post data
          setState(() {
            fetchedPosts = fetchedPosts
              ..add({
                'postDoc': updatedPostDoc,
                'postText': updatedPostDoc['text'],
                'postTimestamp': updatedPostDoc['timestamp'],
                'likes': updatedPostDoc['likes'] ?? 0,
                'comments': updatedPostDoc['comments'] ?? 0,
                'shares': updatedPostDoc['shares'] ?? 0,
                'likedBy': likedBy, // Store likedBy information
              });
          });
        });

        // Add the post subscription to the list
        _subscriptions.add(postSubscription);
      }

      // Sort posts by timestamp
      fetchedPosts.sort((a, b) => (b['postTimestamp'] as Timestamp)
          .compareTo(a['postTimestamp'] as Timestamp));

      setState(() {
        userPosts = fetchedPosts;
        isLoading = false; // Hide loading indicator
      });
    });

    // Add the posts subscription to the list
    _subscriptions.add(postsSubscription);
  }

  // Toggle like function remains unchanged
  void _toggleLike(String postId, DocumentSnapshot postDoc, int index) {
    int currentLikes = userPosts[index]['likes'];

    if (likedPosts.contains(postId)) {
      setState(() {
        likedPosts.remove(postId);
        currentLikes--;
        postDoc.reference.update({
          'likes': currentLikes,
          'likedBy': FieldValue.arrayRemove([currentUser])
        });
        userPosts[index]['likes'] = currentLikes;
      });
    } else {
      setState(() {
        likedPosts.add(postId);
        currentLikes++;
        postDoc.reference.update({
          'likes': currentLikes,
          'likedBy': FieldValue.arrayUnion([currentUser])
        });
        userPosts[index]['likes'] = currentLikes;
      });
    }
  }

  @override
  void dispose() {
    // Cancel all subscriptions when the widget is disposed
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

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

  bool isPostsSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgcolor,
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
            color: AppColor.iconstext,
            fontSize: 20,
            fontWeight: FontWeight.normal,
          ),
        ),
        backgroundColor: AppColor.bgcolor,
        iconTheme: const IconThemeData(
          color: AppColor.iconstext,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColor.iconstext),
            onPressed: () {
              profileController.logoutUser(context); // Call the logout method
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for Profile Picture and Stats
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture with left padding
                Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0), // Add left padding here
                  child: Obx(() =>GestureDetector(
        onTap: () {
          // Navigate to the Profile Picture Screen when the avatar is clicked
          Get.to(() => OnScreenPicture(profilePicUrl: editprofileController.profilePicUrl.value));
        }, 
                  
                  
                  
                 child: CircleAvatar(

                        radius: 40,
                        backgroundColor: (editprofileController
                                .profilePicUrl.value.isEmpty)
                            ? AppColor
                                .iconstext // Replace with your desired background color
                            : Colors.transparent,
                        backgroundImage:
                            editprofileController.profilePicUrl.isNotEmpty
                                ? NetworkImage(
                                    editprofileController.profilePicUrl.value)
                                : null,
                        child: editprofileController.profilePicUrl.isEmpty
                            ? const Icon(Icons.person,
                                size: 40, color: AppColor.unselected)
                            : null,
                      )),
                ),),
                const SizedBox(
                    width: 16), // Spacing between profile picture and stats
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Obx(() => _buildStatColumn(
                          'Posts', profileController.postsCount.value)),
                      GestureDetector(
                        onTap: () {
                          // Navigate to the FriendList screen
                          Get.to(() => const FriendList());
                        },
                        child: Obx(() => _buildStatColumn(
                            'Friends', profileController.friendsCount.value)),
                      ),
                      if (role == 'auth')
                        GestureDetector(
                          onTap: () {
                            final String userId =
                                FirebaseAuth.instance.currentUser!.uid;

                            // Navigate to the FriendList screen
                            Get.to(() => UploadedBooks(userid: userId, isOwnProfile: true));
                          },
                          // Uncomment the following line if you want to include Followers
                          child: Obx(() => _buildStatColumn('Books',
                              profileController.uploadedbooksCount.value)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2), // Spacing between stats and username

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
                          currentUser,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColor.white,
                            fontSize:
                                18, // You can adjust the font size as needed
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                      height: 2), // Spacing between username and about
                  // About Text
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.start, // Align to the start
                    children: [
                      Expanded(
                        // Allows the text to take the available width
                        child: Text(
                          aboutText,
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

            Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8.0), // Add padding around the row
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      // ElevatedButton(
                      //   onPressed: () {},
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: AppColor.cardcolor,
                      //   ),
                      //   child: const Text("Share profile",
                      //       style: TextStyle(color: AppColor.textwhitecolor)),
                      // ),

                      child: ElevatedButton(
                        onPressed: () async {
                          // Await the fetchUserData to complete before navigation
                          // await homecontroller.fetchUserData();

                          // // Navigate to EditProfile screen once data is fetched
                          Get.to(() => const EditProfile());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.unselected,
                          minimumSize: const Size(
                              350, 40), // Set the width to 200 and height to 50
                        ),
                        child: const Text("Edit profile",
                            style: TextStyle(color: AppColor.iconstext)),
                      ),
                    )
                  ],
                )),
            const SizedBox(height: 16),
            // Posts and Books Selection Row
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
                      SvgPicture.asset(
                          AppAssets.texticon, // Path to your SVG file
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
                      SvgPicture.asset(
                          AppAssets.library, // Path to your SVG file
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
            // Posts List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : isPostsSelected
                      ? userPosts.isEmpty
                          ? const Center(
                              child: Text(
                                'Nothing posted yet.',
                                style: TextStyle(
                                  color: AppColor.iconstext,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: userPosts.length,
                              itemBuilder: (context, index) {
                                // Sort the posts by 'postTimestamp' in descending order (most recent first)
                                userPosts.sort((a, b) {
                                  var timeA = a['postTimestamp'] as Timestamp;
                                  var timeB = b['postTimestamp'] as Timestamp;
                                  return timeB.compareTo(
                                      timeA); // Sorting in descending order
                                });
                                // Display each user post in a card
                                final post = userPosts[index];
                                final postDoc =
                                    post['postDoc'] as DocumentSnapshot;

                                return Card(
                                  margin: const EdgeInsets.all(8.0),
                                  color: AppColor.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Header Row for Profile Picture, User Name, and Options
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor:
                                                      (editprofileController
                                                              .profilePicUrl
                                                              .value
                                                              .isEmpty)
                                                          ? AppColor
                                                              .iconstext // Replace with your desired background color
                                                          : Colors.transparent,
                                                  backgroundImage:
                                                      editprofileController
                                                                  .profilePicUrl
                                                                  .value !=
                                                              ''
                                                          ? NetworkImage(
                                                              editprofileController
                                                                  .profilePicUrl
                                                                  .value)
                                                          : null,
                                                  child: editprofileController
                                                              .profilePicUrl
                                                              .value ==
                                                          ''
                                                      ? const Icon(
                                                          Icons.person,
                                                          size: 30,
                                                          color: AppColor
                                                              .unselected,
                                                        )
                                                      : null,
                                                ),
                                                const SizedBox(width: 6.0),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      currentUser,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColor.bgcolor,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4.0),
                                                    Text(
                                                      PostTime.timeAgo(post[
                                                          'postTimestamp']),
                                                      style: const TextStyle(
                                                        color:
                                                            AppColor.unselected,
                                                        fontSize: 12.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            PopupMenuButton<String>(
                                              icon: const Icon(
                                                Icons.more_vert,
                                                color: AppColor.unselected,
                                              ),
                                              onSelected: (String value) async {
                                                if (value == 'delete') {
                                                  await profileController
                                                      .deletePostAndComments(
                                                          postDoc.id);
                                                }
                                              },
                                              itemBuilder:
                                                  (BuildContext context) {
                                                return [
                                                  const PopupMenuItem<String>(
                                                    value: 'delete',
                                                    child: Center(
                                                      child: Text(
                                                        'Delete',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: AppColor
                                                                .iconstext),
                                                      ),
                                                    ),
                                                  ),
                                                ];
                                              },
                                              color: AppColor.unselected,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    20), // Adjust the radius as needed
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8.0),
                                        Text(
                                          post['postText'],
                                          style: const TextStyle(
                                              color: AppColor.bgcolor),
                                        ),
                                        const SizedBox(height: 8.0),
                                        Row(
                                          children: [
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: SvgPicture.asset(
                                                    AppAssets.likeHeart,
                                                    color: likedPosts.contains(
                                                            postDoc.id)
                                                        ? AppColor.clickedbutton
                                                        : AppColor
                                                            .hinttextcolor,
                                                    width:
                                                        20, // Set the size of the SVG
                                                    height: 20,
                                                  ),
                                                  onPressed: () => _toggleLike(
                                                      postDoc.id,
                                                      postDoc,
                                                      index),
                                                ),
                                                Text(
                                                  '${post['likes']} Likes',
                                                  style: const TextStyle(
                                                      color:
                                                          AppColor.unselected),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 12.0),
                                            CommentSection(postId: postDoc.id),
                                            const SizedBox(width: 12.0),
                                            Flexible(
                                              child: Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    AppAssets.share,
                                                    color:
                                                        AppColor.hinttextcolor,
                                                    width:
                                                        20, // Adjust SVG size
                                                    height: 20,
                                                  ),
                                                  const SizedBox(width: 4.0),
                                                  Flexible(
                                                    child: Text(
                                                      '${post['shares']} Shares',
                                                      style: const TextStyle(
                                                        color:
                                                            AppColor.unselected,
                                                        fontSize:
                                                            14.0, // Ensure consistent font size
                                                        overflow: TextOverflow
                                                            .ellipsis, // Handle long text
                                                      ),
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                      : Obx(
                          () => SingleChildScrollView(
                              // This makes the entire Column scrollable
                              child: Column(
                            children: [
                              // Show "No books available" if both lists are empty
                              if (profileController.readingBooks.isEmpty &&
                                  profileController.planToReadBooks.isEmpty &&
                                  profileController.finishedBooks.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(top: 195),
                                  child: Text(
                                    'No books Added...',
                                    style: TextStyle(
                                      color: AppColor.iconstext,
                                    ),
                                  ),
                                ),

                              // "Reading" Books Section
                              profileController.readingBooks.isNotEmpty
                                  ? SizedBox(
                                      width: double.infinity,
                                      child: Card(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 4.0),
                                        color: AppColor.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(MediaQuery.of(
                                                      context)
                                                  .size
                                                  .width *
                                              0.04), // Adjust padding dynamically
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text(
                                                    'Reading',
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColor.bgcolor,
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Get.to(() =>
                                                          const ViewAllBooks(
                                                            sectionTitle:
                                                                'Reading',
                                                            isOwnProfile: true,
                                                          ));
                                                    },
                                                    child: const Text(
                                                      'View All',
                                                      style: TextStyle(
                                                          color:
                                                              AppColor.bgcolor),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                '${profileController.readingBooks.length} books',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: AppColor.bgcolor,
                                                ),
                                              ),
                                              const SizedBox(height: 12.0),
                                              SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  children: profileController
                                                      .readingBooks
                                                      .map((book) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 8.0),
                                                      child: GestureDetector(      
                                                        onTap: () {
                          //                                      Get.delete<
                          // BookDetailsController>(); // Remove the controller
                                                          Get.to(
                                                              () =>
                                                                  BooksDetails(
                                                                    bookId: book[
                                                                        'id'],
                                                                    title: book[
                                                                            'title'] ??
                                                                        'Unknown Title',
                                                                    author: book[
                                                                            'author'] ??
                                                                        'Unknown Author',
                                                                    img: book[
                                                                            'img'] ??
                                                                        '',
                                                                    description:
                                                                        book['desc'] ??
                                                                            'No description available',
                                                                    rating: book['rating'] !=
                                                                            null
                                                                        ? book['rating']
                                                                            .toDouble()
                                                                        : 0.0,
                                                                    pages: book[
                                                                            'pages'] ??
                                                                        '0',
                                                                    isbn: book[
                                                                            'isbn'] ??
                                                                        'No isbn',
                                                                    bookFormate:
                                                                        book['bookformat'] ??
                                                                            'No bookformat',
                                                                  ));
                                                        },
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      4.0),
                                                          child: book['img'] !=
                                                                  null
                                                              ? Image.network(
                                                                  book['img'],
                                                                  width: 40,
                                                                  height: 60,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )
                                                              : Container(
                                                                  width: 40,
                                                                  height: 60,
                                                                  color: Colors
                                                                      .grey,
                                                                  child:
                                                                      const Icon(
                                                                    Icons.book,
                                                                    size: 24,
                                                                    color: Colors
                                                                        .white,
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
                                    )
                                  : Container(),
                              const SizedBox(height: 6),
                              // "Plan to Read" Books Section
                              profileController.planToReadBooks.isNotEmpty
                                  ? SizedBox(
                                      width: double.infinity,
                                      child: Card(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 4.0),
                                        color: AppColor.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(MediaQuery.of(
                                                      context)
                                                  .size
                                                  .width *
                                              0.04), // Adjust padding dynamically
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text(
                                                    'Plan to Read',
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColor.bgcolor,
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Get.to(() =>
                                                          const ViewAllBooks(
                                                            sectionTitle:
                                                                'Plan to Read',
                                                            isOwnProfile: true,
                                                          ));
                                                    },
                                                    child: const Text(
                                                      'View All',
                                                      style: TextStyle(
                                                          color:
                                                              AppColor.bgcolor),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4.0),
                                              Text(
                                                '${profileController.planToReadBooks.length} books',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: AppColor.bgcolor,
                                                ),
                                              ),
                                              const SizedBox(height: 12.0),
                                              SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  children: profileController
                                                      .planToReadBooks
                                                      .map((book) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 8.0),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          // Navigate to Book Details screen
                                                          Get.to(
                                                              () =>
                                                                  BooksDetails(
                                                                    bookId: book[
                                                                        'id'],
                                                                    title: book[
                                                                            'title'] ??
                                                                        'Unknown Title',
                                                                    author: book[
                                                                            'author'] ??
                                                                        'Unknown Author',
                                                                    img: book[
                                                                            'img'] ??
                                                                        '',
                                                                    description:
                                                                        book['desc'] ??
                                                                            'No description available',
                                                                    rating: book['rating'] !=
                                                                            null
                                                                        ? book['rating']
                                                                            .toDouble()
                                                                        : 0.0,
                                                                    pages: book[
                                                                            'pages'] ??
                                                                        '0',
                                                                    isbn: book[
                                                                            'isbn'] ??
                                                                        'No isbn',
                                                                    bookFormate:
                                                                        book['bookformat'] ??
                                                                            'No bookformat',
                                                                  ));
                                                        },
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      4.0),
                                                          child: book['img'] !=
                                                                  null
                                                              ? Image.network(
                                                                  book['img'],
                                                                  width: 40,
                                                                  height: 60,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )
                                                              : Container(
                                                                  width: 40,
                                                                  height: 60,
                                                                  color: Colors
                                                                      .grey,
                                                                  child:
                                                                      const Icon(
                                                                    Icons.book,
                                                                    size: 24,
                                                                    color: Colors
                                                                        .white,
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
                                    )
                                  : Container(),

                              const SizedBox(height: 6),
                              // "Finished" Books Section
                              profileController.finishedBooks.isNotEmpty
                                  ? SizedBox(
                                      width: double.infinity,
                                      child: Card(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 4.0),
                                        color: AppColor.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(MediaQuery.of(
                                                      context)
                                                  .size
                                                  .width *
                                              0.04), // Adjust padding dynamically
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text(
                                                    'Finished',
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColor.bgcolor,
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Get.to(() =>
                                                          const ViewAllBooks(
                                                            sectionTitle:
                                                                'Finished',
                                                            isOwnProfile: true,
                                                          ));
                                                    },
                                                    child: const Text(
                                                      'View All',
                                                      style: TextStyle(
                                                          color:
                                                              AppColor.bgcolor),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4.0),
                                              Text(
                                                '${profileController.finishedBooks.length} books',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: AppColor.bgcolor,
                                                ),
                                              ),
                                              const SizedBox(height: 12.0),
                                              SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  children: profileController
                                                      .finishedBooks
                                                      .map((book) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 8.0),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                           Get.delete<
                          BookDetailsController>(); // Remove the controller
                                                          // Navigate to Book Details screen
                                                          Get.to(
                                                              () =>
                                                                  BooksDetails(
                                                                    bookId: book[
                                                                        'id'],
                                                                    title: book[
                                                                            'title'] ??
                                                                        'Unknown Title',
                                                                    author: book[
                                                                            'author'] ??
                                                                        'Unknown Author',
                                                                    img: book[
                                                                            'img'] ??
                                                                        '',
                                                                    description:
                                                                        book['desc'] ??
                                                                            'No description available',
                                                                    rating: book['rating'] !=
                                                                            null
                                                                        ? book['rating']
                                                                            .toDouble()
                                                                        : 0.0,
                                                                    pages: book[
                                                                            'pages'] ??
                                                                        '0',
                                                                    isbn: book[
                                                                            'isbn'] ??
                                                                        'No isbn',
                                                                    bookFormate:
                                                                        book['bookformat'] ??
                                                                            'No bookformat',
                                                                  ));
                                                        },
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      4.0),
                                                          child: book['img'] !=
                                                                  null
                                                              ? Image.network(
                                                                  book['img'],
                                                                  width: 40,
                                                                  height: 60,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )
                                                              : Container(
                                                                  width: 40,
                                                                  height: 60,
                                                                  color: Colors
                                                                      .grey,
                                                                  child:
                                                                      const Icon(
                                                                    Icons.book,
                                                                    size: 24,
                                                                    color: Colors
                                                                        .white,
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
                                    )
                                  : Container(),
                            ],
                          )),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
