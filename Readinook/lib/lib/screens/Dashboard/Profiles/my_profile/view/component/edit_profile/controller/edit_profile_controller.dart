import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reedinook/screens/Dashboard/Home/view/home.dart';
import 'package:reedinook/utils/custom_snackbar.dart';

class EditProfileController extends GetxController {
  // Controllers for form fields
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();
  final picker = ImagePicker();
  var profilePicUrl = ''.obs; // Observable for profile picture URL
  var isLoading = false.obs; // Observable loading state for image picking
  String initialFullName = '';
  String initialEmail = '';
  String initialAbout = '';

  final usernameError = RxString('');

bool isUsernameValid(String username) {
  return !(username.startsWith('-') || RegExp(r'^\d').hasMatch(username));
}

  void setInitialValues(String fullName, String email, String about) {
    initialFullName = fullName;
    initialEmail = email;
    initialAbout = about;
  }

  // Method to check for changes
  bool hasChanges() {
    return fullNameController.text != initialFullName ||
        emailController.text != initialEmail ||
        aboutController.text != initialAbout;
  }

  // Method to update user data
  Future<void> updateUserData() async {
    isLoading.value = true;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;
      final updatedusername = fullNameController.text.trim();
      final updatedabout = aboutController.text.trim();

      try {

         if (!isUsernameValid(updatedusername)) {
    customSnackbar(title: 'Error', message: 'Invalid username. It cannot start with a number or negative sign.');
    return;
  }
        final userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        final currentUsername = userDoc.data()?['username'] ?? '';
        final currentuserabout = userDoc.data()?['about'] ?? '';

        // Check if username or about needs an update
        // Check if username or about needs an update
        final isUsernameChanged = currentUsername != updatedusername;
        final isAboutChanged = currentuserabout != updatedabout;

        // Validation checks
        if (updatedusername.isEmpty) {
          customSnackbar(title: 'Error', message: 'Full name cannot be empty.');
          isLoading.value = false;
          return;
        }
        // if (updatedabout.isEmpty) {
        //   customSnackbar(title: 'Error',message:  'About cannot be empty.');
        //   isLoading.value = false;
        //   return;
        // }

        if (isAboutChanged) {
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            if (isAboutChanged) 'about': updatedabout,
          }, SetOptions(merge: true));

          // 2. Fetch all the friends who have added this user
          final friendsSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('friends')
              .get();

          // 3. Update the username in each friend's friend list
          for (var friendDoc in friendsSnapshot.docs) {
            final friendId = friendDoc['friendId'];

            // Update the friend's list with the new username
            await FirebaseFirestore.instance
                .collection('users')
                .doc(friendId)
                .collection('friends')
                .where('friendId', isEqualTo: uid)
                .get()
                .then((friendQuery) {
              for (var doc in friendQuery.docs) {
                doc.reference.update({
                  'about': aboutController.text, // Update the friend's username
                });
              }
            });
          }
          customSnackbar(title: "Success", message: "About update");
          Get.to(() => const Home());

          isLoading.value = false;
          return;
        }
        // Check if the username already exists
        final usernameExists = await _checkUsernameExists(updatedusername);

        if (usernameExists) {
          // If username exists, show an error message
          customSnackbar(
              title: 'Error',
              message: 'Username is already taken. Please choose another one.');
          isLoading.value = false;
          return;
        }
        //   // 1. Update the user's own profile
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          if (isUsernameChanged) 'username': updatedusername,
        }, SetOptions(merge: true));

        // 2. Fetch all the friends who have added this user
        final friendsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('friends')
            .get();

        // 3. Update the username in each friend's friend list
        for (var friendDoc in friendsSnapshot.docs) {
          final friendId = friendDoc['friendId'];

          // Update the friend's list with the new username
          await FirebaseFirestore.instance
              .collection('users')
              .doc(friendId)
              .collection('friends')
              .where('friendId', isEqualTo: uid)
              .get()
              .then((friendQuery) {
            for (var doc in friendQuery.docs) {
              doc.reference.update({
                'friendName':
                    fullNameController.text, // Update the friend's username
              });
            }
          });
        }
        // 4. Update posts where the current user is the post owner
        final postsSnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .where('postOwnerId', isEqualTo: uid)
            .get();

        for (var postDoc in postsSnapshot.docs) {
          // Update the username in the post if the current user is the post owner
          await postDoc.reference.update({
            'username':
                fullNameController.text, // Update the post owner username
          });

          // 5. Update the 'likedBy' field if it contains the user's old username
          final likedBy = postDoc['likedBy'] ?? [];
          for (int i = 0; i < likedBy.length; i++) {
            if (likedBy[i] == initialFullName) {
              // Replace the old username with the new one
              likedBy[i] = fullNameController.text;
            }
          }

          // Update the post's likedBy list in Firestore
          await postDoc.reference.update({
            'likedBy':
                likedBy, // Update the likedBy field with the new username
          });
        }

        // 6. Update posts where the user has liked them (likedBy contains the old username)
        final postsLikedByUserSnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .where('likedBy',
                arrayContains:
                    initialFullName) // Find posts where the user has liked them
            .get();

        for (var postDoc in postsLikedByUserSnapshot.docs) {
          final likedBy = postDoc['likedBy'] ?? [];
          for (int i = 0; i < likedBy.length; i++) {
            if (likedBy[i] == initialFullName) {
              // Replace the old username with the new one
              likedBy[i] = fullNameController.text;
            }
          }

          // Update the post's likedBy list in Firestore
          await postDoc.reference.update({
            'likedBy':
                likedBy, // Update the likedBy field with the new username
          });
        }

        // Fetch all group chats
        final groupChatsSnapshot =
            await FirebaseFirestore.instance.collection('group_chats').get();

        for (var groupChatDoc in groupChatsSnapshot.docs) {
          // Update the members array in each group chat
          final members = groupChatDoc['members'] as List<dynamic>;
          for (int i = 0; i < members.length; i++) {
            if (members[i]['userName'] == initialFullName) {
              members[i]['userName'] =
                  fullNameController.text; // Update the username
            }
          }
          await groupChatDoc.reference.update({'members': members});

          // Update the senderName in the messages subcollection
          final messagesSnapshot = await groupChatDoc.reference
              .collection('messages')
              .where('senderName', isEqualTo: initialFullName)
              .get();

          for (var messageDoc in messagesSnapshot.docs) {
            await messageDoc.reference
                .update({'senderName': fullNameController.text});
          }
        }

        // 1. Update the user's own profile
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'username': updatedusername,
        }, SetOptions(merge: true));

        // print('User profile updated');

        // 2. Fetch the friends of the current user
        final friendssSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('friends')
            .get();

        List<String> friendIds = [];
        for (var friendDoc in friendssSnapshot.docs) {
          friendIds.add(friendDoc.id); // Add the friend IDs to the list
        }

        // print('Fetched friends: $friendIds');

        // 3. Iterate through the friends and check their posts
        List<String> friendPostIds = [];
        for (var friendId in friendIds) {
          // Fetch posts made by friends (assuming posts are stored in a `posts` collection)
          final postsSnapshot = await FirebaseFirestore.instance
              .collection('posts')
              .where('postOwnerId', isEqualTo: friendId)
              .get();

          for (var postDoc in postsSnapshot.docs) {
            friendPostIds.add(postDoc.id); // Save the postId of friend's posts
          }
        }

        // print('Friend postIds: $friendPostIds');

        // 4. Iterate through comments and match postId with friend's postIds
        for (var postId in friendPostIds) {
          final postCommentsSnapshot = await FirebaseFirestore.instance
              .collection('comments')
              .doc(postId)
              .collection('postComments')
              .get();

          for (var postCommentDoc in postCommentsSnapshot.docs) {
            final senderName =
                postCommentDoc['username']; // Ensure this field is correct
            // print('Checking comment by $senderName on postId: $postId');
            // print('Comment data: ${postCommentDoc.data()}');

            // 5. Check if the senderName is the same as the initial username
            if (senderName == initialFullName) {
              print(
                  'Preparing to update senderName for comment ID: ${postCommentDoc.id}');

              // Ensure the senderName is different from the current username before updating
              if (postCommentDoc['username'] != updatedusername) {
                // print('Updating senderName for comment ID: ${postCommentDoc.id}');
                await postCommentDoc.reference.update({
                  'username': updatedusername,
                });
                // print('Updated senderName to: $username');
              } else {
                // print('No update needed for comment ID: ${postCommentDoc.id} (senderName is already $username)');
              }
            }
          }
        }

        // Update username in chat rooms posts sub-collections
  

    final chatRoomsSnapshot =
        await FirebaseFirestore.instance.collection('chat_rooms').get();

    for (var chatRoomDoc in chatRoomsSnapshot.docs) {
      // Fetch posts in this chat room where postOwnerId matches the current user ID
      final postsSnapshot = await chatRoomDoc.reference
          .collection('posts')
          .where('postOwnerId', isEqualTo: uid) // Filter by current user
          .get();

      for (var postDoc in postsSnapshot.docs) {
        // Update the username in this post
        await postDoc.reference.update({
          'username': updatedusername,
        });
      }
    }
        // Success message
        customSnackbar(title: "Success", message: 'Profile updated!');
        Get.to(() => const Home());
      } catch (e) {
        // Error handling
        customSnackbar(title: 'Error', message: 'Failed to update profile: $e');
      } finally {
        // Stop loading
        isLoading.value = false;
      }
    } else {
      customSnackbar(title: 'Error', message: 'User not found');
      isLoading.value = false;
    }
  }

// Check if the username already exists
  Future<bool> _checkUsernameExists(String username) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      return querySnapshot
          .docs.isNotEmpty; // Returns true if the username exists
    } catch (e) {
      customSnackbar(
          title: 'Error', message: 'Error checking username availability: $e');
      return false;
    }
  }

  Future<void> pickImage() async {
    try {
      isLoading.value =
          true; // Set loading to true when starting the image picking
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final uid = user.uid;
          final storageRef =
              FirebaseStorage.instance.ref().child('profile_pics/$uid');
          final uploadTask = storageRef.putFile(File(pickedFile.path));

          // Show loading indicator while uploading
          uploadTask.snapshotEvents.listen((taskSnapshot) {});

          final downloadUrl = await (await uploadTask).ref.getDownloadURL();

          // Update Firestore
          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            'profilePicUrl': downloadUrl,
          });

          // Update profile picture URL in this controller
          profilePicUrl.value = downloadUrl; // Store the URL in the observable

          // Step 1: Fetch all friends of the current user
        final friendsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('friends') // Assuming friends are stored in a subcollection
            .get();

        for (var friendDoc in friendsSnapshot.docs) {
          final friendId = friendDoc.id;

          // Step 2: Fetch the friends collection of each friend and update the profilePicUrl
          final friendsOfFriendSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(friendId)
              .collection('friends') // Subcollection of the friend's friends
              .get();

          for (var friendOfFriendDoc in friendsOfFriendSnapshot.docs) {
            // Update the `friendProfilePicUrl` for each friend of a friend
            await friendOfFriendDoc.reference.update({
              'friendProfilePicUrl': downloadUrl,
            });
          }


        List<String> friendIds = [];
        for (var friendDoc in friendsOfFriendSnapshot.docs) {
          friendIds.add(friendDoc.id); // Add the friend IDs to the list
        }
        List<String> friendPostIds = [];
        for (var friendId in friendIds) {
          final postsSnapshot = await FirebaseFirestore.instance
              .collection('posts')
              .where('postOwnerId', isEqualTo: friendId)
              .get();

          for (var postDoc in postsSnapshot.docs) {
            friendPostIds.add(postDoc.id); // Save the postId of friend's posts
          }
        }
        for (var postId in friendPostIds) {
          final postCommentsSnapshot = await FirebaseFirestore.instance
              .collection('comments')
              .doc(postId)
              .collection('postComments')
              .get();

          for (var postCommentDoc in postCommentsSnapshot.docs) {
            final senderName =
                postCommentDoc['username']; // Ensure this field is correct
            // print('Checking comment by $senderName on postId: $postId');
            // print('Comment data: ${postCommentDoc.data()}');


            if (senderName == initialFullName) {
              print(
                  'Preparing to update senderName for comment ID: ${postCommentDoc.id}');

              // Ensure the senderName is different from the current username before updating
              if (postCommentDoc['profilePicUrl'] != downloadUrl) {
                // print('Updating senderName for comment ID: ${postCommentDoc.id}');
                await postCommentDoc.reference.update({
                  'profilePicUrl': downloadUrl,
                });
                // print('Updated senderName to: $username');
              } else {
                // print('No update needed for comment ID: ${postCommentDoc.id} (senderName is already $username)');
              }
            }
          }
        }
        }

          // Step 3: Fetch all posts where postOwnerId matches the current user
          final postsSnapshot = await FirebaseFirestore.instance
              .collection('posts')
              .where('postOwnerId', isEqualTo: uid)
              .get();

          // Step 4: Update the profile picture URL in each post where the user is the owner
          for (var postDoc in postsSnapshot.docs) {
            await postDoc.reference.update({
              'profilePicUrl':
                  downloadUrl, // Update profile picture URL in the post
            });
          }
          // **Step 5: Update profile picture in `group_chats` members array**
          final groupChatsSnapshot =
              await FirebaseFirestore.instance.collection('group_chats').get();

          for (var groupChatDoc in groupChatsSnapshot.docs) {
            final membersList = List.from(groupChatDoc['members']);

            // Update `profilePicUrl` for the current user in the members array
            for (int i = 0; i < membersList.length; i++) {
              if (membersList[i]['userId'] == uid) {
                membersList[i]['profilePicUrl'] = downloadUrl;
              }
            }

            // Update the document with the modified members list
            await groupChatDoc.reference.update({
              'members': membersList,
            });
          }

          customSnackbar(title: "Success", message: 'Profile picture updated!');
        }
      } else {
        customSnackbar(title: 'Info', message: 'No image selected');
      }
    } catch (e) {
      customSnackbar(title: 'Error', message: 'Error: ${e.toString()}');
    } finally {
      isLoading.value = false; // Set loading to false after the operation
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    aboutController.dispose();
    super.onClose();
  }
}
