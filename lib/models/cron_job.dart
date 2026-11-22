class CronJob {
  final String id;
  String name;
  String cronExpression; // e.g. 0 9 * * *
  String prompt;
  String targetChannel; // Chat, WhatsApp, Telegram
  bool isEnabled;
  DateTime? lastRun;
  String lastOutput;

  CronJob({
    required this.id,
    required this.name,
    required this.cronExpression,
    required this.prompt,
    this.targetChannel = 'Chat',
    this.isEnabled = true,
    this.lastRun,
    this.lastOutput = '',
  });

  factory CronJob.fromJson(Map<String, dynamic> json) {
    return CronJob(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      cronExpression: json['cronExpression'] ?? '0 9 * * *',
      prompt: json['prompt'] ?? '',
      targetChannel: json['targetChannel'] ?? 'Chat',
      isEnabled: json['isEnabled'] ?? true,
      lastRun: json['lastRun'] != null ? DateTime.tryParse(json['lastRun']) : null,
      lastOutput: json['lastOutput'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cronExpression': cronExpression,
      'prompt': prompt,
      'targetChannel': targetChannel,
      'isEnabled': isEnabled,
      'lastRun': lastRun?.toIso8601String(),
      'lastOutput': lastOutput,
    };
  }
}
