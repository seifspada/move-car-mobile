import 'package:image_picker/image_picker.dart';

Future<XFile?> captureInspectionPhoto() {
  final picker = ImagePicker();
  return picker.pickImage(
    source: ImageSource.camera,
    imageQuality: 90,
    preferredCameraDevice: CameraDevice.rear,
  );
}
