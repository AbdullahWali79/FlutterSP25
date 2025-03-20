import 'package:flutter/material.dart';
import '../lib/widgets/app_icon.dart';
import 'dart:io';
import 'dart:ui' as ui;

void main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  const size = 1024.0;

  // Create the icon painter
  final painter = AppIconPainter();

  // Create a picture recorder
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // Paint the icon
  painter.paint(canvas, Size(size, size));

  // Convert to image
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.round(), size.round());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final buffer = byteData!.buffer.asUint8List();

  // Ensure directory exists
  final directory = Directory('assets/icon');
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  // Write the icon files
  final iconFile = File('assets/icon/app_icon.png');
  final foregroundFile = File('assets/icon/app_icon_foreground.png');

  await iconFile.writeAsBytes(buffer);
  await foregroundFile.writeAsBytes(buffer);

  print('App icon generated successfully!');
}
