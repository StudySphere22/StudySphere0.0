import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/ChatList/controller/chat_lists_controller.dart';
import 'package:reedinook/screens/Dashboard/Profiles/my_profile/controller/profile_controller.dart';
import 'package:reedinook/utils/app_assets%20.dart';
import 'package:reedinook/utils/colors.dart';
import 'package:reedinook/utils/comments_section.dart';
import 'package:reedinook/utils/post_time.dart';
import 'package:reedinook/utils/share_section.dart';

class PostsList extends StatefulWidget {
  const PostsList({
    super.key,
  });

  @override
  _PostsListState createState() => _PostsListState();
}

class _PostsListState extends State<PostsList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ChatListsController controller = Get.put(ChatListsController());
  final ProfileController profileController = Get.put(ProfileController());
  List<Map<String, dynamic>> friendsWithPosts = [];
  Set<String> likedPosts = {}; // Track liked posts using their IDs
  String currentUser = ''; // Variable to store the current user's username
  String profilePicUrl = '';
  bool isLoading = true; // Add loading state
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUser(); // Fetch current user detail
  }

  void _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser; // Get current user
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          currentUser =
              userDoc['username']; // Assuming 'username' is the field name
               profilePicUrl =
              userDoc['profilePicUrl']; // Assuming 'username' is the field name
        });
        print("Current user: $currentUser");
          print("Current user: $profilePicUrl");

        // After fetching the current user, fetch friends
        _fetchFriends();
      }
    }
  }

  void _fetchFriends() {
    setState(() {
      isLoading = true;
    });

    try {
      final currentUserDoc = _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      final friendsCollectionRef = currentUserDoc.collection('friends');

      // Listen for changes in the friends collection
      friendsCollectionRef.snapshots().listen((friendsSnapshot) {
        List<String> friendUsernames = [];

        for (final friendDoc in friendsSnapshot.docs) {
          friendUsernames.add(friendDoc['friendName']);
          // friendUsernames.add(friendDoc['about']);
          //    friendUsernames.add(friendDoc['friendId']);
        }

        // Start listening for friends' posts in real-time
        _listenForFriendsPosts(friendUsernames);
      });
    } catch (e) {
      print("Error fetching friends: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _listenForFriendsPosts(List<String> friendUsernames) {
    if (friendUsernames.isNotEmpty) {
      // Clear existing posts to avoid duplication
      friendsWithPosts.clear();

      var postsSubscription = _firestore
          .collection('posts')
          .where('username', whereIn: friendUsernames)
          .snapshots()
          .listen((postsSnapshot) {
        for (final postDoc in postsSnapshot.docs) {
          var postId = postDoc.id;

          // Check if the post already exists in friendsWithPosts
          int existingPostIndex = friendsWithPosts
              .indexWhere((post) => post['postDoc'].id == postId);

          // If the post does not exist, add it
          if (existingPostIndex == -1) {
            var likedBy =
                postDoc.data().containsKey('likedBy') ? postDoc['likedBy'] : [];
            bool isLikedByCurrentUser = likedBy.contains(currentUser);

            // Only call setState if the widget is mounted
            if (mounted) {
              setState(() {
                friendsWithPosts.add({
                  'friendName': postDoc['username'],
                  'profilePicUrl': postDoc['profilePicUrl'],
                  'postDoc': postDoc,
                  'postText': postDoc['text'],
                  'postTimestamp': postDoc['timestamp'],
                  'likes': postDoc['likes'] ?? 0,
                  'comments': postDoc['comments'] ?? 0,
                  'shares': postDoc['shares'] ?? 0,
                  'likedBy': likedBy,
                  'isLikedByCurrentUser':
                      isLikedByCurrentUser, // Track liked state
                });
              });
            }
          } else {
            // Update the existing post
            var updatedPostDoc = postDoc.data();
            if (mounted) {
              setState(() {
                friendsWithPosts[existingPostIndex]['likes'] =
                    updatedPostDoc['likes'] ?? 0;
                friendsWithPosts[existingPostIndex]['likedBy'] =
                    updatedPostDoc['likedBy'] ?? [];
                friendsWithPosts[existingPostIndex]['isLikedByCurrentUser'] =
                    friendsWithPosts[existingPostIndex]['likedBy']
                        .contains(currentUser);
              });
            }
          }

          // Set up an individual listener for the post
          var postSubscription =
              postDoc.reference.snapshots().listen((updatedPostDoc) {
            // Ensure the widget is mounted before calling setState
            if (mounted) {
              var likedBy = updatedPostDoc.data()!.containsKey('likedBy')
                  ? updatedPostDoc['likedBy']
                  : [];
              int index = friendsWithPosts.indexWhere(
                  (post) => post['postDoc'].id == updatedPostDoc.id);

              // Update the post in friendsWithPosts
              if (index != -1) {
                // Check if the current user is in the likedBy array
                if (likedBy.contains(currentUser)) {
                  if (!likedPosts.contains(updatedPostDoc.id)) {
                    likedPosts.add(updatedPostDoc
                        .id); // Add to likedPosts if not already present
                  }
                } else {
                  likedPosts.remove(updatedPostDoc
                      .id); // Remove from likedPosts if the user unlikes
                }

                // Only call setState if the widget is mounted
                if (mounted) {
                  setState(() {
                    friendsWithPosts[index]['likedBy'] =
                        likedBy; // Update likedBy list
                    friendsWithPosts[index]['likes'] =
                        likedBy.length; // Update likes count
                  });
                }
              }
            }
          });

          // Add the individual post subscription to _subscriptions
          _subscriptions.add(postSubscription);
        }

        // Update loading state
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      });

      // Add the posts subscription to _subscriptions
      _subscriptions.add(postsSubscription);
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleLike(String postId, DocumentSnapshot postDoc, int index) async {
    int currentLikes = friendsWithPosts[index]['likes'];
     final postDoc = await FirebaseFirestore.instance.collection('posts').doc(postId).get();
    final postOwnerId = postDoc.data()?['postOwnerId'];

    if (likedPosts.contains(postId)) {
      likedPosts.remove(postId);
      currentLikes--;
      friendsWithPosts[index]['likes'] = currentLikes;

      postDoc.reference.update({
        'likes': currentLikes,
        'likedBy': FieldValue.arrayRemove([currentUser]),
      }).then((_) {
        print("Post unliked.");
      }).catchError((error) {
        print("Error unliking post: $error");
      });
    } else {
      likedPosts.add(postId);
      currentLikes++;
      friendsWithPosts[index]['likes'] = currentLikes;

      postDoc.reference.update({
        'likes': currentLikes,
        'likedBy': FieldValue.arrayUnion([currentUser]),
      }).then((_) async {
        print("Post liked.");
        
         // Send like notification
         final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (postOwnerId != currentUserId) {
        final notificationData = {
          'senderId': currentUserId,
          'receiverId': postOwnerId,
          'message': "$currentUser liked your post",
          'profilePicUrl': profilePicUrl,
          'timestamp': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance
            .collection('notifications')
            .doc(postOwnerId)
            .collection('likeNotifications')
            .add(notificationData)
            .then((_) {
              print("Like notification sent to $postOwnerId");
            })
            .catchError((error) {
              print("Error sending like notification: $error");
            });
      }



      }).catchError((error) {
        print("Error liking post: $error");
      });
    }

    // Update local state for UI
    if (mounted) {
      setState(() {
        // Update liked state
        friendsWithPosts[index]['isLikedByCurrentUser'] =
            likedPosts.contains(postId);
      });
    }
  }

  @override
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgcolor,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : friendsWithPosts.isEmpty
                ? const Center(
                    child: Text(
                    'No posts available.',
                    style: TextStyle(color: AppColor.iconstext),
                  ))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: friendsWithPosts.length,
                    itemBuilder: (context, index) {
                      // Sort the posts by 'postTimestamp' in descending order (most recent first)
                      friendsWithPosts.sort((a, b) {
                        var timeA = a['postTimestamp'] as Timestamp;
                        var timeB = b['postTimestamp'] as Timestamp;
                        return timeB
                            .compareTo(timeA); // Sorting in descending order
                      });

                      final post = friendsWithPosts[index];
                      final postDoc = post['postDoc'] as DocumentSnapshot;

                      return Card(
                        margin: const EdgeInsets.all(9.0),
                        color: AppColor.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Post header with profile picture and time
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      // Get.delete<UserProfileController>();
//         print('Friend Name: ${post['friendName']}');
// print('Friend About: ${post['about']}');
// print('Friend Profile Pic URL: ${post['profilePicUrl']}');
// print('Friend ID: ${post['friendId']}');

                                      //   Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //       builder: (context) => UserProfile(
                                      //         friendName: post['friendName'] ?? '', // Default to 'Unknown' if null

                                      //         friendAbout: user['about'] ?? '', // Default if null
                                      //         friendProfilepic: post['profilePicUrl'] ?? '', // Default if null
                                      //         friendId: post['friendId'] ?? '', // Default if null
                                      //         isFriend: true,
                                      //       ),
                                      //     ),
                                      //   );
                                    },
                                    child: CircleAvatar(
                                      radius: 20.0,
                                      backgroundColor: (post['profilePicUrl'] ==
                                                  null ||
                                              post['profilePicUrl'].isEmpty)
                                          ? AppColor
                                              .iconstext // Replace with your desired background color
                                          : Colors
                                              .transparent, // No background color if profile picture exists
                                      backgroundImage: (post['profilePicUrl'] !=
                                                  null &&
                                              post['profilePicUrl'].isNotEmpty)
                                          ? NetworkImage(post['profilePicUrl'])
                                          : null, // No image if null or empty
                                      child: (post['profilePicUrl'] == null ||
                                              post['profilePicUrl'].isEmpty)
                                          ? const Icon(
                                              Icons.person,
                                              size: 30,
                                              color: AppColor.unselected,
                                            )
                                          : null, // Icon if no profile picture
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post['friendName'] ??
                                              'Unknown', // Default 'Unknown' if null
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColor.bgcolor,
                                          ),
                                        ),
                                        Text(
                                          PostTime.timeAgo(
                                              post['postTimestamp'] ??
                                                  0), // Default to 0 if null
                                          style: const TextStyle(
                                            color: AppColor.unselected,
                                            fontSize: 12.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              // Post content
                              Text(
                                post['postText'],
                                style: const TextStyle(color: AppColor.bgcolor),
                              ),

                              const SizedBox(height: 8.0),
                              // Post actions
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: SvgPicture.asset(
                                          AppAssets.likeHeart,
                                          color: likedPosts.contains(postDoc.id)
                                              ? AppColor.clickedbutton
                                              : AppColor.hinttextcolor,
                                          width: 20, // Set the size of the SVG
                                          height: 20,
                                        ),
                                        onPressed: () => _toggleLike(
                                            friendsWithPosts[index]['postDoc']
                                                .id,
                                            friendsWithPosts[index]['postDoc'],
                                            index),
                                      ),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        '${post['likes']} Likes',
                                        style: const TextStyle(
                                            color: AppColor.unselected),
                                      ),
                                    ],
                                  ),
                                  CommentSection(
                                      postId: postDoc.id), // Comments
                                  ShareSection(postId: postDoc.id), // Share
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
