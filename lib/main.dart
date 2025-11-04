import 'package:flutter/material.dart';
import 'package:scoreboard/components/gamecreation.dart';
import 'package:scoreboard/components/scoreboard.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Home')),
        // body: ScoreSheetsTable(players: ['Test', 'Name']),
        body: PlayerNameInputList(),
      ),
    );
  }
}
