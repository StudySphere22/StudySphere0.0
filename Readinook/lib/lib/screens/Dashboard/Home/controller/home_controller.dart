import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class HomeController extends GetxController with WidgetsBindingObserver {
  final _profilePicUrl = ''.obs; 
  final _username = ''.obs;
  final _email = ''.obs; 
  final _about = ''.obs;
  final _role = ''.obs;
  final _pendingFriendRequests = 0.obs; 
  var friendRequestNotificationsCount = 0.obs;
  var commentNotificationsCount = 0.obs;
  var likeNotificationsCount = 0.obs;
  var totalNotificationsCount = 0.obs; // New variable for total notifications count 
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get profilePicUrl => _profilePicUrl.value;
  String get username => _username.value;
  String get email => _email.value;
  String get about => _about.value;
  String get role => _role.value;
  int get pendingFriendRequests => _pendingFriendRequests.value;




 

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this); // Register the observer
    fetchUserData();
    fetchPendingRequests();
    _setUserStatus("online"); // Set user status to online at startup
     listenToFriendRequestNotifications();
    listenToCommentNotifications();
     listenTolikeNotifications();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this); // Remove the observer when controller is closed
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setUserStatus("online");
    } else {
      _setUserStatus("offline");
    }
  }

  Future<void> _setUserStatus(String status) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'status': status,
      });
          await _updateStatusInFriendsCollection(uid, status);
    }
  }
  
// Function to update the status in all friends' collections
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



Future<void> fetchUserData() async {

  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final uid = user.uid;

    // Listen for real-time updates
    FirebaseFirestore.instance.collection('users').doc(uid).snapshots().listen((userDoc) {
      if (userDoc.exists) {
        // Extract data fields
        final username = userDoc.data()?['username'] ?? 'No name provided';
        final email = userDoc.data()?['email'] ?? 'No email provided';
        final profilePicUrl = userDoc.data()?['profilePicUrl'] ?? '';
        final about = userDoc.data()?['about'] ?? '';
        final role = userDoc.data()?['role'] ?? '';

        // Update the reactive variables
        _username.value = username;
        _email.value = email;
        _profilePicUrl.value = profilePicUrl;
        _about.value = about; // Update the about field
        _role.value = role; // Update the about field
      } else {
        // Handle the case when the user document does not exist
        _username.value = 'No name provided';
        _email.value = 'No email provided';
        _profilePicUrl.value = '';
        _about.value = '';
      }

    }, onError: (error) {
      print("Error fetching user data: $error");
    });
  }
}

 void fetchPendingRequests() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Listen for friend requests
      FirebaseFirestore.instance
          .collection('friend_requests')
          .where('receiverId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'pending')
          .snapshots()
          .listen((snapshot) {
        _pendingFriendRequests.value = snapshot.docs.length;
      });
    }
  }

    void listenToFriendRequestNotifications() {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _firestore
          .collection('notifications')
          .doc(user.uid) // Document for the specific user
          .collection('friendRequestNotifications') // Sub-collection for friend request notifications
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((friendRequestSnapshot) {
            friendRequestNotificationsCount.value = friendRequestSnapshot.docs.length; // Update count
            print("Friend Request Notifications Count: ${friendRequestNotificationsCount.value}");
             _updateTotalNotificationsCount(); // Update total count
          });
    }
  }

  void listenToCommentNotifications() {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _firestore
          .collection('notifications')
          .doc(user.uid) // Document for the specific user
          .collection('commentNotifications') // Sub-collection for comment notifications
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((commentSnapshot) {
            commentNotificationsCount.value = commentSnapshot.docs.length; // Update count
            print("Comment Notifications Count: ${commentNotificationsCount.value}");
             _updateTotalNotificationsCount(); // Update total count
          });
    }
  }

    void listenTolikeNotifications() {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _firestore
          .collection('notifications')
          .doc(user.uid) // Document for the specific user
          .collection('likeNotifications') // Sub-collection for comment notifications
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((likeSnapshot) {
            likeNotificationsCount.value = likeSnapshot.docs.length; // Update count
            print("Comment Notifications Count: ${likeNotificationsCount.value}");
             _updateTotalNotificationsCount(); // Update total count
          });
    }
  }

   void _updateTotalNotificationsCount() {
    totalNotificationsCount.value = friendRequestNotificationsCount.value + commentNotificationsCount.value + likeNotificationsCount.value; // Calculate total
}
}



