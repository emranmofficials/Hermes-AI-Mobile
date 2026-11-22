class EnvSecret {
  String key;
  String value;
  String category;
  bool isMasked;

  EnvSecret({
    required this.key,
    required this.value,
    this.category = 'LLM API Keys',
    this.isMasked = true,
  });

  factory EnvSecret.fromJson(Map<String, dynamic> json) {
    return EnvSecret(
      key: json['key'] ?? '',
      value: json['value'] ?? '',
      category: json['category'] ?? 'LLM API Keys',
      isMasked: json['isMasked'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
      'category': category,
      'isMasked': isMasked,
    };
  }
}
