import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:reedinook/utils/custom_snackbar.dart';

class PostsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;

  // Method to save the post
  Future<void> savePost(String? profilePicUrl, String? username, String postText) async {
    if (postText.isEmpty) {
      customSnackbar(title: "Error", message: "Please enter some text for the post");
      return;
    }

    try {

      
      isLoading.value = true; // Start loading
      
       final user = FirebaseAuth.instance.currentUser;
      final postOwnerId = user?.uid; // The ID of the post owner (logged-in user)

       if (postOwnerId == null) {
        customSnackbar(title: "Error",message: "User not logged in");
        return;
      }

      await _firestore.collection('posts').add({
        'text': postText,
        'profilePicUrl': profilePicUrl,
        'username': username, // Save the username
        'likes': 0, // Initialize likes to 0
        'comments': 0, // Initialize comments to 0
        'shares': 0, // Initialize shares to 0
        'timestamp': FieldValue.serverTimestamp(),
        'likedBy': [],
        'postOwnerId': postOwnerId, // Add the post owner ID

      });

      customSnackbar(title: "Success", message: "Post added successfully");
    } catch (e) {
      customSnackbar(title: "Error",message:  "Post not added.");
    } finally {
      isLoading.value = false; // Stop loading
    }
  }
}
