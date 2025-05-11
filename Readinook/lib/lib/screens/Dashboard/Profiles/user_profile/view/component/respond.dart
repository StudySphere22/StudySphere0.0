import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/Dashboard/Profiles/user_profile/controller/user_profile_controller.dart';
import 'package:reedinook/screens/Friendreq/controller/friendreq_controller.dart';
import 'package:reedinook/utils/colors.dart';

class RespondToRequest extends StatefulWidget {
  final String friendId;
  final String requestid;

  const RespondToRequest({super.key, required this.friendId,required this.requestid});

  @override
  _RespondToRequestState createState() => _RespondToRequestState();
}

class _RespondToRequestState extends State<RespondToRequest> {
  // late final RespondController controller;
               late final UserProfileController
      userprofileController; // Declare the controller
       final FriendRequestController friendRequestController = Get.put(FriendRequestController());


  @override
  void initState() {
    super.initState();
     userprofileController = Get.put(UserProfileController(widget.friendId));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Close the keyboard when tapped outside
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.2, // 30% of screen height
          decoration: const BoxDecoration(
            color: Color(0xFF131A22),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header with title and close icon
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // const Text(
                    //   'Respond to Friend Request',
                    //   style: TextStyle(
                    //     fontSize: 20,
                    //     fontWeight: FontWeight.bold,
                    //     color: Colors.white,
                    //   ),
                    // ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColor.iconstext),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the bottom sheet
                      },
                    ),
                  ],
                ),
              ),
              // Buttons for accepting or declining the request
       // Buttons for accepting or declining the request
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start, // Align buttons to the left
            children: [
              // Accept Button with icon
              GestureDetector(
                onTap: () {
                  // Accept Friend Request logic here
                
                 friendRequestController.acceptFriendRequest(widget.requestid, widget.friendId);

                  Navigator.pop(context); // Close bottom sheet
                },
                child: const Align(
                  alignment: Alignment.centerLeft, // Align to the left side of the screen
                  child: Padding(
                    padding: EdgeInsets.only(left: 20), // Add padding to move it right
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Shrink to content width
                      children: [
                        Icon(Icons.person_add, color: AppColor.iconstext, size: 35), // Add friend icon
                        SizedBox(width: 8), // Space between icon and text
                        Text(
                          "Accept", // Text for Accept
                          style: TextStyle(color: AppColor.iconstext),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Cancel Button with icon
              GestureDetector(
                onTap: () {
                
             
                // print("curremt userid ${widget.requestid ?? 'No friend ID provided'}");  // Provide a fallback ID
                //  print("friendId: ${widget.friendId ?? 'No friend ID provided'}");

              friendRequestController.rejectFriendRequest(widget.requestid, widget.friendId);
                    
                  Navigator.pop(context); // Close bottom sheet
                },
                child: const Align(
                  alignment: Alignment.centerLeft, // Align to the left side of the screen
                  child: Padding(
                    padding: EdgeInsets.only(left: 20), // Add padding to move it right
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Shrink to content width
                      children: [
                        Icon(Icons.person_remove, color: AppColor.iconstext, size: 35), // Remove friend icon
                        SizedBox(width: 8), // Space between icon and text
                        Text(
                          "Cancel", // Text for Cancel
                          style: TextStyle(color: AppColor.iconstext),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
            ],
          ),
        ),
      ),
    );
  }
}