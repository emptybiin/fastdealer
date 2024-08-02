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

class ContractFeatureDebug extends StatefulWidget {
  @override
  _ContractFeatureDebugState createState() => _ContractFeatureDebugState();
}

class _ContractFeatureDebugState extends State<ContractFeatureDebug> {
  // 서명 패드의 컨트롤러 설정
  SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  ui.Image? contractImage; // 계약서 이미지 저장 변수
  bool isImageLoaded = false; // 이미지 로딩 상태
  bool isSignatureMode = false; // 서명 모드 여부
  bool isTextInputMode = false; // 텍스트 입력 모드 여부
  String selectedCell = ''; // 선택된 셀 위치
  Rect? selectedArea; // 선택된 영역
  TextEditingController textEditingController =
  TextEditingController(); // 텍스트 입력 컨트롤러
  List<Map<String, dynamic>> predefinedAreas = []; // 미리 정의된 영역 리스트

  @override
  void initState() {
    super.initState();
    // 에셋 파일을 로컬 디렉토리로 복사
    copyAssetFileToLocalDir('assets/contract.xlsx', 'contract.xlsx');
    loadContractImage(); // 계약서 이미지 로드
  }

  // 로컬 파일 경로 가져오기
  Future<String> getFilePath(String fileName) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    return '$path/$fileName';
  }

  // 에셋 파일을 로컬 디렉토리로 복사
  Future<void> copyAssetFileToLocalDir(String assetPath,
      String localFileName) async {
    ByteData data = await rootBundle.load(assetPath);
    List<int> bytes = data.buffer.asUint8List();
    String localPath = await getFilePath(localFileName);
    File localFile = File(localPath);
    await localFile.writeAsBytes(bytes);
  }

  // 계약서 이미지 로드
  Future<void> loadContractImage() async {
    ByteData data = await rootBundle.load('assets/contract_image.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    setState(() {
      contractImage = frame.image;
      isImageLoaded = true;
      // Set predefinedAreas with the list of maps
      predefinedAreas = _calculatePredefinedAreas(
          contractImage!.width.toDouble(), contractImage!.height.toDouble());
    });
  }

// 계약서 이미지의 크기에 따라 미리 정의된 영역 계산
  List<Map<String, dynamic>> _calculatePredefinedAreas(double imageWidth,
      double imageHeight) {
    return [
      {
        'rect': Rect.fromLTWH(
            imageWidth * 0.6, imageHeight * 0.12, imageWidth * 0.1,
            imageHeight * 0.023),
        'cell': 'H5'
      }, // 양도인 이름
      {
        'rect': Rect.fromLTWH(
            imageWidth * 0.6, imageHeight * 0.143, imageWidth * 0.1,
            imageHeight * 0.023),
        'cell': 'H6'
      }, // 양수인 이름
      {
        'rect': Rect.fromLTWH(
            imageWidth * 0.85, imageHeight * 0.115, imageWidth * 0.15,
            imageHeight * 0.023),
        'cell': 'K5'
      }, // 양도인 서명
      {
        'rect': Rect.fromLTWH(
            imageWidth * 0.85, imageHeight * 0.138, imageWidth * 0.15,
            imageHeight * 0.023),
        'cell': 'K6'
      }, // 양수인 서명
      {
        'rect': Rect.fromLTWH(
            imageWidth * 0.125, imageHeight * 0.196, imageWidth * 0.311,
            imageHeight * 0.023),
        'cell': 'C9'
      }, // 자동차등록번호
      {
        'rect': Rect.fromLTWH(
            imageWidth * 0.545, imageHeight * 0.196, imageWidth * 0.452,
            imageHeight * 0.023),
        'cell': 'G9'
      }, // 매매금액
      {
        'rect': Rect.fromLTWH(
            imageWidth * 0.125, imageHeight * 0.221, imageWidth * 0.16,
            imageHeight * 0.023),
        'cell': 'C10'
      }, // 차종
      {
        'rect': Rect.fromLTWH(
            imageWidth * 0.125, imageHeight * 0.244, imageWidth * 0.311,
            imageHeight * 0.023),
        'cell': 'G10-K10'
      }, // 차명
      {
        'rect': Rect.fromLTWH(
            imageWidth * 0.125, imageHeight * 0.267, imageWidth * 0.311,
            imageHeight * 0.023),
        'cell': 'C12'
      }, // 차대번호
      {
        'rect': Rect.fromLTWH(
            imageWidth * 0.125, imageHeight * 0.290, imageWidth * 0.311,
            imageHeight * 0.023),
        'cell': 'C13'
      }, // 등록비용
      {
        'rect': Rect.fromLTWH(
            imageWidth * 0.545, imageHeight * 0.221, imageWidth * 0.452,
            imageHeight * 0.023),
        'cell': 'G10-K10'
      }, // 리스승계
      {
        'rect': Rect.fromLTWH(
            imageWidth * 0.545, imageHeight * 0.244, imageWidth * 0.452,
            imageHeight * 0.023),
        'cell': 'G11-K11'
      }, // 인도금
      {
        'rect': Rect.fromLTWH(
            imageWidth * 0.545, imageHeight * 0.267, imageWidth * 0.452,
            imageHeight * 0.023),
        'cell': 'G12-K12'
      }, // 잔금
      {
        'rect': Rect.fromLTWH(
            imageWidth * 0.545, imageHeight * 0.290, imageWidth * 0.452,
            imageHeight * 0.023),
        'cell': 'G13'
      }, // 비고
      {
        'rect': Rect.fromLTWH(
            imageWidth * 0.285, imageHeight * 0.132, imageWidth * 0.2,
            imageHeight * 0.023),
        'cell': 'A5'
      }, // 상단 날짜
      {
        'rect': Rect.fromLTWH(
            imageWidth * 0.282, imageHeight * 0.770, imageWidth * 0.72,
            imageHeight * 0.023),
        'cell': 'A5'
      }, // 계약년월일
      {
        'rect': Rect.fromLTWH(
            imageWidth * 0.282, imageHeight * 0.794, imageWidth * 0.482,
            imageHeight * 0.023),
        'cell': 'D43'
      }, // 양도인 성명
      {
        'rect': Rect.fromLTWH(
            imageWidth * 0.764, imageHeight * 0.794, imageWidth * 0.238,
            imageHeight * 0.023),
        'cell': 'J43'
      }, // 양도인 서명 또는 날인
      {
        'rect': Rect.fromLTWH(
            imageWidth * 0.282, imageHeight * 0.818, imageWidth * 0.482,
            imageHeight * 0.023),
        'cell': 'D44'
      }, // 양도인 주민등록(사업자)번호
      {
        'rect': Rect.fromLTWH(
            imageWidth * 0.282, imageHeight * 0.843, imageWidth * 0.482,
            imageHeight * 0.023),
        'cell': 'D45'
      }, // 양도인 주소및전화번호
      {
        'rect': Rect.fromLTWH(
            imageWidth * 0.282, imageHeight * 0.867, imageWidth * 0.482,
            imageHeight * 0.023),
        'cell': 'D46'
      }, // 양수인 성명
      {
        'rect': Rect.fromLTWH(
            imageWidth * 0.764, imageHeight * 0.867, imageWidth * 0.238,
            imageHeight * 0.023),
        'cell': 'J46'
      }, // 양수인 서명 또는 날인
      {
        'rect': Rect.fromLTWH(
            imageWidth * 0.282, imageHeight * 0.892, imageWidth * 0.482,
            imageHeight * 0.023),
        'cell': 'D47'
      }, // 양수인 주민등록(사업자)번호
      {
        'rect': Rect.fromLTWH(
            imageWidth * 0.282, imageHeight * 0.916, imageWidth * 0.482,
            imageHeight * 0.023),
        'cell': 'D48'
      }, // 양수인 주소및전화번호
    ];
  }


  // 서명을 엑셀 파일에 저장하는 함수
  Future<void> saveSignatureToExcel(String cellPosition) async {
    var signature = await _controller.toPngBytes(); // 서명 이미지를 PNG 바이트 배열로 변환
    if (signature != null) {
      String localPath = await getFilePath('contract.xlsx'); // 로컬 엑셀 파일 경로 가져오기
      var bytes = File(localPath).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      // 서명 이미지를 파일 시스템에 저장
      String signaturePath = await getFilePath('signature.png');
      File(signaturePath).writeAsBytesSync(signature);

      var sheet = excel['Sheet1'];
      var cell = sheet.cell(CellIndex.indexByString(cellPosition));
      cell.value = 'Signature' as CellValue?; // 셀에 서명 텍스트 추가

      // TODO: 라이브러리가 지원하면 엑셀 파일에 이미지를 삽입하기

      var updatedBytes = excel.encode();
      File(localPath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(updatedBytes!);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Signature Saved to Excel!')));
    }
  }

  // 텍스트를 엑셀 파일에 저장하는 함수
  Future<void> saveTextToExcel(String text, String cellPosition) async {
    String localPath = await getFilePath('contract.xlsx');
    var bytes = File(localPath).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    var sheet = excel['Sheet1'];
    sheet.updateCell(CellIndex.indexByString(cellPosition), text as CellValue?);

    var updatedBytes = excel.encode();
    File(localPath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(updatedBytes!);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Text Saved to Excel!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('계약서 서명 기능'),
      ),
      body: Column(
        children: [
          if (isImageLoaded)
            Expanded(
              child: GestureDetector(
                onTapDown: (details) {
                  final imageScale = MediaQuery
                      .of(context)
                      .size
                      .width / contractImage!.width;
                  final scaledHeight = contractImage!.height * imageScale;
                  final imageTopOffset = (MediaQuery
                      .of(context)
                      .size
                      .height - scaledHeight-155) / 2;

                  final touchPosition = Offset(
                    details.localPosition.dx / imageScale,
                    (details.localPosition.dy - imageTopOffset) / imageScale,
                  );

                  final tappedArea = predefinedAreas.firstWhere(
                        (area) =>
                        (area['rect'] as Rect).contains(touchPosition),
                  );

                  if (tappedArea != null) {
                    setState(() {
                      selectedCell = tappedArea['cell'] as String;
                      selectedArea = tappedArea['rect'] as Rect;
                      isSignatureMode = false;
                      isTextInputMode = false;
                    });
                  }
                },
                child: CustomPaint(
                  size: Size(double.infinity, double.infinity),
                  painter: ContractPainter(
                      contractImage!,
                      predefinedAreas,
                      selectedArea),
                ),
              ),
            ),
          if (isSignatureMode)
            Expanded(
              child: Signature(
                controller: _controller,
                backgroundColor: Colors.lightBlueAccent,
              ),
            ),
          if (isTextInputMode)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: textEditingController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '텍스트를 입력하세요',
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isSignatureMode = true;
                      isTextInputMode = false;
                    });
                  },
                  child: Text('서명'),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isTextInputMode = true;
                      isSignatureMode = false;
                    });
                  },
                  child: Text('텍스트 입력'),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedCell.isNotEmpty) {
                      if (isSignatureMode) {
                        saveSignatureToExcel(selectedCell); // 서명 저장
                      } else if (isTextInputMode) {
                        saveTextToExcel(
                            textEditingController.text, selectedCell); // 텍스트 저장
                      }
                    } else {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('셀을 선택하세요.')));
                    }
                  },
                  child: Text('저장'),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    String localPath = await getFilePath('contract.xlsx');
                    String newFilePath = await getFilePath('new_contract.xlsx');
                    File localFile = File(localPath);
                    File newFile = File(newFilePath);
                    await newFile.writeAsBytes(await localFile.readAsBytes());
                    Share.shareFiles([newFilePath], text: '새로운 계약서 엑셀 파일');
                  },
                  child: Text('내보내기'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class ContractPainter extends CustomPainter {
  final ui.Image contractImage;
  final List<Map<String, dynamic>> predefinedAreas;
  final Rect? selectedArea;

  ContractPainter(this.contractImage, this.predefinedAreas, this.selectedArea);

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
      Rect.fromLTWH(0, centeredTop, size.width, scaledHeight),
      paint,
    );

    // Draw predefined areas
    for (var areaMap in predefinedAreas) {
      final area = areaMap['rect'] as Rect; // Extract the Rect from the map
      final scaledRect = Rect.fromLTWH(
        area.left * imageScale,
        centeredTop + area.top * imageScale,
        area.width * imageScale,
        area.height * imageScale,
      );
      final rectPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(scaledRect, rectPaint);
    }

    // Draw the selected area
    if (selectedArea != null) {
      final scaledSelectedRect = Rect.fromLTWH(
        selectedArea!.left * imageScale,
        centeredTop + selectedArea!.top * imageScale,
        selectedArea!.width * imageScale,
        selectedArea!.height * imageScale,
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