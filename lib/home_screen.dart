import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  String _mealInfo = '';
  String _calorieInfo = ''; // 칼로리 정보를 저장할 변수
  final String apiKey =
      'c0e7d58552314f49a2f37bb240f75052'; // Replace with your API key

  String _formatDate(DateTime date) {
    return DateFormat('M월 d일').format(date);
  }

  bool _isWeekend() {
    return _selectedDate.weekday == 6 || _selectedDate.weekday == 7;
  }

  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
      _fetchMealData();
    });
  }

  void _nextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
      _fetchMealData();
    });
  }

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
      _fetchMealData();
    });
  }

  Future<void> _fetchMealData() async {
    // 주말이면 급식 정보를 가져오지 않음
    if (_isWeekend()) {
      setState(() {
        _mealInfo = '행복하고 즐거운 주말~ ^*^';
        _calorieInfo = '';
      });
      return;
    }

    final String dateString = DateFormat('yyyyMMdd').format(_selectedDate);
    final String url =
        'https://open.neis.go.kr/hub/mealServiceDietInfo?key=$apiKey&type=json&pindex=1&psize=10&ATPT_OFCDC_SC_CODE=J10&SD_SCHUL_CODE=7531328&MLSV_YMD=$dateString';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if the response contains meal data
        if (data['mealServiceDietInfo'][1]['row'].isNotEmpty) {
          setState(() {
            _mealInfo = data['mealServiceDietInfo'][1]['row'][0]['DDISH_NM']
                .replaceAll('<br/>', '\n'); // 줄바꿈 처리
            _calorieInfo = data['mealServiceDietInfo'][1]['row'][0]['CAL_INFO'];
          });
        } else {
          setState(() {
            _mealInfo = '급식 정보가 없습니다.';
            _calorieInfo = '';
          });
        }
      } else {
        throw Exception('Failed to load meal data');
      }
    } catch (e) {
      setState(() {
        _mealInfo = '급식 정보를 불러오는 중 오류가 발생했습니다.';
        _calorieInfo = '';
      });
      if (kDebugMode) print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMealData(); // Fetch meal data when the app starts
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
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
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2025),
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                    _fetchMealData();
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text(
                '날짜 선택',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
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
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('급식 보기',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left),
                Text(
                  '${_formatDate(_selectedDate)} 급식',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.left,
                ),
                Text(
                  _calorieInfo.isNotEmpty ? _calorieInfo : '',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            Container(
              height: 400,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 127, 127, 127),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('메뉴:',
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 10),
                    Text(
                      _mealInfo.isNotEmpty ? _mealInfo : '급식 정보를 불러오는 중...',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30.60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _previousDay,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: const Color.fromARGB(255, 211, 211, 211),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _goToToday,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 20),
                      backgroundColor: const Color.fromARGB(255, 211, 211, 211),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: const Text(
                      '오늘',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _nextDay,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: const Color.fromARGB(255, 211, 211, 211),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
