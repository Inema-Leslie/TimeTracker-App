import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../models/time_entry.dart';

class TimeEntryProvider extends ChangeNotifier {
  late final LocalStorage storage;
  
  // Data collections
  List<Project> _projects = [];
  List<Task> _tasks = [];
  List<TimeEntry> _timeEntries = [];

  // Getters for UI to access data
  List<Project> get projects => List.unmodifiable(_projects);
  List<Task> get tasks => List.unmodifiable(_tasks);
  List<TimeEntry> get timeEntries => List.unmodifiable(_timeEntries);

  TimeEntryProvider() {
    storage = LocalStorage('time_tracker_data');
    loadData();
  }

  // Load all data from local storage
  Future<void> loadData() async {
    await storage.ready;
    
    // Load projects
    final projectsJson = storage.getItem('projects') as List? ?? [];
    _projects = projectsJson
        .map((item) => Project.fromJson(jsonDecode(item)))
        .toList();

    // Load tasks
    final tasksJson = storage.getItem('tasks') as List? ?? [];
    _tasks = tasksJson
        .map((item) => Task.fromJson(jsonDecode(item)))
        .toList();

    // Load time entries
    final entriesJson = storage.getItem('timeEntries') as List? ?? [];
    _timeEntries = entriesJson
        .map((item) => TimeEntry.fromJson(jsonDecode(item)))
        .toList();

    notifyListeners();
  }

  // Save all data to local storage
  Future<void> _saveData() async {
    await storage.ready;
    
    await storage.setItem(
      'projects',
      _projects.map((p) => jsonEncode(p.toJson())).toList(),
    );
    
    await storage.setItem(
      'tasks',
      _tasks.map((t) => jsonEncode(t.toJson())).toList(),
    );
    
    await storage.setItem(
      'timeEntries',
      _timeEntries.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  // Project operations
  Future<void> addProject(String name, String color) async {
    final project = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      color: color,
      createdAt: DateTime.now(),
    );
    
    _projects.add(project);
    await _saveData();
    notifyListeners();
  }

  Future<void> updateProject(Project updatedProject) async {
    final index = _projects.indexWhere((p) => p.id == updatedProject.id);
    if (index != -1) {
      _projects[index] = updatedProject;
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> deleteProject(String projectId) async {
    // Also delete associated tasks and time entries
    _tasks.removeWhere((t) => t.projectId == projectId);
    _timeEntries.removeWhere((e) => e.projectId == projectId);
    _projects.removeWhere((p) => p.id == projectId);
    
    await _saveData();
    notifyListeners();
  }

  // Task operations
  Future<void> addTask(String projectId, String name) async {
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      projectId: projectId,
      name: name,
      createdAt: DateTime.now(),
    );
    
    _tasks.add(task);
    await _saveData();
    notifyListeners();
  }

  Future<void> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    // Also delete associated time entries
    _timeEntries.removeWhere((e) => e.taskId == taskId);
    _tasks.removeWhere((t) => t.id == taskId);
    
    await _saveData();
    notifyListeners();
  }

  // Time entry operations
  Future<void> addTimeEntry(
    String projectId,
    String taskId,
    int totalMinutes,
    DateTime date,
    String notes,
  ) async {
    final entry = TimeEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      projectId: projectId,
      taskId: taskId,
      totalMinutes: totalMinutes,
      date: date,
      notes: notes,
      createdAt: DateTime.now(),
    );
    
    _timeEntries.add(entry);
    await _saveData();
    notifyListeners();
  }

  Future<void> updateTimeEntry(TimeEntry updatedEntry) async {
    final index = _timeEntries.indexWhere((e) => e.id == updatedEntry.id);
    if (index != -1) {
      _timeEntries[index] = updatedEntry;
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> deleteTimeEntry(String entryId) async {
    _timeEntries.removeWhere((e) => e.id == entryId);
    await _saveData();
    notifyListeners();
  }

  // Helper methods
  List<Task> getTasksForProject(String projectId) {
    return _tasks.where((t) => t.projectId == projectId).toList();
  }

  List<TimeEntry> getEntriesForProject(String projectId) {
    return _timeEntries.where((e) => e.projectId == projectId).toList();
  }

  Map<String, int> getTimeGroupedByProject() {
    final Map<String, int> projectTime = {};
    
    for (var entry in _timeEntries) {
      projectTime[entry.projectId] = 
          (projectTime[entry.projectId] ?? 0) + entry.totalMinutes;
    }
    
    return projectTime;
  }
}