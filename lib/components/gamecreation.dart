import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerNameInputList extends StatefulWidget {
  const PlayerNameInputList({Key? key}) : super(key: key);

  @override
  State<PlayerNameInputList> createState() => _PlayerNameInputListState();
}

class _PlayerNameInputListState extends State<PlayerNameInputList> {
  final List<String> _players = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();

  void _addPlayer() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty && !_players.any((p) => p == name)) {
      setState(() {
        _players.add(name);
      });
      _nameController.clear();
    }
  }

  _removePlayer(String player) {
    _players.remove(player);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scoreboard Per Turn')),
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
                  : ListView(
                      children: _players.map((player) {
                        return ListTile(
                          title: Text(
                            player,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: FilledButton(
                            onPressed: _removePlayer(player),
                            child: const Text('Remove'),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class Player {
  final String name;
  final List<int> turns;
  Player({required this.name, required this.turns});
}
