import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:submission/ui/camera_page.dart';
import 'package:submission/ui/result_page.dart';

class HomeController extends ChangeNotifier {
  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  final _picker = ImagePicker();

  Future<void> pickFromGallery(BuildContext context) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _selectedImage = File(picked.path);
      notifyListeners();
    }
  }

  Future<void> pickFromCamera(BuildContext context) async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      _selectedImage = File(picked.path);
      notifyListeners();
    }
  }

  Future<void> cropAndAnalyze(BuildContext context) async {
    if (_selectedImage == null) return;
    final cropped = await ImageCropper().cropImage(
      sourcePath: _selectedImage!.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: const Color(0xFF6750A4),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
        ),
      ],
    );
    if (cropped != null) {
      _selectedImage = File(cropped.path);
      notifyListeners();
      if (context.mounted) goToResult(context);
    }
  }

  void goToResult(BuildContext context) {
    if (_selectedImage == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultPage(imageFile: _selectedImage!),
      ),
    );
  }

  void goToCamera(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CameraPage()),
    );
  }

  void clearImage() {
    _selectedImage = null;
    notifyListeners();
  }
}
