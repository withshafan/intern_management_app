import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/intern_service.dart';
import '../services/task_service.dart';
import '../models/intern.dart';
import '../models/task.dart';
import '../widgets/glass_card.dart';
import '../widgets/shimmer_loading.dart';
import '../theme/app_colors.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final InternService _internService = InternService();
  final TaskService _taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTasksByStatusChart().animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
            const SizedBox(height: 16),
            _buildInternProgressChart().animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1),
            const SizedBox(height: 16),
            _buildTasksCompletedChart().animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksByStatusChart() {
    return StreamBuilder<List<Task>>(
      stream: _taskService.getTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ShimmerLoading.statCard();
        }
        final tasks = snapshot.data ?? [];
        if (tasks.isEmpty) {
          return const GlassCard(child: Center(child: Text('No task data available')));
        }

        int completed = tasks.where((t) => t.status == 'completed').length;
        int inProgress = tasks.where((t) => t.status == 'in-progress').length;
        int pending = tasks.where((t) => t.status == 'pending').length;

        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tasks by Status', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        value: completed.toDouble(),
                        color: AppColors.success,
                        title: '$completed',
                        radius: 50,
                        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      PieChartSectionData(
                        value: inProgress.toDouble(),
                        color: AppColors.primary,
                        title: '$inProgress',
                        radius: 50,
                        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      PieChartSectionData(
                        value: pending.toDouble(),
                        color: AppColors.warning,
                        title: '$pending',
                        radius: 50,
                        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _indicator(AppColors.success, 'Completed'),
                  _indicator(AppColors.primary, 'In Progress'),
                  _indicator(AppColors.warning, 'Pending'),
                ],
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
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildInternProgressChart() {
    return StreamBuilder<List<Intern>>(
      stream: _internService.getInterns(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ShimmerLoading.statCard();
        }
        final interns = snapshot.data ?? [];
        if (interns.isEmpty) {
          return const GlassCard(child: Center(child: Text('No intern data available')));
        }

        interns.sort((a, b) => b.progress.compareTo(a.progress));

        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Intern Progress', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              SizedBox(
                height: 250,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 1.0,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= interns.length) return const SizedBox.shrink();
                            String name = interns[value.toInt()].name;
                            if (name.length > 5) name = name.substring(0, 5) + '.';
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(name, style: const TextStyle(fontSize: 10)),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: interns.asMap().entries.map((e) {
                      final i = e.key;
                      final intern = e.value;
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: intern.progress,
                            color: intern.progress >= 0.7 ? AppColors.success : (intern.progress >= 0.4 ? AppColors.warning : AppColors.danger),
                            width: 16,
                            borderRadius: BorderRadius.circular(4),
                          )
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTasksCompletedChart() {
    return StreamBuilder<List<Task>>(
      stream: _taskService.getTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ShimmerLoading.statCard();
        }
        final tasks = snapshot.data ?? [];
        final completedTasks = tasks.where((t) => t.status == 'completed').toList();
        if (completedTasks.isEmpty) {
          return const GlassCard(child: Center(child: Text('No completed tasks yet')));
        }

        Map<int, int> weeklyData = {};
        for (var t in completedTasks) {
          try {
            DateTime d = DateTime.parse(t.dueDate);
            int week = ((d.difference(DateTime(d.year, 1, 1)).inDays) / 7).floor();
            weeklyData[week] = (weeklyData[week] ?? 0) + 1;
          } catch (_) {}
        }
        
        List<MapEntry<int, int>> sortedWeeks = weeklyData.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
        if (sortedWeeks.length > 10) sortedWeeks = sortedWeeks.sublist(sortedWeeks.length - 10);

        List<FlSpot> spots = [];
        for (int i = 0; i < sortedWeeks.length; i++) {
          spots.add(FlSpot(i.toDouble(), sortedWeeks[i].value.toDouble()));
        }

        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Task Completion Trend', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
