import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:reedinook/utils/custom_snackbar.dart';

class NotificationController extends GetxController {
  late Rx<Stream<List<Map<String, dynamic>>>> notificationsStream; // Reactive stream for notifications
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    final user = _auth.currentUser;

    if (user != null) {
      notificationsStream = Rx<Stream<List<Map<String, dynamic>>>>(
        _firestore
            .collectionGroup('friendRequestNotifications') // Querying friend request notifications
            .where('receiverId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots()
            .asyncMap((friendRequestSnapshot) async {
              // Get comment notifications
              var commentNotificationsSnapshot = await _firestore
                  .collectionGroup('commentNotifications')
                  .where('receiverId', isEqualTo: user.uid)
                  .orderBy('timestamp', descending: true)
                  .get();

                var likeNotificationsSnapshot = await _firestore
                  .collectionGroup('likeNotifications')
                  .where('receiverId', isEqualTo: user.uid)
                  .orderBy('timestamp', descending: true)
                  .get();

              // Combine the two streams into a list of maps
              List<Map<String, dynamic>> combinedNotifications = [];

              // Add friend request notifications
              for (var doc in friendRequestSnapshot.docs) {
                combinedNotifications.add({
                  'type': 'friend_request', // Identify type
                  'data': doc.data(),
                  'id': doc.id,
                });
              }

              // Add comment notifications
              for (var doc in commentNotificationsSnapshot.docs) {
                combinedNotifications.add({
                  'type': 'comment', // Identify type
                  'data': doc.data(),
                  'id': doc.id,
                });
              }

              // Add like notifications
              for (var doc in likeNotificationsSnapshot.docs) {
                combinedNotifications.add({
                  'type': 'like', // Identify type
                  'data': doc.data(),
                  'id': doc.id,
                });
              }

              return combinedNotifications; // Return the combined list
            }),
      );
    }
  }
Future<void> deleteFriendRequestNotification(String notificationId, String user) async {
  try {
    // Fetch the documents that match the query
    QuerySnapshot querySnapshot = await _firestore
        .collectionGroup('friendRequestNotifications')
        .where('receiverId', isEqualTo: user)
        .orderBy('timestamp', descending: true)
        .get();

    // Find the notification reference based on notificationId
    DocumentReference? notificationRef = querySnapshot.docs
        .firstWhereOrNull((doc) => doc.id == notificationId)
        ?.reference;

    // If the document reference is valid, delete it
    if (notificationRef != null) {
      await notificationRef.delete();
      customSnackbar(title: 'Success',message:  'Friend request notification deleted.');
    } else {
      customSnackbar(title: 'Error',message:  'Notification not found.');
    }
  } catch (e) {
    customSnackbar(title: 'Error', message: 'Failed to delete notification: $e');
  }
}


  Future<void> deleteCommentNotification(String notificationId, String user) async {

    try {
    QuerySnapshot querySnapshot = await _firestore
        .collectionGroup('commentNotifications')
        .where('receiverId', isEqualTo: user)
        .orderBy('timestamp', descending: true)
        .get();

    // Find the notification reference based on notificationId
    DocumentReference? notificationRef = querySnapshot.docs
        .firstWhereOrNull((doc) => doc.id == notificationId)
        ?.reference;

    // If the document reference is valid, delete it
    if (notificationRef != null) {
      await notificationRef.delete();
      customSnackbar(title: 'Success',message:  'comments notification deleted.');
    } else {
      customSnackbar(title: 'Error',message:  'Notification not found.');
    }
  } catch (e) {
    customSnackbar(title: 'Error',message:  'Failed to delete notification: $e');
  }
  }

}