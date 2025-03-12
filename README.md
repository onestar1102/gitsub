# 안드로이드 스튜디오 1주차 <br>
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
