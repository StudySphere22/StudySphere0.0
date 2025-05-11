import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/Chats/controller/chat_controller.dart';
import 'package:reedinook/utils/app_assets%20.dart';
import 'package:reedinook/utils/colors.dart';

class Chatting extends StatefulWidget {
  final String friendId;
  final String friendName;
  final String profilePicUrl;
  final String chatRoomId;
  final String status;

  Chatting({
    super.key,
    required this.friendId,
    required this.friendName,
    required this.profilePicUrl,
    required this.chatRoomId,
    required this.status,
  });

  @override
  State<Chatting> createState() => _ChattingState();
}

class _ChattingState extends State<Chatting> {
  late final ChatController chatController;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final RxBool _showOptions = false.obs;
  final ValueNotifier<bool> _isRecording = ValueNotifier(false);

  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  String _currentAudioUrl = '';
  Duration _audioDuration = const Duration();
  Duration _currentPosition = const Duration();

  @override
  void initState() {
    super.initState();
    // Initialize the ChatController with the chatRoomId
    chatController = Get.put(ChatController(widget.chatRoomId));
    _audioPlayer = AudioPlayer();
    // Listen for changes in player state (including when the audio finishes)
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) async {
      if (state == PlayerState.completed) {
        await _audioPlayer.stop(); // Stop the player to fully reset
        setState(() {
          isPlaying = false; // Automatically stop the audio when it finishes
          _currentPosition = Duration.zero; // Reset the position
        });
      }
    });
    // Listen for changes in the audio position (e.g., progress bar)
    _audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        _currentPosition = position;
      });
    });

    // Listen for the audio's duration
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        _audioDuration = duration;
      });
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    // Dispose the controllers when the widget is disposed
    _messageController.dispose();
    _scrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ChatController chatController =
        Get.put(ChatController(widget.chatRoomId));
    return Scaffold(
      backgroundColor: AppColor.bgcolor,
      appBar: AppBar(
        backgroundColor: AppColor.bgcolor,
        iconTheme: const IconThemeData(
          color: AppColor.textwhitecolor,
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: (['profilePicUrl'].isEmpty)
                  ? AppColor
                      .iconstext // Replace with your desired background color
                  : Colors.transparent,
              backgroundImage: (widget.profilePicUrl != '')
                  ? NetworkImage(widget.profilePicUrl)
                  : null,
              child: (widget.profilePicUrl == '')
                  ? const Icon(Icons.account_circle,
                      size: 30, color: AppColor.bgcolor)
                  : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.friendName,
                  style: const TextStyle(
                    color: AppColor.textwhitecolor,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.status,
                  style: TextStyle(
                    color: widget.status == 'online'
                        ? Colors.green
                        : AppColor
                            .iconstext, // Green for online, grey for other statuses
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              AppAssets.callicon,
              color: AppColor.iconstext,
            ),
            onPressed: () {
              // Handle video call button pressed
            },
          ),
          IconButton(
            icon: SvgPicture.asset(
              AppAssets.videoicon,
              color: AppColor.iconstext,
            ),
            onPressed: () {
              // Handle voice call button pressed
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (chatController.messagesStream.value == null ||
                  chatController.postsStream.value == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return StreamBuilder(
                stream: chatController.messagesStream.value,
                builder: (context, messageSnapshot) {
                  if (!messageSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return StreamBuilder(
                    stream: chatController.postsStream.value,
                    builder: (context, postSnapshot) {
                      if (!postSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var messages = messageSnapshot.data!.docs;
                      var posts = postSnapshot.data!.docs;

                      // Combine both messages and posts, sorting them by timestamp
                      List<dynamic> combinedData = [];
                      combinedData.addAll(messages);
                      combinedData.addAll(posts);

                      combinedData.sort(
                          (a, b) => b['timesstamp'].compareTo(a['timesstamp']));

                      // Scroll to the bottom after rendering
                      // WidgetsBinding.instance.addPostFrameCallback((_) {
                      //   if (_scrollController.hasClients) {
                      //     _scrollController.jumpTo(0.0); // Scroll to the bottom
                      //   }
                      // });

                      return ListView.builder(
                        controller: (isPlaying &&
                                _currentAudioUrl == combinedData[3]['text'])
                            ? null // Disable scroll when audio is playing and the URL matches the current message
                            : _scrollController,

                        // controller: _scrollController,
                        reverse: true, // Reverse the ListView
                        itemCount: combinedData.length,
                        itemBuilder: (context, index) {
                          var data = combinedData[index];

                          // Add a SizedBox for spacing between items
                          Widget itemWidget;

                          if (data['type'] == 'posts') {
                            // Handle post rendering
                            var isCurrentUserPost = data['receiverId'] ==
                                FirebaseAuth.instance.currentUser!.uid;

                            itemWidget = Align(
                              alignment: isCurrentUserPost
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width *
                                      0.9, // Set max width to 90% of screen width
                                ),
                                child: Card(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 8),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  color: isCurrentUserPost
                                      ? AppColor.unselected
                                      : AppColor.clickedbutton,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Row with profile picture and username
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 20.0,
                                              backgroundColor: (data[
                                                          'profilePicUrl']
                                                      .isEmpty)
                                                  ? AppColor
                                                      .iconstext // Replace with your desired background color
                                                  : Colors.transparent,
                                              backgroundImage: data[
                                                              'profilePicUrl'] !=
                                                          null &&
                                                      data['profilePicUrl']
                                                          .isNotEmpty
                                                  ? NetworkImage(
                                                      data['profilePicUrl'])
                                                  : null, // No image if null or empty
                                              child: (data['profilePicUrl'] ==
                                                          null ||
                                                      data['profilePicUrl']
                                                          .isEmpty)
                                                  ? const Icon(
                                                      Icons.account_circle,
                                                      size: 30,
                                                      color: AppColor.bgcolor)
                                                  : null, // Icon if no profile picture
                                            ),
                                            const SizedBox(
                                                width:
                                                    10), // Space between picture and name
                                            Text(
                                              data['username'],
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: isCurrentUserPost
                                                    ? AppColor.white
                                                    : AppColor.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                            height:
                                                15), // Space between username and text
                                        // Post/message text
                                        Text(
                                          data['text'],
                                          style: TextStyle(
                                            color: isCurrentUserPost
                                                ? AppColor.white
                                                : AppColor.white,
                                          ),
                                        ),
                                        const SizedBox(
                                            height:
                                                15), // Space between text and icons
                                        // Row with like, share, and comment icons
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Like icon with text
                                            Row(
                                              children: [
                                                // Icon(
                                                //     Icons.thumb_up_alt_outlined,
                                                //     color: isCurrentUserPost
                                                //         ? Colors.white
                                                //         : Colors.black),
                                                const SizedBox(width: 5),
                                                Text(
                                                  '${data['likes'] ?? 0}', // Show number of likes
                                                  style: TextStyle(
                                                    color: isCurrentUserPost
                                                        ? AppColor.white
                                                        : AppColor.white,
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  'Like',
                                                  style: TextStyle(
                                                    color: isCurrentUserPost
                                                        ? AppColor.white
                                                        : AppColor.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // Comment icon with text
                                            Row(
                                              children: [
                                                // Icon(Icons.comment,
                                                //     color: isCurrentUserPost
                                                //         ? Colors.white
                                                //         : Colors.black),
                                                const SizedBox(width: 5),
                                                Text(
                                                  '${data['comments'] ?? 0}', // Show number of comments
                                                  style: TextStyle(
                                                    color: isCurrentUserPost
                                                        ? AppColor.white
                                                        : AppColor.white,
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  'Comment',
                                                  style: TextStyle(
                                                    color: isCurrentUserPost
                                                        ? AppColor.white
                                                        : AppColor.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // Share icon with text
                                            Row(
                                              children: [
                                                // Icon(Icons.share,
                                                //     color: isCurrentUserPost
                                                //         ? Colors.white
                                                //         : Colors.black),
                                                const SizedBox(width: 5),
                                                Text(
                                                  '${data['shares'] ?? 0}', // Show number of shares
                                                  style: TextStyle(
                                                    color: isCurrentUserPost
                                                        ? AppColor.white
                                                        : AppColor.white,
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  'Share',
                                                  style: TextStyle(
                                                    color: isCurrentUserPost
                                                        ? AppColor.white
                                                        : AppColor.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            // Toggle between play and pause
                            void togglePlayPause(String messageText) async {
                              if (_currentAudioUrl == messageText) {
                                if (isPlaying) {
                                  await _audioPlayer.pause();
                                } else {
                                  // Replay from the start if the audio was stopped
                                  await _audioPlayer
                                      .play(UrlSource(messageText));
                                }
                              } else {
                                // If it's a new audio, stop the previous and play the new one
                                await _audioPlayer.stop();
                                await _audioPlayer.play(UrlSource(
                                    messageText)); // Provide the audio URL
                                setState(() {
                                  _currentAudioUrl =
                                      messageText; // Update current audio URL
                                });
                              }

                              setState(() {
                                isPlaying = !isPlaying;
                                _currentAudioUrl = messageText;
                              });
                            }

                            void seekAudio(Duration position) {
                              _audioPlayer.seek(
                                  position); // Seek to the specified position
                            }

                            var isCurrentUserMessage = data['senderId'] ==
                                FirebaseAuth.instance.currentUser!.uid;
                            bool isImageMessage =
                                data['text'].startsWith('image:');
                            bool isAudioMessage =
                                data['text'].startsWith('audio:');

                            String messageText;
                            if (isImageMessage) {
                              messageText = data['text']
                                  .substring(6); // Remove 'image:' prefix
                            } else if (isAudioMessage) {
                              messageText = data['text']
                                  .substring(6); // Remove 'audio:' prefix
                            } else {
                              messageText =
                                  data['text']; // Regular text message
                            }

                            return Align(
                              alignment: isCurrentUserMessage
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 8),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                decoration: BoxDecoration(
                                  color: isCurrentUserMessage
                                      ? AppColor.clickedbutton
                                      : AppColor.unselected,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.8,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Check if it's an image message
                                    if (isImageMessage) ...[
                                      Image.network(
                                        messageText, // Use the actual image URL
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 200,
                                      ),
                                      const SizedBox(height: 8),
                                    ] else if (isAudioMessage) ...[
                                      GestureDetector(
                                        onTap: () {
                                          togglePlayPause(
                                              messageText); // Play or pause the current audio
                                        },
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Play/Pause Button
                                            Icon(
                                              isPlaying &&
                                                      _currentAudioUrl ==
                                                          messageText
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                              color: isCurrentUserMessage
                                                  ? AppColor.white
                                                  : AppColor.white,
                                            ),
                                            const SizedBox(width: 10),

                                            // Progress Bar and Conditional Text in a single Row
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // Draggable Progress Bar
                                                  Slider(
                                                    value: _currentAudioUrl ==
                                                            messageText
                                                        ? _currentPosition
                                                            .inMilliseconds
                                                            .toDouble()
                                                        : 0.0,
                                                    min: 0.0,
                                                    max: _audioDuration
                                                        .inMilliseconds
                                                        .toDouble(),
                                                    activeColor: Colors.green,
                                                    inactiveColor:
                                                        Colors.grey.shade300,
                                                    onChanged: (value) {
                                                      // Update the UI when dragging for the currently playing audio
                                                      if (_currentAudioUrl ==
                                                          messageText) {
                                                        setState(() {
                                                          _currentPosition =
                                                              Duration(
                                                                  milliseconds:
                                                                      value
                                                                          .toInt());
                                                        });
                                                      }
                                                    },
                                                    onChangeEnd: (value) {
                                                      // Seek to the new position only for the current audio
                                                      if (_currentAudioUrl ==
                                                          messageText) {
                                                        seekAudio(Duration(
                                                            milliseconds:
                                                                value.toInt()));
                                                      }
                                                    },
                                                  ),

                                                  const SizedBox(height: 5),

                                                  // Conditional Text
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      if (_currentAudioUrl ==
                                                          messageText) ...[
                                                        Text(
                                                          '${_currentPosition.inMinutes}:${(_currentPosition.inSeconds % 60).toString().padLeft(2, '0')} / ${_audioDuration.inMinutes}:${(_audioDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                                                          style: TextStyle(
                                                            color:
                                                                isCurrentUserMessage
                                                                    ? AppColor
                                                                        .white
                                                                    : AppColor
                                                                        .white,
                                                          ),
                                                        ),
                                                      ] else ...[
                                                        const Text(
                                                          'Audio Message',
                                                          style: TextStyle(
                                                              color: AppColor
                                                                  .white),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(
                                          height:
                                              8), // Space below the audio controls
                                    ] else ...[
                                      // Message text for normal text messages
                                      Text(
                                        messageText,
                                        style: TextStyle(
                                          color: isCurrentUserMessage
                                              ? AppColor.white
                                              : AppColor.white,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: [
                              itemWidget,
                              const SizedBox(
                                  height: 0), // Space between posts/messages
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 10),

          // Options Section (Visible when "plus" button is clicked)
          Obx(() {
            return _showOptions.value
                ? Container(
                    color: AppColor.dropdown,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            size: 30,
                            color: AppColor.iconstext,
                          ),
                          onPressed: () {
                            // Handle camera button pressed
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.insert_drive_file,
                            size: 30,
                            color: AppColor.iconstext,
                          ),
                          onPressed: () {
                            // Handle document button pressed
                          },
                        ),
                        IconButton(
                            icon: const Icon(
                              Icons.photo,
                              size: 30,
                              color: AppColor.iconstext,
                            ),
                            onPressed: () {
                              chatController.pickImage();
                            })
                      ],
                    ),
                  )
                : const SizedBox
                    .shrink(); // Empty space if options are not visible
          }),
          // Message Input Section
          Container(
            margin: const EdgeInsets.only(
                left: 4,
                right: 4,
                bottom: 5), // Add horizontal margin and bottom margin
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8), // Padding inside the container
            decoration: const BoxDecoration(
              color: AppColor.bgcolor,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20), // Rounded top corners
                bottom: Radius.circular(20), // Rounded bottom corners
              ),
            ),

            child: ValueListenableBuilder<bool>(
              valueListenable: _isRecording,
              builder: (context, isRecording, child) {
                return Row(
                  children: [
                    if (!isRecording) ...[
                      // Show the default row with add, text field, and mic
                      IconButton(
                        icon: SvgPicture.asset(
                          AppAssets.plusSquare,
                          color: AppColor.iconstext,
                        ),
                        onPressed: () {
                          _showOptions.value = !_showOptions.value;
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: AppColor.bgcolor),
                          maxLines: null,
                          minLines: 1,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle:
                                const TextStyle(color: AppColor.hinttextcolor),
                            filled: true,
                            fillColor: AppColor.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            suffixIcon: IconButton(
                              icon: SvgPicture.asset(AppAssets.sendicon,
                                  color: AppColor.bgcolor),
                              onPressed: () {
                                if (_messageController.text.isNotEmpty) {
                                  chatController
                                      .sendMessage(_messageController.text);
                                  _messageController.clear();

                                  // Scroll to bottom after sending
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    if (_scrollController.hasClients) {
                                      _scrollController.jumpTo(0.0);
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.mic, color: AppColor.iconstext),
                        onPressed: () async {
                          if (!chatController.isRecording) {
                            await chatController.startRecording();
                            _isRecording.value = true;
                          }
                        },
                      ),
                    ] else ...[
                      // Show recording row with delete, waveform, and send
                      // IconButton(
                      //   icon:
                      //       const Icon(Icons.delete, color: AppColor.iconstext),
                      //   onPressed: () {
                      //     chatController.stopRecording();
                      //     _isRecording.value = false;
                      //   },
                      // ),
                      const Expanded(
                        child: Center(
                          // This is a placeholder for the waveform animation.
                          // You can replace it with an actual waveform widget.
                          child: Text(
                            "Recording...",
                            style: TextStyle(color: AppColor.white),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: SvgPicture.asset(AppAssets.sendicon,
                            color: AppColor.iconstext),
                        onPressed: () async {
                          await chatController.stopRecording();
                          _isRecording.value = false;
                          // You could add code here to send the recorded message
                        },
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
