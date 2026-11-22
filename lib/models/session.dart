class Session {
  final String id;
  String title;
  final DateTime createdAt;
  DateTime updatedAt;
  String modelId;
  String previewText;

  Session({
    required this.id,
    required this.title,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.modelId = 'nousresearch/hermes-3-llama-3.1-405b',
    this.previewText = '',
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'modelId': modelId,
    'previewText': previewText,
  };

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'New Chat',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      modelId: json['modelId'] as String? ?? 'nousresearch/hermes-3-llama-3.1-405b',
      previewText: json['previewText'] as String? ?? '',
    );
  }
}
