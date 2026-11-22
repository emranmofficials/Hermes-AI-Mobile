class MemoryItem {
  final String id;
  String key;
  String content;
  String category; // 'user', 'project', 'preference'
  final DateTime createdAt;
  DateTime updatedAt;

  MemoryItem({
    required this.id,
    required this.key,
    required this.content,
    this.category = 'preference',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'key': key,
    'content': content,
    'category': category,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory MemoryItem.fromJson(Map<String, dynamic> json) {
    return MemoryItem(
      id: json['id'] as String,
      key: json['key'] as String,
      content: json['content'] as String? ?? '',
      category: json['category'] as String? ?? 'preference',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}
