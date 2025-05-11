// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:reedinook/screens/Dashboard/Profiles/my_profile/controller/profile_controller.dart';
// import 'package:reedinook/utils/appbar.dart';
// import 'package:reedinook/utils/colors.dart';

// class SingleBook extends StatefulWidget {
//   final String sectionTitle;
//   final String bookImg;
//   final String bookTitle;
//   final String bookAuthor;
//   final double bookRating;

//   const SingleBook({
//     super.key,
//     required this.sectionTitle,
//     required this.bookImg,
//     required this.bookTitle,
//     required this.bookAuthor,
//     required this.bookRating,
//   });

//   @override
//   State<SingleBook> createState() => _SingleBookState();
// }

// class _SingleBookState extends State<SingleBook> {
//   final ProfileController profileController = Get.find();

//   @override
//   Widget build(BuildContext context) {
//     double screenHeight = MediaQuery.of(context).size.height;
//     double cardHeight = screenHeight * 0.6;  // 60% of the screen height

//     return Scaffold(
//       appBar: CustomAppBar(
//         title: widget.sectionTitle,
//         showBackButton: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Card(
//           elevation: 4.0,
//           color: AppColor.cardcolor, // Set your preferred background color here
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.0),
//           ),
//           child: Column(
//             children: [
//               // Stack for Image and Menu Icon
//               Stack(
//                 children: [
//                  ClipRRect(
//   borderRadius: BorderRadius.circular(12.0),
//   child: widget.bookImg.isNotEmpty
//       ? Image.network(
//           widget.bookImg,
//           width: double.infinity,  // Ensure it takes the full width
//           height: cardHeight,  // Maintain the height
//           fit: BoxFit.cover,  // This will make the image cover the entire area
//         )
//       : Container(
//           color: Colors.grey,
//           width: double.infinity,
//           height: cardHeight,
//           child: const Icon(
//             Icons.book,
//             size: 40,
//             color: Colors.white,
//           ),
//         ),
// ),

//                   // Three-Dot Menu (Top Right)
//                   Positioned(
//                     top: 16.0,
//                     right: 24.0,  // Push the button a little more to the right
//                     child: IconButton(
//                       icon: const Icon(Icons.more_vert),
//                       onPressed: () {
//                         // Add your menu actions here
//                         print("Menu clicked");
//                       },
//                     ),
//                   ),
//                 ],
//               ),

//               // Book Title
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Text(
//                   widget.bookTitle,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 24.0,
//                     color: AppColor.textwhitecolor,
//                   ),
//                   overflow: TextOverflow.ellipsis, // Prevent text overflow
//                   maxLines: 2, // Allow title to span up to 2 lines
//                 ),
//               ),

//               // Book Author
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Text(
//                   widget.bookAuthor,
//                   style: const TextStyle(
//                     fontSize: 16.0,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ),

//               // Book Rating
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(
//                       Icons.star,
//                       color: Colors.amber,
//                       size: 24.0,
//                     ),
//                     const SizedBox(width: 4.0),
//                     Text(
//                       widget.bookRating.toString(),  // Convert double to String
//                       style: const TextStyle(
//                         fontSize: 18.0,
//                         color: AppColor.textwhitecolor,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
