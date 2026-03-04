import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/time_entry_provider.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../models/time_entry.dart';
import 'add_time_entry_screen.dart';
import 'project_task_management_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProjectTaskManagementScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          final entries = provider.timeEntries;
          
          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer_off,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No time entries yet',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first entry',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          // Group entries by project for display
          final entriesByProject = <String, List<TimeEntry>>{};
          for (var entry in entries) {
            entriesByProject.putIfAbsent(entry.projectId, () => []).add(entry);
          }

          return ListView.builder(
            itemCount: entriesByProject.length,
            itemBuilder: (context, index) {
              final projectId = entriesByProject.keys.elementAt(index);
              final projectEntries = entriesByProject[projectId]!;
              
              // Find project name
              final project = provider.projects.firstWhere(
                (p) => p.id == projectId,
                orElse: () => Project(
                  id: 'unknown',
                  name: 'Unknown Project',
                  color: 'FF808080',
                  createdAt: DateTime.now(),
                ),
              );

              // Calculate total time for project
              final totalMinutes = projectEntries.fold(
                0,
                (sum, entry) => sum + entry.totalMinutes,
              );
              
              final hours = totalMinutes ~/ 60;
              final minutes = totalMinutes % 60;

              return Card(
                margin: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        project.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        '${hours}h ${minutes}m total',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    ...projectEntries.map((entry) {
                      final task = provider.tasks.firstWhere(
                        (t) => t.id == entry.taskId,
                        orElse: () => Task(
                          id: 'unknown',
                          projectId: projectId,
                          name: 'Unknown Task',
                          createdAt: DateTime.now(),
                        ),
                      );
                      
                      final entryHours = entry.totalMinutes ~/ 60;
                      final entryMinutes = entry.totalMinutes % 60;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(
                            int.parse('0xFF${project.color.substring(0, 6)}'),
                          ),
                          child: Text(
                            entryHours > 0 ? '$entryHours h' : '$entryMinutes m',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        title: Text(task.name),
                        subtitle: Text(
                          '${_formatDate(entry.date)} - ${entry.notes}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteEntry(context, entry.id),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTimeEntryScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _deleteEntry(BuildContext context, String entryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<TimeEntryProvider>(context, listen: false)
                  .deleteTimeEntry(entryId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}