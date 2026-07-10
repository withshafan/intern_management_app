import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/intern_service.dart';
import '../models/intern.dart';
import '../widgets/glass_card.dart';
import '../widgets/animated_progress_ring.dart';
import '../widgets/shimmer_loading.dart';
import '../theme/app_colors.dart';
import 'intern_detail_screen.dart';
import 'add_intern_screen.dart';

class InternsListScreen extends StatefulWidget {
  const InternsListScreen({super.key});

  @override
  State<InternsListScreen> createState() => _InternsListScreenState();
}

class _InternsListScreenState extends State<InternsListScreen> {
  final InternService _internService = InternService();
  String _searchQuery = '';
  String? _selectedDepartment;
  double? _minProgress;

  void _showDeleteDialog(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Intern'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _internService.deleteIntern(id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name deleted successfully')));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Intern Management')),
      body: Column(
        children: [
          // Search and Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GlassCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search by name...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                  const Divider(),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('Engineering'),
                          selected: _selectedDepartment == 'Engineering',
                          onSelected: (val) => setState(() => _selectedDepartment = val ? 'Engineering' : null),
                          selectedColor: AppColors.primary.withOpacity(0.2),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Design'),
                          selected: _selectedDepartment == 'Design',
                          onSelected: (val) => setState(() => _selectedDepartment = val ? 'Design' : null),
                          selectedColor: AppColors.primary.withOpacity(0.2),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Marketing'),
                          selected: _selectedDepartment == 'Marketing',
                          onSelected: (val) => setState(() => _selectedDepartment = val ? 'Marketing' : null),
                          selectedColor: AppColors.primary.withOpacity(0.2),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('High Performers (>80%)'),
                          selected: _minProgress == 0.8,
                          onSelected: (val) => setState(() => _minProgress = val ? 0.8 : null),
                          selectedColor: AppColors.success.withOpacity(0.2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // List
          Expanded(
            child: StreamBuilder<List<Intern>>(
              stream: _internService.searchInterns(
                query: _searchQuery,
                department: _selectedDepartment,
                minProgress: _minProgress,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(itemCount: 5, itemBuilder: (_, __) => ShimmerLoading.listTile());
                }

                final interns = snapshot.data ?? [];
                if (interns.isEmpty) {
                  return const Center(
                    child: Text('No interns found.', style: TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: interns.length,
                  itemBuilder: (context, index) {
                    final intern = interns[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: GlassCard(
                        padding: EdgeInsets.zero,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => InternDetailScreen(intern: intern)));
                        },
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.2),
                            child: Text(
                              intern.name.isNotEmpty ? intern.name[0].toUpperCase() : '?',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ),
                          title: Text(intern.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Department: ${intern.department}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedProgressRing(
                                progress: intern.progress,
                                color: intern.progress >= 0.7 ? AppColors.success : (intern.progress >= 0.4 ? AppColors.warning : AppColors.danger),
                                size: 40,
                                strokeWidth: 4,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                                onPressed: () => _showDeleteDialog(context, intern.id, intern.name),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms).slideY(begin: 0.1);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddInternScreen()));
          },
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
