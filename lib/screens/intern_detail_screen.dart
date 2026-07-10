import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/intern_service.dart';
import '../services/task_service.dart';
import '../models/intern.dart';
import '../models/task.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/animated_progress_ring.dart';
import '../widgets/shimmer_loading.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';

class InternDetailScreen extends StatefulWidget {
  final Intern intern;

  const InternDetailScreen({super.key, required this.intern});

  @override
  State<InternDetailScreen> createState() => _InternDetailScreenState();
}

class _InternDetailScreenState extends State<InternDetailScreen> {
  final TaskService _taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    // Wrap in stream builder to listen to this intern's changes (optional, but good for realtime)
    // For now we just use widget.intern, but let's fetch realtime tasks
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: Theme.of(context).brightness == Brightness.dark 
                        ? const [AppColors.background, AppColors.cardBackground]
                        : const [AppColors.lightBackground, Color(0xFFE2E8F0)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'avatar_${widget.intern.id}',
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                          child: Text(
                            widget.intern.name.isNotEmpty ? widget.intern.name[0].toUpperCase() : '?',
                            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(widget.intern.name, style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      Text(widget.intern.department, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                    ],
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Reusing AddInternScreen for edit by passing intern to it if supported, or we can build edit logic later in Phase 9 Forms
                  // For now, let's keep it simple or implement EditInternScreen later
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit available in Phase 9')));
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GlassCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Progress', style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            AnimatedProgressRing(
                              progress: widget.intern.progress,
                              color: widget.intern.progress >= 0.7 ? AppColors.success : AppColors.warning,
                              size: 80,
                              strokeWidth: 8,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Joined', style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            Text(widget.intern.joinDate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tasks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AddTaskScreen(internId: widget.intern.id)));
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Task'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          StreamBuilder<List<Task>>(
            stream: _taskService.getTasksForIntern(widget.intern.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(child: ShimmerLoading.listTile());
              }
              final tasks = snapshot.data ?? [];
              if (tasks.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text('No tasks assigned yet.', style: TextStyle(color: Colors.grey))),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final task = tasks[index];
                    Color statusColor = AppColors.danger;
                    if (task.status == 'completed') statusColor = AppColors.success;
                    if (task.status == 'in-progress') statusColor = AppColors.primary;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                      child: GlassCard(
                        padding: EdgeInsets.zero,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task, internName: widget.intern.name)));
                        },
                        child: Container(
                          decoration: BoxDecoration(border: Border(left: BorderSide(color: statusColor, width: 4))),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(task.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text('Due: ${task.dueDate}', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w500)),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                              child: Text(task.status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms).slideX(begin: 0.1),
                    );
                  },
                  childCount: tasks.length,
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
