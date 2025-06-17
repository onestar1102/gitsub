import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PhotoSlideHome extends StatefulWidget {
  const PhotoSlideHome({super.key});

  @override
  State<PhotoSlideHome> createState() => _PhotoSlideHomeState();
}

class _PhotoSlideHomeState extends State<PhotoSlideHome> {
  List<String> _photoUrls = [];
  int _currentIndex = 0;
  Timer? _slideTimer;

  @override
  void initState() {
    super.initState();
    _fetchPhotos();
  }

  void _fetchPhotos() {
    FirebaseFirestore.instance.collection('main_photos').snapshots().listen((snapshot) {
      final urls = snapshot.docs.map((doc) => doc['url'] as String).toList();
      setState(() {
        _photoUrls = urls;
      });
      _startSlideShow();
    });
  }

  void _startSlideShow() {
    _slideTimer?.cancel();
    _slideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _photoUrls.length;
      });
    });
  }

  @override
  void dispose() {
    _slideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_photoUrls.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('슬라이드에 표시할 사진이 없습니다.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('메인 슬라이드')),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 400,
              height: 300,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _photoUrls[_currentIndex],
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                onPressed: () {
                  setState(() {
                    _currentIndex = (_currentIndex - 1 + _photoUrls.length) % _photoUrls.length;
                  });
                },
              ),
            ),
            Positioned(
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 32),
                onPressed: () {
                  setState(() {
                    _currentIndex = (_currentIndex + 1) % _photoUrls.length;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
