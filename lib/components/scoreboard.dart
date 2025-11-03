import 'package:flutter/material.dart';

class ScoreSheetsTable extends StatefulWidget {
  final List<String> players;
  final int initialTurns;

  const ScoreSheetsTable({
    Key? key,
    required this.players,
    this.initialTurns = 1,
  }) : super(key: key);

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
    // TODO fix
    controllers.removeLast();
    turns--;
  }

  int getPlayerTotal(int playerIndex) {
    int total = 0;
    for (int t = 0; t < turns; t++) {
      int? val = int.tryParse(controllers[t][playerIndex].text);
      total += val ?? 0;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Score Sheets')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: _addTurn,
                  child: const Text('Add Turn'),
                ),
                // ElevatedButton(
                //   onPressed: _removeTurn,
                //   child: const Text('Remove Turn'),
                // ),
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
