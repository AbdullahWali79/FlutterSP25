import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class TableGeneratorScreen extends StatefulWidget {
  const TableGeneratorScreen({super.key});

  @override
  State<TableGeneratorScreen> createState() => _TableGeneratorScreenState();
}

class _TableGeneratorScreenState extends State<TableGeneratorScreen> {
  int selectedNumber = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Table Generator'),
        backgroundColor: settings.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  'Select a number:',
                  style: TextStyle(fontSize: settings.fontSize),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<int>(
                    value: selectedNumber,
                    items: List.generate(20, (index) => index + 1)
                        .map((number) => DropdownMenuItem(
                              value: number,
                              child: Text(
                                number.toString(),
                                style: TextStyle(fontSize: settings.fontSize),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedNumber = value;
                        });
                      }
                    },
                    isExpanded: true,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: settings.tableRangeEnd,
              itemBuilder: (context, index) {
                final multiplier = index + 1;
                final result = selectedNumber * multiplier;
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      '$selectedNumber × $multiplier = $result',
                      style: TextStyle(
                        fontSize: settings.fontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
