class AgentProfile {
  final String id;
  String name;
  String role;
  String description;
  String soulContent; // System prompt instructions
  String preferredModel;
  bool isDefault;
  String iconName;

  AgentProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.description,
    required this.soulContent,
    this.preferredModel = 'gemini-3.8-flash',
    this.isDefault = false,
    this.iconName = 'psychology',
  });

  factory AgentProfile.fromJson(Map<String, dynamic> json) {
    return AgentProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      description: json['description'] ?? '',
      soulContent: json['soulContent'] ?? '',
      preferredModel: json['preferredModel'] ?? 'gemini-3.8-flash',
      isDefault: json['isDefault'] ?? false,
      iconName: json['iconName'] ?? 'psychology',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'description': description,
      'soulContent': soulContent,
      'preferredModel': preferredModel,
      'isDefault': isDefault,
      'iconName': iconName,
    };
  }
}
