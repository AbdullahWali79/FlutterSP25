import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            settings.primaryColor.withOpacity(0.1),
            Colors.white,
            settings.primaryColor.withOpacity(0.05),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Icons.settings, color: Colors.white),
              SizedBox(width: 8),
              Text('Settings'),
            ],
          ),
          backgroundColor: settings.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildAnimatedCard(
              'Table Range',
              Icon(Icons.table_chart_outlined, size: 28),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Start from: '),
                      DropdownButton<int>(
                        value: settings.tableRangeStart,
                        items: List.generate(10, (index) => index + 1)
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.toString()),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            context
                                .read<SettingsProvider>()
                                .updateTableRangeStart(value);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('End at: '),
                      DropdownButton<int>(
                        value: settings.tableRangeEnd,
                        items: [10, 15, 20]
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.toString()),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            context
                                .read<SettingsProvider>()
                                .updateTableRangeEnd(value);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildAnimatedCard(
              'Font Settings',
              Icon(Icons.text_fields, size: 28),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Font Size: '),
                      Expanded(
                        child: Slider(
                          value: settings.fontSize,
                          min: 16,
                          max: 32,
                          divisions: 8,
                          label: settings.fontSize.round().toString(),
                          activeColor: settings.primaryColor,
                          onChanged: (value) {
                            context
                                .read<SettingsProvider>()
                                .updateFontSize(value);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<String>(
                    value: settings.fontFamily,
                    isExpanded: true,
                    items: [
                      'Quicksand',
                      'Roboto',
                      'Lato',
                      'Open Sans',
                      'Comic Neue',
                    ]
                        .map((font) => DropdownMenuItem(
                              value: font,
                              child: Text(
                                'Sample Text',
                                style: GoogleFonts.getFont(font),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        context
                            .read<SettingsProvider>()
                            .updateFontFamily(value);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildAnimatedCard(
              'Theme Color',
              Icon(Icons.palette_outlined, size: 28),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(
                  settings.themeOptions.length,
                  (index) {
                    final theme = settings.themeOptions[index];
                    final isSelected = settings.selectedThemeIndex == index;
                    return _AnimatedThemeButton(
                      theme: theme,
                      isSelected: isSelected,
                      onTap: () {
                        context.read<SettingsProvider>().updateTheme(index);
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildAnimatedCard(
              'Quiz Tables',
              Icon(Icons.quiz_outlined, size: 28),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(20, (index) {
                  final number = index + 1;
                  return _AnimatedFilterChip(
                    label: number.toString(),
                    selected: settings.selectedTables.contains(number),
                    onSelected: (selected) {
                      final newTables = [...settings.selectedTables];
                      if (selected) {
                        newTables.add(number);
                      } else {
                        newTables.remove(number);
                      }
                      newTables.sort();
                      context
                          .read<SettingsProvider>()
                          .updateSelectedTables(newTables);
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCard(String title, Widget icon, Widget content) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            child: Card(
              elevation: 4,
              shadowColor: Colors.black26,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        icon,
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    content,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedThemeButton extends StatefulWidget {
  final ThemeColors theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedThemeButton({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  _AnimatedThemeButtonState createState() => _AnimatedThemeButtonState();
}

class _AnimatedThemeButtonState extends State<_AnimatedThemeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _rotateAnimation = Tween<double>(begin: 0, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: child,
          ),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.theme.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: widget.isSelected ? Colors.black : Colors.transparent,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.theme.primary.withOpacity(0.3),
                blurRadius: widget.isSelected ? 12 : 8,
                spreadRadius: widget.isSelected ? 2 : 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedFilterChip extends StatefulWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _AnimatedFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  _AnimatedFilterChipState createState() => _AnimatedFilterChipState();
}

class _AnimatedFilterChipState extends State<_AnimatedFilterChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _bounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onSelected(!widget.selected);
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.translate(
            offset: Offset(0, -2 * _bounceAnimation.value),
            child: child,
          ),
        ),
        child: FilterChip(
          label: Text(widget.label),
          selected: widget.selected,
          onSelected: widget.onSelected,
          elevation: widget.selected ? 4 : 0,
          pressElevation: 8,
        ),
      ),
    );
  }
}
