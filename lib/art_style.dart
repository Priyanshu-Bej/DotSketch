import 'dart:io';
import 'dart:ui' as ui;

const asciiRamp = '@#W\$9876543210?!abc;:+=-,._ ';
const unicodeRamp = ['⣿', '⣷', '⣯', '⣟', '⡿', '⢿', '⠿', '⠻', '⠋', '⠁', ' '];

enum ArtStyle { dots, ascii, outline, unicode }

Future<String> imageToDottedText(
  File imageFile, {
  int width = 40,
  int height = 20,
  ArtStyle style = ArtStyle.ascii,
}) async {
  final bytes = await imageFile.readAsBytes();
  final codec = await ui.instantiateImageCodec(
    bytes,
    targetWidth: width,
    targetHeight: height,
  );
  final frame = await codec.getNextFrame();
  final img = frame.image;
  final byteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (byteData == null) return '';
  final buffer = byteData.buffer.asUint8List();
  StringBuffer sb = StringBuffer();
  // Prepare grayscale buffer for edge detection
  List<List<int>> grayImg = List.generate(
    img.height,
    (y) => List.filled(img.width, 0),
  );
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      int i = (y * img.width + x) * 4;
      int r = buffer[i];
      int g = buffer[i + 1];
      int b = buffer[i + 2];
      int a = buffer[i + 3];
      int gray = a < 128 ? 255 : ((r + g + b) ~/ 3);
      grayImg[y][x] = gray;
    }
  }
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      int gray = grayImg[y][x];
      if (style == ArtStyle.unicode) {
        int idx = ((gray / 255) * (unicodeRamp.length - 1)).round();
        sb.write(unicodeRamp[idx]);
      } else if (style == ArtStyle.dots) {
        sb.write(gray < 128 ? '•' : ' '); // Use medium bold dot
      } else if (style == ArtStyle.outline) {
        int gx = 0, gy = 0;
        if (x > 0 && x < img.width - 1 && y > 0 && y < img.height - 1) {
          gx =
              grayImg[y - 1][x + 1] +
              2 * grayImg[y][x + 1] +
              grayImg[y + 1][x + 1] -
              grayImg[y - 1][x - 1] -
              2 * grayImg[y][x - 1] -
              grayImg[y + 1][x - 1];
          gy =
              grayImg[y + 1][x - 1] +
              2 * grayImg[y + 1][x] +
              grayImg[y + 1][x + 1] -
              grayImg[y - 1][x - 1] -
              2 * grayImg[y - 1][x] -
              grayImg[y - 1][x + 1];
        }
        int edge = ((gx.abs() + gy.abs()) ~/ 2).clamp(0, 255);
        sb.write(edge > 80 ? '•' : ' ');
      } else {
        int idx = ((gray / 255) * (asciiRamp.length - 1)).round();
        sb.write(asciiRamp[idx]);
      }
    }
    sb.writeln();
  }
  return sb.toString();
}
