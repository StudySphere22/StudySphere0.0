import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/Authentication/Login/view/login.dart';
import 'package:reedinook/screens/Books/controller/books_controller.dart';
import 'package:reedinook/screens/ChatList/controller/chat_lists_controller.dart';
import 'package:reedinook/screens/Chats/controller/chat_controller.dart';
import 'package:reedinook/screens/Dashboard/Home/controller/home_controller.dart';
import 'package:reedinook/screens/Dashboard/Home/view/component/comments/controller/comments_controller.dart';
import 'package:reedinook/screens/Dashboard/Home/view/component/shares/controller/share_controller.dart';
import 'package:reedinook/screens/Dashboard/Profiles/my_profile/controller/profile_controller.dart';
import 'package:reedinook/screens/Dashboard/Profiles/my_profile/view/component/change_password/controller/change_password_controller.dart';
import 'package:reedinook/screens/Dashboard/Profiles/my_profile/view/component/edit_profile/controller/edit_profile_controller.dart';
import 'package:reedinook/screens/Dashboard/Searchfriend/controller/searchfriend_controller.dart';
import 'package:reedinook/screens/Friendreq/controller/friendreq_controller.dart';
import 'package:reedinook/utils/colors.dart';
import 'package:reedinook/utils/custom_loading_indicator.dart';
import 'package:reedinook/utils/custom_snackbar.dart';

class ClearDataWidget extends StatefulWidget {
  @override
  _ClearDataWidgetState createState() => _ClearDataWidgetState();
}

class _ClearDataWidgetState extends State<ClearDataWidget> {
  @override
  void initState() {
    super.initState();
    // Delay the execution of _clearDataAndLogout to ensure it's called after the widget has built.
    Future.microtask(() => _clearDataAndLogout());
  }

  Future<void> _clearDataAndLogout() async {
    await _logoutUser();
  }

  Future<void> _logoutUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Set user's status to 'offline' in their document
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'status': 'offline',
        });

        // Update the status in all friends' collections
        await _updateStatusInFriendsCollection(user.uid, 'offline');
      }

      // Now sign out from Firebase
      await FirebaseAuth.instance.signOut();

       Get.delete<HomeController>(); 
      Get.delete<ProfileController>(); 
      Get.delete<ChatListsController>();
       Get.delete<ChatController>();
      Get.delete<SearchFriendController>();
      Get.delete<FriendRequestController>();
       Get.delete<EditProfileController>();
         Get.delete<Notification>();
           Get.delete<ShareController>();
             Get.delete<CommentsController>();
              Get.delete<ChangePasswordController>();
               Get.delete<BooksController>();
      

      // Navigate to login screen after successful logout
      Get.offAll(() => const MyLogin());
    } catch (e) {
      customSnackbar(title: 'Error', message: 'Failed to logout. Please try again.');
    }
  }

  // Function to update status in friends' collection
Future<void> _updateStatusInFriendsCollection(String userId, String status) async {
  try {
    // Get the friends sub-collection for the current user
    CollectionReference friendsCollection = FirebaseFirestore.instance.collection('users').doc(userId).collection('friends');

    // Get all friends in the collection
    QuerySnapshot friendsSnapshot = await friendsCollection.get();

    // Update the current user's status in each friend's friends collection
    for (var friendDoc in friendsSnapshot.docs) {
      String friendId = friendDoc.id; // Friend's document ID

      // Access the friend's friends collection
      CollectionReference friendFriendsCollection = FirebaseFirestore.instance.collection('users').doc(friendId).collection('friends');

      // Update the current user's status in the friend's friends collection
      await friendFriendsCollection.doc(userId).update({
        'status': status,
      });
    }
  } catch (e) {
    print('Failed to update status in friends collection: $e');
  }
}


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColor.bgcolor,
      body: Center(
        child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                        alignment: Alignment.center,
                        child: const CustomLoadingIndicator(),
                      ),
                    ),
      ),
    );
  }
}
