import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../services/auth_service.dart';
import '../../services/task_service.dart';
import 'add_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with TickerProviderStateMixin {
  final _taskService = TaskService();
  List<Task> _tasks = [];
  bool _isLoading = true;
  int _selectedTab = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedTab = _tabController.index);
      _loadTasks();
    });
    _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final userId = context.read<AuthService>().currentUserId;
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      List<Task> tasks;
      switch (_selectedTab) {
        case 0:
          tasks = await _taskService.getTodayTasks(userId);
          break;
        case 1:
          tasks = await _taskService.getRecurringTasks(userId);
          break;
        case 2:
          tasks = await _taskService.getCompletedTasks(userId);
          break;
        default:
          tasks = [];
      }
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthService>().currentUserId;
    if (userId == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthService>().signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Today'),
              Tab(text: 'Recurring'),
              Tab(text: 'Completed'),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildTaskList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );
          _loadTasks();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList() {
    if (_tasks.isEmpty) {
      return const Center(
        child: Text('No tasks found'),
      );
    }

    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Checkbox(
              value: task.status == TaskStatus.completed,
              onChanged: (value) async {
                await _taskService.updateTask(
                  task.copyWith(
                    status: value == true
                        ? TaskStatus.completed
                        : TaskStatus.pending,
                  ),
                );
                _loadTasks();
              },
            ),
            title: Text(task.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.description),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: task.progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    task.progress == 1.0 ? Colors.green : Colors.blue,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
              onSelected: (value) async {
                if (value == 'delete') {
                  await _taskService.deleteTask(task.id);
                  _loadTasks();
                } else if (value == 'edit') {
                  // Navigate to edit task screen
                }
              },
            ),
          ),
        );
      },
    );
  }
}
