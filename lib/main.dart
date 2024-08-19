import 'package:flutter/material.dart';
import 'features/contract_edit/contract_debug.dart';

import 'features/excel_edit/excel_edit_screen.dart';
import 'splash.dart'; // splash.dart 파일 경로 추가

import 'dart:typed_data';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle, ByteData;

import 'package:flutter_localizations/flutter_localizations.dart';
void main() {


  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FastDeal',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(200, 50), // 버튼 크기 설정
          ),
        ),
      ),
      supportedLocales: [
        Locale('en', 'US'),
        Locale('ko', 'KR'), // Korean locale
      ],
      // Add localization delegates here
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: SplashScreen(), // 초기 화면을 스플래시 화면으로 설정
      // home: ContractFeature(reportType:'매입'), // 서명 칸 간격 디버깅용
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fast Deal'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 200, // 버튼의 가로 길이 고정
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExcelEditScreen(reportType: '매입'),
                    ), // '매입' 변수 전달
                  );
                },
                child: Text('차량 매매 보고서 (매입)'),
              ),
            ),
            SizedBox(height: 20), // 버튼 간 간격
            SizedBox(
              width: 200, // 버튼의 가로 길이 고정
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExcelEditScreen(reportType: '판매'),
                    ), // '판매' 변수 전달
                  );
                },
                child: Text('차량 매매 보고서 (판매)'),
              ),
            ),
            SizedBox(height: 20), // 버튼 간 간격 추가
            SizedBox(
              width: 200, // 버튼의 가로 길이 고정
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContractFeature(reportType: '매입'),
                    ),
                  );
                },
                child: Text('관인 계약서(매입)'),
              ),
            ),
            SizedBox(height: 20), // 버튼 간 간격 추가
            SizedBox(
              width: 200, // 버튼의 가로 길이 고정
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContractFeature(reportType: '판매'),
                    ),
                  );
                },
                child: Text('관인 계약서(판매)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
// class CustomRect {
//   final Rect rect;
//   final String name;
//   ui.Image? overlayImage;
//
//   CustomRect(this.rect, this.name, {this.overlayImage});
//
//   bool contains(Offset point) {
//     return rect.contains(point);
//   }
// }
//
//
// class ChnageImage extends StatefulWidget {
//   const ChnageImage({super.key});
//   @override
//   State<ChnageImage> createState() => _ChnageImageState();
// }
//
// class _ChnageImageState extends State<ChnageImage> {
//   ui.Image? contractImage;
//   List<CustomRect> predefinedAreas = [];
//   String? savedImagePath;
//
//   @override
//   void initState() {
//     super.initState();
//     _processImage(); // Start the entire image processing pipeline in initState
//   }
//
//   Future<void> _processImage() async {
//     await loadContractImage();
//     await _overlayTextToImage();
//     await _drawOverlayOnContract();
//     print('_processImage');
//   }
//
//   List<CustomRect> _calculatePredefinedAreas(double imageWidth, double imageHeight) {
//     return [
//       CustomRect(
//           Rect.fromLTWH(imageWidth * 0.283, imageHeight * 0.128,
//               imageWidth * 0.18, imageHeight * 0.024),
//           'topDate'),
//       // 상단 날짜
//       CustomRect(
//           Rect.fromLTWH(imageWidth * 0.282, imageHeight * 0.770,
//               imageWidth * 0.72, imageHeight * 0.024),
//           'contractDate'),
//       // 계약 날짜
//     ];
//   }
//
//   Future<void> loadContractImage() async {
//     ByteData data = await rootBundle.load('assets/contract_image.png');
//     final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
//     final frame = await codec.getNextFrame();
//
//     contractImage = frame.image;
//     predefinedAreas = _calculatePredefinedAreas(
//       contractImage!.width.toDouble(),
//       contractImage!.height.toDouble(),
//     );
//   }
//
//   Future<void> _overlayTextToImage() async {
//     if (contractImage == null) return;
//
//     final dateString = _getCurrentDateString();
//
//     for (var area in predefinedAreas) {
//       final textImage = await _textToImage(
//         dateString,
//         area.rect.width,
//         area.rect.height,
//         37, // Font size
//         align: TextAlign.center,
//       );
//
//       area.overlayImage = textImage;
//     }
//   }
//
//   String _getCurrentDateString() {
//
//     final now = DateTime.now();
//     final year = now.year;
//     final month = now.month.toString().padLeft(2, '0');
//     final day = now.day.toString().padLeft(2, '0');
//     //return '$year-$month-$day';
//     return '2024-05-08';
//   }
//
//   Future<ui.Image> _textToImage(
//       String text,
//       double width,
//       double height,
//       double fontSize, {
//         TextAlign align = TextAlign.center,
//       }) async {
//     final recorder = ui.PictureRecorder();
//     final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));
//
//     final textPainter = TextPainter(
//       text: TextSpan(
//         text: text,
//         style: TextStyle(color: Colors.black, fontSize: fontSize, backgroundColor: Colors.white),
//       ),
//       textDirection: TextDirection.ltr,
//       textAlign: align,
//     );
//     textPainter.layout(maxWidth: width);
//
//     final textWidth = textPainter.width;
//     final textHeight = textPainter.height;
//
//     final Offset textOffset;
//     switch (align) {
//       case TextAlign.left:
//         textOffset = Offset(-2, (height - textHeight) / 2);
//         break;
//       case TextAlign.right:
//         textOffset = Offset(width - textWidth, (height - textHeight) / 2);
//         break;
//       case TextAlign.center:
//       default:
//         textOffset = Offset((width - textWidth) / 2, (height - textHeight) / 2);
//         break;
//     }
//
//     textPainter.paint(canvas, textOffset);
//     final picture = recorder.endRecording();
//     return picture.toImage(width.toInt(), height.toInt());
//   }
//
//   Future<void> _drawOverlayOnContract() async {
//     if (contractImage == null) return;
//
//     final recorder = ui.PictureRecorder();
//     final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, contractImage!.width.toDouble(), contractImage!.height.toDouble()));
//
//     // Draw the contract image first
//     canvas.drawImage(contractImage!, Offset.zero, Paint());
//
//     for (var area in predefinedAreas) {
//       if (area.overlayImage != null) {
//         final imageScale = 1.0; // Scale factor (1.0)
//         final left = area.rect.left * imageScale;
//         final top = area.rect.top * imageScale;
//         final width = area.rect.width * imageScale;
//         final height = area.rect.height * imageScale;
//
//         // Draw the scaled overlay image
//         canvas.drawImageRect(
//           area.overlayImage!,
//           Rect.fromLTWH(0, 0, area.overlayImage!.width.toDouble(), area.overlayImage!.height.toDouble()),
//           Rect.fromLTWH(left, top, width, height),
//           Paint(),
//         );
//       }
//     }
//
//     final picture = recorder.endRecording();
//     final finalImage = await picture.toImage(contractImage!.width, contractImage!.height);
//
//     await _saveImageToFile(finalImage);
//   }
//
//   Future<void> _saveImageToFile(ui.Image image) async {
//     final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//     final uint8list = byteData!.buffer.asUint8List();
//
//     // Get the application's document directory
//     final directory = await getApplicationDocumentsDirectory();
//     final file = File('${directory.path}/contract_image_input.png');
//
//     // Write the PNG data to the file
//     await file.writeAsBytes(uint8list);
//
//     setState(() {
//       savedImagePath = file.path; // Update the saved image path
//     });
//
//     print('Image saved to ${file.path}');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Change Image'),
//       ),
//       body: Center(
//         child: savedImagePath == null
//             ? const CircularProgressIndicator() // Show a loading indicator while processing
//             : Image.file(File(savedImagePath!)), // Display the saved image
//       ),
//     );
//   }
// }
//
