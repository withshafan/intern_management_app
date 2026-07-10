import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/task_service.dart';
import '../services/notification_service.dart';
import '../models/task.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../theme/app_colors.dart';

class AddTaskScreen extends StatefulWidget {
  final String internId;

  const AddTaskScreen({super.key, required this.internId});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TaskService _taskService = TaskService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final dueDate = _dueDateController.text.trim();

    if (title.isEmpty || description.isEmpty || dueDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields', style: TextStyle(color: Colors.white)), backgroundColor: AppColors.danger),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newTask = Task(
        id: '', // Will be generated
        internId: widget.internId,
        title: title,
        description: description,
        dueDate: dueDate,
        status: 'pending',
      );

      final createdTask = await _taskService.addTask(newTask);

      // Schedule notification (Phase 6)
      try {
        final parsedDate = DateTime.parse(dueDate);
        // Remind at 9:00 AM on due date
        final reminderDate = DateTime(parsedDate.year, parsedDate.month, parsedDate.day, 9, 0);
        await NotificationService.scheduleTaskReminder(
          id: createdTask.id.hashCode,
          title: 'Task Due: $title',
          body: 'This task is due today.',
          dueDate: reminderDate,
        );
      } catch (_) {
        // Date parse error, ignore notification
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task "$title" added!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Add Task'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.background, Color(0xFF1A1A2E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('New Task', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: _titleController,
                      label: 'Task Title',
                      icon: Icons.title,
                    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _dueDateController,
                      label: 'Due Date (e.g., 2025-07-15)',
                      icon: Icons.calendar_today_outlined,
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      label: 'Save Task',
                      isLoading: _isLoading,
                      onPressed: _saveTask,
                    ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.9, 0.9)),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}
