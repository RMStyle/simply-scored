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
                  ListTile(
                    leading: const Icon(Icons.document_scanner),
                    title: const Text('Licenses'),
                    onTap: () => showAboutDialog(
                      context: context,
                      applicationName: 'Simply Scored',
                      applicationIcon: FlutterLogo(),
                      applicationVersion: 'test version 3',
                      applicationLegalese: 'Track your game scores easily.',
                    ),
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
