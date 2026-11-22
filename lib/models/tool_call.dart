enum ToolStatus { pending, running, completed, error }

class ToolCall {
  final String id;
  final String name;
  final Map<String, dynamic> arguments;
  ToolStatus status;
  String? output;
  final DateTime startedAt;
  DateTime? completedAt;

  ToolCall({
    required this.id,
    required this.name,
    required this.arguments,
    this.status = ToolStatus.pending,
    this.output,
    DateTime? startedAt,
    this.completedAt,
  }) : startedAt = startedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'arguments': arguments,
    'status': status.name,
    'output': output,
    'startedAt': startedAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };

  factory ToolCall.fromJson(Map<String, dynamic> json) {
    return ToolCall(
      id: json['id'] as String,
      name: json['name'] as String,
      arguments: Map<String, dynamic>.from(json['arguments'] as Map? ?? {}),
      status: ToolStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ToolStatus.completed,
      ),
      output: json['output'] as String?,
      startedAt: DateTime.tryParse(json['startedAt'] ?? '') ?? DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'])
          : null,
    );
  }
}
