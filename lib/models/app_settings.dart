enum ConnectionMode { directCloud, hermesGateway }
enum CloudProvider { nousPortal, openRouter, ollama, openai, gemini }

class AppSettings {
  ConnectionMode connectionMode;
  String gatewayUrl;
  String gatewayToken;

  CloudProvider cloudProvider;
  String apiKey;
  String selectedModel;
  String baseUrl;
  double temperature;
  String systemPrompt;

  AppSettings({
    this.connectionMode = ConnectionMode.directCloud,
    this.gatewayUrl = 'ws://localhost:8000/ws',
    this.gatewayToken = '',
    this.cloudProvider = CloudProvider.openRouter,
    this.apiKey = '',
    this.selectedModel = 'nousresearch/hermes-3-llama-3.1-405b',
    this.baseUrl = 'https://openrouter.ai/api/v1',
    this.temperature = 0.7,
    this.systemPrompt = 'You are Hermes Agent, an autonomous and intelligent AI assistant built by Nous Research. You excel at deep reasoning, coding, tool execution, and clear communication.',
  });

  Map<String, dynamic> toJson() => {
    'connectionMode': connectionMode.name,
    'gatewayUrl': gatewayUrl,
    'gatewayToken': gatewayToken,
    'cloudProvider': cloudProvider.name,
    'apiKey': apiKey,
    'selectedModel': selectedModel,
    'baseUrl': baseUrl,
    'temperature': temperature,
    'systemPrompt': systemPrompt,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      connectionMode: ConnectionMode.values.firstWhere(
        (e) => e.name == json['connectionMode'],
        orElse: () => ConnectionMode.directCloud,
      ),
      gatewayUrl: json['gatewayUrl'] as String? ?? 'ws://localhost:8000/ws',
      gatewayToken: json['gatewayToken'] as String? ?? '',
      cloudProvider: CloudProvider.values.firstWhere(
        (e) => e.name == json['cloudProvider'],
        orElse: () => CloudProvider.openRouter,
      ),
      apiKey: json['apiKey'] as String? ?? '',
      selectedModel: json['selectedModel'] as String? ?? 'nousresearch/hermes-3-llama-3.1-405b',
      baseUrl: json['baseUrl'] as String? ?? 'https://openrouter.ai/api/v1',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      systemPrompt: json['systemPrompt'] as String? ??
          'You are Hermes Agent, an autonomous and intelligent AI assistant built by Nous Research.',
    );
  }
}
