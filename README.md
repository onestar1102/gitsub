# 안드로이드 스튜디오 1주차 <br> + 프로젝트
## 안드로이드 스튜디오 flutter로 Hello world 실행하기 순서<br>
1. 안드로이드 스튜디오 설치 
- 안드로이드 스튜디오와 Flutter 플러그인, SDK를 설치<br>
2. Hello world 실행하기
- 안드로이드 스튜디오로 Flutter를 이용해 Hello_world 프로젝트를 새로 만든 후 실행할 웹 디바이스를 선택하여 Hello_world를 실행한다.

### 결과
성공적으로 실행했으며 관련된 사진은 github에 첨부
--------------------------------------------------------------------
# 안드로이드 스튜디오 2주차<br>
## 실습 : 구구단 출력, 사각형 출력, 요일 출력

1. 구구단 출력하기
  ```ruby void main(){
  for(int i = 2; i <= 9; i++){
    for(int j = 1; j <= 9; j++){
      print("$i * $j = ${i * j}");
    }
    print(" ");
    }
  }
```
2. 정사각형의 길이를 입력하여 사각형 출력하기
  - 빈 사각형
```ruby var result = '';
void main() {
  var n = 10;

  for (var y = 0; y < n; y++) {
    for (var x = 0; x < n; x++) {
      var c = pattern1(n, x, y);
      if (c) {
        result += '=';
      } else {
        result += ' ';
      }
    }
    result += '\n';
  }
  print(result);
}

bool pattern1(int n, int x, int y) {
  var condition = y == 0;
  condition |= y == (n - 1);
  condition |= x == 0;
  condition |= x == (n - 1);
  return condition;
}
```
- 꽉 찬 사각형
```ruby var result = '';
void main() {
  var n = 10;

  for (var y = 0; y < n; y++) {
    for (var x = 0; x < n; x++) {
      var c = pattern1(n, x, y);
      if (c) {
        result += '=';
      } else {
        result += ' ';
      }
    }
    result += '\n';
  }
  print(result);
}

bool pattern1(int n, int x, int y) {
  return true;
}
```
- \모양 사각형
```ruby var result = '';
void main() {
  var n = 10;

  for (var y = 0; y < n; y++) {
    for (var x = 0; x < n; x++) {
      var c = pattern1(n, x, y);
      if (c) {
        result += '=';
      } else {
        result += ' ';
      }
    }
    result += '\n';
  }
  print(result);
}

bool pattern1(int n, int x, int y) {
  var condition = y == 0;
  condition |= y == (n - 1);
  condition |= x == 0;
  condition |= x == (n - 1);
  condition |= (x + y) == (n - 1);
  return condition;
}
```
- /모양 사각형
```ruby var result = '';
void main() {
  var n = 10;

  for (var y = 0; y < n; y++) {
    for (var x = 0; x < n; x++) {
      var c = pattern1(n, x, y);
      if (c) {
        result += '=';
      } else {
        result += ' ';
      }
    }
    result += '\n';
  }
  print(result);
}

bool pattern1(int n, int x, int y) {
  var condition = y == 0;
  condition |= y == (n - 1);
  condition |= x == 0;
  condition |= x == (n - 1);
  condition |= x == y;
  return condition;
}
```
- x모양 사각형
```ruby var result = '';
void main() {
  var n = 10;

  for (var y = 0; y < n; y++) {
    for (var x = 0; x < n; x++) {
      var c = pattern1(n, x, y);
      if (c) {
        result += '=';
      } else {
        result += ' ';
      }
    }
    result += '\n';
  }
  print(result);
}

bool pattern1(int n, int x, int y) {
  var condition = y == 0;
  condition |= y == (n - 1);
  condition |= x == 0;
  condition |= x == (n - 1);
  condition |= x == y;
  condition |= (x + y) == (n - 1);
  return condition;
}
```
3. 년/월/일 입력하고 요일 출력하기
```ruby void main() {
  var input = '2025-03-11';

  DateTime date = DateTime.parse(input);

  List<String> week = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];

  String day = week[date.weekday - 1];

  print(day);
}
```
### 위 내용의 이해를 위해 챗gpt사용함
>> DateTime date= DateTime.parse(input)을 이용해 input값의 날짜와 시간을 객체로 반환 <br>
>> List를 이용하여 문자열로 요일 생성 <br> 
>> List 안의 값은 숫자열로 값을 찾을 수 있기 때문에 0~6으로 저장돼있는것과 같음 ( 숫자열로 접근해야함 ) <br>
>> date.weekday변수로 요일을 숫자로 반환한다 이때 date.weekday는 1부터 시작하기때문에 숫자열(index)와 숫자열을 맞춰야한다 <br>
>> 그렇기에 -1로 date.weekday의 시작점을 0으로 바꾸어 7을 찾아 에러가 나지 않도록 설정해줌으로써 List안의 값을 정확하게 찾을 수 있게된다 <br>

# 안드로이드 스튜디오 3주차
## Dart 문법에 대해
1. 객체 지향 프로그래밍이란?<br>

   객체지향 프로그래밍은 모든것을 객체로 보고 그 객체들끼리 역할, 책임, 협력 등 그들의 관계를 중심으로 프로그래밍하는 기법
2. 클래스란?<br>

   객체를 생성하기 위한 일종의 설계도와 비슷함.
### 클래스의 구조
  - 필드(field)
> 클래스에 포함된 변수를 의미. 객체의 상태(state) 속성을 나타내며, 멤버변수라고도 함
  - 메서드(method)
> 해당 객체의 행위(동작)을 나타냄. 자바에는 모든 메서드가 클래스에 존재하기 떄문에 모든 함수는 메서드임.
3. 객체란
  클래스의 인스턴스나 배열을 말한다고 정의되고, 변수, 함수, 자료 구조의 조

# 4주차
## 과제 - 현재 시각을 표시하는 앱 만들기
 - 상단 앱바 타이틀은 "현재 시각" 이고 정 중앙에 현재 시각을 표시하기(초까지 표시할 것) 시간 갱신은 1초마다 갱신
   해당 코드
```ruby import 'dart:async'; // 타이머를 사용하기 위한 라이브러리
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 및 시간 형식을 위한 라이브러리

void main() {
  runApp(const MyApp()); // 앱 실행
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // 디버그 배너 숨김
      home: ClockScreen(),
    );
  }
}

class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});

  @override
  _ClockScreenState createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  late String _currentTime; // 현재 시간을 저장할 변수
  late Timer _timer; // 1초마다 갱신할 타이머

  @override
  void initState() {
    super.initState();
    _updateTime(); // 초기 시간 설정
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime()); // 1초마다 시간 갱신
  }

  void _updateTime() {
    setState(() {
      // 현재 날짜 및 시간을 "yyyy-MM-dd a hh:mm:ss" 형식으로 변환
      _currentTime = DateFormat('yyyy-MM-dd a hh:mm:ss').format(DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // 화면이 닫힐 때 타이머 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('현재 시각')), // 앱 상단바 제목
      body: Center(
        child: Text(
          _currentTime, // 현재 시각 출력
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}```

# 5주차
## 과제 - 계산기 화면 출력 및 사각형 도형만들기
1. 계산기 코드
```import 'package:flutter/material.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorUI(),
    );
  }
}

class CalculatorUI extends StatelessWidget {
  final List<String> buttons = [
    'AC', '±', '%', '÷',
    '7', '8', '9', '×',
    '4', '5', '6', '−',
    '1', '2', '3', '+',
    '0', '.', '=', 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Display Area
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.bottomRight,
                padding: EdgeInsets.all(24),
                child: Text(
                  '0',
                  style: TextStyle(color: Colors.white, fontSize: 48),
                ),
              ),
            ),

            // Button Grid
            Expanded(
              flex: 5,
              child: Container(
                padding: EdgeInsets.all(8),
                child: GridView.builder(
                  itemCount: buttons.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    return CalculatorButton(label: buttons[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CalculatorButton extends StatelessWidget {
  final String label;

  const CalculatorButton({required this.label});

  @override
  Widget build(BuildContext context) {
    final isOperator = ['÷', '×', '−', '+', '='].contains(label);

    return Container(
      decoration: BoxDecoration(
        color: isOperator ? Colors.blue : Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 24,
            color: isOperator ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }
}
```
2. 도형 채우기 코드
```import 'package:flutter/material.dart';

void main() {
  runApp(BlockLayoutApp());
}

class BlockLayoutApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  //
                  Expanded(
                    flex: 2,
                    child: Container(color: Colors.red),
                  ),
                  //
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        //
                        Expanded(
                          child: Container(color: Colors.blue),
                        ),
                        //
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(color: Colors.black),
                              ),
                              Expanded(
                                child: Container(color: Colors.orange),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            //
            Expanded(
              flex: 3,
              child: Container(color: Colors.yellow),
            ),
          ],
        ),
      ),
    );
  }
}
````````새싹심기222``


