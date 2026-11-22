import 'tool_call.dart';

enum MessageRole { user, assistant, system }

class Message {
  final String id;
  final String sessionId;
  final MessageRole role;
  String content;
  final DateTime timestamp;
  bool isStreaming;
  List<ToolCall> toolCalls;

  Message({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.isStreaming = false,
    List<ToolCall>? toolCalls,
  })  : timestamp = timestamp ?? DateTime.now(),
        toolCalls = toolCalls ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'sessionId': sessionId,
    'role': role.name,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'isStreaming': isStreaming,
    'toolCalls': toolCalls.map((t) => t.toJson()).toList(),
  };

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      role: MessageRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => MessageRole.user,
      ),
      content: json['content'] as String? ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isStreaming: json['isStreaming'] as bool? ?? false,
      toolCalls: (json['toolCalls'] as List?)
              ?.map((t) => ToolCall.fromJson(Map<String, dynamic>.from(t)))
              .toList() ??
          [],
    );
  }
}
