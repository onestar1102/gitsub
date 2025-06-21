// =============================================================================
// lib/providers/carousel_provider.dart
// =============================================================================
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';

class CarouselProvider extends ChangeNotifier {
  final _col = FirebaseFirestore.instance.collection('carousel_images');
  List<Map<String, String>> images = []; // {id, url}

  CarouselProvider() {
    _load();
  }

  Future<void> _load() async {
    final snaps = await _col.get();
    images = snaps.docs
        .map((d) => {'id': d.id, 'url': d['url'] as String})
        .toList();
    notifyListeners();
  }

  Future<void> addImage() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image);
    if (res == null || res.files.single.bytes == null) return;

    final data = res.files.single.bytes!;
    final ext  = res.files.single.extension ?? 'png';
    final name = DateTime.now().millisecondsSinceEpoch.toString();
    final ref  = FirebaseStorage.instance.ref('carousel/$name.$ext');

    final task = await ref.putData(data,
        SettableMetadata(contentType: 'image/$ext'));
    final url  = await task.ref.getDownloadURL();

    final doc = await _col.add({'url': url});
    images.add({'id': doc.id, 'url': url});
    notifyListeners();
  }

  Future<void> deleteImage(String id, String url) async {
    if (url.startsWith('http')) {
      await FirebaseStorage.instance.refFromURL(url).delete();
    }
    await _col.doc(id).delete();
    images.removeWhere((e) => e['id'] == id);
    notifyListeners();
  }

}