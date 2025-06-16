import 'dart:html' as html;
import 'package:flutter/material.dart';

class AudioHtmlPlayerWidget extends StatefulWidget {
  const AudioHtmlPlayerWidget({super.key});

  @override
  State<AudioHtmlPlayerWidget> createState() => _AudioHtmlPlayerWidgetState();
}

class _AudioHtmlPlayerWidgetState extends State<AudioHtmlPlayerWidget> {
  final List<Map<String, String>> _playlist = [
    {
      'title': 'bgm1',
      'file': 'audio/bgm.mp3',
    },
    {
      'title': 'Memory Lane',
      'file': 'assets/audio/memory_lane.mp3',
    },
  ];
  int _currentIndex = 0;
  late html.AudioElement _audio;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audio = html.AudioElement()
      ..src = _playlist[_currentIndex]['file']!
      ..controls = false;
    html.document.body!.append(_audio);
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _audio.pause();
    } else {
      _audio.play();
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  void _playNext() {
    _currentIndex = (_currentIndex + 1) % _playlist.length;
    _audio.src = 'https://wepapphomepage.web.app/audio/bgm.mp3';
    _audio.play();
    setState(() => _isPlaying = true);
  }

  void _playPrevious() {
    _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
    _audio.src = _playlist[_currentIndex]['file']!;
    _audio.play();
    setState(() => _isPlaying = true);
  }

  @override
  void dispose() {
    _audio.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _playlist[_currentIndex]['title']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.skip_previous), onPressed: _playPrevious),
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: _togglePlayPause,
                ),
                IconButton(icon: const Icon(Icons.skip_next), onPressed: _playNext),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
