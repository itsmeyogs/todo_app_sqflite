import 'package:flutter/foundation.dart' show immutable;

const String tasksTable = 'tasks';

class TasksFields {
  static final List<String> values = [
    id,
    title,
    description,
    date,
    startTime,
    endTime,
    priority,
    isCompleted,
  ];

  // Column names for task tables
  static const id = 'id';
  static const title = 'title';
  static const description = 'description';
  static const date = 'date';
  static const startTime = 'startTime';
  static const endTime = 'endTime';
  static const priority = 'priority';
  static const isCompleted = 'isCompleted';
}

@immutable
class Task {
  final int? id;
  final String title;
  final String description;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String priority;
  final bool isCompleted;

  const Task({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.priority,
    required this.isCompleted,
  });

  Task copy({
    int? id,
    String? title,
    String? description,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? priority,
    bool? isCompleted,
  }) =>
      Task(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        date: date ?? this.date,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        priority: priority ?? this.priority,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      TasksFields.id: id,
      TasksFields.title: title,
      TasksFields.description: description,
      TasksFields.date: date.toIso8601String(),
      TasksFields.startTime: startTime,
      TasksFields.endTime: endTime,
      TasksFields.priority : priority,
      TasksFields.isCompleted: isCompleted ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map[TasksFields.id] != null ? map[TasksFields.id] as int : null,
      title: map[TasksFields.title] as String,
      description: map[TasksFields.description] as String,
      date: DateTime.parse(map[TasksFields.date] as String),
      startTime: map[TasksFields.startTime] as String,
      endTime: map[TasksFields.endTime] as String,
      priority: map[TasksFields.priority] as String,
      isCompleted: map[TasksFields.isCompleted] == 1,
    );
  }
}
