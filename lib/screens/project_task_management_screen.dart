import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/time_entry_provider.dart';
import '../models/project.dart';
import '../models/task.dart';

class ProjectTaskManagementScreen extends StatefulWidget {
  const ProjectTaskManagementScreen({super.key});

  @override
  State<ProjectTaskManagementScreen> createState() =>
      _ProjectTaskManagementScreenState();
}

class _ProjectTaskManagementScreenState
    extends State<ProjectTaskManagementScreen> {
  final _projectController = TextEditingController();
  final _taskController = TextEditingController();
  final _colorController = TextEditingController(text: '4285F4'); // Default blue
  String? _selectedProjectId;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Projects & Tasks'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Projects'),
              Tab(text: 'Tasks'),
            ],
          ),
        ),
        body: Consumer<TimeEntryProvider>(
          builder: (context, provider, child) {
            return TabBarView(
              children: [
                // Projects Tab
                _buildProjectsTab(provider),
                // Tasks Tab
                _buildTasksTab(provider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProjectsTab(TimeEntryProvider provider) {
    return Column(
      children: [
        // Add Project Form
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _projectController,
                  decoration: const InputDecoration(
                    hintText: 'Project name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _colorController,
                  decoration: const InputDecoration(
                    hintText: 'Color',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 6,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (_projectController.text.isNotEmpty) {
                    provider.addProject(
                      _projectController.text,
                      _colorController.text.padRight(6, 'F'),
                    );
                    _projectController.clear();
                    _colorController.text = '4285F4';
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Project "${_projectController.text}" added'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
        ),

        // Projects List
        Expanded(
          child: provider.projects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No projects yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add a project above to get started',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: provider.projects.length,
                  itemBuilder: (context, index) {
                    final project = provider.projects[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(
                            int.parse('0xFF${project.color.substring(0, 6)}'),
                          ),
                          child: Text(
                            project.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(project.name),
                        subtitle: Text(
                          '${provider.getTasksForProject(project.id).length} tasks',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProject(context, provider, project),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTasksTab(TimeEntryProvider provider) {
    return Column(
      children: [
        // Add Task Form
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (provider.projects.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Please create a project first before adding tasks',
                          style: TextStyle(color: Colors.orange[800]),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    DropdownButtonFormField<Project>(
                      decoration: const InputDecoration(
                        labelText: 'Select Project',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedProjectId == null 
                          ? null 
                          : provider.projects.firstWhere(
                              (p) => p.id == _selectedProjectId,
                              orElse: () => provider.projects.first,
                            ),
                      hint: const Text('Choose a project'),
                      items: provider.projects.map((project) {
                        return DropdownMenuItem(
                          value: project,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Color(
                                    int.parse('0xFF${project.color.substring(0, 6)}'),
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(project.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (Project? project) {
                        setState(() {
                          _selectedProjectId = project?.id;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _taskController,
                            decoration: const InputDecoration(
                              hintText: 'Task name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (_taskController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a task name'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            if (_selectedProjectId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select a project'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            // Find the selected project
                            final selectedProject = provider.projects.firstWhere(
                              (p) => p.id == _selectedProjectId,
                            );

                            provider.addTask(
                              selectedProject.id,
                              _taskController.text,
                            );
                            
                            _taskController.clear();
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Task added to ${selectedProject.name}'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),

        // Tasks List Grouped by Project
        Expanded(
          child: provider.projects.isEmpty
              ? const SizedBox()
              : ListView.builder(
                  itemCount: provider.projects.length,
                  itemBuilder: (context, index) {
                    final project = provider.projects[index];
                    final tasks = provider.getTasksForProject(project.id);
                    
                    if (tasks.isEmpty) return const SizedBox();
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Color(
                                    int.parse('0xFF${project.color.substring(0, 6)}'),
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                project.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${tasks.length} ${tasks.length == 1 ? 'task' : 'tasks'}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...tasks.map((task) => Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 2,
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.task, size: 20),
                            title: Text(task.name),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteTask(context, provider, task),
                            ),
                          ),
                        )),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _deleteProject(BuildContext context, TimeEntryProvider provider, Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text(
          'Are you sure you want to delete "${project.name}"?\n\n'
          'This will also delete all associated tasks and time entries.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteProject(project.id);
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Project "${project.name}" deleted'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteTask(BuildContext context, TimeEntryProvider provider, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text(
          'Are you sure you want to delete "${task.name}"?\n\n'
          'This will also delete all associated time entries.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteTask(task.id);
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Task "${task.name}" deleted'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _projectController.dispose();
    _taskController.dispose();
    _colorController.dispose();
    super.dispose();
  }
}