import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<XFile?> pickImage() async {
    return await _picker.pickImage(
      source: ImageSource.gallery,
    );
  }
}