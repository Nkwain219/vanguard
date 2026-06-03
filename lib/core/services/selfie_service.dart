import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class SelfieService {
  static SelfieService? _instance;
  static SelfieService get instance => _instance ??= SelfieService._();
  SelfieService._();

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<File?> captureSelfie() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 70,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        return File(image.path);
      }
    } catch (e) {}
    return null;
  }

  Future<String?> uploadSelfie({
    required File file,
    required String employeeId,
    required String eventType,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = 'attendance_selfies/$employeeId/${eventType}_$timestamp.jpg';

      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'employeeId': employeeId,
            'eventType': eventType,
            'timestamp': timestamp.toString(),
          },
        ),
      );

      if (uploadTask.state == TaskState.success) {
        return await ref.getDownloadURL();
      }
    } catch (e) {}
    return null;
  }

  Future<String?> captureAndUpload({
    required String employeeId,
    required String eventType,
  }) async {
    final file = await captureSelfie();
    if (file == null) return null;

    final url = await uploadSelfie(
      file: file,
      employeeId: employeeId,
      eventType: eventType,
    );

    try {
      await file.delete();
    } catch (_) {}

    return url;
  }
}
