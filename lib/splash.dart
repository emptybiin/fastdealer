import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle, ByteData;

import 'main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await changeImage();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(Duration(seconds: 2), () {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'FastDeal',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}




Future<String?> changeImage() async {
  ui.Image? contractImage;
  List<CustomRect> predefinedAreas = [];

  // Load the contract image
  ByteData data = await rootBundle.load('assets/contract_image.png');
  final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
  final frame = await codec.getNextFrame();
  contractImage = frame.image;

  // Calculate predefined areas
  predefinedAreas = _calculatePredefinedAreas(
    contractImage.width.toDouble(),
    contractImage.height.toDouble(),
  );

  // Overlay text on the image
  for (var area in predefinedAreas) {
    final textImage = await _textToImage(
      _getCurrentDateString(),
      area.rect.width,
      area.rect.height,
      38, // Font size
      align: TextAlign.center,
    );
    area.overlayImage = textImage;
  }

  // Draw overlay on contract
  final finalImage = await _drawOverlayOnContract(contractImage, predefinedAreas);

  // Save the image to file
  return await _saveImageToFile(finalImage);
}

List<CustomRect> _calculatePredefinedAreas(double imageWidth, double imageHeight) {
  return [
    CustomRect(
      Rect.fromLTWH(imageWidth * 0.285, imageHeight * 0.128, imageWidth * 0.18, imageHeight * 0.024),
      'topDate',
    ),
    CustomRect(
      Rect.fromLTWH(imageWidth * 0.282, imageHeight * 0.770, imageWidth * 0.72, imageHeight * 0.024),
      'contractDate',
    ),
  ];
}

String _getCurrentDateString() {
  final now = DateTime.now();
  final year = now.year;
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

Future<ui.Image> _textToImage(
    String text, double width, double height, double fontSize,
    {TextAlign align = TextAlign.center}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

  final textPainter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(color: Colors.black, fontSize: fontSize, backgroundColor: Colors.white),
    ),
    textDirection: TextDirection.ltr,
    textAlign: align,
  );
  textPainter.layout(maxWidth: width);

  final textWidth = textPainter.width;
  final textHeight = textPainter.height;
  final Offset textOffset = Offset((width - textWidth) / 2, (height - textHeight) / 2);

  textPainter.paint(canvas, textOffset);
  final picture = recorder.endRecording();
  return picture.toImage(width.toInt(), height.toInt());
}

Future<ui.Image> _drawOverlayOnContract(ui.Image contractImage, List<CustomRect> predefinedAreas) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, contractImage.width.toDouble(), contractImage.height.toDouble()));

  canvas.drawImage(contractImage, Offset.zero, Paint());

  for (var area in predefinedAreas) {
    if (area.overlayImage != null) {
      canvas.drawImageRect(
        area.overlayImage!,
        Rect.fromLTWH(0, 0, area.overlayImage!.width.toDouble(), area.overlayImage!.height.toDouble()),
        area.rect,
        Paint(),
      );
    }
  }

  final picture = recorder.endRecording();
  return picture.toImage(contractImage.width, contractImage.height);
}

Future<String?> _saveImageToFile(ui.Image image) async {
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final uint8list = byteData!.buffer.asUint8List();

  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/contract_image_input.png');

  await file.writeAsBytes(uint8list);

  print('Image saved to ${file.path}');
  return file.path;
}

class CustomRect {
  final Rect rect;
  final String name;
  ui.Image? overlayImage;

  CustomRect(this.rect, this.name, {this.overlayImage});

  bool contains(Offset point) {
    return rect.contains(point);
  }
}
