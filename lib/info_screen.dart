import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = ThemeData(useMaterial3: true);

    return MaterialApp(
      theme: themeData,
      home: Scaffold(
        backgroundColor:
            const Color.fromARGB(246, 243, 233, 184), // 배경색을 투명으로 설정
        appBar: AppBar(
          backgroundColor:
              const Color.fromARGB(246, 243, 233, 184), // 배경색을 투명으로 설정
          title: const Text(
            '알레르기 정보 입력(숫자만)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
        ),
        body: const Padding(
          padding: EdgeInsets.all(10.0),
          child: AllergyInputField(),
        ),
      ),
    );
  }
}

class AllergyInputField extends StatefulWidget {
  const AllergyInputField({super.key});

  @override
  _AllergyInputFieldState createState() => _AllergyInputFieldState();
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

  void _deleteItem(int index) {
    setState(() {
      _inputList.removeAt(index);
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
    // Sort the list in ascending order
    List<String> sortedList = List.from(_inputList);
    sortedList.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    AudioPlayer audioPlayer = AudioPlayer(); // 배경음악 재생 여부

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: '숫자를 입력하세요',
          ),
          onSubmitted: _handleSubmit,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        const SizedBox(height: 10),
        Text(
          _errorMessage,
          style: const TextStyle(color: Colors.red),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: sortedList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        '입력한 알레르기 숫자 정보: ${sortedList[index]}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteItem(index),
                      ),
                    );
                  },
                ),
                Center(
                  child: Image.asset(
                    'assets/al.jpg',
                    width: 400,
                    height: 500,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(),
        Row(
          mainAxisAlignment: MainAxisAlignment.start, // 왼쪽 정렬
          children: [
            IconButton(
              onPressed: () async {
                await audioPlayer.play(AssetSource("basic.mp3"));
              },
              icon: const Icon(Icons.play_arrow),
            ),
            IconButton(
              onPressed: () async {
                await audioPlayer.stop();
              },
              icon: const Icon(Icons.ac_unit),
            ),
          ],
        ),
      ],
    );
  }
}
