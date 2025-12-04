import 'package:flutter/material.dart';
import 'package:scoreboard/components/gamecreation.dart';

void main() {
  runApp(MaterialApp(home: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Player Select')),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                child: Text('Settings', style: TextStyle(fontSize: 24)),
              ),
              ListTile(
                leading: const Icon(Icons.document_scanner),
                title: const Text('Licenses'),
                onTap: () => showAboutDialog(context: context),
              ),
            ],
          ),
        ),
        body: PlayerNameInputList(),
      ),
    );
  }
}
