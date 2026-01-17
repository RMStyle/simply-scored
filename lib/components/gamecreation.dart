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
import 'package:simply_scored/components/scoreboard.dart';

class PlayerNameInputList extends StatefulWidget {
  const PlayerNameInputList({super.key});

  @override
  State<PlayerNameInputList> createState() => _PlayerNameInputListState();
}

class _PlayerNameInputListState extends State<PlayerNameInputList> {
  List<String> _players = [];
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlayerList();
  }

  Future<void> _loadPlayerList() async {
    final prefs = await SharedPreferences.getInstance();
    _players = prefs.getStringList('players') ?? [];
  }

  void _addPlayer() async {
    final prefs = await SharedPreferences.getInstance();
    final name = _nameController.text.trim();
    if (name.isNotEmpty && !_players.any((p) => p == name)) {
      setState(() {
        _players.add(name);
        prefs.setStringList('players', _players);
      });
      _nameController.clear();
    }
  }

  Future<void> _removePlayer(String name) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _players.remove(name);
      prefs.setStringList('players', _players);
    });
  }

  void _onPressed() {
    if (_players.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => ScoreSheetsTable(players: _players),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one player.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Add Player Name',
                    ),
                    // onSubmitted: () => _addPlayer,
                  ),
                ),
                ElevatedButton(
                  onPressed: _addPlayer,
                  child: const Text('Add Player'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _players.isEmpty
                  ? const Center(child: Text('No players yet!'))
                  : ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      itemCount: _players.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          key: ValueKey(_players[index]),
                          title: Text(
                            _players[index],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: FittedBox(
                            fit: BoxFit.fill,
                            child: Row(
                              spacing: 16,
                              children: <Widget>[
                                OutlinedButton(
                                  onPressed: () =>
                                      _removePlayer(_players[index]),
                                  child: const Icon(Icons.delete),
                                ),
                                ReorderableDragStartListener(
                                  index: index,
                                  child: const Icon(Icons.drag_handle),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final String player = _players.removeAt(oldIndex);
                          _players.insert(newIndex, player);
                        });
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onPressed,
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
