import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_planner/models/task.dart';
import 'package:task_planner/providers/task_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskProvider);
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    final totalTasks = tasks.length;
    final completionRate = totalTasks > 0
        ? (completedTasks / totalTasks * 100).toStringAsFixed(1)
        : '0.0';

    // Calculate tasks by priority
    final tasksByPriority = {
      TaskPriority.low:
          tasks.where((task) => task.priority == TaskPriority.low).length,
      TaskPriority.medium:
          tasks.where((task) => task.priority == TaskPriority.medium).length,
      TaskPriority.high:
          tasks.where((task) => task.priority == TaskPriority.high).length,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCompletionRateCard(completionRate, completedTasks, totalTasks),
          const SizedBox(height: 16),
          _buildPriorityDistributionCard(tasksByPriority),
          const SizedBox(height: 16),
          _buildTaskTrendsCard(tasks),
        ],
      ),
    );
  }

  Widget _buildCompletionRateCard(
    String completionRate,
    int completedTasks,
    int totalTasks,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Completion Rate',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$completionRate%',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$completedTasks/$totalTasks tasks completed',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: totalTasks > 0 ? completedTasks / totalTasks : 0,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityDistributionCard(
      Map<TaskPriority, int> tasksByPriority) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tasks by Priority',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: tasksByPriority[TaskPriority.low]?.toDouble() ?? 0,
                      title: '${tasksByPriority[TaskPriority.low]}',
                      color: Colors.green,
                    ),
                    PieChartSectionData(
                      value:
                          tasksByPriority[TaskPriority.medium]?.toDouble() ?? 0,
                      title: '${tasksByPriority[TaskPriority.medium]}',
                      color: Colors.orange,
                    ),
                    PieChartSectionData(
                      value:
                          tasksByPriority[TaskPriority.high]?.toDouble() ?? 0,
                      title: '${tasksByPriority[TaskPriority.high]}',
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('Low', Colors.green),
                _buildLegendItem('Medium', Colors.orange),
                _buildLegendItem('High', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
          margin: const EdgeInsets.only(right: 4),
        ),
        Text(label),
      ],
    );
  }

  Widget _buildTaskTrendsCard(List<Task> tasks) {
    // Group tasks by month
    final tasksByMonth = <DateTime, int>{};
    final now = DateTime.now();
    for (var i = 0; i < 6; i++) {
      final month = DateTime(now.year, now.month - i, 1);
      tasksByMonth[month] = tasks.where((task) {
        return task.createdAt.year == month.year &&
            task.createdAt.month == month.month;
      }).length;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task Creation Trends',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(
                              value.toInt());
                          return Text('${date.month}/${date.year}');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: tasksByMonth.entries.map((entry) {
                        return FlSpot(
                          entry.key.millisecondsSinceEpoch.toDouble(),
                          entry.value.toDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
