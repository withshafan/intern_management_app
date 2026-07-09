import 'package:flutter/material.dart';
import '../services/intern_service.dart';
import '../models/intern.dart';

class AddInternScreen extends StatefulWidget {
  const AddInternScreen({super.key});

  @override
  State<AddInternScreen> createState() => _AddInternScreenState();
}

class _AddInternScreenState extends State<AddInternScreen> {
  final InternService _internService = InternService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _joinDateController = TextEditingController();

  double _progress = 0.0;
  bool _isLoading = false;

  Future<void> _saveIntern() async {
    // Validate fields
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _departmentController.text.trim().isEmpty ||
        _joinDateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Generate a unique ID for the intern
      final String id = DateTime.now().millisecondsSinceEpoch.toString();

      final intern = Intern(
        id: id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        department: _departmentController.text.trim(),
        joinDate: _joinDateController.text.trim(),
        progress: _progress,
      );

      await _internService.addIntern(intern);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Intern added successfully!')),
        );
        Navigator.pop(context); // Go back to home screen
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
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _departmentController.dispose();
    _joinDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Intern'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Email
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Department
              TextField(
                controller: _departmentController,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Join Date
              TextField(
                controller: _joinDateController,
                decoration: const InputDecoration(
                  labelText: 'Join Date (e.g., Jan 2025)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24),

              // Progress Slider
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
                      onChanged: _isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _progress = value;
                              });
                            },
                    ),
                  ),
                  Text('${(_progress * 100).toInt()}%'),
                ],
              ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveIntern,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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
                    : const Text('Save Intern', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
