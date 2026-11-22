class SystemLog {
  final DateTime timestamp;
  final String level; // INFO, WARN, ERROR, DEBUG
  final String tag;
  final String message;

  SystemLog({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
  });

  factory SystemLog.fromJson(Map<String, dynamic> json) {
    return SystemLog(
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      level: json['level'] ?? 'INFO',
      tag: json['tag'] ?? 'SYSTEM',
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'level': level,
      'tag': tag,
      'message': message,
    };
  }
}
