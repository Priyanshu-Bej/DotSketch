import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'ui/image_preview.dart';
import 'ui/modern_app_bar.dart';
import 'ui/modern_card.dart';
import 'ui/modern_dropdown.dart';
import 'ui/modern_slider.dart';
import 'ui/theme.dart';

enum DotStyle { dots, ascii, outline }

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
  // Denser ASCII ramp for more detail
  const asciiRamp = '@#W\$9876543210?!abc;:+=-,._ ';
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
  runApp(const DotSketchApp());
}

class DotSketchApp extends StatelessWidget {
  const DotSketchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DotSketch',
      theme: DotSketchTheme.lightTheme,
      home: const DotSketchHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DotSketchHome extends StatefulWidget {
  const DotSketchHome({super.key});

  @override
  State<DotSketchHome> createState() => _DotSketchHomeState();
}

class _DotSketchHomeState extends State<DotSketchHome> {
  void _copyText() {
    if (_dottedText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _dottedText));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Copied to clipboard!')));
    }
  }

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
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _dottedText = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ModernAppBar(title: 'DotSketch'),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ModernCard(
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image_outlined),
                        label: const Text('Choose Image'),
                      ),
                      if (_image != null) ...[
                        const SizedBox(height: 16),
                        ImagePreview(image: _image!),
                      ],
                    ],
                  ),
                ),
                if (_image != null) ...[
                  ModernCard(
                    child: Column(
                      children: [
                        ModernDropdown<DotStyle>(
                          value: _selectedStyle,
                          label: 'Style',
                          items: const [
                            DropdownMenuItem(
                              value: DotStyle.dots,
                              child: Text('Dots Only'),
                            ),
                            DropdownMenuItem(
                              value: DotStyle.ascii,
                              child: Text('ASCII Art'),
                            ),
                            DropdownMenuItem(
                              value: DotStyle.outline,
                              child: Text('Outline Only'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedStyle = v);
                          },
                        ),
                        const SizedBox(height: 12),
                        ModernSlider(
                          value: _outputWidth,
                          min: 20,
                          max: 100,
                          divisions: 8,
                          label: 'Width',
                          onChanged: (v) => setState(() => _outputWidth = v),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _convertToDottedText,
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('Convert to Dotted Text'),
                        ),
                      ],
                    ),
                  ),
                ],
                ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Output',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: SelectableText(
                          _dottedText.isEmpty
                              ? 'Dotted text will appear here.'
                              : _dottedText,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _dottedText.isNotEmpty ? _copyText : null,
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy Dotted Text'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
