import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/Books/view/component/upload_books/view/upload_book.dart';
import 'package:reedinook/screens/ChatList/view/component/group/view/group.dart';
import 'package:reedinook/utils/app_assets%20.dart';
import 'package:reedinook/utils/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title; // Title is now nullable
  final String? hintText; // Hint text is also nullable
  final TextEditingController?
      searchController; // Added searchController parameter
  final Function(String)? onSearchChanged; // Added onSearchChanged callback
  final bool showBackButton; // Add parameter to control back button visibility
  final bool groupicon;
  final String role;

  const CustomAppBar({
    super.key,
    this.title, // Initialize title as optional
    this.hintText, // Initialize hintText as optional
    this.searchController, // Initialize searchController as optional
    this.onSearchChanged, // Initialize onSearchChanged as optional
    this.showBackButton = false, // Default to false
    this.groupicon = false, // Default to false
    required this.role,
  }) : assert(
          (title != null && hintText == null) ||
              (title == null && hintText != null),
          'You must provide either a title or a hintText, but not both.',
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * .12, // Set the height as required
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: Color(0xFF131A22),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          crossAxisAlignment: CrossAxisAlignment.start, // Align to the start
          children: [
            const SizedBox(height: 10), // Add space above the title
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Place title on left, plus on right
              children: [
                Row(
                  children: [
                    if (showBackButton)
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: AppColor.iconstext), // Back button icon
                        onPressed: () {
                          Navigator.pop(
                              context); // Go back to the previous screen
                        },
                      ),
                    const SizedBox(
                        width: 10), // Add space between back button and title
                    if (title != null) // Display title if provided
                      Text(
                        title!,
                        style: const TextStyle(
                          color: AppColor.iconstext,
                          fontSize: 20, // Set font size as required
                          fontWeight: FontWeight.normal, // Non-bold text
                        ),
                      ),
                  ],
                ),
                if (groupicon) // Show plus icon if true
                  IconButton(
                    icon: SvgPicture.asset(AppAssets.groupicon,
                        color: AppColor.iconstext),
                    onPressed: () {
                      // Open a bottom sheet to create a new group
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled:
                            true, // Allows flexible height based on content
                        backgroundColor: Colors
                            .transparent, // Make background transparent for better visual
                        builder: (BuildContext context) {
                          return const Group(); // The screen for creating a group chat
                        },
                      );
                    },
                  ),

                //                Expanded(
                //   child: Container(), // Pushes other content to the right
                // ),
                // Only show the plus icon if role == 'auth'
                if (role == 'auth')
                  IconButton(
                    icon: const Icon(
                      Icons.add,
                      size: 24, // Adjust size as needed
                      color: AppColor.iconstext,
                    ),
                    onPressed: () {
                   Get.to(() => const UploadBooks());
                    },
                  ),
                // Alternatively, if you also check for `groupicon`
                if (groupicon && role == 'auth')
                  IconButton(
                    icon: const Icon(
                      Icons.group,
                      size: 24, // Adjust size as needed
                      color: AppColor.iconstext,
                    ),
                    onPressed: () {
                      // Define action for group icon
                    },
                  ),
              ],
            ),
            if (searchController != null)
              Padding(
                padding: const EdgeInsets.only(
                    top: 8.0), // Space between title and search field
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: hintText ?? '', // Use hintText if provided
                    border: InputBorder.none,
                    hintStyle: const TextStyle(
                        color: Colors.white54), // Style for hint text
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear,
                          color: Colors.white54), // Icon to clear text
                      onPressed: () {
                        searchController?.clear(); // Clear the search input
                        onSearchChanged
                            ?.call(''); // Optionally notify the search change
                      },
                    ),
                  ),
                  style: const TextStyle(
                    color: Colors.white, // Text color
                    fontSize: 15, // Set font size as required
                    fontWeight: FontWeight.normal, // Non-bold text
                  ),
                  onChanged:
                      onSearchChanged, // Call the onSearchChanged function
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(Get.height * .12); // Provide preferred size
}
