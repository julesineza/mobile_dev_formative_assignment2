import 'package:flutter/foundation.dart';

import '../services/upload_image.dart';

class ImageUploadProvider extends ChangeNotifier {
  ImageUploadProvider({UploadImageService? service})
    : _service = service ?? UploadImageService();

  final UploadImageService _service;

  String? _imageUrl;
  bool _isUploading = false;
  String? _errorMessage;

  String? get imageUrl => _imageUrl;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;

  Future<bool> pickAndUploadImage() async {
    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _imageUrl = await _service.pickAndUploadImage();
      return true;
    } on ImageUploadException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to upload the image right now. Please try again.';
      return false;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  void clearImage() {
    _imageUrl = null;
    _errorMessage = null;
    notifyListeners();
  }
}