import 'package:flutter/material.dart';
import '../services/intern_service.dart';
import '../services/task_service.dart';
import '../models/intern.dart';
import '../models/task.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final InternService _internService = InternService();
  final TaskService _taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // We'll combine streams using StreamBuilder for interns and tasks
            StreamBuilder<List<Intern>>(
              stream: _internService.getInterns(),
              builder: (context, internSnapshot) {
                if (internSnapshot.hasError) {
                  return Text('Error loading interns: ${internSnapshot.error}');
                }
                if (internSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final interns = internSnapshot.data ?? [];
                final int totalInterns = interns.length;
                final double avgProgress = totalInterns > 0
                    ? interns.fold(0.0, (sum, i) => sum + i.progress) / totalInterns
                    : 0.0;

                return StreamBuilder<List<Task>>(
                  stream: _taskService.getTasks(),
                  builder: (context, taskSnapshot) {
                    if (taskSnapshot.hasError) {
                      return Text('Error loading tasks: ${taskSnapshot.error}');
                    }
                    if (taskSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final tasks = taskSnapshot.data ?? [];
                    final int totalTasks = tasks.length;
                    final int completedTasks =
                        tasks.where((t) => t.status == 'completed').length;
                    final int pendingTasks =
                        tasks.where((t) => t.status != 'completed').length;

                    // Stats cards
                    return Column(
                      children: [
                        // Row 1: Total Interns + Avg Progress
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Total Interns',
                                totalInterns.toString(),
                                Icons.people,
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'Avg Progress',
                                '${(avgProgress * 100).toInt()}%',
                                Icons.trending_up,
                                Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Row 2: Total Tasks + Completed
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Total Tasks',
                                totalTasks.toString(),
                                Icons.task,
                                Colors.purple,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'Completed',
                                completedTasks.toString(),
                                Icons.check_circle,
                                Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Pending tasks row (full width)
                        _buildStatCard(
                          'Pending Tasks',
                          pendingTasks.toString(),
                          Icons.pending,
                          Colors.red,
                        ),
                        const SizedBox(height: 24),

                        // Recent activity section
                        const Divider(thickness: 2),
                        const SizedBox(height: 12),
                        const Text(
                          'Recent Tasks',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Show up to 5 most recent tasks (by id, which is timestamp-based)
                        if (tasks.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'No tasks created yet',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          ..._buildRecentTasks(tasks),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRecentTasks(List<Task> tasks) {
    // Sort by id (timestamp) descending to show newest first
    final sorted = List<Task>.from(tasks)
      ..sort((a, b) => b.id.compareTo(a.id));
    final recent = sorted.take(5).toList();

    return recent.map((task) {
      Color statusColor;
      switch (task.status) {
        case 'completed':
          statusColor = Colors.green;
          break;
        case 'in-progress':
          statusColor = Colors.orange;
          break;
        default:
          statusColor = Colors.red;
      }

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: Icon(Icons.task, color: statusColor),
          title: Text(task.title),
          subtitle: Text(task.dueDate),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              task.status.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
          isThreeLine: false,
        ),
      );
    }).toList();
  }
}
