import 'dart:convert';
import 'package:dy_food_flutter/food_info.dart';
import 'package:dy_food_flutter/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  List<FoodInfo> _foodInfoList = [];
  // String _mealInfo = '';
  String _calorieInfo = ''; // 칼로리 정보를 저장할 변수
  final String apiKey =
      'c0e7d58552314f49a2f37bb240f75052'; // Replace with your API key
  List<int> _inputList = [];

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
        _foodInfoList = [];
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
          final List<String> dataList = data['mealServiceDietInfo'][1]['row'][0]
                  ['DDISH_NM']
              .split('<br/>');
          setState(() {
            _foodInfoList =
                dataList.map((data) => FoodInfo.fromData(data)).toList();
            _calorieInfo = data['mealServiceDietInfo'][1]['row'][0]['CAL_INFO'];
          });
          
          // 알레르기 알림 체크
          NotificationService.checkAllergyAlert(_foodInfoList, _inputList);
        } else {
          setState(() {
            _foodInfoList = [];
            _calorieInfo = '';
          });
        }
      } else {
        throw Exception('Failed to load meal data');
      }
    } catch (e) {
      setState(() {
        _foodInfoList = [];
        _calorieInfo = '';
      });
      if (kDebugMode) print(e);
    }
  }

  void _fetchInputList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? inputStringList = prefs.getStringList('inputList');
    if (inputStringList == null) return;

    setState(() {
      _inputList = inputStringList.map((input) => int.parse(input)).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchMealData(); // Fetch meal data when the app starts
    _fetchInputList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFECFEF), Color(0xFFFECDA2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'DY 급식 🍽️',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9A8B), Color(0xFFA8E6CF)],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _selectedDate = pickedDate;
                              _fetchMealData();
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          '날짜 선택 📅',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildDateCard(),
                      const SizedBox(height: 20),
                      _buildMealCard(),
                      const SizedBox(height: 20),
                      _buildNavigationButtons(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.orange.shade400,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                '${_formatDate(_selectedDate)} 급식',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          if (_calorieInfo.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                _calorieInfo,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMealCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.restaurant,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 10),
              const Text(
                '오늘의 메뉴',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_foodInfoList.isEmpty && _isWeekend())
            const Center(
              child: Text(
                '🎉 주말에는 급식이 없어요!',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
            )
          else if (_foodInfoList.isEmpty)
            const Center(
              child: Text(
                '급식 정보가 없습니다',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
            )
          else
            ..._foodInfoList.map(
              (food) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        food.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (food.allergens.isNotEmpty)
                      Wrap(
                        spacing: 5,
                        children: food.allergens.map(
                          (allergen) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _inputList.contains(allergen)
                                  ? Colors.red.shade400
                                  : Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$allergen',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ).toList(),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _goToToday,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              '오늘 급식 보기 🎅',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavButton(
              icon: Icons.chevron_left,
              onPressed: _previousDay,
              colors: [Color(0xFFFF9A8B), Color(0xFFFECFEF)],
            ),
            _buildNavButton(
              icon: Icons.chevron_right,
              onPressed: _nextDay,
              colors: [Color(0xFFFECFEF), Color(0xFFFF9A8B)],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onPressed,
    required List<Color> colors,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(20),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

}
