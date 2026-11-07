import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../core/constants.dart';

abstract class ImageUploadService {
  Future<String> uploadImage(XFile image);
}

class CloudinaryImageService implements ImageUploadService {
  CloudinaryImageService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<String> uploadImage(XFile image) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload',
    );
    // An unsigned upload preset needs no API key or secret, so nothing
    // secret is stored in the app.
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = cloudinaryUploadPreset
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          await image.readAsBytes(),
          filename: image.name,
        ),
      );

    final response = await http.Response.fromStream(
      await _client.send(request),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Cloudinary upload failed (${response.statusCode}): ${response.body}',
      );
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['secure_url'] as String;
  }
}
