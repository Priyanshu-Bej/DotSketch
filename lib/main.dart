import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

enum DotStyle { dots, ascii }

Future<String> imageToDottedText(
  File imageFile, {
  int width = 40,
  int height = 20,
  DotStyle style = DotStyle.ascii,
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
  // ASCII ramp from dark to light
  const asciiRamp = '@%#*+=-:. ';
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      int i = (y * img.width + x) * 4;
      int r = buffer[i];
      int g = buffer[i + 1];
      int b = buffer[i + 2];
      int a = buffer[i + 3];
      if (a < 128) {
        sb.write(' ');
        continue;
      }
      int gray = ((r + g + b) ~/ 3);
      if (style == DotStyle.dots) {
        sb.write(gray < 128 ? '.' : ' ');
      } else {
        int idx = ((gray / 255) * (asciiRamp.length - 1)).round();
        sb.write(asciiRamp[idx]);
      }
    }
    sb.writeln();
  }
  return sb.toString();
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DotSketch',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DotSketchHome(),
    );
  }
}

class DotSketchHome extends StatefulWidget {
  const DotSketchHome({super.key});

  @override
  State<DotSketchHome> createState() => _DotSketchHomeState();
}

class _DotSketchHomeState extends State<DotSketchHome> {
  DotStyle _selectedStyle = DotStyle.ascii;
  double _outputWidth = 40;

  Future<void> _convertToDottedText() async {
    if (_image == null) return;
    setState(() {
      _dottedText = 'Processing...';
    });
    // Height is proportional to width for aspect ratio
    int width = _outputWidth.round();
    int height = (width / 2).round();
    final result = await imageToDottedText(
      _image!,
      width: width,
      height: height,
      style: _selectedStyle,
    );
    setState(() {
      _dottedText = result;
    });
  }

  File? _image;
  String _dottedText = '';
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _dottedText = '';
      });
      // TODO: Process image to dotted text
    }
  }

  void _copyText() {
    if (_dottedText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _dottedText));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Copied to clipboard!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DotSketch')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Choose Image'),
            ),
            const SizedBox(height: 16),
            if (_image != null)
              Column(
                children: [
                  Image.file(_image!, height: 200),
                  const SizedBox(height: 16),
                ],
              ),
            if (_image != null) ...[
              Row(
                children: [
                  const Text('Style:'),
                  const SizedBox(width: 8),
                  DropdownButton<DotStyle>(
                    value: _selectedStyle,
                    items: const [
                      DropdownMenuItem(
                        value: DotStyle.dots,
                        child: Text('Dots Only'),
                      ),
                      DropdownMenuItem(
                        value: DotStyle.ascii,
                        child: Text('ASCII Art'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedStyle = v);
                    },
                  ),
                  const SizedBox(width: 16),
                  const Text('Width:'),
                  Expanded(
                    child: Slider(
                      min: 20,
                      max: 100,
                      divisions: 8,
                      value: _outputWidth,
                      label: _outputWidth.round().toString(),
                      onChanged: (v) => setState(() => _outputWidth = v),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton(
                  onPressed: _convertToDottedText,
                  child: const Text('Convert to Dotted Text'),
                ),
              ),
            ],
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  _dottedText.isEmpty
                      ? 'Dotted text will appear here.'
                      : _dottedText,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _dottedText.isNotEmpty ? _copyText : null,
              child: const Text('Copy Dotted Text'),
            ),
          ],
        ),
      ),
    );
  }
}
