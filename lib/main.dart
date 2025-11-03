import 'package:flutter/material.dart';
import 'package:scoreboard/components/gamecreation.dart';
import 'package:scoreboard/components/scoreboard.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  // final List list = ['x', 'Ricky', 'Nessi', 'Nico'];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Home')),
        // body: ScoreSheetsTable(players: ['Ricky', 'Nessi']),
        body: PlayerNameInputList(),
      ),
    );
  }
}
