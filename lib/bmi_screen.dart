import 'package:dy_food_flutter/Menu_bottom.dart';
import 'package:flutter/material.dart';

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // appBar: AppBar(title: Text('ㄴㅇㅁㄴㅇㅁㄴㅇ')),
      body: Center(child: Text('sadasd')),
      bottomNavigationBar: MenuBottom(),
    );
  }
}
