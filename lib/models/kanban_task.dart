enum TaskStatus { todo, inProgress, review, done }
enum TaskPriority { low, medium, high, critical }

class KanbanTask {
  final String id;
  String title;
  String description;
  TaskStatus status;
  TaskPriority priority;
  String? assignedSubagent;
  List<String> logs;
  final DateTime createdAt;
  DateTime updatedAt;

  KanbanTask({
    required this.id,
    required this.title,
    required this.description,
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    this.assignedSubagent,
    List<String>? logs,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : logs = logs ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'status': status.name,
    'priority': priority.name,
    'assignedSubagent': assignedSubagent,
    'logs': logs,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory KanbanTask.fromJson(Map<String, dynamic> json) {
    return KanbanTask(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Untitled Task',
      description: json['description'] as String? ?? '',
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.todo,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      assignedSubagent: json['assignedSubagent'] as String?,
      logs: (json['logs'] as List?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}
