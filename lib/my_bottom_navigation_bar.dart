import 'package:flutter/material.dart';

class MyBottomNavigationBar extends StatelessWidget {
  const MyBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  /// 현재 선택된 탭의 인덱스
  final int currentIndex;

  /// [BottomNavigationBar]에 표시될 아이템 목록
  final List<BottomNavigationBarItem> items;

  /// 탭이 선택되었을 때 호출되는 [콜백 함수](https://velog.io/@qlr222/Flutter-Callback-1)
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: items,
    );
  }
}
