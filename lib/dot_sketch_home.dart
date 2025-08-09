import 'dart:io';

import 'package:dot_sketch/art_style.dart';
import 'package:dot_sketch/ui/image_preview.dart';
import 'package:dot_sketch/ui/modern_app_bar.dart';
import 'package:dot_sketch/ui/modern_card.dart';
import 'package:dot_sketch/ui/modern_dropdown.dart';
import 'package:dot_sketch/ui/modern_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class DotSketchHome extends StatefulWidget {
  const DotSketchHome({super.key});

  @override
  State<DotSketchHome> createState() => _DotSketchHomeState();
}

class _DotSketchHomeState extends State<DotSketchHome> {
  File? _image;
  String _dottedText = '';

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _dottedText = '';
      });
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

  ArtStyle _selectedStyle = ArtStyle.dots;
  double _outputWidth = 20;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ModernAppBar(title: 'DotSketch'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  '1. Select an Image',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
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
                                const Divider(height: 32),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    '2. Customize Output',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                ModernCard(
                                  child: Column(
                                    children: [
                                      ModernDropdown<ArtStyle>(
                                        value: _selectedStyle,
                                        label: 'Style',
                                        items: const [
                                          DropdownMenuItem(
                                            value: ArtStyle.dots,
                                            child: Text('Dots Only'),
                                          ),
                                          DropdownMenuItem(
                                            value: ArtStyle.ascii,
                                            child: Text('ASCII Art'),
                                          ),
                                          DropdownMenuItem(
                                            value: ArtStyle.outline,
                                            child: Text('Outline Only'),
                                          ),
                                          DropdownMenuItem(
                                            value: ArtStyle.unicode,
                                            child: Text('Unicode Art'),
                                          ),
                                        ],
                                        onChanged: (v) {
                                          if (v != null) {
                                            setState(() => _selectedStyle = v);
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      ModernSlider(
                                        value: _outputWidth,
                                        min: 20,
                                        max: 100,
                                        divisions: 8,
                                        label: 'Width',
                                        onChanged: (v) =>
                                            setState(() => _outputWidth = v),
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton.icon(
                                        onPressed: _convertToDottedText,
                                        icon: const Icon(Icons.auto_awesome),
                                        label: const Text(
                                          'Convert to Dotted Text',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  '3. Result',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              ModernCard(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
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
                                      onPressed: _dottedText.isNotEmpty
                                          ? _copyText
                                          : null,
                                      icon: const Icon(Icons.copy),
                                      label: const Text('Copy Dotted Text'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            '1. Select an Image',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
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
                          const Divider(height: 32),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              '2. Customize Output',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          ModernCard(
                            child: Column(
                              children: [
                                ModernDropdown<ArtStyle>(
                                  value: _selectedStyle,
                                  label: 'Style',
                                  items: const [
                                    DropdownMenuItem(
                                      value: ArtStyle.dots,
                                      child: Text('Dots Only'),
                                    ),
                                    DropdownMenuItem(
                                      value: ArtStyle.ascii,
                                      child: Text('ASCII Art'),
                                    ),
                                    DropdownMenuItem(
                                      value: ArtStyle.outline,
                                      child: Text('Outline Only'),
                                    ),
                                    DropdownMenuItem(
                                      value: ArtStyle.unicode,
                                      child: Text('Unicode Art'),
                                    ),
                                  ],
                                  onChanged: (v) {
                                    if (v != null)
                                      setState(() => _selectedStyle = v);
                                  },
                                ),
                                const SizedBox(height: 12),
                                ModernSlider(
                                  value: _outputWidth,
                                  min: 20,
                                  max: 100,
                                  divisions: 8,
                                  label: 'Width',
                                  onChanged: (v) =>
                                      setState(() => _outputWidth = v),
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
                        const Divider(height: 32),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            '3. Result',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        ModernCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
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
                                onPressed: _dottedText.isNotEmpty
                                    ? _copyText
                                    : null,
                                icon: const Icon(Icons.copy),
                                label: const Text('Copy Dotted Text'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
    // ...existing code...
  }
}
