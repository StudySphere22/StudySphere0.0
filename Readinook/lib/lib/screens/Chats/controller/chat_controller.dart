import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reedinook/utils/custom_snackbar.dart';

class ChatController extends GetxController {
  final String chatRoomId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage =
      FirebaseStorage.instance; // Initialize Firebase Storage
  final ImagePicker _picker = ImagePicker(); // Create an ImagePicker instance

  var isLoading = false.obs;
  var messagesStream =
      Rxn<Stream<QuerySnapshot>>(); // Reactive stream for messages
  var postsStream = Rxn<Stream<QuerySnapshot>>(); // Reactive stream for posts



  ChatController(this.chatRoomId);

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecorderInitialized = false;
  bool get isRecording => _recorder.isRecording;

  @override
  void onInit() {
    super.onInit();
    getMessages(); // Initialize the message stream
    getPosts(); // Initialize the post stream
    initializeRecorder();
  }

  // Method to send a message
  Future<void> sendMessage(String message, {String? imageUrl, String? audioUrl}) async {
  final currentUser = _auth.currentUser;
  print("current user $currentUser");
  if (currentUser == null) return;

  final timestamp = DateTime.now();

  try {
    isLoading.value = true;

    // Prepare the message content
    String content;

    if (imageUrl != null) {
      content = 'image:$imageUrl'; // Prefix with 'image:' to indicate it's an image
    } else if (audioUrl != null) {
      content = 'audio:$audioUrl'; // Prefix with 'audio:' to indicate it's audio
    } else {
      content = message; // Regular text message
    }

    // Add the message to Firestore
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'text': content,
      'senderId': currentUser.uid,
      'timesstamp': timestamp,
      'isRead': false, // Mark the message as unread when sent
      'type' : 'messages',
    });
  } catch (e) {
    customSnackbar(title: "Error",message:  "Failed to send message");
  } finally {
    isLoading.value = false;
  }
}

  // Method to fetch messages stream
  void getMessages() {
    messagesStream.value = _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timesstamp', descending: true)
        .snapshots();
  
}
  

  // Method to pick an image
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File selectedImage = File(image.path);
      String? imageUrl = await uploadImage(selectedImage);
      sendMessage('', imageUrl: imageUrl); // Send message with image URL
    }
  }

  // Method to upload image to Firebase Storage
  Future<String?> uploadImage(File image) async {
    try {
      // Create a reference to the location you want to upload to
      String filePath =
          'chat_images/${DateTime.now().millisecondsSinceEpoch}.png';
      var storageRef = _storage.ref(filePath);

      // Upload the image
      await storageRef.putFile(image);

      // Get the download URL
      String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      customSnackbar(title: "Error", message: "Failed to upload image");
      return null;
    }
  }



  // Method to fetch posts stream
  void getPosts() {
    postsStream.value = _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('posts')
        .orderBy('timesstamp',
            descending: true) // Adjust based on your data structure
        .snapshots();
  }
   Future<void> initializeRecorder() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      await _recorder.openRecorder();
      _isRecorderInitialized = true;
    } else {
      customSnackbar(title: "Permission",message:  "Microphone permission denied.");
    }
  }

  Future<void> startRecording() async {
    if (_isRecorderInitialized) {
      final path = 'audio_${DateTime.now().millisecondsSinceEpoch}.aac';
      await _recorder.startRecorder(toFile: path);
    }
  }

  Future<void> stopRecording() async {
    if (_isRecorderInitialized) {
      final path = await _recorder.stopRecorder();
      if (path != null) {
        File audioFile = File(path);
        String? audioUrl = await uploadAudio(audioFile);
        if (audioUrl != null) {
          sendMessage('', audioUrl: audioUrl); // Send audio message
        }
      }
    }
  }

  Future<String?> uploadAudio(File audioFile) async {
    try {
      String filePath = 'audio_messages/${DateTime.now().millisecondsSinceEpoch}.aac';
      var storageRef = _storage.ref(filePath);

      await storageRef.putFile(audioFile);
      return await storageRef.getDownloadURL();
    } catch (e) {
      customSnackbar(title: "Error",message:  "Failed to upload audio");
      return null;
    }
  }


  // @override
  // void onClose() {
  //   messagesStream.value
  //       ?.listen((_) {})
  //       .cancel(); // Cancel the message stream subscription if needed
  //   postsStream.value
  //       ?.listen((_) {})
  //       .cancel(); // Cancel the post stream subscription if needed
  //   _recorder.closeRecorder();
  //   super.onClose();
  // }
}
