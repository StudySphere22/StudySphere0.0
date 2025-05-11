import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:reedinook/utils/custom_snackbar.dart';

class ShareController extends GetxController {
  final String postId; // Store post ID
  final RxList<Map<String, dynamic>> friends = <Map<String, dynamic>>[].obs;
  final RxList<String> selectedFriends = <String>[].obs; // Store selected friends' IDs
  RxInt sharesCount = 0.obs; // Observable for shares count

  // Constructor to accept postId
  ShareController(this.postId);

  @override
  void onInit() {
    super.onInit();
    fetchFriends();
    listenToSharesCount();
  }

  void fetchFriends() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("No user logged in.");
      return;
    }

    print("Current User ID: ${user.uid}");

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('friends')
        .snapshots()
        .listen((snapshot) {
      print("Friends snapshot count: ${snapshot.docs.length}");
      friends.clear(); // Clear the existing friends list

      for (var friendDoc in snapshot.docs) {
        final friendId = friendDoc.id; // Assuming the document ID is the friend ID

        FirebaseFirestore.instance
            .collection('users')
            .doc(friendId)
            .get()
            .then((friendProfileDoc) {
          if (friendProfileDoc.exists) {
            // Ensure fields are not null
            final username = friendProfileDoc['username'] ?? 'Unknown';
            final profilePicUrl = friendProfileDoc['profilePicUrl'];

            // Create a friend object with profile details
            final friendData = {
              'id': friendId,
              'username': username,
              'profilePicUrl': profilePicUrl,
            };

            // Add friend data to the friends list
            friends.add(friendData);
          }
        }).catchError((error) {
          print("Error fetching friend's profile: $error");
        });
      }
    }, onError: (error) {
      print("Error listening to friends collection: $error");
    });
  }

  void toggleFriendSelection(String friendId) {
    if (selectedFriends.contains(friendId)) {
      selectedFriends.remove(friendId); // Deselect if already selected
    } else {
      selectedFriends.add(friendId); // Add to selected list if not selected
    }

    update(); // Ensure UI is updated
  }

  Future<void> sendPost() async {
    try {
      final postDoc = await FirebaseFirestore.instance.collection('posts').doc(postId).get();

      if (!postDoc.exists) {
        print("Post document does not exist.");
        return;
      }

      final currentUserId = FirebaseAuth.instance.currentUser!.uid; // Get current user ID

      // Increment the shares count by the number of selected friends
      int incrementBy = selectedFriends.length;
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'shares': FieldValue.increment(incrementBy), // Increment shares by the number of selected friends
      });

      // Retrieve the updated post document to get the new shares count
      final updatedPostDoc = await FirebaseFirestore.instance.collection('posts').doc(postId).get();
      final updatedPostData = updatedPostDoc.data()!;

      // Send the updated post to the selected friends
      await sendToSelectedFriends(updatedPostData, currentUserId);

    } catch (e) {
      print('Error sending post: $e');
    }
  }

  Future<void> sendToSelectedFriends(Map<String, dynamic> postDetails, String currentUserId) async {
      final timestamp = DateTime.now();
    for (String friendId in selectedFriends) {
      // Include friendId in the post details
      Map<String, dynamic> postToSend = {
        ...postDetails,
        'receiverId': friendId, // Specify the receiver for the post
        'isRead' : false,
        'type': "posts",
        'timesstamp': timestamp,
      };
      await sendPostToChatRoom(postToSend, friendId, currentUserId);
    }
  }

  Future<void> sendPostToChatRoom(Map<String, dynamic> postDetails, String friendId, String currentUserId) async {
    String chatRoomId = getChatRoomId(currentUserId, friendId);
    
    final chatRoomSnapshot = await FirebaseFirestore.instance.collection('chat_rooms').doc(chatRoomId).get();

    if (chatRoomSnapshot.exists) {
      // Send post details to the existing chat room
      await FirebaseFirestore.instance.collection('chat_rooms').doc(chatRoomId).collection('posts').add({
        ...postDetails, // Spread the postDetails map to include all fields
      });

      // print("Post sent to friend ID: $friendId in existing chat room: $chatRoomId");
     customSnackbar(title: 'Success', message: 'post has been sent successfully!');
    } else {
      // Create a new chat room if it doesn't exist
      await FirebaseFirestore.instance.collection('chat_rooms').doc(chatRoomId).set({
        'users': [currentUserId, friendId],
      });

      // Send post details to the new chat room
      await FirebaseFirestore.instance.collection('chat_rooms').doc(chatRoomId).collection('posts').add({
        ...postDetails, // Spread the postDetails map to include all fields
      });

      print("Created new chat room and sent post to friend ID: $friendId in chat room: $chatRoomId");
    }
  }

  // void showSnackBar(String message) {
  //   Get.snackbar(
  //     'Share Post', // Title
  //     message, // Message
  //     snackPosition: SnackPosition.BOTTOM,
  //     duration: Duration(seconds: 3),
  //     backgroundColor: Colors.blueAccent,
  //     colorText: Colors.white,
  //   );
  // }

  // Function to generate a unique chat room ID based on participant IDs
  String getChatRoomId(String currentUserId, String friendId) {
    List<String> ids = [currentUserId, friendId]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  void listenToSharesCount() {
    FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .snapshots()
        .listen((document) {
      if (document.exists) {
        final newSharesCount = document.data()?['shares'] ?? 0;
        if (newSharesCount != sharesCount.value) {
          sharesCount.value = newSharesCount;
          print("Shares count updated: $newSharesCount");
        }
      } else {
        print("No document found for post ID: $postId");
      }
    }, onError: (error) {
      print("Error listening to shares count: $error");
    });
  }

 
}
