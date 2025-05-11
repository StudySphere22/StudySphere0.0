import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/Books/controller/books_controller.dart';
import 'package:reedinook/screens/Books/view/component/books-details/controller/books_details_controller.dart';
import 'package:reedinook/utils/colors.dart';
import 'package:reedinook/utils/custom_snackbar.dart';
import 'package:reedinook/utils/status_dropdown.dart';

class BooksDetails extends StatefulWidget {
  final String bookId;
  final String title;
  final String author;
  final String img;
  final String description;
  final double rating;
  final int pages;
  final String isbn;
  final String bookFormate;

  const BooksDetails({
    super.key,
    required this.bookId,
    required this.title,
    required this.author,
    required this.img,
    required this.description,
    required this.rating,
    required this.pages,
    required this.isbn,
    required this.bookFormate,
  });

  @override
  State<BooksDetails> createState() => _BooksDetailsState();
}

class _BooksDetailsState extends State<BooksDetails> {
  bool isBookInReadingList =
      false; // Flag to check if the book is in the reading list
  bool isExpanded = false;
  final RxDouble userRating = 0.0.obs;
  final BookDetailsController bookDetailsController =
      Get.put(BookDetailsController());
  final BooksController booksController =
      Get.put(BooksController()); // Use BooksController

  @override
  void initState() {
    super.initState();
    bookDetailsController.listenToBookInReadingList(widget.bookId);
    bookDetailsController.listenToPlantoReading(widget.bookId);
    bookDetailsController.setBookId(widget.bookId);
  }

  void handleStatusSelection(String value) async {
    // Check if the username is not empty before proceeding with status changes
    if (bookDetailsController.userName.isNotEmpty) {
      if (value == 'Reading') {
        // Call the method to save the book to the "Reading" collection
        await bookDetailsController.addBookToReading(
          bookId: widget.bookId,
          title: widget.title,
          author: widget.author,
          img: widget.img,
          description: widget.description,
          rating: widget.rating,
          pages: widget.pages,
          isbn: widget.isbn,
          bookFormate: widget.bookFormate,
        );
      } else if (value == 'Plan To Read') {
        // Call the method to save the book to the "Plan to Read" collection
        await bookDetailsController.addBookToPlantoReading(
          bookId: widget.bookId,
          title: widget.title,
          author: widget.author,
          img: widget.img,
          description: widget.description,
          rating: widget.rating,
          pages: widget.pages,
          isbn: widget.isbn,
          bookFormate: widget.bookFormate,
        );
      } else if (value == 'Finished') {
        await bookDetailsController.addBookToFinished(
          bookId: widget.bookId,
          title: widget.title,
          author: widget.author,
          img: widget.img,
          description: widget.description,
          rating: widget.rating,
          pages: widget.pages,
          isbn: widget.isbn,
          bookFormate: widget.bookFormate,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgcolor,
      appBar: AppBar(
        backgroundColor: AppColor.bgcolor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColor.iconstext,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          StatusDropdown(
            onSelected: handleStatusSelection,
            bookId: widget.bookId, // Pass the bookId to the dropdown
          ), // Use StatusDropdown here
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Book Image
                  widget.img.isNotEmpty
                      ? Image.network(
                          widget.img,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.book, size: 100),

                  const SizedBox(height: 10),

                  // Book Title
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 22,
                      color: AppColor.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 5),

                  // Book Author
                  Text(
                    widget.author,
                    style: const TextStyle(
                        fontSize: 18, color: AppColor.iconstext),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 5),

                  // Display Rating
                  Obx(() {
                    // Ensure the book exists in the list before accessing it
                    var currentBook = booksController.filteredBooks.isNotEmpty
                        ? booksController.books.firstWhere(
                            (book) => book['id'] == widget.bookId,
                            orElse: () => null,
                          )
                        : null;

                    if (currentBook == null) {
                      return Text(
                        "Rating: ${widget.rating.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: AppColor.clickedbutton,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }

                    double currentRating =
                        currentBook['rating'] ?? widget.rating;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(5, (index) {
                          if (index < currentRating.floor()) {
                            return const Icon(Icons.star,
                                color: AppColor.clickedbutton, size: 20);
                          } else if (index < currentRating) {
                            return const Icon(Icons.star_half,
                                color: AppColor.clickedbutton, size: 20);
                          } else {
                            return const Icon(Icons.star_border,
                                color: AppColor.clickedbutton, size: 20);
                          }
                        }),
                        const SizedBox(width: 4),
                        Text(
                          currentRating.toStringAsFixed(2),
                          style: const TextStyle(
                            color: AppColor.iconstext,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 5),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     // Implement Read button functionality
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: AppColor.cardcolor,
                  //     elevation: 5,
                  //   ),
                  //   child: const Text(
                  //     "Read",
                  //     style: TextStyle(color: Colors.white),
                  //   ),
                  // ),

                  const SizedBox(height: 20),

                  // Pages, ISBN, and Book Format with vertical divider
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 15.0, // Space between items
                    runSpacing: 10.0, // Space between rows when wrapping
                    children: [
                      _buildInfoColumn("${widget.pages}", "Pages"),
                      _buildVerticalDivider(),
                      _buildInfoColumn(widget.isbn, "ISBN"),
                      _buildVerticalDivider(),
                      _buildInfoColumn(widget.bookFormate, "Book Format"),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Book Description with Read More/Less functionality
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: isExpanded
                            ? double.infinity
                            : 100, // Adjust height based on expansion
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Text(
                          isExpanded
                              ? widget.description
                              : widget.description.length > 200
                                  ? '${widget.description.substring(0, 200)}...'
                                  : widget
                                      .description, // Show full description if less than 200 characters
                          style: const TextStyle(color: AppColor.iconstext),
                        ),
                      ),
                    ),
                  ),
                  if (widget.description.length >
                      200) // Only show button if necessary
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        child: Text(
                          isExpanded ? 'Read Less' : 'Read More',
                          style: const TextStyle(
                              color: AppColor.clickedbutton,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  const SizedBox(height: 5),

                  Column(
                    children: [
                      // Row for displaying star icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...List.generate(5, (index) {
                            return IconButton(
                              icon: Icon(
                                index < userRating.value
                                    ? Icons.star
                                    : Icons.star_border,
                                color: AppColor.clickedbutton,
                              ),
                              onPressed: () {
                                setState(() {
                                  userRating.value = index +
                                      1.0; // Set rating based on the star clicked
                                });
                              },
                            );
                          }),
                        ],
                      ),

                      // Submit Button
                      ElevatedButton(
                        onPressed: () {
                          if (userRating <= 0) {
                            customSnackbar(
                                title: "Error",
                                message: "Please select a valid rating");
                            return;
                          }
                          if (userRating > 0) {
                            // Submit the rating to Firestore
                            bookDetailsController.rateBook(
                                widget.bookId, userRating.value);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.clickedbutton,
                          elevation: 5,
                        ),
                        child: const Text(
                          "Submit",
                          style: TextStyle(color: AppColor.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      
        ],
      ),
    );
  }

  // Helper method to create information columns
  Column _buildInfoColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: AppColor.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColor.iconstext),
        ),
      ],
    );
  }

  // Helper method to create vertical divider
  Container _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColor.textblackcolor,
      margin: const EdgeInsets.symmetric(horizontal: 15),
    );
  }
}
