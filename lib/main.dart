import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          titleSpacing: 0.0, // 텍스트의 좌우 여백을 없앰
          title: const Padding(
            padding: EdgeInsets.only(left: 16.0), // 왼쪽에 16의 여백 추가
            child: Align(
              alignment: Alignment.centerLeft, // 텍스트를 왼쪽 정렬
              child: Text(
                'DY 급식',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 30,
                ),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // 회색 배경
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // 모서리 둥글게
                  ),
                ),
                child: const Text(
                  '날짜 선택',
                  style: TextStyle(
                    color: Colors.black, // 검은색 텍스트
                    fontSize: 16, // 적절한 폰트 크기
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(30.60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.stratch,
            children: [
              Container(
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('급식 보기',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left),
                    Text('9월 10일 급식',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.left),
                    Text('500 kcal',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.right),
                  ],
                ),
              ),
              Container(
                height: 400,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 127, 127, 127),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Container() //하단 바 만들기
            ],
          ),
        ),
      ),
    );
  }
}
