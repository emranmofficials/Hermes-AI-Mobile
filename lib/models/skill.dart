class Skill {
  final String id;
  final String name;
  final String description;
  final String trigger;
  final String instructions;
  final String category;
  bool isEnabled;

  Skill({
    required this.id,
    required this.name,
    required this.description,
    required this.trigger,
    required this.instructions,
    this.category = 'General',
    this.isEnabled = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'trigger': trigger,
    'instructions': instructions,
    'category': category,
    'isEnabled': isEnabled,
  };

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      trigger: json['trigger'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }
}
