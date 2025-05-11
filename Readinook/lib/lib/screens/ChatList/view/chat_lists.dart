import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/ChatList/controller/chat_lists_controller.dart';
import 'package:reedinook/screens/ChatList/view/component/group/controller/group_controller.dart';
import 'package:reedinook/screens/Chats/controller/chat_controller.dart';
import 'package:reedinook/screens/Chats/view/Chatting.dart';
import 'package:reedinook/screens/Dashboard/Profiles/user_profile/controller/user_profile_controller.dart';
import 'package:reedinook/screens/Dashboard/Profiles/user_profile/view/user_profile.dart';
import 'package:reedinook/screens/Group_chat/controller/group_chat_controller.dart';
import 'package:reedinook/screens/Group_chat/view/group_chat.dart';
import 'package:reedinook/utils/app_assets%20.dart';
import 'package:reedinook/utils/appbar.dart';
import 'package:reedinook/utils/colors.dart';

class ChatLists extends StatefulWidget {
  final String friendId;

  const ChatLists({super.key, required this.friendId});

  @override
  _ChatListsState createState() => _ChatListsState();
}

class _ChatListsState extends State<ChatLists> {
  final ChatListsController chatlistcontroller = Get.put(ChatListsController());
  final GroupController groupController = Get.put(GroupController());
  @override
  void initState() {
    super.initState();
    // Call the function to check group membership when the widget is initialized
    groupController.checkUserInGroupChat();
    chatlistcontroller.fetchGroupChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgcolor,
      body: Column(
        children: [
          const CustomAppBar(title: "Friends", groupicon: true, role: '',),
          Expanded(
            child: Obx(() {
              if (chatlistcontroller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (chatlistcontroller.friends.isEmpty) {
                return const Center(child: Text('No friends found.',style: TextStyle(color: AppColor.iconstext)));
              }

              // Filter group chats where the current user is a member
              var userId = FirebaseAuth.instance.currentUser?.uid ?? '';
              var filteredGroupChats = chatlistcontroller.group_chats
                  .where((group) => group['members']
                      .any((member) => member['userId'] == userId))
                  .toList();

              return ListView.builder(
                itemCount: filteredGroupChats.length +
                    chatlistcontroller.friends.length,
                padding: const EdgeInsets.only(top: 4.0, bottom: 80),
                itemBuilder: (context, index) {
                  if (index < filteredGroupChats.length) {
                    // Show group chat cards
                    var group = filteredGroupChats[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 3.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        color: AppColor.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Group Name
                              Text(
                                group['groupName'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.bgcolor,
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Members Row
                              Row(
                                children: [
                                  // Profile Pictures
                                  Flexible(
                                    flex: 2,
                                    child: SizedBox(
                                      height: 40,
                                      child: Stack(
                                        children: [
                                          for (var i = 0;
                                              i < group['members'].length;
                                              i++)
                                            Positioned(
                                              left: i *
                                                  10.0, // Adjust overlap as needed
                                              child: CircleAvatar(
                                                radius: 20,
                                                backgroundColor: (group[
                                                        'profilePicUrl'] ==
                                                    null ||
                                                group['profilePicUrl'].isEmpty)
                                            ? AppColor
                                                .iconstext // Replace with your desired background color
                                            : Colors
                                                .transparent,
                                                backgroundImage: NetworkImage(
                                                  group['members'][i]
                                                          ['profilePicUrl'] ??
                                                      '',
                                                ),
                                                child: group['members'][i]
                                                            ['profilePicUrl'] ==
                                                        null
                                                    ? const Icon(
                                                        Icons.account_circle,
                                                        size: 30,
                                                        color:
                                                            AppColor.bgcolor,
                                                      )
                                                    : null,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // const SizedBox(width: 8),
                                  // Member Names
                                  Expanded(
                                    flex: 8,
                                    child: Text(
                                      group['members']
                                          .map((member) => member['userName'])
                                          .join(", "),
                                      style: const TextStyle(
                                         fontWeight: FontWeight.bold,
                                        color: AppColor.bgcolor,
                                        fontSize: 12,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      maxLines: 1,
                                      softWrap: false,
                                    ),
                                  ),
                                  // Chat Icon
                                  Transform.translate(
                                    offset: const Offset(-5.0, 0),
                                    child: IconButton(
                                      icon: SvgPicture.asset(
                                        AppAssets.chat,
                                        color: AppColor.unselected,
                                      ),
                                      onPressed: () {
                                         Get.delete<GroupChatController>();
                                        var groupId = group['groupId'];
                                        var members = group['members'];

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => GroupChat(
                                              members: members,
                                              groupId: groupId,
                                              currentUserId: userId,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    // Show individual friend cards
                    var adjustedIndex = index - filteredGroupChats.length;
                    var friend = chatlistcontroller.friends[adjustedIndex];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 3.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        color: AppColor.white,
                        child: Stack(
                          children: [
                            ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              leading: GestureDetector(
                                onTap: () {
                                  Get.delete<UserProfileController>();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserProfile(
                                        friendName: friend['friendName'],
                                        friendAbout: friend['about'],
                                        friendProfilepic:
                                            friend['profilePicUrl'],
                                        friendId: friend['friendId'],
                                        friendrole: friend['role'],
                                        isFriend: true,
                                         requestid: '',

                                      ),
                                    ),
                                  );
                                },
                                child: CircleAvatar(
                                  backgroundColor: (friend['profilePicUrl'] ==
                                              null ||
                                          friend['profilePicUrl'].isEmpty)
                                      ? AppColor
                                          .iconstext // Replace with your desired background color
                                      : Colors.transparent,
                                  backgroundImage: (friend['profilePicUrl'] !=
                                              null &&
                                          friend['profilePicUrl'] != '')
                                      ? NetworkImage(friend['profilePicUrl'])
                                      : null,
                                  child: (friend['profilePicUrl'] == null ||
                                          friend['profilePicUrl'] == '')
                                      ? const Icon(Icons.person,
                                          size: 30, color: AppColor.unselected)
                                      : null,
                                ),
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    friend['friendName'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.bgcolor,
                                    ),
                                  ),
                                  if (friend['unreadPostsCount'] > 0)
                                    Text(
                                      friend['unreadPostsCount'] > 3
                                          ? '3+ New Posts'
                                          : '${friend['unreadPostsCount']} New Post${friend['unreadPostsCount'] > 1 ? 's' : ''}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.clickedbutton,
                                        fontSize: 14,
                                      ),
                                    ),
                                  if (friend['unreadPostsCount'] == 0 &&
                                      friend['unreadMessageCount'] > 0)
                                    Text(
                                      friend['unreadMessageCount'] > 3
                                          ? '3+ New Messages'
                                          : '${friend['unreadMessageCount']} New Message${friend['unreadMessageCount'] > 1 ? 's' : ''}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.clickedbutton,
                                        fontSize: 14,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: SvgPicture.asset(
                                      AppAssets.chat,
                                      color: AppColor.unselected,
                                    ),
                                    onPressed: () async {
                                      var currentUser =
                                          FirebaseAuth.instance.currentUser;

                                      String chatRoomId =
                                          chatlistcontroller.generateChatRoomId(
                                              currentUser!.uid,
                                              friend['friendId'] ?? '');

                                      bool chatRoomExists =
                                          await chatlistcontroller
                                              .checkChatRoomExists(chatRoomId);
                                      if (!chatRoomExists) {
                                        // await
                                         chatlistcontroller.createChatRoom(
                                            chatRoomId,
                                            currentUser.uid,
                                            friend['friendId'] ?? '');
                                      }
                                      //  await
                                      chatlistcontroller
                                          .markMessagesAsRead(
                                              friend['friendId'] ?? '');
                                                // await 
                                    chatlistcontroller.markPostsAsRead(
                                          friend['friendId'] ?? '');

                                      chatlistcontroller.updateFriendList(
                                          friend['friendId'], 0,
                                          isMessage: true);
                                      chatlistcontroller.updateFriendList(
                                          friend['friendId'], 0,
                                          isMessage: false);

                                      Get.delete<ChatController>();

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Chatting(
                                            friendId: friend['friendId'] ?? '',
                                            friendName: friend['friendName'] ??
                                                'Unknown',
                                            profilePicUrl:
                                                friend['profilePicUrl'] ?? '',
                                            chatRoomId: chatRoomId,
                                            status:
                                                friend['status'] ?? 'offline',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 35,
                              left: 42,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (friend['status'] == 'online')
                                      ? AppColor.clickedbutton
                                      : AppColor.unselected,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              );
            }),
          )
        ],
      ),
    );
  }
}
