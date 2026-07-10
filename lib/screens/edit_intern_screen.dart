import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/intern_service.dart';
import '../models/intern.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../theme/app_colors.dart';

class EditInternScreen extends StatefulWidget {
  final Intern intern;
  const EditInternScreen({super.key, required this.intern});

  @override
  State<EditInternScreen> createState() => _EditInternScreenState();
}

class _EditInternScreenState extends State<EditInternScreen> {
  final InternService _internService = InternService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _departmentController = TextEditingController();
  final _joinDateController = TextEditingController();

  double _progress = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.intern.name;
    _emailController.text = widget.intern.email;
    _departmentController.text = widget.intern.department;
    _joinDateController.text = widget.intern.joinDate;
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.cardBackground,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: AppColors.background,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _joinDateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _updateIntern() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final department = _departmentController.text.trim();
    final joinDate = _joinDateController.text.trim();

    if (name.isEmpty || email.isEmpty || department.isEmpty || joinDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields', style: TextStyle(color: Colors.white)), backgroundColor: AppColors.danger),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedIntern = Intern(
        id: widget.intern.id, // Keep the same ID
        name: name,
        email: email,
        department: department,
        joinDate: joinDate,
        progress: _progress, 
      );

      await _internService.updateIntern(updatedIntern);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Intern $name updated!')),
        );
        Navigator.pop(context); // Go back after saving
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
        title: const Text('Edit Intern'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: Theme.of(context).brightness == Brightness.dark 
                    ? const [AppColors.background, Color(0xFF1A1A2E)]
                    : const [AppColors.lightBackground, Color(0xFFE2E8F0)],
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
                    const Text('Intern Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _departmentController,
                      label: 'Department',
                      icon: Icons.business_outlined,
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _joinDateController,
                      label: 'Join Date',
                      icon: Icons.calendar_today_outlined,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Initial Progress', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                              Text('${(_progress * 100).toInt()}%', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.primary,
                              inactiveTrackColor: AppColors.primary.withOpacity(0.2),
                              thumbColor: AppColors.primary,
                              overlayColor: AppColors.primary.withOpacity(0.2),
                              trackHeight: 4,
                            ),
                            child: Slider(
                              value: _progress,
                              onChanged: (val) => setState(() => _progress = val),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.2),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      label: 'Update Intern',
                      isLoading: _isLoading,
                      onPressed: _updateIntern,
                    ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.9, 0.9)),
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
