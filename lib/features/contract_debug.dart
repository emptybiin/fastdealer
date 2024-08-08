import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'package:share_plus/share_plus.dart';

class CustomRect {
  final Rect rect;
  final String name; // Add a name field
  ui.Image? overlayImage;

  CustomRect(this.rect, this.name, {this.overlayImage});

  bool contains(Offset point) {
    return rect.contains(point);
  }
}

class ContractFeatureDebug extends StatefulWidget {
  @override
  _ContractFeatureDebugState createState() => _ContractFeatureDebugState();
}

class _ContractFeatureDebugState extends State<ContractFeatureDebug> {
  SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );
  ui.Image? contractImage;
  ui.Image? combinedImage;

  bool isImageLoaded = false;
  bool isSignatureMode = false;
  bool isTextInputMode = false;

  CustomRect? _selectedArea; // Private variable

  TextEditingController textEditingController = TextEditingController();
  FocusNode textFocusNode = FocusNode(); // Add a FocusNode
  List<CustomRect> predefinedAreas = [];
  double signatureHeight = 0.0;

  CustomRect? get selectedArea => _selectedArea;

  set selectedArea(CustomRect? area) {
    setState(() {
      _selectedArea = area;
      print(
          'Selected Area Updated: ${_selectedArea?.name}'); // CustomRect의 name 속성 사용
    });
  }

  @override
  void initState() {
    super.initState();
    copyAssetFileToLocalDir('assets/contract.xlsx', 'contract.xlsx');
    loadContractImage();
  }

  Future<void> loadContractImage() async {
    ByteData data = await rootBundle.load('assets/contract_image.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    setState(() {
      contractImage = frame.image;
      isImageLoaded = true;
      predefinedAreas = _calculatePredefinedAreas(
          contractImage!.width.toDouble(), contractImage!.height.toDouble());
    });
  }

  List<CustomRect> _calculatePredefinedAreas(
      double imageWidth, double imageHeight) {
    return [
      CustomRect(
          Rect.fromLTWH(imageWidth * 0.6, imageHeight * 0.117, imageWidth * 0.1,
              imageHeight * 0.023),
          'transferorName'),
      // 양도인 이름
      CustomRect(
          Rect.fromLTWH(imageWidth * 0.6, imageHeight * 0.140, imageWidth * 0.1,
              imageHeight * 0.023),
          'transfereeName'),
      // 양수인 이름
      CustomRect(
          Rect.fromLTWH(imageWidth * 0.85, imageHeight * 0.115,
              imageWidth * 0.12, imageHeight * 0.023),
          'transferorSignature'),
      // 양도인 서명
      CustomRect(
          Rect.fromLTWH(imageWidth * 0.85, imageHeight * 0.138,
              imageWidth * 0.12, imageHeight * 0.023),
          'transfereeSignature'),
      // 양수인 서명
      CustomRect(
          Rect.fromLTWH(imageWidth * 0.124, imageHeight * 0.191,
              imageWidth * 0.312, imageHeight * 0.024),
          'vehicleRegistrationNumber'),
      // 차량 등록 번호
      CustomRect(
          Rect.fromLTWH(imageWidth * 0.124, imageHeight * (0.191 + 0.024 * 1),
              imageWidth * 0.16, imageHeight * 0.024),
          'vehicleType'),
      // 차량 종류
      CustomRect(
          Rect.fromLTWH(imageWidth * 0.37, imageHeight * (0.191 + 0.024 * 1),
              imageWidth * 0.067, imageHeight * 0.024),
          'year'),
      // 연식
      CustomRect(
          Rect.fromLTWH(imageWidth * 0.124, imageHeight * (0.191 + 0.024 * 2),
              imageWidth * 0.312, imageHeight * 0.024),
          'carModel'),
      // 차종
      CustomRect(
          Rect.fromLTWH(imageWidth * 0.124, imageHeight * (0.191 + 0.024 * 3),
              imageWidth * 0.312, imageHeight * 0.024),
          'chassisNumber'),
      // 차대 번호
      CustomRect(
          Rect.fromLTWH(imageWidth * 0.124, imageHeight * (0.191 + 0.024 * 4),
              imageWidth * 0.312, imageHeight * 0.025),
          'registrationFee'),
      // 등록비
      CustomRect(
          Rect.fromLTWH(imageWidth * 0.543, imageHeight * 0.191,
              imageWidth * 0.453, imageHeight * 0.024),
          'transactionAmount'),
      // 매매 금액
      CustomRect(
          Rect.fromLTWH(imageWidth * 0.543, imageHeight * (0.191 + 0.024 * 1),
              imageWidth * 0.3, imageHeight * 0.024),
          'leaseTransfer'),
      // 리스 승계
      CustomRect(
          Rect.fromLTWH(imageWidth * 0.543, imageHeight * (0.191 + 0.024 * 2),
              imageWidth * 0.3, imageHeight * 0.024),
          'downPayment'),
      // 인도금
      CustomRect(
          Rect.fromLTWH(imageWidth * 0.543, imageHeight * (0.191 + 0.024 * 3),
              imageWidth * 0.3, imageHeight * 0.024),
          'remainingBalance'),
      // 잔금

      CustomRect(
          Rect.fromLTWH(imageWidth * 0.843, imageHeight * (0.191 + 0.024 * 1),
              imageWidth * 0.153, imageHeight * 0.024),
          'leaseTransfer_fee'),
      // 리스 승계
      CustomRect(
          Rect.fromLTWH(imageWidth * 0.843, imageHeight * (0.191 + 0.024 * 2),
              imageWidth * 0.153, imageHeight * 0.024),
          'downPayment_fee'),
      // 인도금
      CustomRect(
          Rect.fromLTWH(imageWidth * 0.843, imageHeight * (0.191 + 0.024 * 3),
              imageWidth * 0.153, imageHeight * 0.024),
          'remainingBalance_fee'),
      // 잔금

      CustomRect(
          Rect.fromLTWH(imageWidth * 0.543, imageHeight * (0.191 + 0.024 * 4),
              imageWidth * 0.453, imageHeight * 0.025),
          'remarks'),
      // 비고
      CustomRect(
          Rect.fromLTWH(imageWidth * 0.285, imageHeight * 0.128,
              imageWidth * 0.18, imageHeight * 0.024),
          'topDate'),
      // 상단 날짜
      CustomRect(
          Rect.fromLTWH(imageWidth * 0.282, imageHeight * 0.770,
              imageWidth * 0.72, imageHeight * 0.024),
          'contractDate'),
      // 계약 날짜
      CustomRect(
          Rect.fromLTWH(imageWidth * 0.282, imageHeight * 0.794,
              imageWidth * 0.241, imageHeight * 0.024),
          'transferorNameFull'),
      // 양도인 이름 (풀네임)
      CustomRect(
          Rect.fromLTWH(imageWidth * 0.764, imageHeight * 0.794,
              imageWidth * 0.238, imageHeight * 0.024),
          'transferorSignatureOrSeal'),
      // 양도인 서명 또는 도장
      CustomRect(
          Rect.fromLTWH(imageWidth * 0.282, imageHeight * 0.818,
              imageWidth * 0.482, imageHeight * 0.024),
          'transferorIdNumber'),
      // 양도인 주민등록번호
      CustomRect(
          Rect.fromLTWH(imageWidth * 0.282, imageHeight * 0.843,
              imageWidth * 0.482, imageHeight * 0.024),
          'transferorAddressAndPhone'),
      // 양도인 주소 및 전화번호
      CustomRect(
          Rect.fromLTWH(imageWidth * 0.282, imageHeight * 0.867,
              imageWidth * 0.482, imageHeight * 0.024),
          'transfereeNameFull'),
      // 양수인 이름 (풀네임)
      CustomRect(
          Rect.fromLTWH(imageWidth * 0.764, imageHeight * 0.867,
              imageWidth * 0.238, imageHeight * 0.024),
          'transfereeSignatureOrSeal'),
      // 양수인 서명 또는 도장
      CustomRect(
          Rect.fromLTWH(imageWidth * 0.282, imageHeight * 0.892,
              imageWidth * 0.482, imageHeight * 0.024),
          'transfereeIdNumber'),
      // 양수인 주민등록번호
      CustomRect(
          Rect.fromLTWH(imageWidth * 0.282, imageHeight * 0.916,
              imageWidth * 0.482, imageHeight * 0.024),
          'transfereeAddressAndPhone'),
      // 양수인 주소 및 전화번호
    ];
  }

  Future<ui.Image> _signatureToImage() async {
    final signatureBytes = await _controller.toPngBytes();
    final codec = await ui.instantiateImageCodec(signatureBytes!);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
  String formatNumberWithCommas(String text) {
    try {
      final intValue = int.parse(text);
      final numberBuffer = StringBuffer();

      String intValueStr = intValue.toString();
      int length = intValueStr.length;

      for (int i = 0; i < length; i++) {
        if (i > 0 && (length - i) % 3 == 0) {
          numberBuffer.write(',');
        }
        numberBuffer.write(intValueStr[i]);
      }

      return numberBuffer.toString();
    } catch (e) {
      return text;
    }
  }

  Future<ui.Image> _textToImage(
      String text,
      double width,
      double height,
      double fontSize, {
        TextAlign align = TextAlign.center,
        required String name // Add this parameter to pass the name
      }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

    // Conditionally format the text based on the name
    final shouldFormat = [
      'transactionAmount_fee',
      'leaseTransfer_fee',
      'remainingBalance_fee',
      'downPayment_fee',
      'registrationFee'
    ].contains(name);

    final formattedText = shouldFormat ? formatNumberWithCommas(text) : text;

    final textPainter = TextPainter(
      text: TextSpan(
        text: formattedText,
        style: TextStyle(color: Colors.black, fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    );
    textPainter.layout(maxWidth: width);

    final textWidth = textPainter.width;
    final textHeight = textPainter.height;

    final Offset textOffset;
    switch (align) {
      case TextAlign.left:
        textOffset = Offset(-2, (height - textHeight) / 2);
        break;
      case TextAlign.right:
        textOffset = Offset(width - textWidth, (height - textHeight) / 2);
        break;
      case TextAlign.center:
      default:
        textOffset = Offset((width - textWidth) / 2, (height - textHeight) / 2);
        break;
    }

    textPainter.paint(canvas, textOffset);
    final picture = recorder.endRecording();
    return picture.toImage(width.toInt(), height.toInt());
  }



  Future<ui.Image> _combineImages(
      ui.Image baseImage, ui.Image overlayImage, Rect rect) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
        recorder,
        Rect.fromLTWH(
            0, 0, baseImage.width.toDouble(), baseImage.height.toDouble()));
    final paint = Paint();

    canvas.drawImage(baseImage, Offset(0, 0), paint);

    final srcRect = Rect.fromLTWH(
        0, 0, overlayImage.width.toDouble(), overlayImage.height.toDouble());
    canvas.drawImageRect(overlayImage, srcRect, rect, paint);

    final picture = recorder.endRecording();
    return picture.toImage(baseImage.width, baseImage.height);
  }

  Future<String> getFilePath(String fileName) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    return '$path/$fileName';
  }

  Future<void> _saveImage(ui.Image image, String fileName) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(buffer);
    print('Image saved at $filePath'); // Log the file path for debugging
  }

  Future<void> _saveSignatureOrText() async {
    if (selectedArea != null) {
      ui.Image? overlayImage;

      if (isSignatureMode) {
        overlayImage = await _signatureToImage();
      } else if (isTextInputMode) {
        double fontSize = 40.0;
        TextAlign textAlign = TextAlign.center;

        // Handle specific conditions for '_fee' types
        if (['leaseTransfer_fee', 'downPayment_fee', 'remainingBalance_fee']
            .contains(selectedArea!.name)) {
          fontSize = 38.0; // Adjust font size
          textAlign = TextAlign.left; // Left align text
        }
        // Handle other conditions
        else if (['leaseTransfer', 'downPayment', 'remainingBalance']
            .contains(selectedArea!.name)) {
          textAlign = TextAlign.left; // Left align text
        }

        final imageWidth = selectedArea!.rect.width;
        final spaceWidth =
            fontSize / 2; // Estimate the width of a space character

        String textToRender = textEditingController.text;

        // Split the text by '-' to handle each segment separately
        final segments = textToRender.split('-');

        // Create a new string with variable spaces
        StringBuffer sb = StringBuffer();
        for (int i = 0; i < segments.length; i++) {
          if (i > 0) {
            // Calculate the number of spaces based on position
            int numSpaces;
            if (i == 1) {
              numSpaces = (0.3 * (imageWidth / spaceWidth)).floor();
            } else if (i == 2) {
              numSpaces = (0.3 * (imageWidth / spaceWidth)).floor();
            } else {
              numSpaces = (imageWidth / spaceWidth).floor();
            }
            sb.write(' ' * numSpaces); // Append the calculated number of spaces
          }
          sb.write(segments[i]); // Append the current segment
        }
        textToRender = sb.toString();

        overlayImage = await _textToImage(
          textToRender,
          selectedArea!.rect.width,
          selectedArea!.rect.height,
          fontSize,
          align: textAlign,
          name: selectedArea!.name, // Add this parameter
        );

        if (overlayImage != null) {
          for (var area in predefinedAreas) {
            if (area.rect == selectedArea!.rect) {
              area.overlayImage = overlayImage;
              break;
            }
          }

          final updatedImage = await _combineImages(
              contractImage!, overlayImage, selectedArea!.rect);
          await _saveImage(updatedImage, 'contract_with_overlay.png');

          setState(() {
            combinedImage = updatedImage;
            isSignatureMode = false;
            isTextInputMode = false;
            textEditingController.clear();
            selectedArea = null;
          });
        }
      }
    }
  }

  Future<void> copyAssetFileToLocalDir(
      String assetPath, String localFileName) async {
    ByteData data = await rootBundle.load(assetPath);
    List<int> bytes = data.buffer.asUint8List();
    String localPath = await getFilePath(localFileName);
    File localFile = File(localPath);
    await localFile.writeAsBytes(bytes);
  }

  void _handleCellSelection(CustomRect area) {
    setState(() {
      selectedArea = area;
      print('Selected Area Name: ${area.name}');
      isSignatureMode = false;
      isTextInputMode = false;

      // Reset signature controller
      _controller.clear();

      // Clear text input controller
      textEditingController.clear();
    });
  }

  bool _showSelectCellSnackBar = false;

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // Function to show snackbar
    void _showSnackBar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 2),
        ),
      );
    }

    // Show snackbar if needed
    if (_showSelectCellSnackBar) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackBar('셀을 선택해주세요');
        // Reset the flag to prevent repeated snackbars
        setState(() {
          _showSelectCellSnackBar = false;
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('계약서 서명 기능'),
      ),
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard or any overlay input when tapped outside
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            // Image Container - Fixed Position
            if (isImageLoaded)
              Positioned.fill(
                child: GestureDetector(
                  onTapDown: (details) {
                    final imageScale = MediaQuery.of(context).size.width /
                        contractImage!.width;
                    final scaledHeight = contractImage!.height * imageScale;
                    final imageTopOffset =
                        (MediaQuery.of(context).size.height * imageScale -
                                scaledHeight) /
                            2;

                    final touchPosition = Offset(
                      details.localPosition.dx / imageScale,
                      (details.localPosition.dy / imageScale) +
                          imageTopOffset * 2.6,
                    );

                    final tappedArea = predefinedAreas.firstWhere(
                      (area) => area.contains(touchPosition),
                      orElse: () => CustomRect(Rect.zero, ''),
                    );

                    _handleCellSelection(tappedArea);
                  },
                  child: CustomPaint(
                    painter: ContractPainter(
                      contractImage!,
                      predefinedAreas,
                      selectedArea,
                      combinedImage,
                    ),
                  ),
                ),
              ),

            // Overlay TextField or Signature
            if ((isTextInputMode || isSignatureMode) &&
                selectedArea != null &&
                selectedArea!.rect != Rect.zero)
              Positioned(
                bottom: keyboardHeight,
                left: MediaQuery.of(context).size.width * 0.15,
                right: MediaQuery.of(context).size.width * 0.15,
                child: Container(
                  color: Colors.white.withOpacity(0.8),
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: isSignatureMode
                      ? MediaQuery.of(context).size.width *
                      1.5 *
                      ((selectedArea?.rect.height ?? 1) /
                          (selectedArea?.rect.width ?? 1)) +
                      100
                      : 150,


                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Expanded(
                      child: isSignatureMode
                          ? Signature(
                        controller: _controller,
                        backgroundColor: Colors.lightBlueAccent,
                      )
                          : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: textEditingController,
                          focusNode: textFocusNode,
                          keyboardType: [
                            'transactionAmount_fee',
                            'leaseTransfer_fee',
                            'remainingBalance_fee',
                            'downPayment_fee',
                            'registrationFee',
                            'year',
                            'transferorIdNumber',
                            'transfereeIdNumber'
                          ].contains(selectedArea!.name)
                              ? TextInputType.numberWithOptions(decimal: true, signed: false)
                              : TextInputType.text,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black, width: 1.0),
                            ),
                            labelText: [
                              'transactionAmount_fee',
                              'leaseTransfer_fee',
                              'remainingBalance_fee',
                              'downPayment_fee',
                              'registrationFee',
                              'year',
                              'transferorIdNumber',
                              'transfereeIdNumber'
                            ].contains(selectedArea!.name)
                                ? '숫자를 입력하세요'
                                : '텍스트를 입력하세요',
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                          readOnly: [
                            'leaseTransfer',
                            'downPayment',
                            'remainingBalance'
                          ].contains(selectedArea!.name),
                          onTap: () async {
                            if ([
                              'leaseTransfer',
                              'downPayment',
                              'remainingBalance'
                            ].contains(selectedArea!.name)) {
                              DateTime? selectedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1990),
                                lastDate: DateTime(2101),
                              );

                              if (selectedDate != null) {
                                textEditingController.text =
                                "${selectedDate.toLocal()}".split(' ')[0];
                              }
                            } else {
                              FocusScope.of(context).requestFocus(textFocusNode);
                            }
                          },
                        ),
                      ),
                    ),


                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Functionality for the Initialize button will be added later
                            },
                            child: Text('Initialize'),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _saveSignatureOrText();
                            },
                            child: Text('Save'),
                          ),
                        )
                      ],
                    ),
                  ]),
                ),
              ),




          ],
        ),
      ),



      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (selectedArea == null) {
                      _showSelectCellSnackBar = true;
                    } else {
                      isSignatureMode = true;
                      isTextInputMode = false;
                    }
                  });
                },
                child: Text('서명'),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (selectedArea == null) {
                      _showSelectCellSnackBar = true;
                    } else {
                      isTextInputMode = true;
                      isSignatureMode = false;
                      Future.delayed(Duration(milliseconds: 100), () {
                        FocusScope.of(context).requestFocus(textFocusNode);
                      });
                    }
                  });
                },
                child: Text('텍스트 입력'),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _saveSignatureOrText();
                },
                child: Text('저장'),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  // Save the combined image locally
                  if (combinedImage != null) {
                    await _saveImage(
                        combinedImage!, 'contract_with_overlay.png');
                  }

                  // Get the local path for the Excel file
                  String localPath = await getFilePath('contract.xlsx');
                  String newFilePath = await getFilePath('new_contract.xlsx');
                  File localFile = File(localPath);
                  File newFile = File(newFilePath);

                  // Copy the Excel file to the new path
                  await newFile.writeAsBytes(await localFile.readAsBytes());

                  // Share the new Excel file
                  Share.shareFiles([newFilePath], text: '새로운 계약서 엑셀 파일');
                },
                child: Text('내보내기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContractPainter extends CustomPainter {
  final ui.Image contractImage;
  final List<CustomRect> predefinedAreas;
  final CustomRect? selectedArea;
  final ui.Image? combinedImage;

  ContractPainter(
    this.contractImage,
    this.predefinedAreas,
    this.selectedArea,
    this.combinedImage,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;
    final imageScale = size.width / contractImage.width;
    final scaledHeight = contractImage.height * imageScale;
    final centeredTop = (size.height - scaledHeight) / 2;

    // Draw contract image
    canvas.drawImageRect(
      contractImage,
      Rect.fromLTWH(0, 0, contractImage.width.toDouble(),
          contractImage.height.toDouble()),
      Rect.fromLTWH(0, centeredTop, size.width, scaledHeight),
      paint,
    );

    // Draw combined image if available
    if (combinedImage != null) {
      canvas.drawImageRect(
        combinedImage!,
        Rect.fromLTWH(0, 0, combinedImage!.width.toDouble(),
            combinedImage!.height.toDouble()),
        Rect.fromLTWH(0, centeredTop, size.width, scaledHeight),
        paint,
      );
    }

    // Draw predefined areas with overlay images
    for (var area in predefinedAreas) {
      final scaledRect = Rect.fromLTWH(
        area.rect.left * imageScale,
        centeredTop + area.rect.top * imageScale,
        area.rect.width * imageScale,
        area.rect.height * imageScale,
      );
      final rectPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(scaledRect, rectPaint);

      // Draw overlay image if available
      if (area.overlayImage != null) {
        final overlayRect = Rect.fromLTWH(
          scaledRect.left,
          scaledRect.top,
          scaledRect.width,
          scaledRect.height,
        );
        canvas.drawImageRect(
          area.overlayImage!,
          Rect.fromLTWH(0, 0, area.overlayImage!.width.toDouble(),
              area.overlayImage!.height.toDouble()),
          overlayRect,
          Paint(),
        );
      }
    }

    // Draw selected area
    if (selectedArea != null) {
      final scaledSelectedRect = Rect.fromLTWH(
        selectedArea!.rect.left * imageScale,
        centeredTop + selectedArea!.rect.top * imageScale,
        selectedArea!.rect.width * imageScale,
        selectedArea!.rect.height * imageScale,
      );
      final selectedPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(scaledSelectedRect, selectedPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
