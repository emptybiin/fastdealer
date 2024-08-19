import 'package:flutter/material.dart';

class FieldInfo {
  final String labelText;
  final RegExp validationPattern;
  final String errorMessage;

  FieldInfo({
    required this.labelText,
    required this.validationPattern,
    required this.errorMessage,
  });
}

FieldInfo getFieldInfo(int index) {
  switch (index) {
    case 0:
      return FieldInfo(
        labelText: '고객명',
        validationPattern: RegExp(r'^[a-zA-Z가-힣\s]+$'),
        errorMessage: '한글 또는 영어',
      );
    case 1:
      return FieldInfo(
        labelText: '차량명',
        validationPattern: RegExp(r'^[a-zA-Z0-9\s]+$'),
        errorMessage: 'Invalid input for 차량명',
      );
    case 2:
      return FieldInfo(
        labelText: '리스사명',
        validationPattern: RegExp(r'^[a-zA-Z가-힣\s]+$'),
        errorMessage: 'Invalid input for 리스사명',
      );
    case 3:
    case 4:
    case 5:
    case 7:
    case 8:
    case 9:
    case 10:
    case 11:
    case 12:
    case 13:
    case 14:
    case 15:
    case 16:
      return FieldInfo(
        labelText: getLabelText(index),
        validationPattern: RegExp(r'^\d+$'),
        errorMessage: '${getLabelText(index)}는 숫자만 입력가능합니다.',
      );
    case 6:
      return FieldInfo(
        labelText: '최종납입 날짜',
        validationPattern: RegExp(r'^(0?[1-9]|1[0-2])[-./](0?[1-9]|[12][0-9]|3[01])$'),
        errorMessage: '2024-08-15 -> 8.15 입력',
      );
    case 17:
      return FieldInfo(
        labelText: '추가 입력 1',
        validationPattern: RegExp(r'.*'),
        errorMessage: 'Invalid input for 추가 입력 1',
      );
    case 18:
      return FieldInfo(
        labelText: '추가 입력 1 내용',
        validationPattern: RegExp(r'.*'),
        errorMessage: 'Invalid input for 추가 입력 1 내용',
      );
    case 19:
      return FieldInfo(
        labelText: '추가 입력 2',
        validationPattern: RegExp(r'.*'),
        errorMessage: 'Invalid input for 추가 입력 2',
      );
    case 20:
      return FieldInfo(
        labelText: '추가 입력 2 내용',
        validationPattern: RegExp(r'.*'),
        errorMessage: 'Invalid input for 추가 입력 2 내용',
      );
    default:
      return FieldInfo(
        labelText: '필드 ${index + 1}',
        validationPattern: RegExp(r'.*'),
        errorMessage: 'Invalid input for 필드 ${index + 1}',
      );
  }
}

String getLabelText(int index) {
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
      return '추가 입력 1 제목';
    case 18:
      return '추가 입력 1 내용';
    case 19:
      return '추가 입력 2 제목';
    case 20:
      return '추가 입력 2 내용';
    default:
      return '필드 ${index + 1}의 값을 입력하세요';
  }
}

// Validate input function
bool validateInput(int index, String value) {
  // Allow empty values to be valid
  if (value.isEmpty) {
    return true;
  }

  final fieldInfo = getFieldInfo(index);
  final pattern = fieldInfo.validationPattern;
  final isValid = pattern.hasMatch(value);

  return isValid;
}


TextInputType getKeyboardType(int index) {
  if ([3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 18, 20].contains(index)) {
    return TextInputType.number;
  }
  return TextInputType.text;
}

String getExampleValue(int index) {
  switch (index) {
    case 0:
      return '홍길동'; // Example for customer name
    case 1:
      return '차량명'; // Example for car model
    case 2:
      return '리스사명'; // Example for leasing company
    case 3:
      return '100(회)'; // Example for execution count
    case 4:
      return '99(회) 실행 횟수 보다 큰 값을 넣으면 에러'; // Example for payment count
    case 5:
      return '50000'; // Example for car price
    case 6:
      return '8.15 (월.일 형식)'; // Example for final payment date (MM.DD)
    case 7:
      return '10000'; // Example for unreturned principal
    case 8:
      return '20000'; // Example for deposit
    case 9:
      return '15000'; // Example for advance payment
    case 10:
      return '30000'; // Example for residual value
    case 11:
      return '5000'; // Example for lease fee
    case 12:
      return '1000'; // Example for daily tax
    case 13:
      return '2000'; // Example for daily interest
    case 14:
      return '250'; // Example for transfer fee
    case 15:
      return '300'; // Example for sales commission
    case 16:
      return '150'; // Example for other costs
    case 17:
      return 'Additional Info 1'; // Example for additional input 1
    case 18:
      return 'Details for Additional Info 1'; // Example for additional input 1 details
    case 19:
      return 'Additional Info 2'; // Example for additional input 2
    case 20:
      return 'Details for Additional Info 2'; // Example for additional input 2 details
    default:
      return 'Example Value'; // Default placeholder
  }
}
