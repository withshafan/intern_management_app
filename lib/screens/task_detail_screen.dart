import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/task_service.dart';
import '../services/notification_service.dart';
import '../models/task.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  final String internName;

  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.internName,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final TaskService _taskService = TaskService();
  bool _isLoading = false;
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.task.status;
  }

  Future<void> _updateStatus(String newStatus) async {
    if (newStatus == _currentStatus) return;
    setState(() {
      _isLoading = true;
      _currentStatus = newStatus;
    });

    try {
      final updated = Task(
        id: widget.task.id,
        internId: widget.task.internId,
        title: widget.task.title,
        description: widget.task.description,
        dueDate: widget.task.dueDate,
        status: newStatus,
      );
      await _taskService.updateTask(updated);

      if (newStatus == 'completed') {
        await NotificationService.cancel(widget.task.id.hashCode);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status updated')));
      }
    } catch (e) {
      setState(() {
        _currentStatus = widget.task.status; // Revert on error
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Delete Task', style: TextStyle(color: Colors.white)),
        content: Text('Delete "${widget.task.title}"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.white))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      await _taskService.deleteTask(widget.task.id);
      await NotificationService.cancel(widget.task.id.hashCode);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            onPressed: _isLoading ? null : _deleteTask,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Frosted background effect
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.background, Color(0xFF1A1A2E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.1)),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: const SizedBox(),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Assigned to: ${widget.internName}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Text(widget.task.title, style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 16),
                        const Text('Description', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text(widget.task.description, style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: AppColors.danger),
                            const SizedBox(width: 8),
                            Text('Due: ${widget.task.dueDate}', style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
                  const SizedBox(height: 32),
                  const Text('Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 16),
                  _buildStatusToggle('pending', 'Pending', Icons.schedule, AppColors.warning).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                  const SizedBox(height: 12),
                  _buildStatusToggle('in-progress', 'In Progress', Icons.autorenew, AppColors.primary).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                  const SizedBox(height: 12),
                  _buildStatusToggle('completed', 'Completed', Icons.check_circle, AppColors.success).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                  
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 24.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusToggle(String statusValue, String label, IconData icon, Color color) {
    final isSelected = _currentStatus == statusValue;
    return GestureDetector(
      onTap: () => _updateStatus(statusValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : AppColors.cardBackground,
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : Colors.white,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check, color: color)
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 1200.ms, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
