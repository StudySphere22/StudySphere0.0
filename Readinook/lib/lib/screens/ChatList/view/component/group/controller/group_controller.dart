import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:reedinook/utils/custom_snackbar.dart';

class GroupController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;



RxList<String> groupIds = <String>[].obs;

Future<void> checkUserInGroupChat() async {
  try {
    String currentUserId = _auth.currentUser!.uid;

    // Listen for real-time updates where the current user is a member
    FirebaseFirestore.instance
        .collection('groups')
        .where('members', arrayContains: currentUserId)
        .snapshots() // Real-time listener
        .listen((groupSnapshot) {
      // Clear previous data and add new group IDs when there are changes
      groupIds.clear();
      for (var doc in groupSnapshot.docs) {
        groupIds.add(doc.id); // Add group ID to the observable list
      }
    });
  } catch (e) {
    print("Error checking group membership: $e");
  }
}

  Future<void> createGroupChat(String groupName, List<Map<String, dynamic>> selectedFriends) async {
  try {
    // Get the current user's ID and user data
    String currentUserId = _auth.currentUser!.uid;
    DocumentSnapshot currentUserDoc = await _firestore.collection('users').doc(currentUserId).get();
    String currentUserName = currentUserDoc['username'] ?? 'Unknown';
    String currentUserProfilePic = currentUserDoc['profilePicUrl'] ?? '';

    // Prepare the list of members with profile data
    List<Map<String, dynamic>> members = [
      {
        'userId': currentUserId,
        'userName': currentUserName,
        'profilePicUrl': currentUserProfilePic,
      },
      ...selectedFriends.map((friend) => {
        'userId': friend['friendId'],
        'userName': friend['friendName'],
        'profilePicUrl': friend['profilePicUrl'] ?? '',
      }).toList(),
    ];

    // Create a new document in the 'group_chats' collection
    final groupDoc = _firestore.collection('group_chats').doc();

    // Set group data with the list of members
    await groupDoc.set({
      'groupId': groupDoc.id,
      'groupName': groupName,
      'members': members,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // // Optional: Add initial welcome message or set up other group details
    // await groupDoc.collection('messages').add({
    //   'senderId': currentUserId,
    //   'text': 'This is a system-generated message: Welcome to the group!',
    //   'timestamp': FieldValue.serverTimestamp(),
    // });

    customSnackbar(title: "Success", message: "Group created successfully");
  } catch (e) {
    customSnackbar(title: "Error",message:  "Failed to create group: $e");
  }
}
}