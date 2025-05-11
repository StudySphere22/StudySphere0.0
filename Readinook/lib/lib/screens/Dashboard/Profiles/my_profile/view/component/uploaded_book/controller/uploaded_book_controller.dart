import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:reedinook/utils/custom_snackbar.dart';

class UploadedBooksController extends GetxController {
  final RxList<Map<String, dynamic>> uploadedBooks = <Map<String, dynamic>>[].obs;
  final String userId;

  UploadedBooksController(this.userId);

 RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    listenToUploadedBooks();
  }

  void listenToUploadedBooks() async {
    try {
      // Listen to the 'books' collection for changes where 'userId' matches
      FirebaseFirestore.instance
          .collection('books')
          .where('userId', isEqualTo: userId) // Filter books by userId
          .snapshots()
          .listen((QuerySnapshot booksSnapshot) {
        // Map Firestore documents to a list of dynamic maps
        uploadedBooks.value = booksSnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                })
            .toList();
      });
    } catch (e) {
      // Show an error snackbar if fetching books fails
      customSnackbar(title:"Error", message: "Failed to listen to uploaded books: $e");
    }
  }


  Future<void> deleteBook(String bookId) async {
    isLoading.value=true;
  try {
    final firestore = FirebaseFirestore.instance;

    // Start a batch for atomic operations
    final batch = firestore.batch();

    // Reference to the book document
    final bookRef = firestore.collection('books').doc(bookId);

    // Add book deletion to the batch
    batch.delete(bookRef);

    // Query `user_ratings` for documents where `bookId` matches
    final userRatingQuerySnapshot = await firestore
        .collection('user_ratings')
        .where('bookId', isEqualTo: bookId)
        .get();

    // Add each matching `user_rating` document to the batch for deletion
    for (var doc in userRatingQuerySnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Query all users to check their sub-collections for matching bookId
    final usersSnapshot = await firestore.collection('users').get();

    for (var userDoc in usersSnapshot.docs) {
      final userId = userDoc.id;

      // Helper function to delete documents in a sub-collection
      Future<void> deleteFromSubCollection(String subCollection) async {
        final subCollectionSnapshot = await firestore
            .collection('users')
            .doc(userId)
            .collection(subCollection)
            .where('bookId', isEqualTo: bookId)
            .get();

        for (var subDoc in subCollectionSnapshot.docs) {
          batch.delete(subDoc.reference);
        }
      }

      // Delete from `reading`, `Finished`, and `PlanToRead`
      await deleteFromSubCollection('Books->reading');
      await deleteFromSubCollection('Books->Finished');
      await deleteFromSubCollection('Books->PlanToRead');
    }

    // Commit the batch
    await batch.commit();

    customSnackbar(
        title: "Success", message: "Book and all related records deleted successfully");
  } catch (e) {
    // Handle any errors
    customSnackbar(title: "Error", message: "Failed to delete the book and related records: $e");
   } finally {
    isLoading.value = false; // Set loading to false after completion
  }
  }
}
