import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/Dashboard/Notifications/controller/notification_controller.dart';
import 'package:reedinook/utils/appbar.dart';
import 'package:reedinook/utils/colors.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate the NotificationController
    final NotificationController notificationController =
        Get.put(NotificationController());

    return Scaffold(
      backgroundColor: AppColor.bgcolor,
      appBar: const CustomAppBar(title: "Notifications", showBackButton: true, role: '',),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              return StreamBuilder<List<Map<String, dynamic>>>(
                stream: notificationController.notificationsStream.value,
                builder: (context, snapshot) {
                  // While loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // If no notifications or data is empty
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "No notifications.",
                        style: TextStyle(color: AppColor.iconstext),
                      ),
                    );
                  }

                  var notifications = snapshot.data!;

                  return ListView.builder(
                    itemCount: notifications.length,
                    padding: const EdgeInsets.only(top: 4.0),
                    itemBuilder: (context, index) {
                      var notification = notifications[index];
                      var message =
                          notification['data']['message'] ?? 'No message';
                      var senderId = notification['data']['senderId'];
                      var messageId = notification['id'];
                      var receiverId = notification['data']['receiverId'];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 3.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          color: AppColor.white,
                          child: Dismissible(
                            key: Key(messageId),
                            direction: DismissDirection.startToEnd,
                            onDismissed: (direction) {
                              // Check if the notification is a friend request or a comment
                              if (notification['type'] == 'friend_request') {
                                notificationController
                                    .deleteFriendRequestNotification(
                                        messageId, receiverId);
                              } else if (notification['type'] == 'comment') {
                                notificationController
                                    .deleteCommentNotification(
                                        messageId, receiverId);
                              }
                            },
                            background: Container(
                              color: AppColor.unselected,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 16.0),
                              child: const Icon(Icons.delete,
                                  color: AppColor.iconstext),
                            ),
                            child: FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(senderId)
                                  .get(),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return ListTile(
                                    title: Text(message),
                                    subtitle: const Text(
                                        "Fetching user information..."),
                                  );
                                }

                                if (userSnapshot.hasError ||
                                    !userSnapshot.hasData) {
                                  return ListTile(
                                    title: Text(message),
                                    subtitle: const Text(
                                        "Failed to fetch user information"),
                                  );
                                }

                                var userData = userSnapshot.data!.data() as Map<
                                    String, dynamic>?; // Cast the user data
                                var profilePicUrl =
                                    userData?['profilePicUrl'] ??
                                        ''; // Access profilePicUrl safely
                                var timestamp = notification['data']
                                        ['timestamp']
                                    as Timestamp?; // Access timestamp safely
                                var formattedDate = timestamp != null
                                    ? DateTime.fromMillisecondsSinceEpoch(
                                            timestamp.millisecondsSinceEpoch)
                                        .toString()
                                    : 'Unknown date';

                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: (profilePicUrl == null ||
                                            profilePicUrl.isEmpty)
                                        ? AppColor
                                            .iconstext // Replace with your desired background color
                                        : Colors.transparent,
                                    backgroundImage: profilePicUrl.isNotEmpty
                                        ? NetworkImage(profilePicUrl)
                                        : null,
                                    child: profilePicUrl.isEmpty
                                        ? const Icon(Icons.person,
                                            size: 30, color: AppColor.unselected)
                                        : null, // Set a default background color
                                  ),
                                  title: Text(
                                    message,
                                    style: const TextStyle(
                                        color: AppColor.bgcolor),
                                  ),
                                  subtitle: Text(
                                    "Received on $formattedDate",
                                    style: const TextStyle(
                                        color: AppColor.hinttextcolor),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
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
