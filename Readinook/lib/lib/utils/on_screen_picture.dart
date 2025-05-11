import 'package:flutter/material.dart';

class OnScreenPicture extends StatelessWidget {
  final String profilePicUrl;

  const OnScreenPicture({Key? key, required this.profilePicUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Picture'),
      ),
      body: Center(
        child: profilePicUrl.isNotEmpty
            ? Image.network(profilePicUrl) // Display the image if URL is available
            : const Icon(Icons.person, size: 100), // Default icon if no image
      ),
    );
  }
}
