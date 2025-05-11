import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:get/get.dart';
import 'package:reedinook/utils/custom_snackbar.dart';

class UserProfileController extends GetxController {
  var friendsoffreindsList = <Map<String, dynamic>>[].obs; // Observable list to store friends as maps
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  var friendPosts = <Map<String, dynamic>>[].obs; // Observable list for friend's posts
  var likedPosts = <String>{}.obs; // Observable set to store liked posts
  var friendRequests = <Map<String, dynamic>>[].obs;
  var friendRequestSent = false.obs; // Observable to track if a friend request is sent
  final String friendId; // Friend's user ID
  late String currentUserId; // Current user ID
  late String currentUserName; // Current user's name
  var isFriend = false.obs; // Observable to track friendship status
  var friendRequestReceived = false.obs; // Track if a friend request is received

 RxList<Map<String, dynamic>> readingBooks = RxList<Map<String, dynamic>>([]);
  RxList<Map<String, dynamic>> planToReadBooks = RxList<Map<String, dynamic>>([]);
  RxList<Map<String, dynamic>> finishedBooks = RxList<Map<String, dynamic>>([]);
   RxList<Map<String, dynamic>> uploadedbooks = RxList<Map<String, dynamic>>([]);
  var readingBooksCount =  0.obs;
  var planToReadBooksCount = 0.obs;
  var finishedBooksCount = 0.obs;
  var uploadedbooksCount = 0.obs;





  UserProfileController(this.friendId);

  @override
  void onInit() {
    super.onInit();
    _getCurrentUser();
    listenFriends();
    _listenForFriendPosts(); // Listen for friend's posts on init
    listenToFriendRequestStatus(friendId); // Listen for real-time updates
     checkIfFriend(friendId); // Check if current user and friend are friends
      listenToFriendshipStatus(friendId); // Start listening to friendship status
      listenForIncomingFriendRequest(friendId); // Start listening for incoming requests
        checkIfFriend(friendId); // Check if friendId is in the user's friends list
  }
  

  void listenForIncomingFriendRequest(String friendId) {
  _firestore
      .collection('friend_requests')
      .where('receiverId', isEqualTo: currentUserId) // Current user as the receiver
      .where('senderId', isEqualTo: friendId)       // Friend as the sender
      .where('status', isEqualTo: 'pending')        // Check for pending requests
      .snapshots()
      .listen((snapshot) {
    if (snapshot.docs.isNotEmpty) {
      friendRequestReceived.value = true; // Friend request is received
    } else {
      friendRequestReceived.value = false; // No friend request received
    }
  });
}



  // Listen to changes in friendship status
  void listenToFriendshipStatus(String friendId) {
    _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .doc(friendId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        isFriend.value = true;
        _listenForFriendPosts(); // Fetch friend's posts if still friends
      } else {
        isFriend.value = false;
        friendPosts.clear(); // Clear posts if unfriended
      }
    });
  }


 void checkIfFriend(String friendId) async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .where('friendId', isEqualTo: friendId)
        .get();

    isFriend.value = querySnapshot.docs.isNotEmpty; // Update friendship status
  }

  // Listen for friend request status changes in real-time
  void listenToFriendRequestStatus(String friendId) {
    _firestore
        .collection('friend_requests')
        .where('senderId', isEqualTo: currentUserId)
        .where('receiverId', isEqualTo: friendId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        friendRequestSent.value = true; // Friend request is pending
      } else {
        friendRequestSent.value = false; // No pending friend request
      }
    });
  }

  // Method to send a friend request
  Future<void> sendFriendRequest(String friendId) async {
    try {
      await _firestore.collection('friend_requests').add({
        'senderId': currentUserId,
        'receiverId': friendId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending friend request: $e');
    }
  }

  // Method to cancel a friend request
  Future<void> cancelFriendRequest(String friendId) async {
    try {
      final querySnapshot = await _firestore
          .collection('friend_requests')
          .where('senderId', isEqualTo: currentUserId)
          .where('receiverId', isEqualTo: friendId)
          .where('status', isEqualTo: 'pending')
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete(); // Delete the pending request
      }
         checkIfFriend(friendId); // Refresh friendship status
    } catch (e) {
      print('Error canceling friend request: $e');
    }
  }

  void _getCurrentUser() async {
    final User? user = _auth.currentUser; // Get the current authenticated user
    if (user != null) {
      currentUserId = user.uid; // Store the current user ID
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUserId).get();
      currentUserName = userDoc['username']; // Assuming 'name' is the field that stores the user's name
    } else {
      print("No user is signed in.");
    }
  }

  
// 
  void listenFriends() {
    _firestore
        .collection('users')
        .doc(friendId)
        .collection('friends')
        .snapshots()
        .listen((snapshot) {
      friendsoffreindsList.value = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'friendName': doc['friendName'],
          'friendProfilePicUrl': doc['friendProfilePicUrl'],
          'friendsabout': doc['about'],
          'role':doc['role'],
        };
      }).toList();
    }, onError: (error) {
      print("Error fetching friends: $error"); // Debugging line
    });
  }

  void _listenForFriendPosts() {
    _firestore
        .collection('posts')
        .where('postOwnerId', isEqualTo: friendId)
        .snapshots()
        .listen((postsSnapshot) {
      List<Map<String, dynamic>> fetchedPosts = [];

      for (var postDoc in postsSnapshot.docs) {
        List<dynamic> likedBy = postDoc.data().containsKey('likedBy')
            ? postDoc['likedBy']
            : [];

        // Check if the current user's name is in the likedBy list (for UI - yellow icon)
        if (likedBy.contains(currentUserName)) {
          likedPosts.add(postDoc.id); // Add to liked posts
        } else {
          likedPosts.remove(postDoc.id); // Remove if unliked
        }

        // Store post data
        fetchedPosts.add({
          'postId': postDoc.id,
          'postText': postDoc['text'],
          'postTimestamp': postDoc['timestamp'],
          'likes': postDoc['likes'] ?? 0,
          'comments': postDoc['comments'] ?? 0,
          'shares': postDoc['shares'] ?? 0,
          'likedBy': likedBy,
        });
      }

      // Sort posts by timestamp
      fetchedPosts.sort((a, b) =>
          (b['postTimestamp'] as Timestamp).compareTo(a['postTimestamp'] as Timestamp));

      // Update the observable list of friend's posts
      friendPosts.value = fetchedPosts;
    });
  }

  void onLikeButtonPressed(String postId) {
    if (likedPosts.contains(postId)) {
      likedPosts.remove(postId);
      // Update Firestore to decrement likes and remove the current user's name
      _firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([currentUserName]) // Remove current user's name
      });
    } else {
      likedPosts.add(postId);
      // Update Firestore to increment likes and add the current user's name
      _firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([currentUserName]) // Add current user's name
      });
    }
  }

  void listenFriendRequests() {
    _firestore
        .collection('friend_requests')
        .where('senderId', isEqualTo: currentUserId)
        .where('receiverId', isEqualTo: friendId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      friendRequests.value = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'receiverId': doc['receiverId'],
          'status': doc['status'],
          'timestamp': doc['timestamp'],
        };
      }).toList();

      friendRequestSent.value = friendRequests.isNotEmpty;

      if (friendRequestSent.value) {
        print("Pending friend request found.");
      } else {
        print("No pending friend requests.");
      }
    }, onError: (error) {
      print("Error fetching friend requests: $error");
    });
  }
  
  void unfriendUser(String friendId) async {
    try {
      // Remove friend from current user's friends collection
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('friends')
          .doc(friendId)
          .delete();

      // Remove current user from friend's friends collection
      await _firestore
          .collection('users')
          .doc(friendId)
          .collection('friends')
          .doc(currentUserId)
          .delete();

      // Construct the chat room ID based on the sender and receiver format
      String chatRoomId1 = "${currentUserId}_$friendId";
      String chatRoomId2 = "${friendId}_$currentUserId";

      // Check if the chat room exists for the first format
      DocumentSnapshot chatRoomDoc1 = await _firestore.collection('chat_rooms').doc(chatRoomId1).get();

      // Use the first chat room ID if it exists, otherwise use the second format
      String chatRoomId = chatRoomDoc1.exists ? chatRoomId1 : chatRoomId2;

      // Reference to the chat room's messages collection
      CollectionReference messagesRef = _firestore.collection('chat_rooms').doc(chatRoomId).collection('messages');

      // Delete each message in the messages sub-collection
      QuerySnapshot messagesSnapshot = await messagesRef.get();
      for (var doc in messagesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete the chat room document
      await _firestore.collection('chat_rooms').doc(chatRoomId).delete();

      // Update isFriend to false locally and notify the UI
      checkIfFriend(friendId); // Refresh friendship status
      customSnackbar(title: "Success",message:  "This user is no longer your friend.");

    } catch (e) {
      customSnackbar(title: "Error", message: "Unable to unfriend at this time.");
    }
  }

 void friendsBooks(String profileUserId) async {
  // Clear the existing lists before adding new data to prevent duplication
  readingBooks.clear();
  planToReadBooks.clear();
  finishedBooks.clear();

  // Access friend's "reading" collection
  _firestore
      .collection('users')
      .doc(profileUserId)
      .collection('Books->reading')
      .snapshots()
      .listen((readingSnapshot) {
    List<Map<String, dynamic>> readingList = readingSnapshot.docs.map((doc) {
      var data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

    readingBooks.addAll(readingList);
    readingBooksCount.value = readingBooks.length;
  });

  // Access friend's "PlanToRead" collection
  _firestore
      .collection('users')
      .doc(profileUserId)
      .collection('Books->PlanToRead')
      .snapshots()
      .listen((planToReadSnapshot) {
    List<Map<String, dynamic>> planToReadList = planToReadSnapshot.docs.map((doc) {
      var data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

    planToReadBooks.addAll(planToReadList);
    planToReadBooksCount.value = planToReadBooks.length;
  });

  // Access friend's "Finished" collection
  _firestore
      .collection('users')
      .doc(profileUserId)
      .collection('Books->Finished')
      .snapshots()
      .listen((finishedSnapshot) {
    List<Map<String, dynamic>> finishedList = finishedSnapshot.docs.map((doc) {
      var data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

    finishedBooks.addAll(finishedList);
    finishedBooksCount.value = finishedBooks.length;
  });

   FirebaseFirestore.instance
            .collection('books')
            .where('userId', isEqualTo: profileUserId) // Filter books by userId
            .snapshots()
            .listen((uploadedbooksSnapshot) {
          List<Map<String, dynamic>> uploadedbooksList = uploadedbooksSnapshot.docs.map((doc) {
            var data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

          // Update the plan-to-read books count and list
          uploadedbooksCount.value = uploadedbooksList.length;
          uploadedbooks.assignAll(uploadedbooksList);
        });
}
}