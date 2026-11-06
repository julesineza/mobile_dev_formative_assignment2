import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class UploadImageService {
  UploadImageService({Client? client, Storage? storage})
    : _client = client,
      _storage = storage;

  final Client? _client;
  final Storage? _storage;

  Future<String> pickAndUploadImage() async {
    final XFile? image;
    try {
      image = await ImagePicker()
          .pickImage(source: ImageSource.gallery)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw const ImageUploadException(
              'The image picker did not respond. Please restart the app and try again.',
            ),
          );
    } on ImageUploadException {
      rethrow;
    } catch (error) {
      throw ImageUploadException('Unable to open the image picker: $error');
    }

    if (image == null) {
      throw const ImageUploadException('No image was selected.');
    }

    final compressedImage = await _compressImage(image);
    final configuration = await _loadConfiguration();
    final client =
        _client ??
        (Client()
          ..setEndpoint(configuration.endpoint)
          ..setProject(configuration.projectId));
    final storage = _storage ?? Storage(client);

    try {
      await _ensureAppwriteSession(client);
      final file = await storage
          .createFile(
            bucketId: configuration.bucketId,
            fileId: ID.unique(),
            permissions: [Permission.read(Role.any())],
            file: InputFile.fromBytes(
              bytes: compressedImage,
              filename: _compressedFilename(image.name),
            ),
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () => throw const ImageUploadException(
              'The image upload timed out. Check your connection and try again.',
            ),
          );

      return _fileViewUrl(configuration, file);
    } on AppwriteException catch (error) {
      if (error.code == 401 ||
          error.message?.toLowerCase().contains('permission') == true) {
        throw const ImageUploadException(
          'Appwrite denied this upload. In Appwrite Console, open the storage '
          'bucket and enable Create permission for Users (or Any), then try '
          'again.',
        );
      }
      throw ImageUploadException(
        error.message ?? 'Appwrite could not upload the image.',
      );
    } on ImageUploadException {
      rethrow;
    } catch (error) {
      throw ImageUploadException('Unable to upload the image: $error');
    }
  }

  Future<void> _ensureAppwriteSession(Client client) async {
    final account = Account(client);
    try {
      await account.get();
    } on AppwriteException catch (error) {
      if (error.code != 401) rethrow;
      await account.createAnonymousSession();
    }
  }

  Future<Uint8List> _compressImage(XFile image) async {
    try {
      final compressed = await FlutterImageCompress.compressWithList(
        await image.readAsBytes(),
        minWidth: 1600,
        minHeight: 1200,
        quality: 75,
        format: CompressFormat.jpeg,
        keepExif: false,
      );
      if (compressed.isEmpty) {
        throw const ImageUploadException(
          'Image compression returned an empty file.',
        );
      }
      return compressed;
    } on ImageUploadException {
      rethrow;
    } catch (error) {
      throw ImageUploadException('Unable to compress the image: $error');
    }
  }

  String _compressedFilename(String originalName) {
    final baseName = originalName.split('.').first;
    return '${baseName}_compressed.jpg';
  }

  Future<_AppwriteConfiguration> _loadConfiguration() async {
    final json = jsonDecode(await rootBundle.loadString('env.json'));
    if (json is! Map<String, dynamic>) {
      throw const ImageUploadException('Invalid Appwrite configuration.');
    }

    final endpoint = json['APPWRITE_ENDPOINT'] as String?;
    final projectId = json['APPWRITE_PROJECT_ID'] as String?;
    final bucketId = json['bucketID'] as String?;
    if (endpoint == null || projectId == null || bucketId == null) {
      throw const ImageUploadException(
        'Appwrite configuration is missing required values.',
      );
    }

    return _AppwriteConfiguration(
      endpoint: endpoint,
      projectId: projectId,
      bucketId: bucketId,
    );
  }

  String _fileViewUrl(_AppwriteConfiguration configuration, models.File file) {
    return '${configuration.endpoint}/storage/buckets/'
        '${configuration.bucketId}/files/${file.$id}/view'
        '?project=${configuration.projectId}';
  }
}

class ImageUploadException implements Exception {
  const ImageUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _AppwriteConfiguration {
  const _AppwriteConfiguration({
    required this.endpoint,
    required this.projectId,
    required this.bucketId,
  });

  final String endpoint;
  final String projectId;
  final String bucketId;
}
