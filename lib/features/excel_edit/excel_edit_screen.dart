import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'fieldInfo.dart'; // Make sure this import matches your file structure
import 'package:flutter/services.dart';


class ExcelEditScreen extends StatefulWidget {
  final String reportType;

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

  void _generateJson({required bool isPreview, required BuildContext context}) async {
    final Map<String, dynamic> data = {'type': widget.reportType};
    for (int i = 0; i < _controllers.length; i++) {
      final key = getLabelText(i);
      data[key] = _controllers[i].text.replaceAll(',', ''); // Remove commas for raw data
    }

    final jsonString = jsonEncode({'body': data});
    print(jsonString);

    String customerName = data['고객명'];
    String todayDate = DateFormat('yyyyMMdd').format(DateTime.now());
    String type = data['type'];
    String fileName = '${customerName}_${todayDate}_${type}.xlsx';

    final encodedJson = Uri.encodeComponent(jsonString);
    final url = 'https://9lplmto9of.execute-api.ap-northeast-2.amazonaws.com/default/fastdeal?body=$encodedJson';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final encodedFileContent = responseData['file_content'];
        print('Success: File received');

        final fileBytes = base64.decode(encodedFileContent);
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';

        final file = File(filePath);
        await file.writeAsBytes(fileBytes);

        print('File saved to $filePath');

        _excelFile = file;

        if (isPreview) {
          _openExcelFile(context);
        } else {
          _shareExcelFile();
        }
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

  Future<void> _openExcelFile(BuildContext context) async {
    _requestPermissions();
    try {
      if (_excelFile != null) {
        final result = await OpenFile.open(_excelFile!.path);
        if (result.type != ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to open file: ${result.message}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File opened successfully')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No file to open')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: $e')),
      );
    }
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      final result = await Permission.storage.request();
      if (result.isDenied) {
        print('Storage permission denied');
        return;
      }
      if (result.isPermanentlyDenied) {
        print('Storage permission permanently denied');
        await openAppSettings();
        return;
      }
    }
    print('Storage permission granted');
  }

  void _onFieldSubmitted(int index, String value) {
    bool isValid = validateInput(index, value);
    if (isValid) {
      if (index < _controllers.length - 1) {
        if (index < 16) {
          // Move to the next focus node if index is 16 or less
          FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
        } else {
          // Remove focus if index is greater than 16
          FocusScope.of(context).unfocus();
        }
      } else {
        FocusScope.of(context).unfocus();
      }
    } else {
      _showErrorSnackBar(context, index);
    }
  }

  final Set<int> _commaFormattingIndices = {5, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};

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
                    labelText: getFieldInfo(i).labelText,
                    hintText: getExampleValue(i),
                    errorText: validateInput(i, _controllers[i].text) ? null : getFieldInfo(i).errorMessage,
                  ),
                  keyboardType: getKeyboardType(i),
                  textInputAction: i < 16 ? TextInputAction.next : TextInputAction.done,
                  inputFormatters: [
                    if (_commaFormattingIndices.contains(i)) // Apply only to specified indices
                      FilteringTextInputFormatter.digitsOnly,
                  ],
                  onSubmitted: (value) {
                    _onFieldSubmitted(i, value);
                  },
                  onChanged: (value) {
                    if (_commaFormattingIndices.contains(i)) {
                      // Remove commas for raw value
                      final rawValue = value.replaceAll(',', '');
                      _controllers[i].text = rawValue;
                      _controllers[i].selection = TextSelection.collapsed(offset: rawValue.length);
                    }
                    setState(() {});
                  },
                  onEditingComplete: () {
                    if (_commaFormattingIndices.contains(i)) {
                      // Format the value when editing is complete
                      final rawValue = _controllers[i].text.replaceAll(',', '');
                      final formattedValue = formatWithCommas(rawValue);
                      _controllers[i].text = formattedValue;
                      _controllers[i].selection = TextSelection.collapsed(offset: formattedValue.length);
                    }
                  },
                ),
              ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _generateJson(isPreview: true, context: context),
                  child: Text('Preview'),
                ),
                ElevatedButton(
                  onPressed: () => _generateJson(isPreview: false, context: context),
                  child: Text('Export'),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceAround,
            )
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, int index) {
    final snackBar = SnackBar(
      content: Text(getFieldInfo(index).errorMessage),
      duration: Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    FocusScope.of(context).requestFocus(_focusNodes[index]);
  }
}
// 5 7 8 9 10 11 12 13 14 15 16

String formatWithCommas(String value) {
  if (value.isEmpty) return value;

  final number = int.tryParse(value);
  if (number == null) return value;

  final formatter = NumberFormat('#,###', 'en_US');
  return formatter.format(number);
}