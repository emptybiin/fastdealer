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

class CustomRect {
  final Rect rect;
  final String name;
  String text;
  ui.Image? overlayImage;

  CustomRect(this.rect, this.name, this.text, {this.overlayImage});

  bool contains(Offset point) {
    return rect.contains(point);
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

  // 판매
  for (var area in predefinedAreas) {
    // Check for specific names and apply the custom text
    if (area.name == 'transferorNameFull') {
      area.text = '(주)기억';
    } else if (area.name == 'transferorIdNumber') {
      area.text = '110111-6116308';
    } else if (area.name == 'transferorAddressAndPhone') {
      area.text = '서울시 서초구 양재대로 11길 36 은관 401호';
    } else if (area.name == 'topDate' || area.name == 'contractDate') {
      area.text =
          _getCurrentDateString(); // Set current date for 'topDate' and 'contractDate'
    }

    // Set font size based on the area name
    double fontSize =
        (area.name == 'topDate' || area.name == 'contractDate') ? 34 : 24;

    final textImage = await _textToImage(area.text, area.rect.width,
        area.rect.height, fontSize, // Conditional font size
        align: TextAlign.center,
        areaName: area.name);
    area.overlayImage = textImage;
    area.text = ''; // Clear text after it's used
  }

  // Draw overlay on contract for 판매
  final finalImage =
      await _drawOverlayOnContract(contractImage, predefinedAreas);

  // Save the image to file for 판매
  await _saveImageToFile(finalImage, 'sale');

  // 매입
  for (var area in predefinedAreas) {
    // Check for specific names and apply the custom text
    if (area.name == 'transfereeIdNumber') {
      area.text = '(주)기억 110111-6116308';
    } else if (area.name == 'transfereeAddressAndPhone') {
      area.text = '서울시 서초구 양재대로 11길 36 은관 401호';
    } else if (area.name == 'topDate' || area.name == 'contractDate') {
      area.text =
          _getCurrentDateString(); // Set current date for 'topDate' and 'contractDate'
    }

    // Set font size based on the area name
    double fontSize =
        (area.name == 'topDate' || area.name == 'contractDate') ? 34 : 24;

    final textImage = await _textToImage(area.text, area.rect.width,
        area.rect.height, fontSize, // Conditional font size
        align: TextAlign.center,
        areaName: area.name);
    area.overlayImage = textImage;
    area.text = ''; // Clear text after it's used
  }

  // Draw overlay on contract for 매입
  final finalImage2 =
      await _drawOverlayOnContract(contractImage, predefinedAreas);

  // Save the image to file for 매입
  await _saveImageToFile(finalImage2, 'purc');
}

List<CustomRect> _calculatePredefinedAreas(
    double imageWidth, double imageHeight) {
  return [
    CustomRect(
        Rect.fromLTWH(imageWidth * 0.255, imageHeight * 0.167,
            imageWidth * 0.18, imageHeight * 0.024),
        'topDate',
        _getCurrentDateString()),
    // 상단 날짜

    CustomRect(
        Rect.fromLTWH(imageWidth * 0.312, imageHeight * (0.706 - 0.0175),
            imageWidth * 0.653, imageHeight * 0.0175),
        'contractDate',
        _getCurrentDateString()),
    // 계약 날짜

    CustomRect(
        Rect.fromLTWH(imageWidth * 0.312, imageHeight * 0.706,
            imageWidth * 0.233, imageHeight * 0.0175),
        'transferorNameFull',
        ''),
    // 양도인 이름 (주)기억

    CustomRect(
        Rect.fromLTWH(imageWidth * 0.312, imageHeight * (0.706 + 0.0175 * 1),
            imageWidth * 0.233, imageHeight * 0.0175),
        'transferorIdNumber',
        ''),
    // 양도인 주민등록번호(사업자번호) 1000~~
    CustomRect(
        Rect.fromLTWH(imageWidth * 0.312, imageHeight * (0.706 + 0.0175 * 2),
            imageWidth * 0.438, imageHeight * 0.0175 * 2),
        'transferorAddressAndPhone',
        ''),
    // 양도인 주소 및 전화번호

    CustomRect(
        Rect.fromLTWH(imageWidth * 0.312, imageHeight * (0.706 + 0.0175 * 4),
            imageWidth * 0.233, imageHeight * 0.0175),
        'transfereeNameFull',
        ''),
    // 양수인 이름 (풀네임)

    CustomRect(
        Rect.fromLTWH(imageWidth * 0.312, imageHeight * (0.706 + 0.0175 * 5),
            imageWidth * 0.233, imageHeight * 0.0175),
        'transfereeIdNumber',
        ''),
    // 양수인 사업자번호
    CustomRect(
        Rect.fromLTWH(imageWidth * 0.312, imageHeight * (0.706 + 0.0175 * 6),
            imageWidth * 0.438, imageHeight * 0.0175 * 2),
        'transfereeAddressAndPhone',
        ''),
    // 양수인 주소 및 전화번호
  ];
}

String _getCurrentDateString() {
  final now = DateTime.now();
  final year = now.year;
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  // return '$year-$month-$day';
  return '2024년05월05일';
}

Future<ui.Image> _textToImage(
    String text, double width, double height, double fontSize,
    {TextAlign align = TextAlign.center, String? areaName}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

  // Set background color based on the area name
  Color backgroundColor = (areaName == 'topDate' || areaName == 'contractDate')
      ? Colors.white
      : Colors.transparent;

  // Set up the text painter
  final textPainter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.black,
        fontSize: fontSize,
        backgroundColor: backgroundColor,
      ),
    ),
    textDirection: TextDirection.ltr,
    textAlign: align,
  );
  textPainter.layout(maxWidth: width);

  // Calculate text position
  final textWidth = textPainter.width;
  final textHeight = textPainter.height;
  final Offset textOffset =
      Offset((width - textWidth) / 2, (height - textHeight) / 2);

  // Paint the text onto the canvas
  textPainter.paint(canvas, textOffset);

  // Finalize and return the image
  final picture = recorder.endRecording();
  return picture.toImage(width.toInt(), height.toInt());
}

Future<ui.Image> _drawOverlayOnContract(
    ui.Image contractImage, List<CustomRect> predefinedAreas) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, contractImage.width.toDouble(),
          contractImage.height.toDouble()));

  canvas.drawImage(contractImage, Offset.zero, Paint());

  for (var area in predefinedAreas) {
    if (area.overlayImage != null) {
      canvas.drawImageRect(
        area.overlayImage!,
        Rect.fromLTWH(0, 0, area.overlayImage!.width.toDouble(),
            area.overlayImage!.height.toDouble()),
        area.rect,
        Paint(),
      );
    }
  }

  final picture = recorder.endRecording();
  return picture.toImage(contractImage.width, contractImage.height);
}

Future<String?> _saveImageToFile(ui.Image image, String path) async {
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final uint8list = byteData!.buffer.asUint8List();

  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/contract_image_${path}_input.png');

  await file.writeAsBytes(uint8list);

  print('Image saved to ${file.path}');
  return file.path;
}
