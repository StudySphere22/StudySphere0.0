import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/Dashboard/Profiles/my_profile/controller/profile_controller.dart';




class ChatListsController extends GetxController {
  // Observable list for friends
  var friends = <Map<String, dynamic>>[].obs; // Store friends with additional data
 var group_chats = <Map<String, dynamic>>[].obs;
  var unreadMessageCounts = <String, int>{}; // Dictionary to store unread message counts
  var unreadPostsCounts = <String, int>{}; // Dictionary to store unread posts counts
  var isLoading = true.obs; // Reactive loading state

   // Getter for total unread count
 
int get totalUnreadCount {
  return friends.fold(0, (int sum, friend) => sum + (friend['totalUnreadCount'] ?? 0) as int);
}


  StreamSubscription<QuerySnapshot>? unreadMessagesSubscription;
  StreamSubscription<QuerySnapshot>? unreadPostsSubscription;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchFriends(); // Fetch friends when the controller is init
}

  Future<void> fetchFriends() async {
    isLoading.value = true; // Set loading state to true

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (currentUserDoc.exists) {
        final friendsCollectionRef = currentUserDoc.reference.collection('friends');

        // Listen for real-time updates in the friends collection
        friendsCollectionRef.snapshots().listen((friendsSnapshot) {
          List<Map<String, dynamic>> fetchedFriends = [];
          for (final friendDoc in friendsSnapshot.docs) {
            var friendId = friendDoc.id;
            final friendName = friendDoc['friendName'];
            final profilePicUrl = friendDoc['friendProfilePicUrl'];
            final status = friendDoc['status'];
            final about = friendDoc['about'];
            final role = friendDoc['role'];

            // Add friend info and unread message/post counts
            fetchedFriends.add({
              'friendId': friendId,
              'friendName': friendName ?? 'Unknown',
              'profilePicUrl': profilePicUrl ?? '',
              'status': status ?? '',
              'unreadMessageCount': unreadMessageCounts[friendId] ?? 0, // Initialize with zero
              'unreadPostsCount': unreadPostsCounts[friendId] ?? 0, // Initialize with zero
              'about': about ?? '',
              'role': role ?? '',
      
            });
          }

          friends.value = fetchedFriends; // Update the friends observable list

          // Update the friend's count in ProfileController
          Get.find<ProfileController>().friendsCount.value = fetchedFriends.length;

          // Start listening to unread messages and posts for each friend
          for (final friend in fetchedFriends) {
            listenToUnreadMessages(friend['friendId']);
            listenToUnreadPosts(friend['friendId']);
          }
        });
      }
    } catch (e) {
      print("Error fetching friends: $e");
    } finally {
      isLoading.value = false; // Set loading state to false
    }
  }

  // Listen for unread messages
  void listenToUnreadMessages(String friendId) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final chatRoomId = generateChatRoomId(currentUserId, friendId);

    unreadMessagesSubscription = FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('senderId', isNotEqualTo: currentUserId) // Only count messages from the friend
        .where('isRead', isEqualTo: false) // Assuming you have a field that indicates read status
        .snapshots()
        .listen(
      (snapshot) {
        unreadMessageCounts[friendId] = snapshot.docs.length;
        // Update the friends list observable
        updateFriendList(friendId, snapshot.docs.length, isMessage: true);
      },
      onError: (error) {
        print('Error fetching unread messages: $error');
      },
    );
  }


void listenToUnreadPosts(String friendId) {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final chatRoomId = generateChatRoomId(currentUserId, friendId);

  FirebaseFirestore.instance
      .collection('chat_rooms')
      .doc(chatRoomId)
      .collection('posts')
      .where('receiverId', isEqualTo: currentUserId)
      .where('isRead', isEqualTo: false) 
      .snapshots()
      .listen(
    (snapshot) {
      int unreadPostCount = snapshot.docs.length; // Directly use the length of the snapshot
      print('Total Unread Posts for Friend ID $friendId: $unreadPostCount'); // Debug log for total count

      unreadPostsCounts[friendId] = unreadPostCount; // Update unread posts count
      updateFriendList(friendId, unreadPostCount, isMessage: false);
    },
    onError: (error) {
      print('Error fetching unread posts: $error');
    },
  );
}

  // Mark messages as read
  Future<void> markMessagesAsRead(String friendId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final currentUserId = currentUser.uid;
    final chatRoomId = generateChatRoomId(currentUserId, friendId);

    await _firestore.collection('chat_rooms').doc(chatRoomId).collection('messages')
        .where('senderId', isEqualTo: friendId)
        .where('isRead', isEqualTo: false)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.update({'isRead': true});
      }
    });
  }

  // Mark posts as read
  Future<void> markPostsAsRead(String friendId) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final chatRoomId = generateChatRoomId(currentUserId, friendId);

  await FirebaseFirestore.instance
      .collection('chat_rooms')
      .doc(chatRoomId)
      .collection('posts')
            .where('receiverId', isEqualTo: currentUserId)
      .where('isRead', isEqualTo: false)
      .get()
      .then((snapshot) {
    for (var doc in snapshot.docs) {
      doc.reference.update({'isRead': true});
    }
  });
}
  // Update friend list with unread message or post count
  void updateFriendList(String friendId, int count, {required bool isMessage}) {
    int friendIndex = friends.indexWhere((friend) => friend['friendId'] == friendId);
    if (friendIndex != -1) {
      if (isMessage) {
        friends[friendIndex]['unreadMessageCount'] = count; // Update unread message count
      } else {
        friends[friendIndex]['unreadPostsCount'] = count; // Update unread posts count
      }
      
      friends[friendIndex]['totalUnreadCount'] = friends[friendIndex]['unreadMessageCount'] + friends[friendIndex]['unreadPostsCount'];
      friends.sort((a, b) => (b['totalUnreadCount'] ?? 0).compareTo(a['totalUnreadCount'] ?? 0));
      friends.refresh(); // Refresh the observable to reflect changes
    }
  }
  // Calculate total unread count

  String generateChatRoomId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  // Check if a chat room exists
  Future<bool> checkChatRoomExists(String chatRoomId) async {
    final chatRoomDoc = await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .get();
    return chatRoomDoc.exists;
  }

  // Create a new chat room
  Future<void> createChatRoom(String chatRoomId, String userId1, String userId2) async {
    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .set({
      'users': [userId1, userId2],
    });
  }




Future<void> fetchGroupChats() async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("No current user found.");
      return;
    }

    final groupChatsCollectionRef = FirebaseFirestore.instance.collection('group_chats');

   groupChatsCollectionRef.snapshots().listen((groupChatsSnapshot) {


  List<Map<String, dynamic>> fetchedGroups = [];
  for (final groupDoc in groupChatsSnapshot.docs) {
    var groupId = groupDoc.id;
    final groupName = groupDoc['groupName'] ?? '';


    // Extract members list correctly
    List<Map<String, dynamic>> membersList = [];
    if (groupDoc['members'] is List) {
      membersList = List<Map<String, dynamic>>.from(groupDoc['members']);
    }

    List<String> memberUserIds = membersList.map((member) => member['userId'] as String).toList();



    if (memberUserIds.contains(currentUser.uid)) {
      print("User is a member of group $groupName.");
      fetchedGroups.add({
        'groupId': groupId,
        'groupName': groupName,
        'members': membersList,
      });
    }
  }
  group_chats.value = fetchedGroups; // Update the observable list
});

  } catch (e) {
    print("Error fetching group chats: $e");
  }
}







 

  @override
  void dispose() {
    unreadMessagesSubscription?.cancel();
    unreadPostsSubscription?.cancel();
    super.dispose();
  }



}

