import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

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
  final FocusNode _buttonFocusNode = FocusNode(debugLabel: 'Menu Button');
  late List<String> players;
  late List<List<TextEditingController>> controllers;
  late List<List<FocusNode>> focusNodes;
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
    focusNodes = List.generate(
      turns,
      (_) => List.generate(players.length, (_) => FocusNode()),
    );
  }

  void _addTurn() {
    setState(() {
      turns++;
      controllers.add(
        List.generate(players.length, (_) => TextEditingController()),
      );
      focusNodes.add(List.generate(players.length, (_) => FocusNode()));
    });
  }

  void _removeTurn() {
    if (turns <= 1 || controllers.isEmpty) return;
    setState(() {
      final removedRow = controllers.removeLast();
      for (final c in removedRow) {
        c.dispose();
      }
      final removedFocusRow = focusNodes.removeLast();
      for (final f in removedFocusRow) {
        f.dispose();
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
    for (final row in focusNodes) {
      for (final f in row) {
        f.dispose();
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

  Future<void> _saveToFile() async {
    // Let the user pick where to save the file.
    final selected = await FilePicker.platform.saveFile(
      dialogTitle: 'Save scoreboard',
      fileName: 'scoreboard.json',
      bytes: utf8.encode(jsonEncode(_scoreboardToJson())),
    );
    if (selected == null) return; // user cancelled

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Saved succesfully')));
    }
  }

  Future<void> _loadFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.isEmpty) return;
      final pickedPath = result.files.single.path;
      if (pickedPath == null) return;
      final file = File(pickedPath);

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
      for (final row in focusNodes) {
        for (final f in row) {
          f.dispose();
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
        focusNodes = List.generate(
          turns,
          (_) => List.generate(players.length, (_) => FocusNode()),
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

  void _clearAllInputs() {
    setState(() {
      for (final row in controllers) {
        for (final c in row) {
          c.clear();
        }
      }
    });
  }

  Future<void> _callUnsavedChangesDialog(bool didPop) async {
    if (!didPop) {
      final shouldLeave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Unsaved Changes"),
          content: const Text("You have unsaved changes. Leave anyway?"),
          actions: [
            TextButton(
              child: const Text("Stay"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text("Leave"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );
      if (shouldLeave == true && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _focusNextField() {
    for (int row = 0; row < turns; row++) {
      for (int column = 0; column < players.length; column++) {
        if (focusNodes[row][column].hasFocus) {
          int nodeRow = row;
          int nodeCol = column + 1;
          if (nodeCol >= players.length) {
            nodeCol = 0;
            nodeRow = row + 1;
          }
          if (nodeRow >= turns) {
            _addTurn();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (focusNodes.isNotEmpty && focusNodes.last.isNotEmpty) {
                focusNodes.last.first.requestFocus();
              }
            });
          } else {
            focusNodes[nodeRow][nodeCol].requestFocus();
          }
          return;
        }
      }
    }
    if (turns > 0 && players.isNotEmpty) {
      focusNodes[0][0].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        await _callUnsavedChangesDialog(didPop);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Score Sheets'),
          actions: [
            MenuAnchor(
              childFocusNode: _buttonFocusNode,
              builder: (_, MenuController controller, Widget? child) {
                return IconButton(
                  focusNode: _buttonFocusNode,
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  icon: const Icon(Icons.more_vert),
                );
              },
              menuChildren: [
                MenuItemButton(
                  onPressed: _saveToFile,
                  leadingIcon: const Icon(Icons.save),
                  child: Text('Save'),
                ),
                MenuItemButton(
                  onPressed: _loadFromFile,
                  leadingIcon: const Icon(Icons.folder_open),
                  child: Text('Load'),
                ),
                MenuItemButton(
                  onPressed: _clearAllInputs,
                  leadingIcon: const Icon(Icons.delete),
                  child: Text('Clear All Inputs'),
                ),
              ],
            ),
          ],
          automaticallyImplyLeading: !Platform.isAndroid,
        ),
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
                    rows: List.generate(turns + (showTotals ? 1 : 0), (
                      rowIndex,
                    ) {
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
                      return DataRow(
                        cells: [
                          DataCell(Text('Turn ${rowIndex + 1}')),
                          ...List.generate(
                            players.length,
                            (col) => DataCell(
                              SizedBox(
                                width: 60,
                                child: TextField(
                                  focusNode: focusNodes[rowIndex][col],
                                  controller: controllers[rowIndex][col],
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    hintText: '-',
                                  ),
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: false,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (_) => setState(() {}),
                                  onSubmitted: (_) => _focusNextField(),
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
      ),
    );
  }
}
