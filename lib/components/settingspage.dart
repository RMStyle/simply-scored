// Copyright (C) 2026 Fredeic Püllen
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simply_scored/models/settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Settings _settings = Settings();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _settings.showHints = prefs.getBool('showHints') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _changeHintSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _settings.showHints = value;
      prefs.setBool('showHints', value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: _isLoading
            ? []
            : [
                ListTile(
                  title: Text('Enter Hint'),
                  subtitle: Text('Show hints during first data entry'),
                  trailing: Switch(
                    value: _settings.showHints,
                    onChanged: (bool value) {
                      _changeHintSetting(value);
                    },
                  ),
                ),
              ],
      ),
    );
  }
}
