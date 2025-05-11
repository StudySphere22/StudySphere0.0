import 'package:cloud_firestore/cloud_firestore.dart';

class PostTime {
  
  static timeAgo(Timestamp timestamp) {
  DateTime postDate = timestamp.toDate();
  DateTime now = DateTime.now();
  Duration difference = now.difference(postDate);

  if (difference.inDays >= 30) {
    int months = (difference.inDays / 30).floor();
    return "$months month${months > 1 ? 's' : ''} ago";
  } else if (difference.inDays >= 7) {
    int weeks = (difference.inDays / 7).floor();
    return "$weeks week${weeks > 1 ? 's' : ''} ago";
  } else if (difference.inDays > 0) {
    return "${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago";
  } else if (difference.inHours > 0) {
    return "${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago";
  } else if (difference.inMinutes > 0) {
    return "${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago";
  } else {
    return "Just now";
  }
}

}