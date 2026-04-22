import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  try {
    // 1. Create transparent PNG
    final dir = Directory('assets');
    if (!dir.existsSync()) {
      dir.createSync();
    }
    
    final transparentBytes = [
      137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 
      0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0, 0, 11, 73, 68, 65, 84, 
      8, 215, 99, 96, 0, 2, 0, 0, 5, 0, 1, 226, 38, 5, 155, 0, 0, 0, 0, 73, 69, 
      78, 68, 174, 66, 96, 130
    ];
    File('assets/transparent.png').writeAsBytesSync(transparentBytes);
    print('Created assets/transparent.png');

    // 2. Resize existing app icon
    final iconPath = 'store_assets/app_icon.png';
    final iconFile = File(iconPath);
    if (iconFile.existsSync()) {
      final imageBytes = iconFile.readAsBytesSync();
      final image = img.decodeImage(imageBytes);
      if (image != null) {
        final resized = img.copyResize(image, width: 640, height: 640);
        iconFile.writeAsBytesSync(img.encodePng(resized));
        print('Successfully resized store_assets/app_icon.png to 640x640!');
      } else {
        print('Could not decode app_icon.png.');
      }
    } else {
      print('store_assets/app_icon.png does not exist.');
    }
  } catch (e) {
    print('Error: $e');
  }
}
