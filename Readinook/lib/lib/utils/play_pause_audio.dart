import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl; // URL of the audio message

  const AudioPlayerWidget({Key? key, required this.audioUrl}) : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer; // Audio player instance
  bool isPlaying = false; // Track whether the audio is playing

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    
    // Listen for audio completion to reset play button
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false; // Reset to play button when audio ends
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Dispose of the player when the widget is removed
    super.dispose();
  }

  // Method to handle play/pause toggle
  void playPauseAudio() async {
    if (isPlaying) {
      await _audioPlayer.pause(); // Pause the audio
      setState(() {
        isPlaying = false; // Button should show play icon
      });
    } else {
      try {
        await _audioPlayer.play(UrlSource(widget.audioUrl)); // Play the audio
        setState(() {
          isPlaying = true; // Button should show pause icon
        });
      } catch (e) {
        // Handle errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to play audio: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Audio Message",
          style: TextStyle(color: Colors.white),
        ),
        IconButton(
          icon: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow, // Toggle icon based on isPlaying
            color: Colors.white,
          ),
          onPressed: playPauseAudio, // Handle play/pause action
        ),
      ],
    );
  }
}
