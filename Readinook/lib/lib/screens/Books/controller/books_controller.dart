import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class BooksController extends GetxController {
  var books = [].obs; // Observable list to hold books (fetched 200 books)
  var selectedGenre = 'All'.obs; // Observable to track selected genre
  var searchTerm = ''.obs; // Observable to track the search term
  var filteredBooks = [].obs; // Observable list to hold filtered books
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance; // FirebaseAuth instance to get current user

  @override
  void onInit() {
    super.onInit();
    fetchBooks(); // Fetch the first 200 books when the controller is initialized
  }

  // Fetch the first 200 books
  void fetchBooks({int limit = 200}) {
    String currentUserId = auth.currentUser?.uid ?? ''; // Get current user's ID
    if (currentUserId.isEmpty) {
      print("User not logged in");
      return;
    }

    // Fetch the first 200 books from the main 'books' collection
    Query mainBooksQuery = firestore.collection('books').limit(limit);

    // Listen for real-time updates to the book collection
    mainBooksQuery.snapshots().listen((QuerySnapshot snapshot) {
      var fetchedBooks = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add the document ID to the data
        return data;
      }).toList();

      books.value = fetchedBooks; // Store the fetched 200 books
      filterBooks(); // Apply filtering for genre and search term
    }, onError: (error) {
      print("Error fetching books: $error");
    });
  }

 void filterBooks() {
  // Step 1: Filter by genre (check if genre contains selected genre)
  var genreFilteredBooks = selectedGenre.value == 'All'
      ? books
      : books.where((book) {
          var genre = book['genre']?.toString().toLowerCase() ?? ''; // Safely get genr
          return genre.contains(selectedGenre.value.toLowerCase()); // Substring match
        }).toList();

  // Step 2: Further filter by search term
  if (searchTerm.value.isEmpty) {
    filteredBooks.value = genreFilteredBooks; // No search term, apply only genre filtering
  } else {
    filteredBooks.value = genreFilteredBooks
        .where((book) {
          var title = book['title']?.toString().toLowerCase() ?? ''; // Safely get title
          var author = book['author']?.toString().toLowerCase() ?? ''; // Safely get author
          var isbn = book['isbn']?.toString().toLowerCase() ?? ''; // Safely get ISBN

          // Match title, author, or ISBN
          return title.startsWith(searchTerm.value.toLowerCase()) ||
                 author.startsWith(searchTerm.value.toLowerCase()) ||
                 isbn.startsWith(searchTerm.value.toLowerCase());
        })
        .toList();
  }
// add search book bu author and isbn
}


  // Method to change the selected genre and apply filtering
  void selectGenre(String genre) {
    selectedGenre.value = genre; // Update the selected genre
    filterBooks(); // Re-filter books based on the new genre
  }

  // Method to set the search term and apply filtering
  void setSearchTerm(String term) {
    searchTerm.value = term; // Update the search term
    filterBooks(); // Re-filter books based on the search term
  }
}
