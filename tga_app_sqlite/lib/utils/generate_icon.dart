// import 'dart:io';
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import '../widgets/app_icon.dart';
//
// Future<void> generateAppIcon() async {
//   const size = 1024.0; // Standard size for app icons
//
//   final widget = RepaintBoundary(
//     child: AppIcon(size: size),
//   );
//
//   final renderObject = widget.createRenderObject(null);
//   renderObject.layout(BoxConstraints.tight(const Size(size, size)));
//
//   final image = await renderObject.toImage(pixelRatio: 1);
//   final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//   final buffer = byteData!.buffer.asUint8List();
//
//   final iconFile = File('assets/icon/app_icon.png');
//   final foregroundFile = File('assets/icon/app_icon_foreground.png');
//
//   await iconFile.writeAsBytes(buffer);
//   await foregroundFile.writeAsBytes(buffer);
// }
