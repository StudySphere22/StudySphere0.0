import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/Books/controller/books_controller.dart';
import 'package:reedinook/screens/Books/view/component/books-details/view/books_details.dart';
import 'package:reedinook/screens/Dashboard/Home/controller/home_controller.dart';
import 'package:reedinook/utils/appbar.dart';
import 'package:reedinook/utils/colors.dart';

class Books extends StatefulWidget {
  const Books({super.key});

  @override
  State<Books> createState() => _BooksState();
}

class _BooksState extends State<Books> {
  final BooksController booksController =
      Get.put(BooksController()); // Initialize GetX controller
  final HomeController homecontroller = Get.find<HomeController>();
  final RxString selectedGenre = 'All'.obs;
  String role = '';

  final List<String> genres = [
    'All',
    'History',
    'Art',
    'Politics',
    'Romance',
    'Biography',
    'Fantasy',
  ]; // List of genres to display

  @override
  void initState() {
    super.initState();
    role = homecontroller.role;
    // role = 'auth';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgcolor,
      body: Column(
        children: [
          CustomAppBar(title: "Books", role: role), // AppBar
          const SizedBox(height: 10), // Space between AppBar and search bar

          // Search bar with rounded corners and search icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10.0), // Rounded border for the card
              ),
              child: TextField(
                onChanged: (value) {
                  booksController
                      .setSearchTerm(value); // Set search term in controller
                },
                decoration: InputDecoration(
                  hintText: 'Search books by title, author, or ISBN quickly...',
                  hintStyle: const TextStyle(color: AppColor.unselected),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none, // Remove the default border
                  ),
                  filled: true,
                  fillColor:
                      AppColor.white, // Background color for the TextField
                  contentPadding:
                      const EdgeInsets.all(16), // Padding inside the text field
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: AppColor.unselected),
                    onPressed: () {
                      // Handle search functionality
                    },
                  ),
                ),
                style: const TextStyle(
                    color: AppColor.bgcolor), // Set the text color to white
              ),
            ),
          ),
          // Popular genres sectionjhh
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(
                    'Popular Genres',
                    style: TextStyle(
                      color: AppColor.iconstext,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: genres.map((genre) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 3.0),
                        child: Obx(() => GestureDetector(
                              onTap: () {
                                booksController.selectGenre(
                                    genre); // Set genre and fetch filtered books
                              },
                              child: Chip(
                                label: Text(
                                  genre,
                                  style: const TextStyle(
                                      color: AppColor.iconstext),
                                ),
                                backgroundColor: booksController
                                            .selectedGenre.value ==
                                        genre
                                    ? AppColor.clickedbutton
                                    : AppColor
                                        .unselected, // Color when unselected
                              ),
                            )),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Book list
          Expanded(
            child: Obx(() {
              if (booksController.filteredBooks.isEmpty) {
                return const Center(
                    child: CircularProgressIndicator()); // Loading indicator
              }

              return ListView.builder(
                padding: const EdgeInsets.only(
                    bottom: 80.0), // Adjust this value as needed
                itemCount: booksController.filteredBooks.length,
                itemBuilder: (context, index) {
                  var book = booksController.filteredBooks.isNotEmpty &&
                          index < booksController.filteredBooks.length
                      ? booksController.filteredBooks[index]
                      : {};

                  return GestureDetector(
                    onTap: () {
                      // Get.delete<
                      //     BookDetailsController>(); // Remove the controller

                      // Navigate to BooksDetails screen when a book is clicked
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BooksDetails(
                            bookId: book['id'],
                            title: book['title'] ??
                                'Unknown Title', // Pass book title
                            author: book['author'] ??
                                'Unknown Author', // Pass author
                            img: book['img'] ?? '', // Pass book image
                            description: book['desc'] ??
                                'No description available', // Pass book description
                            rating: book['rating'] != null
                                ? book['rating'].toDouble()
                                : 0.0,
                            pages:
                                book['pages'] ?? '0', // Pass book description
                            isbn: book['isbn'] ?? 'No isbn',
                            bookFormate: book['bookformat'] ??
                                'No bookformat', // Pass book description
                          ),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.all(15),
                      color: AppColor.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            10.0), // Rounded corners for book card
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Book image
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0),
                            ),
                            child: book['img'] != null
                                ? Image.network(
                                    book['img'],
                                    width: double.infinity,
                                    height: 250,
                                    fit: BoxFit
                                        .fill, // Ensures the full image is shown without cropping or blurring
                                  )
                                : Container(
                                    color: Colors.grey,
                                    height: 250,
                                    child: const Icon(Icons.book,
                                        size: 50, color: Colors.white),
                                  ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Book title
                                Text(
                                  book['title'] ?? 'Unknown Title',
                                  style: const TextStyle(
                                    color: AppColor.bgcolor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // Author name
                                Text(
                                  book['author'] ?? 'Unknown Author',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColor.bgcolor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Rating with stars
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: AppColor.clickedbutton,
                                        size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      book['rating']?.toString() ?? 'N/A',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColor.bgcolor),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
