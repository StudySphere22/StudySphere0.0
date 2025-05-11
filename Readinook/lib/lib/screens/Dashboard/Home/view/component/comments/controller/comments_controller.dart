import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';


class CommentsController extends GetxController {
  final String postId;
  final RxList<Map<String, dynamic>> comments = <Map<String, dynamic>>[].obs;
    final RxInt commentsCount = 0.obs;  // To store the total count of comments

  CommentsController(this.postId);
  
  @override
  void onInit() {
    super.onInit();
    fetchComments();
    countComments();  
  }

void fetchComments() {
  print("Fetching comments for postId: $postId");
  FirebaseFirestore.instance
      .collection('comments')
      .doc(postId)
      .collection('postComments')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .listen((snapshot) {
          print("Comments fetched: ${snapshot.docs.length}");
          comments.value = snapshot.docs.map((doc) => doc.data()).toList();
      });
}


  
   void countComments() {
    FirebaseFirestore.instance
        .collection('comments')
        .doc(postId)
        .collection('postComments')
        .snapshots()
        .listen((snapshot) {
      commentsCount.value = snapshot.docs.length;  // Update the count
    });
  }


  Future<void> postComment(String commentText) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && commentText.trim().isNotEmpty) {
      // Get user details
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final username = userDoc.data()?['username'] ?? 'Anonymous';
      final profilePicUrl = userDoc.data()?['profilePicUrl'] ?? '';

      final commentData = {
        'username': username,
        'profilePicUrl': profilePicUrl,
        'userId': user.uid,
        'commentText': commentText,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Add the comment to the Firestore under the specific post
      await FirebaseFirestore.instance
          .collection('comments')
          .doc(postId)
          .collection('postComments')
          .add(commentData);

        await FirebaseFirestore.instance
        .collection('posts') // Ensure this is the correct collection where your posts are stored
        .doc(postId) // Use postId to find the specific post document
        .update({
          'comments': FieldValue.increment(1), // Increment comment count by 1
        }).then((_) {
          print("Comment count updated successfully.");
        }).catchError((error) {
          print("Error updating comment count: $error");
        });
    // Fetch the post document to get the post owner's userId (you may have ownerId as a field in the post)
    final postDoc = await FirebaseFirestore.instance.collection('posts').doc(postId).get();
    final postOwnerId = postDoc.data()?['postOwnerId'];

    if (postOwnerId != null && postOwnerId != user.uid) {
      // Create a comment notification for the post owner
      final notificationData = {
        'senderId': user.uid,
        'receiverId': postOwnerId,
        'profilePicUrl': profilePicUrl,
        'message': "$username commented on your post",
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Add the notification to the 'commentNotifications' subcollection inside 'notifications'
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(postOwnerId)
          .collection('commentNotifications')
          .add(notificationData)
          .then((_) {
            print("Comment notification sent to post owner: $postOwnerId");
          })
          .catchError((error) {
            print("Error sending comment notification: $error");
          });
    } else {
      print("Post owner is the commenter or userId is null.");
    }
  }
}

}
