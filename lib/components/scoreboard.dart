import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class ScoreSheetsTable extends StatefulWidget {
  final List<String> players;
  final int initialTurns;

  const ScoreSheetsTable({
    super.key,
    required this.players,
    this.initialTurns = 1,
  });

  @override
  State<ScoreSheetsTable> createState() => _ScoreSheetsTableState();
}

class _ScoreSheetsTableState extends State<ScoreSheetsTable> {
  late List<String> players;
  late List<List<TextEditingController>> controllers;
  late int turns;
  bool showTotals = true;

  @override
  void initState() {
    super.initState();
    players = widget.players;
    turns = widget.initialTurns;
    controllers = List.generate(
      turns,
      (_) => List.generate(players.length, (_) => TextEditingController()),
    );
  }

  void _addTurn() {
    setState(() {
      turns++;
      controllers.add(
        List.generate(players.length, (_) => TextEditingController()),
      );
    });
  }

  void _removeTurn() {
    if (turns <= 1 || controllers.isEmpty) return;
    setState(() {
      final removedRow = controllers.removeLast();
      for (final c in removedRow) {
        c.dispose();
      }
      turns--;
    });
  }

  @override
  void dispose() {
    for (final row in controllers) {
      for (final c in row) {
        c.dispose();
      }
    }
    super.dispose();
  }

  int getPlayerTotal(int playerIndex) {
    int total = 0;
    for (int t = 0; t < turns; t++) {
      int? val = int.tryParse(controllers[t][playerIndex].text);
      total += val ?? 0;
    }
    return total;
  }

  Map<String, dynamic> _scoreboardToJson() {
    return {
      'players': players,
      'turns': turns,
      'scores': controllers
          .map((row) => row.map((c) => c.text).toList())
          .toList(),
    };
  }

  Future<String> _localFilePath(String name) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$name';
  }

  Future<void> _saveToFile({String filename = 'scoreboard.json'}) async {
    String? path;
    File file;

    if (filename == 'scoreboard.json') {
      // Let the user pick where to save the file.
      final selected = await FilePicker.platform.saveFile(
        dialogTitle: 'Save scoreboard',
        fileName: filename,
      );
      if (selected == null) return; // user cancelled
      path = selected;
      file = File(path);
    } else {
      path = await _localFilePath(filename);
      file = File(path);
    }

    await file.writeAsString(jsonEncode(_scoreboardToJson()));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Saved to $path')));
    }
  }

  Future<void> _loadFromFile({String filename = 'scoreboard.json'}) async {
    try {
      File? file;
      if (filename != 'scoreboard.json') {
        final dir = await getApplicationDocumentsDirectory();
        file = File('${dir.path}/$filename');
        if (!await file.exists()) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('File not found: $filename')),
            );
          }
          return;
        }
      } else {
        // Use native file picker to choose a JSON file.
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['json'],
        );
        if (result == null || result.files.isEmpty) return;
        final pickedPath = result.files.single.path;
        if (pickedPath == null) return;
        file = File(pickedPath);
      }

      final raw = await file.readAsString();
      final data = jsonDecode(raw) as Map<String, dynamic>;

      final savedPlayers = List<String>.from(data['players'] ?? []);
      final savedScores =
          (data['scores'] as List<dynamic>?)
              ?.map((r) => List<String>.from(r as List<dynamic>))
              .toList() ??
          [];
      final savedTurns = data['turns'] is int
          ? data['turns'] as int
          : savedScores.length;

      // dispose old controllers
      for (final row in controllers) {
        for (final c in row) {
          c.dispose();
        }
      }

      if (!mounted) return;
      setState(() {
        players = savedPlayers;
        turns = savedTurns;
        controllers = List.generate(
          turns,
          (r) => List.generate(players.length, (c) {
            final txt = (r < savedScores.length && c < savedScores[r].length)
                ? savedScores[r][c]
                : '';
            return TextEditingController(text: txt);
          }),
        );
      });
      if (mounted) {
        final loadedName = file.path.split(Platform.pathSeparator).last;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Loaded $loadedName')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load file: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Score Sheets')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                ElevatedButton.icon(
                  onPressed: _addTurn,
                  label: const Text('Add Turn'),
                  icon: const Icon(Icons.add),
                ),
                ElevatedButton.icon(
                  onPressed: (turns > 1) ? _removeTurn : null,
                  label: const Text('Remove Turn'),
                  icon: const Icon(Icons.remove),
                ),
                ElevatedButton.icon(
                  onPressed: _saveToFile,
                  label: const Text('Save'),
                  icon: const Icon(Icons.save),
                ),
                ElevatedButton.icon(
                  onPressed: _loadFromFile,
                  label: const Text('Load'),
                  icon: const Icon(Icons.folder_open),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    const DataColumn(label: Text('Turn')),
                    ...players.map((name) => DataColumn(label: Text(name))),
                  ],
                  rows: List.generate(turns + (showTotals ? 1 : 0), (rowIndex) {
                    if (showTotals && rowIndex == turns) {
                      return DataRow(
                        cells: [
                          const DataCell(
                            Text(
                              'Total',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          ...List.generate(
                            players.length,
                            (col) => DataCell(
                              Text(
                                getPlayerTotal(col).toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    // Data rows
                    return DataRow(
                      cells: [
                        DataCell(Text('Turn ${rowIndex + 1}')),
                        ...List.generate(
                          players.length,
                          (col) => DataCell(
                            SizedBox(
                              width: 60,
                              child: TextField(
                                controller: controllers[rowIndex][col],
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  hintText: '-',
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
