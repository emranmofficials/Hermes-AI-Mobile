class ChannelConfig {
  // WhatsApp
  bool whatsAppEnabled;
  String whatsAppPhone;
  String whatsAppStatus; // disconnected, pairing, connected
  String whatsAppQrData;

  // Telegram
  bool telegramEnabled;
  String telegramToken;
  String telegramUsername;
  String telegramStatus; // disconnected, connected
  List<String> telegramAllowlist;

  // Discord
  bool discordEnabled;
  String discordToken;
  String discordWebhookUrl;
  String discordChannelId;
  String discordStatus;

  // Slack
  bool slackEnabled;
  String slackWebhookUrl;
  String slackStatus;

  ChannelConfig({
    this.whatsAppEnabled = false,
    this.whatsAppPhone = '',
    this.whatsAppStatus = 'disconnected',
    this.whatsAppQrData = 'HERMES-WA-PAIRING-SESSION-ACTIVE',
    this.telegramEnabled = false,
    this.telegramToken = '',
    this.telegramUsername = '@HermesAgentBot',
    this.telegramStatus = 'disconnected',
    List<String>? telegramAllowlist,
    this.discordEnabled = false,
    this.discordToken = '',
    this.discordWebhookUrl = '',
    this.discordChannelId = '',
    this.discordStatus = 'disconnected',
    this.slackEnabled = false,
    this.slackWebhookUrl = '',
    this.slackStatus = 'disconnected',
  }) : telegramAllowlist = telegramAllowlist ?? [];

  factory ChannelConfig.fromJson(Map<String, dynamic> json) {
    return ChannelConfig(
      whatsAppEnabled: json['whatsAppEnabled'] ?? false,
      whatsAppPhone: json['whatsAppPhone'] ?? '',
      whatsAppStatus: json['whatsAppStatus'] ?? 'disconnected',
      whatsAppQrData: json['whatsAppQrData'] ?? 'HERMES-WA-PAIRING-SESSION-ACTIVE',
      telegramEnabled: json['telegramEnabled'] ?? false,
      telegramToken: json['telegramToken'] ?? '',
      telegramUsername: json['telegramUsername'] ?? '@HermesAgentBot',
      telegramStatus: json['telegramStatus'] ?? 'disconnected',
      telegramAllowlist: (json['telegramAllowlist'] as List?)?.map((e) => e.toString()).toList() ?? [],
      discordEnabled: json['discordEnabled'] ?? false,
      discordToken: json['discordToken'] ?? '',
      discordWebhookUrl: json['discordWebhookUrl'] ?? '',
      discordChannelId: json['discordChannelId'] ?? '',
      discordStatus: json['discordStatus'] ?? 'disconnected',
      slackEnabled: json['slackEnabled'] ?? false,
      slackWebhookUrl: json['slackWebhookUrl'] ?? '',
      slackStatus: json['slackStatus'] ?? 'disconnected',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'whatsAppEnabled': whatsAppEnabled,
      'whatsAppPhone': whatsAppPhone,
      'whatsAppStatus': whatsAppStatus,
      'whatsAppQrData': whatsAppQrData,
      'telegramEnabled': telegramEnabled,
      'telegramToken': telegramToken,
      'telegramUsername': telegramUsername,
      'telegramStatus': telegramStatus,
      'telegramAllowlist': telegramAllowlist,
      'discordEnabled': discordEnabled,
      'discordToken': discordToken,
      'discordWebhookUrl': discordWebhookUrl,
      'discordChannelId': discordChannelId,
      'discordStatus': discordStatus,
      'slackEnabled': slackEnabled,
      'slackWebhookUrl': slackWebhookUrl,
      'slackStatus': slackStatus,
    };
  }
}
