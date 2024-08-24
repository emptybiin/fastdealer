import 'dart:typed_data';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:signature/signature.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle, ByteData;

class CustomRect {
  final Rect rect;
  final String name; // Add a name field
  ui.Image? overlayImage;

  CustomRect(this.rect, this.name, {this.overlayImage});

  bool contains(Offset point) {
    return rect.contains(point);
  }
}

class ContractFeature extends StatefulWidget {
  final String reportType;

  ContractFeature({required this.reportType});

  @override
  _ContractFeatureState createState() => _ContractFeatureState();
}

class _ContractFeatureState extends State<ContractFeature> {
  SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );
  ui.Image? contractImage;
  ui.Image? combinedImage;
  List<Offset> touchCoordinates = [];
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
          'Selected Area Updated: ${_selectedArea?.rect}'); // CustomRect의 name 속성 사용
    });
  }

  @override
  void initState() {
    super.initState();
    copyAssetFileToLocalDir('assets/contract.xlsx', 'contract.xlsx');
    loadContractImage();
  }

  Future<void> loadContractImage() async {
    String filePath = '';

    if (widget.reportType == '매입') {
      filePath =
          '/data/user/0/com.groonui.fastdealer/app_flutter/contract_image_purc_input.png';
    } else {
      filePath =
          '/data/user/0/com.groonui.fastdealer/app_flutter/contract_image_sale_input.png';
    }
    final file = File(filePath);
    final data = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(data);
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
      // CustomRect(
      //     Rect.fromLTWH(imageWidth * 0, imageHeight * 0, imageWidth * 0.1,
      //         imageHeight * 1),
      //     'transferorName'),
      // CustomRect(
      //     Rect.fromLTWH(imageWidth * 0, imageHeight * 0, imageWidth * 1,
      //         imageHeight * 0.1),
      //     'transferorName'),

      CustomRect(
          Rect.fromLTWH(imageWidth * 0.687, imageHeight * 0.154,
              imageWidth * 0.18, imageHeight * 0.025),
          'transfereeName'),
      // 양도인 이름

      CustomRect(
          Rect.fromLTWH(imageWidth * 0.687, imageHeight * (0.154 + 0.025),
              imageWidth * 0.18, imageHeight * 0.025),
          'transferorName'),
      // 양수인 이름

      CustomRect(
          Rect.fromLTWH(imageWidth * 0.867, imageHeight * 0.154,
              imageWidth * 0.1, imageHeight * 0.025),
          'transferorSignature'),
      // 양도인 서명

      CustomRect(
          Rect.fromLTWH(imageWidth * 0.867, imageHeight * (0.154 + 0.025),
              imageWidth * 0.1, imageHeight * 0.025),
          'transfereeSignature'),
      // 양수인 서명

      CustomRect(
          Rect.fromLTWH(imageWidth * 0.232, imageHeight * 0.223,
              imageWidth * 0.221, imageHeight * 0.0175),
          'vehicleRegistrationNumber'),
      // 차량 등록 번호

      CustomRect(
          Rect.fromLTWH(imageWidth * 0.162, imageHeight * (0.223 + 0.0175 * 1),
              imageWidth * 0.15, imageHeight * 0.0175),
          'vehicleType'),
      // 차량 종류

      CustomRect(
          Rect.fromLTWH(imageWidth * 0.39, imageHeight * (0.223 + 0.0175 * 1),
              imageWidth * 0.063, imageHeight * 0.0175),
          'year'),
      // 연식

      CustomRect(
          Rect.fromLTWH(imageWidth * 0.232, imageHeight * (0.223 + 0.0175 * 2),
              imageWidth * 0.221, imageHeight * 0.0175),
          'carModel'),
      // 차명

      CustomRect(
          Rect.fromLTWH(imageWidth * 0.232, imageHeight * (0.223 + 0.0175 * 3),
              imageWidth * 0.221, imageHeight * 0.0175),
          'chassisNumber'),
      // 차대 번호

      CustomRect(
          Rect.fromLTWH(imageWidth * 0.232, imageHeight * (0.223 + 0.0175 * 4),
              imageWidth * 0.157, imageHeight * 0.0175),
          'registrationFee'),
      // 등록비용

      CustomRect(
          Rect.fromLTWH(imageWidth * 0.617, imageHeight * 0.223,
              imageWidth * 0.28, imageHeight * 0.0175),
          'transactionAmount'),
      // 매매 금액

      CustomRect(
          Rect.fromLTWH(imageWidth * 0.617, imageHeight * (0.223 + 0.0175 * 1),
              imageWidth * 0.135, imageHeight * 0.0175),
          'leaseTransfer'),
      // 계약금 날짜
      //
      CustomRect(
          Rect.fromLTWH(imageWidth * 0.617, imageHeight * (0.223 + 0.0175 * 2),
              imageWidth * 0.135, imageHeight * 0.0175),
          'downPayment'),
      // 인도금 날짜

      CustomRect(
          Rect.fromLTWH(imageWidth * 0.617, imageHeight * (0.223 + 0.0175 * 3),
              imageWidth * 0.135, imageHeight * 0.0175),
          'remainingBalance'),
      // 잔금 날짜
      //
      CustomRect(
          Rect.fromLTWH(imageWidth * 0.7975, imageHeight * (0.223 + 0.0175 * 1),
              imageWidth * 0.1, imageHeight * 0.0175),
          'leaseTransfer_fee'),
      // 계약금 금액

      CustomRect(
          Rect.fromLTWH(imageWidth * 0.7975, imageHeight * (0.223 + 0.0175 * 2),
              imageWidth * 0.1, imageHeight * 0.0175),
          'downPayment_fee'),
      // 인도금

      CustomRect(
          Rect.fromLTWH(imageWidth * 0.7975, imageHeight * (0.223 + 0.0175 * 3),
              imageWidth * 0.1, imageHeight * 0.0175),
          'remainingBalance_fee'),
      // 잔금

      CustomRect(
          Rect.fromLTWH(imageWidth * 0.547, imageHeight * (0.223 + 0.0175 * 4),
              imageWidth * 0.422, imageHeight * 0.0175),
          'remarks'),
      // 비고

      CustomRect(
          Rect.fromLTWH(imageWidth * 0.255, imageHeight * 0.167,
              imageWidth * 0.18, imageHeight * 0.024),
          'topDate'),
      // 상단 날짜

      CustomRect(
          Rect.fromLTWH(imageWidth * 0.312, imageHeight * (0.706 - 0.0175),
              imageWidth * 0.653, imageHeight * 0.0175),
          'contractDate'),
      // 계약 날짜

      CustomRect(
          Rect.fromLTWH(imageWidth * 0.312, imageHeight * 0.706,
              imageWidth * 0.233, imageHeight * 0.0175),
          'transferorNameFull'),
      // 양도인 이름

      CustomRect(
          Rect.fromLTWH(imageWidth * 0.545, imageHeight * 0.706,
              imageWidth * 0.205, imageHeight * 0.0175),
          'transferorPhoneNumber'),
      // 양도인 전화번호


      CustomRect(
          Rect.fromLTWH(imageWidth * 0.750, imageHeight * 0.706,
              imageWidth * 0.215, imageHeight * 0.0175*4),
          'transferorSignatureOrSeal'),
      // 양도인 서명 또는 도장

      CustomRect(
          Rect.fromLTWH(imageWidth * 0.312, imageHeight * (0.706+ 0.0175 * 1),
              imageWidth * 0.233, imageHeight * 0.0175),
          'transferorIdNumber'),
      // 양도인 주민등록번호(사업자번호)


      CustomRect(
          Rect.fromLTWH(imageWidth * 0.312, imageHeight * (0.706 + 0.0175 * 2),
              imageWidth * 0.438, imageHeight * 0.0175 * 2),
          'transferorAddressAndPhone'),
      // 양도인 주소 및 전화번호



      CustomRect(
          Rect.fromLTWH(imageWidth * 0.312, imageHeight * (0.706 + 0.0175 * 4),
              imageWidth * 0.233, imageHeight * 0.0175),
          'transfereeNameFull'),
      // 양수인 이름 (풀네임)

      CustomRect(
          Rect.fromLTWH(imageWidth * 0.545, imageHeight * (0.706 + 0.0175 * 4),
              imageWidth * 0.205, imageHeight * 0.0175),
          'transfereePhoneNumber'),
      // 양수인 핸드폰번호

      CustomRect(
          Rect.fromLTWH(imageWidth * 0.312, imageHeight * (0.706 + 0.0175 * 5),
              imageWidth * 0.233, imageHeight * 0.0175),
          'transfereeIdNumber'),
      // 양수인 사업자번호



      CustomRect(
          Rect.fromLTWH(imageWidth * 0.750, imageHeight *  (0.706 + 0.0175 * 4),
              imageWidth * 0.215, imageHeight * 0.0175*4),
          'transfereeSignatureOrSeal'),
      // 양도인 서명 또는 도장

      CustomRect(
          Rect.fromLTWH(imageWidth * 0.312, imageHeight * (0.706 + 0.0175 * 6),
              imageWidth * 0.438, imageHeight * 0.0175*2),
          'transfereeAddressAndPhone'),
      // 양수인 주소 및 전화번호


      CustomRect(
          Rect.fromLTWH(imageWidth * 0.085, imageHeight *  0.577,
              imageWidth * 0.605, imageHeight * 0.024),
          'add1'),
      // 추가 1 섹션

      CustomRect(
          Rect.fromLTWH(imageWidth * 0.085, imageHeight *  (0.577 + 0.024),
              imageWidth * 0.605, imageHeight * 0.024),
          'add1data'),

      // 추가 1 데이터
      CustomRect(
          Rect.fromLTWH(imageWidth * 0.085, imageHeight *   (0.577 + 0.024*2),
              imageWidth * 0.605, imageHeight * 0.024),
          'add2'),
      // 추가 2 섹션

      CustomRect(
          Rect.fromLTWH(imageWidth * 0.085, imageHeight *   (0.577 + 0.024*3),
              imageWidth * 0.605, imageHeight * 0.024),
          'add2data'),
      // 추가 2 데이터


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
      String text, double width, double height, double fontSize,
      {TextAlign align = TextAlign.center,
      required String name // Add this parameter to pass the name
      }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

    // Conditionally format the text based on the name
    final shouldFormat = [
      'transactionAmount',
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
        // Ensure _signatureToImage is correctly implemented
        overlayImage = await _signatureToImage();
      } else if (isTextInputMode) {
        double fontSize = 32.0;
        TextAlign textAlign = TextAlign.center;

        if (['leaseTransfer_fee', 'downPayment_fee', 'remainingBalance_fee']
            .contains(selectedArea!.name)) {
          fontSize = 30.0;
          textAlign = TextAlign.center;
        } else if (['leaseTransfer', 'downPayment', 'remainingBalance']
            .contains(selectedArea!.name)) {
          textAlign = TextAlign.center;
        }

        String textToRender = textEditingController.text;
        final segments = textToRender.split('-');

        // 분할된 텍스트에 '년', '월', '일' 추가
        if (segments.length == 3) {
          textToRender =
          '${segments[0]}년${segments[1]}월${segments[2]}일';
          fontSize = 30.0;
        }

        overlayImage = await _textToImage(
          textToRender,
          selectedArea!.rect.width,
          selectedArea!.rect.height,
          fontSize,
          align: textAlign,
          name: selectedArea!.name,
        );
      }

      if (overlayImage != null) {
        bool areaUpdated = false;
        for (var area in predefinedAreas) {
          if (area.rect == selectedArea!.rect) {
            area.overlayImage = overlayImage;
            areaUpdated = true;
            break;
          }
        }
        if (!areaUpdated) {
          print('Selected area not found in predefinedAreas.');
        }

        final updatedImage = await _combineImages(
          contractImage!,
          overlayImage,
          selectedArea!.rect,
        );
        await _saveImage(updatedImage, 'contract_with_overlay.png');

        setState(() {
          combinedImage = updatedImage;
          isSignatureMode = false;
          isTextInputMode = false;
          textEditingController.clear();
          selectedArea = null;
        });
      } else {
        print('Overlay image is null.');
      }
    } else {
      print('Selected area is null.');
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
      //print('Selected Area Name: ${area.name}');
      isSignatureMode = false;
      isTextInputMode = false;

      // Reset signature controller
      _controller.clear();

      // Clear text input controller
      textEditingController.clear();
    });
  }

  bool _showSelectCellSnackBar = false;

// Define a flag to control touch correction mode
  bool _isTouchCorrectionMode = false;

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final appBarHeight = AppBar().preferredSize.height;
    print(appBarHeight);

    // Function to show snackbar
    void _showSnackBar(String message) {
      ScaffoldMessenger.of(context)
          .clearSnackBars(); // Clear existing SnackBars
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
                    final deviceWidth = MediaQuery.of(context).size.width;
                    final padding = MediaQuery.of(context).padding;
                    final deviceHeight = MediaQuery.of(context).size.height -
                        padding.top -
                        padding.bottom;
                    final keyboardHeight =
                        MediaQuery.of(context).viewInsets.bottom;

                    // Original touch position
                    final originalPosition = details.localPosition;

                    if (contractImage != null) {
                      final imageWidth = contractImage!.width.toDouble();
                      final imageHeight = contractImage!.height.toDouble();

                      // Correct the touch position
                      final correctedPosition = correctTouchOffset(
                        originalPosition,
                        imageWidth,
                        imageHeight,
                        deviceWidth,
                        deviceHeight,
                        appBarHeight,
                        keyboardHeight,
                      );
                      // Debug prints for validation
                      print('Original touch position: $originalPosition');
                      print('Corrected touch position: $correctedPosition');

                      final tappedArea = predefinedAreas.firstWhere(
                            (area) => area.contains(correctedPosition),
                        orElse: () => CustomRect(Rect.zero, ''),
                      );

                      _handleCellSelection(tappedArea);

                      if (_isTouchCorrectionMode) {
                        // Only add touch coordinates if there are fewer than 4
                        if (touchCoordinates.length < 4) {
                          touchCoordinates.add(originalPosition);
                          _showSnackBar('${touchCoordinates.length}회 터치 완료');

                          if (touchCoordinates.length == 4) {
                            _showSnackBar('완료했습니다');
                          }
                        }
                      }
                    } else {
                      // Handle null contractImage scenario
                      print('Error: contractImage is null');
                    }
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
                bottom: MediaQuery.of(context).size.height * 0.25 -
                    (isTextInputMode
                        ? MediaQuery.of(context).size.width *
                        1.5 *
                        ((selectedArea?.rect.height ?? 1) /
                            (selectedArea?.rect.width ?? 1)) +
                        100
                        : 150),
                left: MediaQuery.of(context).size.width * 0.15,
                right: MediaQuery.of(context).size.width * 0.15,
                child: Container(
                  color: Colors.white.withOpacity(0.8),
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: isTextInputMode
                      ? MediaQuery.of(context).size.width *
                      1.5 *
                      ((selectedArea?.rect.height ?? 1) /
                          (selectedArea?.rect.width ?? 1)) +
                      100
                      : 150,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 100,
                        child: isTextInputMode
                            ? Padding(
                          padding: const EdgeInsets.all(5.0),
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
                              'transfereeIdNumber',
                              'transactionAmount',
                              'transferorPhoneNumber',
                              'transfereePhoneNumber'
                            ].contains(selectedArea?.name)
                                ? TextInputType.numberWithOptions(
                                decimal: true, signed: false)
                                : TextInputType.text,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black, width: 2.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black, width: 1.0),
                              ),
                              labelText: [
                                'transactionAmount_fee',
                                'leaseTransfer_fee',
                                'remainingBalance_fee',
                                'downPayment_fee',
                                'registrationFee',
                                'year',
                                'transferorIdNumber',
                                'transfereeIdNumber',
                                'transactionAmount',
                                'transferorPhoneNumber',
                                'transfereePhoneNumber'
                              ].contains(selectedArea?.name)
                                  ? '숫자를 입력하세요'
                                  : '텍스트를 입력하세요',
                              labelStyle: TextStyle(color: Colors.black),
                            ),
                            readOnly: [
                              'leaseTransfer',
                              'downPayment',
                              'remainingBalance'
                            ].contains(selectedArea?.name),
                            onTap: () async {
                              if ([
                                'leaseTransfer',
                                'downPayment',
                                'remainingBalance'
                              ].contains(selectedArea?.name)) {
                                DateTime? selectedDate =
                                await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1990),
                                  lastDate: DateTime(2101),
                                  locale: Locale('ko', 'KR'), // Set the locale to Korean
                                );

                                if (selectedDate != null) {
                                  textEditingController.text =
                                  "${selectedDate.toLocal()}".split(' ')[0];

                                  // Automatically request focus to the TextField
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    FocusScope.of(context).requestFocus(textFocusNode);
                                  });
                                }
                              } else {
                                FocusScope.of(context).requestFocus(textFocusNode);
                              }
                            },
                          ),
                        )
                            : Signature(
                          controller: _controller,
                          backgroundColor: Colors.lightBlueAccent,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _saveSignatureOrText();
                              },
                              child: Text('저장'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                      _isTouchCorrectionMode = false; // Ensure it's off
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
                      _isTouchCorrectionMode = false; // Ensure it's off
                      Future.delayed(Duration(milliseconds: 100), () {
                        FocusScope.of(context).requestFocus(textFocusNode);
                      });
                    }
                  });
                },
                child: Text('텍스트'),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Clear previous coordinates
                  touchCoordinates.clear();

                  // Change to touch correction mode
                  setState(() {
                    _isTouchCorrectionMode =
                    true; // Enable touch correction mode
                    isSignatureMode = false;
                    isTextInputMode = false;

                    _showSnackBar('이미지의 좌단 상단을 각각 2번씩 터치해주세요');
                  });
                },
                child: Text('터치보정'),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  final overlayPainter = OverlayPainter(
                    contractImage!,
                    predefinedAreas,
                    onSave: (savedImage) {
                      print('Image saved successfully!');
                    },
                  );

                  final recorder = ui.PictureRecorder();
                  final canvas = Canvas(
                      recorder,
                      Rect.fromLTWH(0, 0, contractImage!.width.toDouble(),
                          contractImage!.height.toDouble()));

                  final size = Size(contractImage!.width.toDouble(),
                      contractImage!.height.toDouble());

                  overlayPainter.paint(canvas, size);

                  await overlayPainter.saveCanvasAsImage(size);
                },
                child: Text('내보내기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Offset correctTouchOffset(
      Offset touchPosition,
      double imageWidth,
      double imageHeight,
      double deviceWidth,
      double deviceHeight,
      double topPadding,
      double bottomPadding) {
    final imageAspectRatio = imageWidth / imageHeight;
    final screenHeight = deviceHeight - topPadding * 2.5;
    final screenAspectRatio = deviceWidth / screenHeight;

    double imageScale;
    double dx = 0, dy = 0;

    if (screenAspectRatio > imageAspectRatio) {
      // Screen is wider than the image
      imageScale = screenHeight / imageHeight;
      dx = (deviceWidth - imageWidth * imageScale) /
          2; // Center the image horizontally
    } else {
      // Screen is narrower or matches the image's aspect ratio
      imageScale = deviceWidth / imageWidth;
      dy = (screenHeight - imageHeight * imageScale) /
          2; // Center the image vertically
    }

    if (touchCoordinates.isNotEmpty) {
      double minX =
          touchCoordinates.map((p) => p.dx).reduce((a, b) => a < b ? a : b);
      double minY =
          touchCoordinates.map((p) => p.dy).reduce((a, b) => a < b ? a : b);

      dx = minX;
      dy = minY;
    }

    // Calculate corrected touch position
    final correctedX = ((touchPosition.dx - dx) / imageScale);
    final correctedY = ((touchPosition.dy - dy) / imageScale);

    // Debugging prints
    print('Image width: $imageWidth');
    print('Image height: $imageHeight');
    print('Device width: $deviceWidth');
    print('Device height: $deviceHeight');
    print('Top padding: $topPadding');
    print('Bottom padding: $bottomPadding');
    print('Image aspect ratio: $imageAspectRatio');
    print('Screen aspect ratio: $screenAspectRatio');
    print('Image scale: $imageScale');
    print('Horizontal offset (dx): $dx');
    print('Vertical offset (dy): $dy');

    return Offset(correctedX, correctedY);
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

    // Calculate the scale to fit the image within the available size, keeping the aspect ratio
    final imageAspectRatio = contractImage.width / contractImage.height;
    final screenAspectRatio = size.width / size.height;

    double imageScale;
    double dx = 0, dy = 0;

    if (screenAspectRatio > imageAspectRatio) {
      // Screen is wider than the image
      imageScale = size.height / contractImage.height;
      dx = (size.width - contractImage.width * imageScale) /
          2; // Center the image horizontally
    } else {
      // Screen is narrower or matches the image's aspect ratio
      imageScale = size.width / contractImage.width;
      dy = (size.height - contractImage.height * imageScale) /
          2; // Center the image vertically
    }

    final scaledWidth = contractImage.width * imageScale;
    final scaledHeight = contractImage.height * imageScale;

    // Draw contract image, centered within the available space
    canvas.drawImageRect(
      contractImage,
      Rect.fromLTWH(0, 0, contractImage.width.toDouble(),
          contractImage.height.toDouble()),
      Rect.fromLTWH(dx, dy, scaledWidth, scaledHeight),
      paint,
    );
    // print('Contract Image Rect: (${dx}, ${dy}, ${dx + scaledWidth}, ${dy + scaledHeight})');

    // Draw combined image if available, centered within the available space
    if (combinedImage != null) {
      canvas.drawImageRect(
        combinedImage!,
        Rect.fromLTWH(0, 0, combinedImage!.width.toDouble(),
            combinedImage!.height.toDouble()),
        Rect.fromLTWH(dx, dy, scaledWidth, scaledHeight),
        paint,
      );
    }

    // Prepare text style
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 10,
      fontWeight: FontWeight.bold,
      backgroundColor: Colors.white,
    );

    // Get today's date as a string
    // final todayDate = DateTime.now().toLocal().toString().split(' ')[0];

    // Draw predefined areas with overlay images
    for (var area in predefinedAreas) {
      final scaledRect = Rect.fromLTWH(
        dx + area.rect.left * imageScale,
        dy + area.rect.top * imageScale,
        area.rect.width * imageScale,
        area.rect.height * imageScale,
      );

      if (area.name == 'carModel') {
        // Assuming scaledRect is defined and calculated somewhere in your code
        print(scaledRect);
      }

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

      // if (['topDate', 'contractDate'].contains(area.name)) {
      //   // Prepare text for drawing with today's date
      //   final textSpan = TextSpan(
      //     text: todayDate,
      //     style: textStyle,
      //   );
      //   final textPainter = TextPainter(
      //     text: textSpan,
      //     textAlign: TextAlign.center,
      //     textDirection: TextDirection.ltr,
      //   );
      //
      //   // Layout the text within the bounds of the scaledRect
      //   textPainter.layout(maxWidth: scaledRect.width);
      //
      //   // Calculate position within the scaledRect
      //   final offset = Offset(
      //     scaledRect.left + (scaledRect.width - textPainter.width) / 2,
      //     scaledRect.top + (scaledRect.height - textPainter.height) / 2,
      //   );
      //
      //   // Draw text
      //   textPainter.paint(canvas, offset);
      // }
    }

    // Draw selected area
    if (selectedArea != null) {
      final scaledSelectedRect = Rect.fromLTWH(
        dx + selectedArea!.rect.left * imageScale,
        dy + selectedArea!.rect.top * imageScale,
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

class OverlayPainter extends CustomPainter {
  final ui.Image contractImage;
  final List<CustomRect> predefinedAreas;
  final Function(ui.Image)? onSave;

  OverlayPainter(
    this.contractImage,
    this.predefinedAreas, {
    this.onSave,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;
    final imageScale = size.width / contractImage.width;
    final scaledHeight = contractImage.height * imageScale;
    final centeredTop = (size.height - scaledHeight) / 2;

    // Draw the contract image
    canvas.drawImageRect(
      contractImage,
      Rect.fromLTWH(0, 0, contractImage.width.toDouble(),
          contractImage.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, scaledHeight),
      paint,
    );

    // Draw overlay images within their predefined areas
    for (var area in predefinedAreas) {
      if (area.overlayImage != null) {
        final scaledRect = Rect.fromLTWH(
          area.rect.left * imageScale,
          area.rect.top * imageScale,
          area.rect.width * imageScale,
          area.rect.height * imageScale,
        );

        // Define the source rectangle from the overlay image
        final srcRect = Rect.fromLTWH(
          0,
          0,
          area.overlayImage!.width.toDouble(),
          area.overlayImage!.height.toDouble(),
        );

        // Draw the overlay image within the area
        canvas.drawImageRect(
          area.overlayImage!,
          srcRect,
          scaledRect,
          paint,
        );
      }
    }
  }

  Future<void> saveCanvasAsImage(Size size) async {
    final recorder = ui.PictureRecorder();
    final tempCanvas =
        Canvas(recorder, Rect.fromLTWH(0, 0, size.width, size.height));

    // Re-draw everything onto the temp canvas
    paint(tempCanvas, size);

    // Create an image from the canvas
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());

    // Convert the image to PNG byte data
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    // Save the image to local storage
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/contract_image_output.png';
    final file = File(filePath);
    await file.writeAsBytes(pngBytes);

    // Share the image file
    _shareImageFile(filePath);
  }

  Future<void> _shareImageFile(String filePath) async {
    if (File(filePath).existsSync()) {
      Share.shareFiles([filePath], text: 'Here is the image file');
    } else {
      print('File does not exist at path: $filePath');
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Check if the current state differs from the old state
    if (oldDelegate is OverlayPainter) {
      return contractImage != oldDelegate.contractImage ||
          predefinedAreas != oldDelegate.predefinedAreas;
    }
    return true; // Repaint if the old delegate is not an instance of OverlayPainter
  }
}

//   Future<void> saveCanvasAsImage(Size size) async {
//     final recorder = ui.PictureRecorder();
//     final tempCanvas = Canvas(recorder, Rect.fromLTWH(0, 0, size.width, size.height));
//
//     // Re-draw everything onto the temp canvas
//     paint(tempCanvas, size);
//
//     // Create an image from the canvas
//     final picture = recorder.endRecording();
//     final img = await picture.toImage(size.width.toInt(), size.height.toInt());
//
//     // Optionally, call a callback if provided
//     if (onSave != null) {
//       onSave!(img);
//     }
//
//     // Save the image as a PNG file
//     await _saveImageAsPng(img);
//   }
//
//   Future<void> _saveImageAsPng(ui.Image image) async {
//     // Convert the image to a byte array (PNG format)
//     final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//     final pngBytes = byteData!.buffer.asUint8List();
//
//     // Get the path to save the image
//     final directory = await getApplicationDocumentsDirectory();
//     final path = '${directory.path}/contract_with_overlay.png';
//
//     // Save the image to the file
//     final file = File(path);
//     await file.writeAsBytes(pngBytes);
//
//     print('Image saved to $path');
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }
