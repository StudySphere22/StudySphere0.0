import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/Dashboard/Profiles/user_profile/controller/user_profile_controller.dart';
import 'package:reedinook/utils/appbar.dart';
import 'package:reedinook/utils/colors.dart';

class ViewAllUserBooks extends StatefulWidget {
  final String sectionTitle;
  // final String currentuser;
  final bool isOwnProfile;

  const ViewAllUserBooks({super.key, required this.sectionTitle, required this.isOwnProfile});

  @override
  State<ViewAllUserBooks> createState() => _ViewAllUserBooksState();
}

class _ViewAllUserBooksState extends State<ViewAllUserBooks> {
  final UserProfileController userprofileController = Get.find();

  @override
  Widget build(BuildContext context) {
    final books = widget.sectionTitle == 'Reading'
       ? userprofileController.readingBooks
        : widget.sectionTitle == 'Plan to Read'
            ? userprofileController.planToReadBooks
            : userprofileController.finishedBooks;

    return Scaffold(
      backgroundColor: AppColor.bgcolor,
      appBar: CustomAppBar(
        title: widget.sectionTitle,
        showBackButton: true, role: '',
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            //   child: Text(
            //     widget.currentuser,
            //     style: const TextStyle(
            //       fontSize: 20,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 8.0),

            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 6.0), // Padding for each card
                        child: Card(
                          color: AppColor.white, // Card color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0), // Inner padding for vertical space
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 15.0), // Even spacing on both sides
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(4.0),
                                child: book['img'] != null
                                    ? Image.network(
                                        book['img'],
                                        width: 50,
                                        height: 75,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 50,
                                        height: 75,
                                        color: Colors.grey,
                                        child: const Icon(
                                          Icons.book,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                              title: Text(
                                book['title'] ?? 'No Title',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.bgcolor
                                ),
                              ),
                              trailing: widget.isOwnProfile // Check if it's the user's own profile
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.update,
                                        color: AppColor.unselected,
                                      ), // Update icon
                                      onPressed: () {
                                        // Handle the update functionality
                                      },
                                    )
                                  : null, // Hide the button if it's not the user's own profile
                            ),
                          ),
                        ),
                      );
                    },
                  )),
            ),
          ],
        ),
      ),
    );
  }
}