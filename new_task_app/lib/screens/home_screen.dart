import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import '../providers/task_appearance_provider.dart';
import 'package:provider/provider.dart';

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

    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      useSafeArea: true,
      builder: (context) => AnimatedContainer(
        duration: Duration(
          milliseconds:
              (context.watch<TaskAppearanceProvider>().dialogAnimationDuration *
                      1000)
                  .round(),
        ),
        child: StatefulBuilder(
          builder: (context, setState) => Consumer<TaskAppearanceProvider>(
            builder: (context, appearanceProvider, child) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      appearanceProvider.dialogCornerRadius),
                ),
                elevation: appearanceProvider.dialogElevation,
                backgroundColor: Colors.transparent,
                child: Container(
                  decoration: appearanceProvider.dialogUseGradient
                      ? BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary.withOpacity(
                                  appearanceProvider.dialogBackgroundOpacity),
                              Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(appearanceProvider
                                      .dialogBackgroundOpacity),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(
                              appearanceProvider.dialogCornerRadius),
                        )
                      : BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surface
                              .withOpacity(
                                  appearanceProvider.dialogBackgroundOpacity),
                          borderRadius: BorderRadius.circular(
                              appearanceProvider.dialogCornerRadius),
                        ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Add New Task',
                          style: TextStyle(
                            fontSize: appearanceProvider.titleFontSize,
                            fontWeight: appearanceProvider.titleFontWeight,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: titleController,
                          style: TextStyle(
                            fontSize: appearanceProvider.titleFontSize,
                            fontWeight: appearanceProvider.titleFontWeight,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Title',
                            labelStyle: TextStyle(
                              fontSize: appearanceProvider.descriptionFontSize,
                              fontWeight:
                                  appearanceProvider.descriptionFontWeight,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  appearanceProvider.dialogCornerRadius / 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descriptionController,
                          style: TextStyle(
                            fontSize: appearanceProvider.descriptionFontSize,
                            fontWeight:
                                appearanceProvider.descriptionFontWeight,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Description',
                            labelStyle: TextStyle(
                              fontSize: appearanceProvider.descriptionFontSize,
                              fontWeight:
                                  appearanceProvider.descriptionFontWeight,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  appearanceProvider.dialogCornerRadius / 2),
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
                              ),
                            ),
                            const SizedBox(width: 8),
                            Switch(
                              value: isRepeatable,
                              onChanged: (value) {
                                setState(() {
                                  isRepeatable = value;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize:
                                      appearanceProvider.descriptionFontSize,
                                  fontWeight:
                                      appearanceProvider.descriptionFontWeight,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () async {
                                if (titleController.text.isNotEmpty) {
                                  final task = Task(
                                    title: titleController.text,
                                    description: descriptionController.text,
                                    createdAt: DateTime.now(),
                                    isRepeatable: isRepeatable,
                                  );
                                  await DatabaseHelper.instance
                                      .insertTask(task.toMap());
                                  Navigator.pop(context);
                                  _loadTasks();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      appearanceProvider.dialogCornerRadius /
                                          2),
                                ),
                              ),
                              child: Text(
                                'Add',
                                style: TextStyle(
                                  fontSize:
                                      appearanceProvider.descriptionFontSize,
                                  fontWeight:
                                      appearanceProvider.descriptionFontWeight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
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
