import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final image = img.Image(width: 256, height: 256);
  img.fill(image, color: img.ColorRgba8(0, 0, 0, 0));
  File('assets/transparent.png').writeAsBytesSync(img.encodePng(image));
  print('Generated 256x256 transparent PNG!');
}
