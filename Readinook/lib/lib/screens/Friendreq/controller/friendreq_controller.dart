import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/Dashboard/Home/controller/home_controller.dart';
import 'package:reedinook/screens/Dashboard/Profiles/my_profile/view/component/edit_profile/controller/edit_profile_controller.dart';
import 'package:reedinook/utils/custom_snackbar.dart';



class FriendRequestController extends GetxController {
  var friendRequests = <Map<String, dynamic>>[].obs; // Observable list of friend requests
  var isLoading = true.obs; // Observable loading state
  final HomeController homeController = Get.put(HomeController());
  final EditProfileController editprofileController = Get.put(EditProfileController());
  String currentuser = '';
  String profilepic = '';

  // Store the StreamSubscription to cancel the listener later
  Map<String, StreamSubscription<DocumentSnapshot>> statusListeners = {};


  

  @override
  void onInit() {
    super.onInit();
    currentuser = homeController.username;
    profilepic = editprofileController.profilePicUrl.value;
    fetchFriendRequests(); // Fetch friend requests on initialization
  }

  @override
  void onClose() {
    // Cancel all listeners when the controller is disposed
    _cancelAllStatusListeners();
    super.onClose();
  }

  Future<void> fetchFriendRequests() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    isLoading.value = true; // Set loading to true

    try {
      FirebaseFirestore.instance
          .collection('friend_requests')
          .where('receiverId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'pending')
           .snapshots()
        .listen((snapshot) async {

      List<Map<String, dynamic>> requests = [];

      for (var request in snapshot.docs) {
        var senderId = request['senderId'];
        var requestId = request.id;

        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(senderId)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data()!;
          requests.add({
            'requestId': requestId,
            'senderId': senderId,
            'senderName': data['username'] ?? 'Unknown User',
            'profilePicUrl': data['profilePicUrl'] ?? '',
            'about': data['about'] ?? '', // Add additional details like about
            'status': data['status'] ?? '', // Add online/offline status
            'role': data['role'] ?? '', // Add online/offline status
          });

        }
      }

      friendRequests.value = requests; // Update the observable list
         });
    } catch (e) {
      customSnackbar(title: "Error",message:  "Error fetching friend requests.");
    } finally {
      isLoading.value = false; // Set loading to false
    }
  }

 Future<void> rejectFriendRequest(String requestId, String senderId) async {
  try {

    if (requestId.isEmpty || senderId.isEmpty) {
      print("Error: Request ID or Sender ID is empty");
      customSnackbar(title: "Error",message: "Request ID or Sender ID is empty");
      return;
    }
    // Step 1: Update the friend request status to 'rejected'
    await FirebaseFirestore.instance
        .collection('friend_requests')
        .doc(requestId)
        .update({
      'status': 'rejected',
    });

    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Step 2: Fetch current user's profile
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final currentUserName = currentUserDoc.data()?['username'] ?? 'Unknown';
      final currentUserProfilePicUrl =
          currentUserDoc.data()?['profilePicUrl'] ?? '';

      // Step 3: Create notification data
      final friendRequestNotificationData = {
        'senderId': currentUser.uid,
        'profilePicUrl': currentUserProfilePicUrl, // Include profile picture URL
            'receiverId': senderId, // Include profile picture URL
        'message': '$currentUserName rejected your friend request', // Update message
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Step 4: Store the notification under the sender's document in the notifications collection
      await FirebaseFirestore.instance
          .collection('notifications') // Notifications collection
          .doc(senderId) // Sender's user ID
          .collection('friendRequestNotifications') // Sub-collection for friend request notifications
          .add(friendRequestNotificationData);

      print("Friend request notification sent to $senderId");

      // Step 5: Remove the rejected request from the list
      friendRequests.removeWhere((request) => request['requestId'] == requestId);
      customSnackbar(title: "Info",message:  "Friend request rejected.");
    }
  } catch (e) {
    customSnackbar(title: "Error", message: "Error rejecting friend request. $e");
    print("Error rejecting friend request: $e");
  }
}


  Future<void> acceptFriendRequest(String requestId, String senderId) async {
    try {
      // Step 1: Update the friend request status to 'accepted'
      await FirebaseFirestore.instance
          .collection('friend_requests')
          .doc(requestId)
          .update({
        'status': 'accepted',
      });

      var currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Step 2: Fetch sender's data
        final senderDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(senderId)
            .get();

        if (!senderDoc.exists) {
          print("Sender document does not exist.");
          return;
        }

        final senderName = senderDoc.data()?['username'] ?? 'Unknown';
        final senderProfilePicUrl = senderDoc.data()?['profilePicUrl'] ?? '';

        // Fetch current user's profile
        final currentUserDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        final currentUserName = currentUserDoc.data()?['username'] ?? 'Unknown';
        final currentUserProfilePicUrl =
            currentUserDoc.data()?['profilePicUrl'] ?? '';

        // Step 3: Add sender to current user's friends list
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('friends')
            .doc(senderId)
            .set({
          'friendId': senderId,
          'friendName': senderName,
          'friendProfilePicUrl': senderProfilePicUrl,
          'status': senderDoc.data()?['status'] ?? 'offline', // Add sender's status
          'about':senderDoc.data()?['about'] ?? '',
          'role' :senderDoc.data()? ['role'] ?? '',
        });

        // Step 4: Add current user to sender's friends list
        await FirebaseFirestore.instance
            .collection('users')
            .doc(senderId)
            .collection('friends')
            .doc(currentUser.uid)
            .set({
          'friendId': currentUser.uid,
          'friendName': currentUserName,
          'friendProfilePicUrl': currentUserProfilePicUrl,
          'status': currentUserDoc.data()?['status'] ?? 'offline', // Add current user's status
          'about': currentUserDoc.data()?['about'] ?? '', // Add current user's status
          'role' :currentUserDoc.data()? ['role'] ?? '',
        });

      // Step 5: Send notification to the sender about the acceptance
      final friendRequestNotificationData = {
        'senderId': currentUser.uid,
        'profilePicUrl': currentUserProfilePicUrl, // Include profile picture URL
        'receiverId': senderId, // Include profile picture URL
        'message': '$currentUserName has accepted your friend request. You are now connected!',
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Store the notification under the sender's document in the notifications collection
      await FirebaseFirestore.instance
          .collection('notifications') // Notifications collection
          .doc(senderId) // Sender's user ID
          .collection('friendRequestNotifications') // Sub-collection for friend request notifications
          .add(friendRequestNotificationData);

      print("Friend request notification sent to $senderId");

        // Remove the accepted request from the list
        friendRequests.removeWhere((request) => request['requestId'] == requestId);

        customSnackbar(title: "Success",message:  "Friend request accepted.");

        // Step 6: Listen to the sender's real-time status and update it in the current user's friend list
        _listenToFriendStatus(senderId, currentUser.uid);

        // Step 7: Listen to the current user's real-time status and update it in the sender's friend list
        _listenToFriendStatus(currentUser.uid, senderId);


//           print("update fiorndstauts");
//        Future.delayed(Duration.zero, () {
//   if (Get.isRegistered<UserProfileController>(tag: senderId)) {
//     UserProfileController userProfileController = Get.find<UserProfileController>(tag: senderId);
//     userProfileController.checkIfFriend(senderId);
//     print("checkIfFriend triggered for senderId: $senderId");
//   } else {
//     print("UserProfileController not found for tag: $senderId");
//   }
// });




      

      }
    } catch (e) {
      // Log the error to the console for debugging
      print("Error accepting friend request: $e");
      customSnackbar(title: "Error", message: "Error accepting friend request");
    }
  }

  // Method to listen to friend's status and update it in the friend list
  void _listenToFriendStatus(String userId, String friendId) {
    var listener = FirebaseFirestore.instance.collection('users').doc(userId).snapshots().listen((userDoc) {
      if (userDoc.exists) {
        var status = userDoc.data()?['status'] ?? 'offline';
        // Update the friend's status in the friend's collection
        FirebaseFirestore.instance
            .collection('users')
            .doc(friendId)
            .collection('friends')
            .doc(userId)
            .update({
          'status': status,
        });
      }
    }, onError: (error) {
      print("Error listening to friend's status: $error");
    });

    // Save the listener to cancel it later
    statusListeners[userId] = listener;
  }
  // Method to cancel all status listeners
  void _cancelAllStatusListeners() {
    statusListeners.forEach((key, subscription) {
      subscription.cancel();
    });
    statusListeners.clear();
  }

}
