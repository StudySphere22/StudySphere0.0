import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:reedinook/utils/custom_snackbar.dart';

class SearchFriendController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var searchResults = <DocumentSnapshot>[].obs;
  var friendRequests = <DocumentSnapshot>[].obs;
  var isLoading = false.obs;
  late String _currentUserId;
  var friendsList = <String>[].obs;
  var friendsMap = <String, String>{}; // friendId -> friendName
  

  @override
  void onInit() {
    super.onInit();
    _currentUserId = _auth.currentUser!.uid;
    fetchFriends(); // Fetch friends on initialization
  fetchIncomingFriendRequests();
  }

  // Fetch friends of the current user
  void fetchFriends() {
    try {
      _firestore.collection('users').doc(_currentUserId).snapshots().listen((currentUserDoc) {
        final friendsCollectionRef = currentUserDoc.reference.collection('friends');
        friendsCollectionRef.snapshots().listen((friendsSnapshot) {
          friendsMap.clear();
          for (final friendDoc in friendsSnapshot.docs) {
            String friendId = friendDoc['friendId'];
            String friendName = friendDoc['friendName'];
            friendsMap[friendId] = friendName;
          }
        });
      });
    } catch (e) {
      customSnackbar(title: "Error", message: "Error fetching friends: $e");
    }
  }

void fetchIncomingFriendRequests() {
  try {
    _firestore
        .collection('friend_requests')
        .where('receiverId', isEqualTo: _currentUserId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      friendRequests.clear();
      friendRequests.addAll(snapshot.docs);
    });
  } catch (e) {
    customSnackbar(title: "Error",message:  "Error fetching incoming friend requests: $e");
  }
}
bool isFriendRequestReceived(String senderId) {
  return friendRequests.any((request) =>
      request['senderId'] == senderId && request['status'] == 'pending');
}

  // Perform search for users by username
  void performSearch(String query) {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThan: '$query\uf8ff')
          .snapshots()
          .listen((snapshot) {
            // Clear previous results
            searchResults.clear();
            for (var doc in snapshot.docs) {
              String receiverId = doc.id;
              // Check if the user is already a friend or has sent a friend request
              friendsMap.containsKey(receiverId);
              checkIfFriendRequestSent(receiverId);
              isFriendRequestReceived(receiverId);
              searchResults.add(doc); // Add to searchResults, you can modify this as needed
            }
            
          });
    } catch (e) {
      customSnackbar(title: "Error", message: "Error while searching. Please try again.");
    }
  }

  // Check if a friend request has already been sent
  bool checkIfFriendRequestSent(String receiverId) {
    return friendRequests.any((request) => request['receiverId'] == receiverId && request['status'] == 'pending');
  }

  // Send friend request to the specified user
Future<void> sendFriendRequest(String receiverId) async {
  final currentUser = _auth.currentUser;

  if (currentUser == null) {
    customSnackbar(title: "Error", message: "You must be logged in to send friend requests.");
    return;
  }

  if (receiverId == _currentUserId) {
    customSnackbar(title: "Error", message: "You cannot send a friend request to yourself.");
    return;
  }

  try {
    // Listen for existing friend requests to check if there's already a pending one
    final querySnapshot = await _firestore
        .collection('friend_requests')
        .where('senderId', isEqualTo: currentUser.uid)
        .where('receiverId', isEqualTo: receiverId)
        .where('status', isEqualTo: 'pending')
        .get();

    // If a pending request exists, show a message and return
    if (querySnapshot.docs.isNotEmpty) {
      customSnackbar(title: "Error", message: "You have already sent a friend request to this user.");
      return;
    }

    // Send the friend request if no pending request exists
    await _firestore.collection('friend_requests').add({
      'senderId': currentUser.uid,
      'receiverId': receiverId,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    customSnackbar(title: "Success",message:  "Friend request sent!");
  } catch (e) {
    customSnackbar(title: "Error",message:  "Failed to send friend request. Try again.");
  }
}
}