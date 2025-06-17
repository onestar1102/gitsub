import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: MainImageManagerScreen()));
}

class MainImageManagerScreen extends StatefulWidget {
  const MainImageManagerScreen({super.key});

  @override
  State<MainImageManagerScreen> createState() => _MainImageManagerScreenState();
}

class _MainImageManagerScreenState extends State<MainImageManagerScreen> {
  Uint8List? _previewImage;
  bool _isUploading = false;
  List<String> _imageUrls = [];
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchImages();
    _startSlideshow();
  }

  void _startSlideshow() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_imageUrls.isNotEmpty) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _imageUrls.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchImages() async {
    final listResult = await FirebaseStorage.instance.ref('main_images').listAll();
    final urls = await Future.wait(listResult.items.map((item) => item.getDownloadURL()));
    setState(() => _imageUrls = urls);
  }

  Future<void> _pickAndPreviewImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result != null && result.files.single.bytes != null) {
      setState(() => _previewImage = result.files.single.bytes);
    }
  }

  Future<void> _uploadImage() async {
    if (_previewImage == null) return;
    setState(() => _isUploading = true);

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = FirebaseStorage.instance.ref('main_images/$timestamp.jpg');
      await ref.putData(_previewImage!);
      await _fetchImages();
      setState(() => _previewImage = null);
    } catch (e) {
      debugPrint('업로드 실패: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteCurrentImage() async {
    if (_imageUrls.isEmpty) return;
    try {
      final ref = await FirebaseStorage.instance.refFromURL(_imageUrls[_currentIndex]);
      await ref.delete();
      await _fetchImages();
      setState(() => _currentIndex = 0);
    } catch (e) {
      debugPrint('삭제 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        title: const Text('메인 이미지 관리'),
        centerTitle: true,
        backgroundColor: Colors.pink[100],
      ),
      body: Center(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_previewImage != null)
                Image.memory(_previewImage!, height: 200, fit: BoxFit.cover)
              else if (_imageUrls.isNotEmpty)
                Image.network(_imageUrls[_currentIndex], height: 200, fit: BoxFit.cover)
              else
                const Text('업로드된 이미지가 없습니다.'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickAndPreviewImage,
                    icon: const Icon(Icons.photo),
                    label: const Text('사진 선택'),
                  ),
                  const SizedBox(width: 10),
                  if (_previewImage != null)
                    ElevatedButton.icon(
                      onPressed: _isUploading ? null : _uploadImage,
                      icon: _isUploading
                          ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.cloud_upload),
                      label: const Text('업로드'),
                    ),
                  const SizedBox(width: 10),
                  if (_imageUrls.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: _deleteCurrentImage,
                      icon: const Icon(Icons.delete),
                      label: const Text('삭제'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (_imageUrls.length > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        setState(() {
                          _currentIndex = (_currentIndex - 1 + _imageUrls.length) % _imageUrls.length;
                        });
                      },
                    ),
                    Text("${_currentIndex + 1} / ${_imageUrls.length}"),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        setState(() {
                          _currentIndex = (_currentIndex + 1) % _imageUrls.length;
                        });
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
