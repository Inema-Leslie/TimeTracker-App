import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/time_entry_provider.dart';
import '../models/project.dart';
import '../models/task.dart';

class AddTimeEntryScreen extends StatefulWidget {
  const AddTimeEntryScreen({super.key});

  @override
  State<AddTimeEntryScreen> createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  
  Project? _selectedProject;
  Task? _selectedTask;
  DateTime _selectedDate = DateTime.now();
  int _hours = 0;
  int _minutes = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Time Entry'),
      ),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Project Dropdown
                DropdownButtonFormField<Project>(
                  decoration: const InputDecoration(
                    labelText: 'Project',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedProject,
                  items: provider.projects.map((project) {
                    return DropdownMenuItem(
                      value: project,
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
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
                  onChanged: (project) {
                    setState(() {
                      _selectedProject = project;
                      _selectedTask = null; // Reset task when project changes
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a project';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Task Dropdown (only shown if project is selected)
                if (_selectedProject != null)
                  DropdownButtonFormField<Task>(
                    decoration: const InputDecoration(
                      labelText: 'Task',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedTask,
                    items: provider
                        .getTasksForProject(_selectedProject!.id)
                        .map((task) {
                      return DropdownMenuItem(
                        value: task,
                        child: Text(task.name),
                      );
                    }).toList(),
                    onChanged: (task) {
                      setState(() {
                        _selectedTask = task;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a task';
                      }
                      return null;
                    },
                  ),

                const SizedBox(height: 16),

                // Date Picker
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMM dd, yyyy').format(_selectedDate),
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Time Input (Hours and Minutes)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Hours',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: _hours.toString(),
                        onChanged: (value) {
                          setState(() {
                            _hours = int.tryParse(value) ?? 0;
                          });
                        },
                        validator: (value) {
                          final hours = int.tryParse(value ?? '');
                          if (hours == null || hours < 0) {
                            return 'Enter valid hours';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Minutes',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: _minutes.toString(),
                        onChanged: (value) {
                          setState(() {
                            _minutes = int.tryParse(value) ?? 0;
                          });
                        },
                        validator: (value) {
                          final minutes = int.tryParse(value ?? '');
                          if (minutes == null || minutes < 0 || minutes >= 60) {
                            return 'Minutes must be 0-59';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Notes Field
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some notes';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Save Button
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final totalMinutes = (_hours * 60) + _minutes;
                      
                      if (totalMinutes == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a time greater than 0'),
                          ),
                        );
                        return;
                      }

                      await provider.addTimeEntry(
                        _selectedProject!.id,
                        _selectedTask!.id,
                        totalMinutes,
                        _selectedDate,
                        _notesController.text,
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Time entry added successfully'),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save Entry'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}