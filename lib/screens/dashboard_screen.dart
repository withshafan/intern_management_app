import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/intern_service.dart';
import '../services/task_service.dart';
import '../models/intern.dart';
import '../models/task.dart';
import '../widgets/glass_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/animated_progress_ring.dart';
import '../widgets/shimmer_loading.dart';
import '../theme/app_colors.dart';

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
      appBar: AppBar(title: const Text('Dashboard')),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatsGrid().animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
              _buildDueSoonOverdue().animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
              _buildAnalyticsPreview().animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
              _buildRecentTasks().animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        // Large Interns Card
        StreamBuilder<List<Intern>>(
          stream: _internService.getInterns(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return ShimmerLoading.statCard();
            final interns = snapshot.data ?? [];
            final totalInterns = interns.length;
            final double avgProgress = totalInterns > 0 ? interns.fold(0.0, (sum, i) => sum + i.progress) / totalInterns : 0.0;
            return GlassCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.people_alt, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(height: 12),
                        Text('$totalInterns', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.primary)),
                        const Text('Total Interns', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  AnimatedProgressRing(
                    progress: avgProgress,
                    color: AppColors.primary,
                    size: 80,
                    strokeWidth: 8,
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        // Tasks Stats
        StreamBuilder<List<Task>>(
          stream: _taskService.getTasks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Row(
                children: [
                  Expanded(child: ShimmerLoading.statCard()),
                  const SizedBox(width: 12),
                  Expanded(child: ShimmerLoading.statCard()),
                ],
              );
            }
            final tasks = snapshot.data ?? [];
            final pendingTasks = tasks.where((t) => t.status != 'completed').length;
            final completedTasks = tasks.where((t) => t.status == 'completed').length;

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: StatCard(icon: Icons.task_alt, label: 'Completed', value: completedTasks, accentColor: AppColors.success)),
                    const SizedBox(width: 12),
                    Expanded(child: StatCard(icon: Icons.pending_actions, label: 'Pending', value: pendingTasks, accentColor: AppColors.warning)),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDueSoonOverdue() {
    return StreamBuilder<List<Task>>(
      stream: _taskService.overdueTasks(),
      builder: (context, overdueSnap) {
        return StreamBuilder<List<Task>>(
          stream: _taskService.dueTodayTasks(),
          builder: (context, dueTodaySnap) {
            if (overdueSnap.connectionState == ConnectionState.waiting || dueTodaySnap.connectionState == ConnectionState.waiting) {
              return ShimmerLoading.statCard();
            }
            final overdue = overdueSnap.data ?? [];
            final dueToday = dueTodaySnap.data ?? [];

            if (overdue.isEmpty && dueToday.isEmpty) return const SizedBox.shrink();

            return GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Attention Needed', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.danger)),
                  const SizedBox(height: 12),
                  if (overdue.isNotEmpty) ...[
                    Text('${overdue.length} Overdue Task(s)', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger)),
                    ...overdue.take(3).map((t) => _buildMiniTask(t, AppColors.danger)),
                  ],
                  if (dueToday.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('${dueToday.length} Due Today', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.warning)),
                    ...dueToday.take(3).map((t) => _buildMiniTask(t, AppColors.warning)),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMiniTask(Task task, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildAnalyticsPreview() {
    return StreamBuilder<List<Task>>(
      stream: _taskService.getTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return ShimmerLoading.statCard();
        final tasks = snapshot.data ?? [];
        if (tasks.isEmpty) return const SizedBox.shrink();

        int completed = tasks.where((t) => t.status == 'completed').length;
        int inProgress = tasks.where((t) => t.status == 'in-progress').length;
        int pending = tasks.where((t) => t.status == 'pending').length;

        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Task Breakdown', style: Theme.of(context).textTheme.titleLarge),
                  const Text('See Analytics →', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: Row(
                  children: [
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 20,
                          sections: [
                            PieChartSectionData(value: completed.toDouble(), color: AppColors.success, radius: 20, showTitle: false),
                            PieChartSectionData(value: inProgress.toDouble(), color: AppColors.primary, radius: 20, showTitle: false),
                            PieChartSectionData(value: pending.toDouble(), color: AppColors.warning, radius: 20, showTitle: false),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _indicator(AppColors.success, 'Completed ($completed)'),
                          const SizedBox(height: 4),
                          _indicator(AppColors.primary, 'In Progress ($inProgress)'),
                          const SizedBox(height: 4),
                          _indicator(AppColors.warning, 'Pending ($pending)'),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _indicator(Color color, String text) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildRecentTasks() {
    return StreamBuilder<List<Task>>(
      stream: _taskService.getTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(children: List.generate(3, (index) => ShimmerLoading.listTile()));
        }
        final tasks = snapshot.data ?? [];
        if (tasks.isEmpty) return const SizedBox.shrink();

        final recent = (List<Task>.from(tasks)..sort((a, b) => b.id.compareTo(a.id))).take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
              child: Text('Recent Tasks', style: Theme.of(context).textTheme.titleLarge),
            ),
            ...recent.asMap().entries.map((e) {
              final index = e.key;
              final task = e.value;
              Color statusColor = AppColors.danger;
              if (task.status == 'completed') statusColor = AppColors.success;
              if (task.status == 'in-progress') statusColor = AppColors.primary;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: GlassCard(
                  padding: EdgeInsets.zero,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: statusColor, width: 4)),
                    ),
                    child: ListTile(
                      title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Due: ${task.dueDate}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: Text(task.status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms).slideY(begin: 0.1),
              );
            }),
          ],
        );
      },
    );
  }
}
