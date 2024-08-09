import 'package:flutter/material.dart';
import 'features/contract_debug.dart';
import 'features/excel_edit_screen.dart';
import 'splash.dart'; // splash.dart 파일 경로 추가

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
      home: SplashScreen(), // 초기 화면을 스플래시 화면으로 설정
      // home: ContractFeatureDebug(), // 서명 칸 간격 디버깅용
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
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExcelEditScreen(reportType: '매입')), // '매입' 변수 전달
                );
              },
              child: Text('차량 매매 보고서 (매입)'),
            ),
            SizedBox(height: 20), // 버튼 간 간격
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExcelEditScreen(reportType: '판매')), // '판매' 변수 전달
                );
              },
              child: Text('차량 매매 보고서 (판매)'),
            ),
            SizedBox(height: 20), // 버튼 간 간격 추가
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ContractFeatureDebug()),
                );
              },
              child: Text('관인 계약서'),
            ),
          ],
        ),
      ),
    );
  }
}

