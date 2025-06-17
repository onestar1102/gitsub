import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PhotoManageScreen extends StatefulWidget {
  const PhotoManageScreen({super.key});

  @override
  State<PhotoManageScreen> createState() => _PhotoManageScreenState();
}

class _PhotoManageScreenState extends State<PhotoManageScreen> {
  Uint8List? _selectedImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _selectedImage = result.files.single.bytes;
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;
    setState(() => _isUploading = true);

    try {
      final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child('main_photos/$fileName');
      await ref.putData(_selectedImage!);
      final url = await ref.getDownloadURL();
      await FirebaseFirestore.instance.collection('main_photos').add({
        'url': url,
        'uploadedAt': DateTime.now(),
      });
      setState(() {
        _selectedImage = null;
      });
    } catch (e) {
      debugPrint('Upload error: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteImage(String docId, String url) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(url);
      await ref.delete();
      await FirebaseFirestore.instance.collection('main_photos').doc(docId).delete();
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('사진 관리')),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _selectedImage != null
                  ? Image.memory(_selectedImage!, fit: BoxFit.cover)
                  : const Center(child: Text('사진을 선택해주세요')),
            ),
            const SizedBox(height: 8),
            if (_isUploading) const CircularProgressIndicator(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('사진 선택'),
                  onPressed: _pickImage,
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('업로드'),
                  onPressed: _uploadImage,
                ),
              ],
            ),
            const Divider(height: 32),
            const Text('업로드된 사진 목록'),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('main_photos')
                    .orderBy('uploadedAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final url = doc['url'];
                      return ListTile(
                        leading: Image.network(url, width: 50, height: 50, fit: BoxFit.cover),
                        title: Text(url),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteImage(doc.id, url),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
