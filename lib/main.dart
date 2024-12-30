import 'package:dy_food_flutter/info_screen.dart';
import 'package:dy_food_flutter/home_screen.dart';
import 'package:dy_food_flutter/my_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  await initializeDateFormatting();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  /// [BottomNavigationBar]에서 선택된 탭에 따라 보여줄 화면 목록을 저장하는 state입니다.
  final List<Widget> _pages = const [
    HomeScreen(),
    InfoScreen(),
  ];

  /// 하단 네비게이션바에 표시될 아이템들을 정의합니다.
  /// 각 아이템은 [BottomNavigationBarItem.icon]과 [BottomNavigationBarItem.label]로 구성됩니다.
  final List<BottomNavigationBarItem> _items = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calculate),
      label: 'info',
    ),
  ];

  /// 현재 선택된 탭의 인덱스를 저장하는 변수입니다.
  /// 이 코드에선 0은 [HomeScreen], 1은 [BmiScreen] 화면을 의미합니다.
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // 현재 선택된 탭(_currentIndex)에 해당하는 화면을 보여줍니다.
        body: _pages[_currentIndex],
        // 커스텀 하단 네비게이션바를 구현합니다.
        bottomNavigationBar: MyBottomNavigationBar(
          currentIndex: _currentIndex,
          items: _items,
          // 탭이 선택되었을 때 실행되는 콜백 함수입니다.
          onTap: (int index) {
            // setState를 호출하여 UI를 업데이트합니다.
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
