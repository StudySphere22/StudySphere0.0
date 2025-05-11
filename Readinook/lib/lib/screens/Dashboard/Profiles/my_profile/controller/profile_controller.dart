
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/ChatList/controller/chat_lists_controller.dart';
import 'package:reedinook/screens/Dashboard/Home/controller/home_controller.dart';
import 'package:reedinook/screens/Dashboard/Profiles/my_profile/view/component/edit_profile/controller/edit_profile_controller.dart';
import 'package:reedinook/utils/clear_data.dart';
import 'package:reedinook/utils/colors.dart';
import 'package:reedinook/utils/custom_snackbar.dart';



class ProfileController extends GetxController {
  // var profilePicUrl = ''.obs; // Observable for profile picture URL
  var postsCount = 0.obs;
  var friendsCount = 0.obs;
  var posts = <DocumentSnapshot>[].obs; // Observable list for posts
  var books = <DocumentSnapshot>[].obs; // Observable for books
  var bookCount = 0.obs; // Observable to store the count of books
  RxList<Map<String, dynamic>> readingBooks = RxList<Map<String, dynamic>>([]);
  RxList<Map<String, dynamic>> planToReadBooks = RxList<Map<String, dynamic>>([]);
  RxList<Map<String, dynamic>> finishedBooks = RxList<Map<String, dynamic>>([]);
  RxList<Map<String, dynamic>> uploadedbooks= RxList<Map<String, dynamic>>([]);
  var readingBooksCount =  0.obs;
  var planToReadBooksCount = 0.obs;
  var finishedBooksCount = 0.obs;
  var uploadedbooksCount = 0.obs;
  var isPostsSelected = true.obs; // Track whether posts or books are selected
  // final picker = ImagePicker();
  String currentUser = '';
  

  final ChatListsController friendListController = Get.put(ChatListsController());
    final HomeController homecontroller = Get.put(HomeController());
    final EditProfileController editprofileController = Get.put(EditProfileController());


    
  @override
  void onInit() {
    super.onInit();
    currentUser = homecontroller.username;
     _getProfileData(); // Fetch profile data on controller init
     friendsCount.value = friendListController.friends.length;
    


  }
Future<void> logoutUser(BuildContext context) async {
  // Show confirmation dialog
  bool? shouldLogout = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppColor.bgcolor,
        title: const Text('Logout', style: TextStyle(color: AppColor.white)),
        content: const Text('Are you sure you want to logout?', style: TextStyle(color: AppColor.white)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // User does not want to logout
            },
            child: const Text('Cancel', style: TextStyle(color: AppColor.iconstext)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // User wants to logout
            },
            child: const Text('Logout', style: TextStyle(color: AppColor.clickedbutton)),
          ),
        ],
      );
    },
  );

  if (shouldLogout == true) {
    // Navigate to ClearDataWidget to clear state before signing out
    Get.to(() => ClearDataWidget());
  }
}



  Future<void> _getProfileData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final uid = user.uid;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      editprofileController.profilePicUrl.value = userDoc.data()?['profilePicUrl'] ?? '';
      postsCount.value = userDoc.data()?['postsCount'] ?? 0;

      final username = userDoc.data()?['username'];
      if (username != null) {
        // Fetch user posts
        final postsSnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .where('username', isEqualTo: username)
            .get();
        posts.assignAll(postsSnapshot.docs);

        // Real-time listener for "Books->reading" collection
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('Books->reading')
            .snapshots()
            .listen((readingBooksSnapshot) {
          List<Map<String, dynamic>> readingBooksList = readingBooksSnapshot.docs.map((doc) {
            var data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

          // Update the reading books count and list
          readingBooksCount.value = readingBooksList.length;
          readingBooks.assignAll(readingBooksList);
        });

        // Real-time listener for "Books->PlanToRead" collection
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('Books->PlanToRead')
            .snapshots()
            .listen((planToReadBooksSnapshot) {
          List<Map<String, dynamic>> planToReadBooksList = planToReadBooksSnapshot.docs.map((doc) {
            var data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

          // Update the plan-to-read books count and list
          planToReadBooksCount.value = planToReadBooksList.length;
          planToReadBooks.assignAll(planToReadBooksList);
        });

        // Real-time listener for "Books->Finished" collection
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('Books->Finished')
            .snapshots()
            .listen((finishedBooksSnapshot) {
          List<Map<String, dynamic>> finisedBooksList = finishedBooksSnapshot.docs.map((doc) {
            var data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

          // Update the plan-to-read books count and list
          finishedBooksCount.value = finisedBooksList.length;
          finishedBooks.assignAll(finisedBooksList);
        });

         FirebaseFirestore.instance
            .collection('books')
            .where('userId', isEqualTo: uid) 
            .snapshots()
            .listen((uploadedbooksSnapshot) {
          List<Map<String, dynamic>> uploadedbooksList = uploadedbooksSnapshot.docs.map((doc) {
            var data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

          
          uploadedbooksCount.value = uploadedbooksList.length;
          uploadedbooks.assignAll(uploadedbooksList);
        });
      }
    }
  }
}



  void updatePostsCount(int count) {
    postsCount.value = count; // Update posts count
    print('Updating posts count to: $count'); // Debugging line
  }
  
 


  Future<void> deletePostAndComments(String postId) async {
    try {
      print('Deleting post and associated comments...');

      // Reference to the post document in the posts collection
      DocumentReference postRef =
          FirebaseFirestore.instance.collection('posts').doc(postId);

      // Reference to the comments document in the comments collection
      DocumentReference commentsRef =
          FirebaseFirestore.instance.collection('comments').doc(postId);

      // Start a batch write operation  A WriteBatch object is created to group multiple write operations into a single atomic operation. This ensures that either all operations succeed or none do, maintaining data integrity.
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Delete the post document
      batch.delete(postRef);

      // Delete the comments document associated with this postId
      batch.delete(commentsRef);

      // Optionally, if you want to ensure all comments in the postComments sub-collection are deleted, do this:
      // Fetch the postComments collection and delete each comment
      QuerySnapshot postCommentsSnapshot =
          await commentsRef.collection('postComments').get();
      for (DocumentSnapshot commentDoc in postCommentsSnapshot.docs) {
        batch.delete(commentDoc.reference);
      }

      // Commit the batch operation
      await batch.commit();

      customSnackbar(title: 'Success', message: 'Post Deleted successfully!');
    } catch (e) {
      print('Error deleting post and comments: $e');
    }
  }

}
