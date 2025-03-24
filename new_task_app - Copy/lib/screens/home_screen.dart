import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import '../providers/task_appearance_provider.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  List<Task> _tasks = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await DatabaseHelper.instance.getAllTasks();
    setState(() {
      _tasks = tasks
          .map((task) => Task.fromMap(task))
          .where((task) => !task.isCompleted)
          .toList();
    });
  }

  Future<void> _searchTasks(String query) async {
    if (query.isEmpty) {
      _loadTasks();
      return;
    }
    final tasks = await DatabaseHelper.instance.searchTasks(query);
    setState(() {
      _tasks = tasks
          .map((task) => Task.fromMap(task))
          .where((task) => !task.isCompleted)
          .toList();
    });
  }

  Future<void> _addTask() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isRepeatable = false;

    final appearanceProvider = context.read<TaskAppearanceProvider>();

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(
        milliseconds:
            (appearanceProvider.dialogAnimationDuration * 1000).round(),
      ),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: FadeTransition(
            opacity: animation,
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                final appearanceProvider =
                    context.watch<TaskAppearanceProvider>();

                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        appearanceProvider.dialogCornerRadius),
                  ),
                  elevation: appearanceProvider.dialogElevation,
                  backgroundColor: appearanceProvider.dialogUseGradient
                      ? Colors.transparent
                      : Theme.of(context).scaffoldBackgroundColor.withOpacity(
                            appearanceProvider.dialogBackgroundOpacity,
                          ),
                  content: Container(
                    decoration: appearanceProvider.dialogUseGradient
                        ? BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                appearanceProvider.dialogGradientStartColor,
                                appearanceProvider.dialogGradientEndColor,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(
                                appearanceProvider.dialogCornerRadius),
                          )
                        : null,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Add New Task',
                          style: TextStyle(
                            fontSize: appearanceProvider.titleFontSize * 1.2,
                            fontWeight: appearanceProvider.titleFontWeight,
                            color: appearanceProvider.dialogTextColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            color:
                                appearanceProvider.dialogInputBackgroundColor,
                            borderRadius: BorderRadius.circular(
                                appearanceProvider.dialogCornerRadius / 2),
                            border: Border.all(
                              color: appearanceProvider.dialogInputBorderColor,
                            ),
                          ),
                          child: TextField(
                            controller: titleController,
                            decoration: InputDecoration(
                              labelText: 'Title',
                              labelStyle: TextStyle(
                                color: appearanceProvider.dialogTextColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    appearanceProvider.dialogCornerRadius / 2),
                                borderSide: BorderSide(
                                  color:
                                      appearanceProvider.dialogInputBorderColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    appearanceProvider.dialogCornerRadius / 2),
                                borderSide: BorderSide(
                                  color:
                                      appearanceProvider.dialogInputBorderColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    appearanceProvider.dialogCornerRadius / 2),
                                borderSide: BorderSide(
                                  color:
                                      appearanceProvider.dialogInputBorderColor,
                                  width: 2,
                                ),
                              ),
                            ),
                            style: TextStyle(
                              fontSize: appearanceProvider.titleFontSize,
                              fontWeight: appearanceProvider.titleFontWeight,
                              color: appearanceProvider.dialogTextColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color:
                                appearanceProvider.dialogInputBackgroundColor,
                            borderRadius: BorderRadius.circular(
                                appearanceProvider.dialogCornerRadius / 2),
                            border: Border.all(
                              color: appearanceProvider.dialogInputBorderColor,
                            ),
                          ),
                          child: TextField(
                            controller: descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              labelStyle: TextStyle(
                                color: appearanceProvider.dialogTextColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    appearanceProvider.dialogCornerRadius / 2),
                                borderSide: BorderSide(
                                  color:
                                      appearanceProvider.dialogInputBorderColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    appearanceProvider.dialogCornerRadius / 2),
                                borderSide: BorderSide(
                                  color:
                                      appearanceProvider.dialogInputBorderColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    appearanceProvider.dialogCornerRadius / 2),
                                borderSide: BorderSide(
                                  color:
                                      appearanceProvider.dialogInputBorderColor,
                                  width: 2,
                                ),
                              ),
                            ),
                            style: TextStyle(
                              fontSize: appearanceProvider.descriptionFontSize,
                              fontWeight:
                                  appearanceProvider.descriptionFontWeight,
                              color: appearanceProvider.dialogTextColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              'Repeatable Task',
                              style: TextStyle(
                                fontSize:
                                    appearanceProvider.descriptionFontSize,
                                fontWeight:
                                    appearanceProvider.descriptionFontWeight,
                                color: appearanceProvider.dialogTextColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Switch(
                              value: isRepeatable,
                              onChanged: (value) {
                                setDialogState(() {
                                  isRepeatable = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: appearanceProvider.descriptionFontSize,
                          fontWeight: appearanceProvider.descriptionFontWeight,
                          color: appearanceProvider.dialogTextColor,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (titleController.text.isNotEmpty) {
                          try {
                            final task = Task(
                              title: titleController.text,
                              description: descriptionController.text,
                              createdAt: DateTime.now(),
                              isRepeatable: isRepeatable,
                              isCompleted: false,
                            );
                            await DatabaseHelper.instance
                                .insertTask(task.toMap());
                            if (mounted) {
                              Navigator.pop(context);
                              _loadTasks();
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error adding task: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a title'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Add',
                        style: TextStyle(
                          fontSize: appearanceProvider.descriptionFontSize,
                          fontWeight: appearanceProvider.descriptionFontWeight,
                          color: appearanceProvider.dialogTextColor,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteTask(Task task) async {
    await DatabaseHelper.instance.deleteTask(task.id!);
    _loadTasks();
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    task.isCompleted = !task.isCompleted;
    await DatabaseHelper.instance.updateTask(task.toMap());
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search tasks...',
                  border: InputBorder.none,
                ),
                onChanged: _searchTasks,
              )
            : const Text('Task Manager'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _loadTasks();
                }
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return Dismissible(
            key: Key(task.id.toString()),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
                size: 32,
              ),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              _deleteTask(task);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context
                        .watch<TaskAppearanceProvider>()
                        .taskGradientStartColor,
                    context
                        .watch<TaskAppearanceProvider>()
                        .taskGradientEndColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(
                  context.watch<TaskAppearanceProvider>().taskCornerRadius,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(
                      context.watch<TaskAppearanceProvider>().taskShadowOpacity,
                    ),
                    spreadRadius: 1,
                    blurRadius:
                        context.watch<TaskAppearanceProvider>().taskShadowBlur,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    context.watch<TaskAppearanceProvider>().taskCornerRadius,
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) => _toggleTaskCompletion(task),
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                    fontWeight:
                        context.watch<TaskAppearanceProvider>().titleFontWeight,
                    fontSize:
                        context.watch<TaskAppearanceProvider>().titleFontSize,
                  ),
                ),
                subtitle: task.description != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          task.description!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: context
                                .watch<TaskAppearanceProvider>()
                                .descriptionFontSize,
                            fontWeight: context
                                .watch<TaskAppearanceProvider>()
                                .descriptionFontWeight,
                          ),
                        ),
                      )
                    : null,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/task',
                    arguments: task,
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
