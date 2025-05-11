import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/Books/view/component/books-details/view/books_details.dart';
import 'package:reedinook/screens/Dashboard/Profiles/my_profile/view/component/uploaded_book/controller/uploaded_book_controller.dart';
import 'package:reedinook/utils/colors.dart';
import 'package:reedinook/utils/custom_loading_indicator.dart';

class UploadedBooks extends StatefulWidget {
  final String userid;
  final bool isOwnProfile;
  const UploadedBooks(
      {super.key, required this.userid, required this.isOwnProfile});

  @override
  State<UploadedBooks> createState() => _UploadedBooksState();
}

class _UploadedBooksState extends State<UploadedBooks> {
  late final UploadedBooksController _controller;

  @override
  void initState() {
    super.initState();
    // Pass `userid` to the controller
    _controller = Get.put(UploadedBooksController(widget.userid));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgcolor,
      appBar: AppBar(
        backgroundColor: AppColor.bgcolor,
        title: const Text(
          'Uploaded Books',
          style: TextStyle(color: AppColor.iconstext),
        ),
        //  backgroundColor: AppColor.bgcolor,
        iconTheme: const IconThemeData(
          color: AppColor.iconstext,
        ),
      ),

     body: Stack(
        children: [
          Obx(() {
        if (_controller.uploadedBooks.isEmpty) {
          return const Center(
            child: Text('No uploaded books found',  style: TextStyle(color: AppColor.iconstext),),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(
              bottom: 80.0), // Adjust this value as needed
          itemCount: _controller.uploadedBooks.length,
          itemBuilder: (context, index) {
            final book = _controller.uploadedBooks[index];

            return GestureDetector(
              onTap: () {
                // Navigate to a detailed book screen if needed
                //  Get.delete<
                //                   BookDetailsController>(); // Remove the controlle
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BooksDetails(
                      bookId: book['id'] ?? '',
                      title: book['title'] ?? 'Unknown Title',
                      author: book['author'] ?? 'Unknown Author',
                      img: book['img'] ?? '',
                      description: book['desc'] ?? 'No description available',
                      rating: book['rating'] != null
                          ? book['rating'].toDouble()
                          : 0.0,
                      pages: book['pages'] ?? '0',
                      isbn: book['isbn'] ?? 'No ISBN',
                      bookFormate: book['bookformat'] ?? 'No Format',
                    ),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.all(15),
                color: AppColor.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10.0), // Rounded corners for card
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Book Image
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
                                  fit: BoxFit.fill,
                                )
                              : Container(
                                  color: Colors.grey,
                                  height: 250,
                                  child: const Icon(Icons.book,
                                      size: 50, color: Colors.white),
                                ),
                        ),
                        // Book Details
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                book['title'] ?? 'No Title',
                                style: const TextStyle(
                                  color: AppColor.bgcolor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Author
                              Text(
                                'Author: ${book['author'] ?? 'Unknown Author'}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColor.bgcolor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Rating
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: AppColor.clickedbutton,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    book['rating']?.toStringAsFixed(2) ?? 'N/A',
                                    style: const TextStyle(
                                        fontSize: 14, color: AppColor.bgcolor),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Popup menu for own profile
                    if (widget.isOwnProfile)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') {
                              _controller.deleteBook(book['id']); // Delete book from books collections
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'delete',
                              child: Center(
                                child: Text(
                                  'Delete',
                                  style: TextStyle(
                                      fontSize: 14, color: AppColor.iconstext),
                                ),
                              ),
                            ),
                          ],
                          icon: const Icon(
                            Icons.more_vert,
                            color: AppColor.bgcolor,
                          ),
                          color: AppColor.unselected,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                20), // Adjust the radius as needed
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      // Loading indicator overlay
          Obx(() {
            return _controller.isLoading.value
                ? Center(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                        alignment: Alignment.center,
                        child:
                            const CustomLoadingIndicator(), // Centered loading indicator
                      ),
                    ),
                  )
                : const SizedBox.shrink(); // Empty widget when not loading
          }),
        ],
      ),
    );
  }
}
