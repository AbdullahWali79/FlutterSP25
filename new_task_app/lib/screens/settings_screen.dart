import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<List<Color>> _presetGradients = [
    [Colors.blue, Colors.purple],
    [Colors.green, Colors.teal],
    [Colors.orange, Colors.deepOrange],
    [Colors.pink, Colors.red],
    [Colors.indigo, Colors.blue],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Theme Colors',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _presetGradients.length,
              itemBuilder: (context, index) {
                final colors = _presetGradients[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () {
                      context
                          .read<ThemeProvider>()
                          .updateGradientColors(colors);
                    },
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: colors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Custom Colors',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildColorPicker(
            'Primary Color',
            context.watch<ThemeProvider>().gradientColors[0],
            (color) {
              final colors = context.read<ThemeProvider>().gradientColors;
              context.read<ThemeProvider>().updateGradientColors([
                color,
                colors[1],
              ]);
            },
          ),
          const SizedBox(height: 16),
          _buildColorPicker(
            'Secondary Color',
            context.watch<ThemeProvider>().gradientColors[1],
            (color) {
              final colors = context.read<ThemeProvider>().gradientColors;
              context.read<ThemeProvider>().updateGradientColors([
                colors[0],
                color,
              ]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker(
      String label, Color color, Function(Color) onColorChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildColorOption(Colors.blue, onColorChanged),
            _buildColorOption(Colors.purple, onColorChanged),
            _buildColorOption(Colors.green, onColorChanged),
            _buildColorOption(Colors.teal, onColorChanged),
            _buildColorOption(Colors.orange, onColorChanged),
            _buildColorOption(Colors.deepOrange, onColorChanged),
            _buildColorOption(Colors.pink, onColorChanged),
            _buildColorOption(Colors.red, onColorChanged),
            _buildColorOption(Colors.indigo, onColorChanged),
          ],
        ),
      ],
    );
  }

  Widget _buildColorOption(Color color, Function(Color) onColorChanged) {
    return GestureDetector(
      onTap: () => onColorChanged(color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey,
            width: 2,
          ),
        ),
      ),
    );
  }
}
