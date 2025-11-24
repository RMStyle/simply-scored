import 'package:flutter/material.dart';
import 'package:scoreboard/components/scoreboard.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class PlayerNameInputList extends StatefulWidget {
  const PlayerNameInputList({Key? key}) : super(key: key);

  @override
  State<PlayerNameInputList> createState() => _PlayerNameInputListState();
}

class _PlayerNameInputListState extends State<PlayerNameInputList> {
  List<String> _players = [];
  final TextEditingController _nameController = TextEditingController();

  void _addPlayer() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty && !_players.any((p) => p == name)) {
      setState(() {
        _players.add(name);
      });
      _nameController.clear();
    }
  }

  _removePlayer(String name) {
    setState(() {
      _players.remove(name);
    });
  }

  void _goToScoreSheet() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ScoreSheetsTable(players: _players),
      ),
    );
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
                  : ListView.builder(
                      itemCount: _players.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(
                            _players[index],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: FilledButton(
                            onPressed: () => _removePlayer(_players[index]),
                            child: const Text('Remove'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => ScoreSheetsTable(players: _players),
            ),
          );
        },
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
