import 'dart:convert';
import 'dart:typed_data';

import 'package:campus_incident_app/repositories/image_upload_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  final photo = XFile.fromData(
    Uint8List.fromList([1, 2, 3]),
    name: 'photo.jpg',
  );

  test('returns the secure_url from Cloudinary', () async {
    late http.BaseRequest sentRequest;
    final client = MockClient.streaming((request, _) async {
      sentRequest = request;
      final body = jsonEncode({
        'secure_url': 'https://res.cloudinary.com/x/photo.jpg',
      });
      return http.StreamedResponse(Stream.value(utf8.encode(body)), 200);
    });

    final url = await CloudinaryImageService(client: client).uploadImage(photo);

    expect(url, 'https://res.cloudinary.com/x/photo.jpg');
    expect(sentRequest.url.path, endsWith('/image/upload'));
    expect(
      (sentRequest as http.MultipartRequest).fields['upload_preset'],
      isNotEmpty,
    );
  });

  test('throws when Cloudinary rejects the upload', () async {
    final client = MockClient.streaming((request, _) async {
      return http.StreamedResponse(Stream.value(utf8.encode('{}')), 400);
    });

    expect(
      CloudinaryImageService(client: client).uploadImage(photo),
      throwsException,
    );
  });
}
