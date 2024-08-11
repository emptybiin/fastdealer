import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';


class ExcelEditScreen extends StatefulWidget {
  final String reportType; // 매입 또는 판매를 나타내는 변수

  ExcelEditScreen({required this.reportType});

  @override
  _ExcelEditScreenState createState() => _ExcelEditScreenState();
}

class _ExcelEditScreenState extends State<ExcelEditScreen> {
  final List<TextEditingController> _controllers = List.generate(21, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(21, (_) => FocusNode());
  File? _excelFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _generateJson() async {
    final Map<String, dynamic> data = {
      'type': widget.reportType,
    };
    for (int i = 0; i < _controllers.length; i++) {
      final key = _getLabelText(i);
      data[key] = _controllers[i].text;
    }

    final jsonString = jsonEncode({'body': data});
    print(jsonString);

    // URL-encode the JSON string
    final encodedJson = Uri.encodeComponent(jsonString);

    // Construct the full URL with query string
    final url = 'https://9lplmto9of.execute-api.ap-northeast-2.amazonaws.com/default/fastdeal?body=$encodedJson';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final encodedFileContent = responseData['file_content'];
        final fileName = responseData['file_name'];
        print('Success: File received');

        // Decode the file content
        final fileBytes = base64.decode(encodedFileContent);

        // Get the directory for saving the file
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';

        // Save the file
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);

        print('File saved to $filePath');

        // Store the file for sharing
        _excelFile = file;
        _shareExcelFile();
      } else {
        print('Failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _shareExcelFile() async {
    if (_excelFile != null) {
      Share.shareFiles([_excelFile!.path], text: 'Updated Excel file');
    } else {
      print('No file to share');
    }
  }









  void _onFieldSubmitted(int index) {
    if (index == 5) {
      _selectDate(context, _controllers[6], 6); // 차량매매가 입력 후 최종납입 날짜 캘린더를 자동으로 띄움
    } else if (index < 16 && index != 6) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller, int currentIndex) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        controller.text = "${pickedDate.toLocal()}".split(' ')[0];
        FocusScope.of(context).requestFocus(_focusNodes[currentIndex + 1]); // 최종납입 날짜 선택 후 미회수원금으로 이동
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.reportType} 보고서'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            for (int i = 0; i < _controllers.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  decoration: InputDecoration(
                    labelText: _getLabelText(i),
                  ),
                  keyboardType: _getKeyboardType(i),
                  textInputAction: i < 17 ? TextInputAction.next : TextInputAction.done,
                  onSubmitted: (value) => _onFieldSubmitted(i),
                  onTap: () {
                    if (i == 6) {
                      _selectDate(context, _controllers[i], i);
                    }
                  },
                  readOnly: i == 6,
                ),
              ),
            ElevatedButton(
              onPressed: _generateJson,
              child: Text('내보내기'),
            ),
          ],
        ),
      ),
    );
  }

  String _getLabelText(int index) {
    switch (index) {
      case 0:
        return '고객명';
      case 1:
        return '차량명';
      case 2:
        return '리스사명';
      case 3:
        return '실행횟수';
      case 4:
        return '납입횟수';
      case 5:
        return '차량매매가';
      case 6:
        return '최종납입 날짜';
      case 7:
        return '미회수원금';
      case 8:
        return '보증금';
      case 9:
        return '선납금';
      case 10:
        return '잔존가치';
      case 11:
        return '리스료';
      case 12:
        return '일할차세';
      case 13:
        return '일할이자';
      case 14:
        return '승계수수료';
      case 15:
        return '판매수수료';
      case 16:
        return '기타비용';
      case 17:
        return '추가 입력 1';
      case 18:
        return '추가 입력 1 내용';
      case 19:
        return '추가 입력 2';
      case 20:
        return '추가 입력 2 내용';
      default:
        return '필드 ${index + 1}의 값을 입력하세요';
    }
  }

  TextInputType _getKeyboardType(int index) {
    if (index == 6) {
      return TextInputType.datetime;
    } else if ([3, 4, 5, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 18, 20].contains(index)) {
      return TextInputType.number;
    }
    return TextInputType.text;
  }
}

