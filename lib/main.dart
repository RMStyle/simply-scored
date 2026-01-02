import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:simply_scored/components/gamecreation.dart';

void main() {
  runApp(MaterialApp(home: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          // Otherwise, use fallback schemes.
          lightColorScheme = ColorScheme.fromSeed(seedColor: Colors.blueAccent);
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: Colors.blueAccent,
            brightness: Brightness.dark,
          );
        }
        return MaterialApp(
          theme: ThemeData(colorScheme: lightColorScheme),
          darkTheme: ThemeData(colorScheme: darkColorScheme),
          home: Scaffold(
            appBar: AppBar(title: const Text('Player Select')),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  const DrawerHeader(
                    child: Text('Settings', style: TextStyle(fontSize: 24)),
                  ),
                  AboutListTile(
                    icon: const Icon(Icons.document_scanner),
                    applicationName: 'Simply Scored',
                    applicationIcon: ImageIcon(
                      AssetImage('assets/images/icon.png'),
                    ),
                    applicationVersion: '0.1.2',
                    aboutBoxChildren: [
                      Text(
                        'Track your game scores easily. This is app is fully open source. Get the code at https://git.adminforge.de/rmstyle/scoreboard ',
                      ),
                      Text(
                        'For any questions contact me via mail dev@fpuellen.com',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            body: PlayerNameInputList(),
          ),
        );
      },
    );
  }
}
