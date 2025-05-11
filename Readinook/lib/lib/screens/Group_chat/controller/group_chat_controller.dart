import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GroupChatController extends GetxController {
  final String groupId; // Unique ID for the group chat
  final TextEditingController messageController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  GroupChatController({required this.groupId});

  var groupMembers = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchGroupMembers();
     // Fetch group members when the controller is initialized
  }
Future<bool> checkIfFriend(String currentUser, String clickedUserId) async {
  try {
    // Ensure currentUser and clickedUserId are not null
    final friendsCollection = firestore.collection('users')
        .doc(currentUser)
        .collection('friends');

    // Fetch all friends in the current user's subcollection
    final querySnapshot = await friendsCollection.get();

    // Check if the clickedUserId is in the friends list
    bool isFriend = querySnapshot.docs.any((doc) => doc.id == clickedUserId);

    // // Debugging: Print the friends list and clicked user ID
    // print("Friends List: ${querySnapshot.docs.map((doc) => doc.id).toList()}");
    // print("Clicked UserId: $clickedUserId");
    // print("Is Friend: $isFriend");

    return isFriend; // Return true if match is found, otherwise false
  } catch (e) {
    print("Error checking friendship status: $e");
  }
  return false; // Default to false if any error occurs
}



  // Fetch group members' details
  Future<void> fetchGroupMembers() async {
    try {
      // Get the document for the group
      final groupDoc =
          await firestore.collection('group_chats').doc(groupId).get();

      if (groupDoc.exists) {
        // Fetch the list of user IDs in the group
        List<dynamic> memberIds = groupDoc.data()?['members'] ?? [];
        // print('Member IDs: $memberIds'); // Debugging line to check structure

        List<Map<String, dynamic>> membersData = [];
        for (var member in memberIds) {
          String userId = '';

          // Check if member is a map and extract the user ID
          if (member is Map) {
            userId = member['userId'] ??
                ''; // Assuming 'userId' is the key in the map
          } else if (member is String) {
            userId = member; // If it's already a string
          }

          // Fetch user details using userId
          if (userId.isNotEmpty) {
            final userDoc =
                await firestore.collection('users').doc(userId).get();

            if (userDoc.exists) {
              final userData = userDoc.data();
              membersData.add({
                'id': userId,
                'name': userData?['username'] ?? 'Unknown',
                'about': userData?['about'] ?? '',
                'profilePicUrl': userData?['profilePicUrl'] ?? '',
                'role' : userData?['role']?? '',
              });
            }
          }
        }

// Update the observable list with fetched members' details
        groupMembers.value = membersData;
      }
    } catch (e) {
      print("Error fetching group members: $e");
    }
  }

  // Listen to messages in real-time
  Stream<QuerySnapshot> getMessages() {
    return firestore
        .collection('group_chats')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Send a message
  Future<void> sendMessage(
      String senderId, String senderName, String message) async {
    if (message.isEmpty) return;

    await firestore
        .collection('group_chats')
        .doc(groupId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
    messageController.clear();
  }
}
