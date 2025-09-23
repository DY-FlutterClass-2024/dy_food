import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA8E6CF), Color(0xFF88D8C0)],
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
                  children: [
                    Icon(
                      Icons.health_and_safety,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '알레르기 정보 ✨',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: AllergyInputField(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AllergyInputField extends StatefulWidget {
  const AllergyInputField({super.key});

  @override
  State<AllergyInputField> createState() => _AllergyInputFieldState();
}

class _AllergyInputFieldState extends State<AllergyInputField> {
  SharedPreferences? _prefs;

  final TextEditingController _controller = TextEditingController();
  List<String> _inputList = [];
  String _errorMessage = '';

  Future<void> _initPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _prefs = prefs;
      _inputList = prefs.getStringList('inputList') ?? [];
    });
  }

  Future<void> _updateInputList() async {
    if (_prefs != null) {
      await _prefs!.setStringList('inputList', _inputList);
    }
  }

  void _handleSubmit(String value) {
    int? intValue = int.tryParse(value);

    // Check if input is a valid integer, less than 20, and not a duplicate
    if (intValue != null && intValue <= 19) {
      setState(() {
        if (_inputList.contains(value)) {
          _errorMessage = '중복된 값을 입력할 수 없습니다';
        } else {
          _inputList.add(value);
          _controller.clear();
          _errorMessage = ''; // Clear error message on success
          _updateInputList();
        }
      });
    } else {
      setState(() {
        _errorMessage = '19 이하의 숫자만 입력할 수 있습니다';
      });
    }
  }

  void _deleteItem(String value) {
    setState(() {
      _inputList.remove(value);
      _updateInputList();
    });
  }

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  @override
  Widget build(BuildContext context) {
    List<String> sortedList = List.from(_inputList);
    sortedList.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    AudioPlayer audioPlayer = AudioPlayer();

    return Column(
      children: [
        Container(
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
            children: [
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '알레르기 번호를 입력하세요 (0-19)',
                  prefixIcon: Icon(
                    Icons.numbers,
                    color: Colors.teal.shade400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                onSubmitted: _handleSubmit,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (sortedList.isNotEmpty)
          Container(
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
                      Icons.list_alt,
                      color: Colors.teal.shade400,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '내 알레르기 목록',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: sortedList.map((item) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9A8B), Color(0xFFFECFEF)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _deleteItem(item),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            width: double.infinity,
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
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade400,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            '알레르기 정보표',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3436),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () async {
                                await audioPlayer.play(AssetSource("basic.mp3"));
                              },
                              icon: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF9A8B), Color(0xFFFECFEF)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () async {
                                await audioPlayer.stop();
                              },
                              icon: const Icon(
                                Icons.stop,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: Image.asset(
                      'assets/al.jpg',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
