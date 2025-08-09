// ...imports...

// Character ramps for ASCII and Unicode art

import 'package:dot_sketch/dot_sketch_home.dart';
import 'package:flutter/material.dart';

import 'ui/theme.dart';

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
