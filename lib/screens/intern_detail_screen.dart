import 'package:flutter/material.dart';
import '../services/intern_service.dart';
import '../models/intern.dart';
import '../services/task_service.dart';
import '../models/task.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';

class InternDetailScreen extends StatefulWidget {
  final Intern intern;

  const InternDetailScreen({super.key, required this.intern});

  @override
  State<InternDetailScreen> createState() => _InternDetailScreenState();
}

class _InternDetailScreenState extends State<InternDetailScreen> {
  final InternService _internService = InternService();
  final TaskService _taskService = TaskService();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _departmentController;
  late TextEditingController _joinDateController;

  late double _progress;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current intern data
    _nameController = TextEditingController(text: widget.intern.name);
    _emailController = TextEditingController(text: widget.intern.email);
    _departmentController = TextEditingController(text: widget.intern.department);
    _joinDateController = TextEditingController(text: widget.intern.joinDate);
    _progress = widget.intern.progress;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _departmentController.dispose();
    _joinDateController.dispose();
    super.dispose();
  }

  Future<void> _updateIntern() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedIntern = Intern(
        id: widget.intern.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        department: _departmentController.text.trim(),
        joinDate: _joinDateController.text.trim(),
        progress: _progress,
      );

      await _internService.updateIntern(updatedIntern);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Intern updated successfully!')),
        );
        setState(() {
          _isEditing = false;
        });
        // Refresh the screen with new data
        // Since we don't pass the updated object back, we can pop and re-push
        // Or just set state and let user go back
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Intern' : 'Intern Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (_isEditing)
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      setState(() {
                        _isEditing = false;
                        // Reset fields to original
                        _nameController.text = widget.intern.name;
                        _emailController.text = widget.intern.email;
                        _departmentController.text = widget.intern.department;
                        _joinDateController.text = widget.intern.joinDate;
                        _progress = widget.intern.progress;
                      });
                    },
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    widget.intern.name.isNotEmpty
                        ? widget.intern.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Name field
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                enabled: _isEditing && !_isLoading,
              ),
              const SizedBox(height: 16),

              // Email field
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: _isEditing && !_isLoading,
              ),
              const SizedBox(height: 16),

              // Department field
              TextField(
                controller: _departmentController,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                enabled: _isEditing && !_isLoading,
              ),
              const SizedBox(height: 16),

              // Join Date field
              TextField(
                controller: _joinDateController,
                decoration: const InputDecoration(
                  labelText: 'Join Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                enabled: _isEditing && !_isLoading,
              ),
              const SizedBox(height: 24),

              // Progress
              Row(
                children: [
                  const Text('Progress:'),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Slider(
                      value: _progress,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      label: '${(_progress * 100).toInt()}%',
                      onChanged: _isEditing && !_isLoading
                          ? (value) {
                              setState(() {
                                _progress = value;
                              });
                            }
                          : null,
                    ),
                  ),
                  Text('${(_progress * 100).toInt()}%'),
                ],
              ),

              const SizedBox(height: 32),

              const Divider(thickness: 2),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tasks',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTaskScreen(internId: widget.intern.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Task'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              StreamBuilder<List<Task>>(
                stream: _taskService.getTasksForIntern(widget.intern.id),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final tasks = snapshot.data ?? [];
                  
                  if (tasks.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No tasks assigned yet.',
                        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task.description),
                              Text('Due: ${task.dueDate}', style: const TextStyle(color: Colors.red)),
                            ],
                          ),
                          trailing: Chip(
                            label: Text(
                              task.status,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            backgroundColor: task.status == 'completed'
                                ? Colors.green
                                : task.status == 'in-progress'
                                    ? Colors.orange
                                    : Colors.grey,
                          ),
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskDetailScreen(
                                  task: task,
                                  internName: widget.intern.name,
                                ),
                              ),
                            );
                            if (result == true) {
                              setState(() {}); 
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 32),

              // Save button (only shown in edit mode)
              if (_isEditing)
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateIntern,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Update Intern', style: TextStyle(fontSize: 18)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
