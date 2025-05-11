import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/Books/view/component/books-details/controller/books_details_controller.dart';
import 'package:reedinook/utils/app_assets%20.dart';
import 'package:reedinook/utils/colors.dart';

class StatusDropdown extends StatelessWidget {
  final Function(String) onSelected;
  final String
      bookId; // We need the bookId to listen for changes in the reading list

  const StatusDropdown({
    super.key,
    required this.onSelected,
    required this.bookId, // Pass the bookId to the controller
  });

  @override
  Widget build(BuildContext context) {
    final BookDetailsController bookDetailsController =
        Get.put(BookDetailsController());

    // Call the method to listen to the book's status in the reading list
    bookDetailsController.listenToBookInReadingList(bookId);
    bookDetailsController.listenToPlantoReading(bookId);
     bookDetailsController.listenToFinished(bookId);

    return PopupMenuButton<String>(
      icon: SvgPicture.asset(AppAssets.plusSquare, color: AppColor.iconstext,), // "+" icon remains at its position
      onSelected: onSelected, // Pass the selected value back to the parent
      offset:
          const Offset(0, 20), // Shift the dropdown list downward by 10 pixels
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'Reading',
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Spread out Text and Icon
            children: [
              const Text(
                'Reading',
                style: TextStyle(color: AppColor.white),
              ),
              // Only wrap the tick icon in Obx to make it react to the observable
              Obx(() {
                return bookDetailsController.isBookInReadingList.value
                    ? const Icon(
                        Icons.check_circle,
                        color: AppColor.clickedbutton, // Tick icon color
                        size: 20,
                      )
                    : const SizedBox
                        .shrink(); // Return an empty widget if no tick icon
              }),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'Plan To Read',
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Spread out Text and Icon
            children: [
              const Text(
                'Plan To Read',
                style: TextStyle(color: AppColor.white),
              ),
              // Only wrap the tick icon in Obx to make it react to the observable
              Obx(() {
                return bookDetailsController.isBookInPlanToReadList.value
                    ? const Icon(
                        Icons.check_circle,
                        color: AppColor.clickedbutton, // Tick icon color
                        size: 20,
                      )
                    : const SizedBox
                        .shrink(); // Return an empty widget if no tick icon
              }),
            ],
          ),
        ),
         PopupMenuItem<String>(
          value: 'Finished',
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Spread out Text and Icon
            children: [
              const Text(
                'Finished',
                style: TextStyle(color: AppColor.white),
              ),
              // Only wrap the tick icon in Obx to make it react to the observable
              Obx(() {
                return bookDetailsController.isBookInFinishedList.value
                    ? const Icon(
                        Icons.check_circle,
                        color: AppColor.clickedbutton, // Tick icon color
                        size: 20,
                      )
                    : const SizedBox
                        .shrink(); // Return an empty widget if no tick icon
              }),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'Dropped',
          child: Text(
            'Dropped',
            style: TextStyle(color: AppColor.white),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'Favorites',
          child: Text(
            'Favorites',
            style: TextStyle(color: AppColor.white),
          ),
        ),
      ],
      color: AppColor.dropdown, // Set the background color for dropdown
    );
  }
}
