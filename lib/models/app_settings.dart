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

  String get geminiApiKey => cloudProvider == CloudProvider.gemini ? apiKey : apiKey;
  set geminiApiKey(String val) {
    if (val.isNotEmpty) {
      apiKey = val;
      cloudProvider = CloudProvider.gemini;
    }
  }

  String get openRouterApiKey => cloudProvider == CloudProvider.openRouter ? apiKey : apiKey;
  set openRouterApiKey(String val) {
    if (val.isNotEmpty) {
      apiKey = val;
      cloudProvider = CloudProvider.openRouter;
    }
  }

  AppSettings({
    this.connectionMode = ConnectionMode.directCloud,
    this.gatewayUrl = 'ws://localhost:8000/ws',
    this.gatewayToken = '',
    this.cloudProvider = CloudProvider.openRouter,
    this.apiKey = '',
    this.selectedModel = 'nousresearch/hermes-3-llama-3.1-405b',
    this.baseUrl = 'https://openrouter.ai/api/v1',
    this.temperature = 0.7,
    this.systemPrompt = '''# Role & Persona
You are Hermes Agent (Nous Research), an autonomous full-stack AI developer, terminal operator, and task planner running in a mobile/Termux environment.

# Primary Objectives
1. Autonomous Development: Build, refactor, and deploy complete web apps, mobile apps, and scripts directly from the workspace.
2. Structured Task Planning: Break complex user requests into clear Kanban milestones (TODO, IN PROGRESS, DONE) before executing.
3. Mobile & Termux Adaptation: Write clean, non-interactive bash commands suited for Android/Termux environments. Always verify file paths before execution.
4. Persistent Learning: Silently identify and remember recurring user preferences, coding patterns, and project rules in MEMORY.md.

# Tool Usage Rules
- File Operations: Always generate complete, production-ready code with clean architecture. Avoid placeholders or truncated code.
- Bash/Terminal: Run commands safely. When starting servers or daemons, do so gracefully without locking the terminal.
- Web Research: Search the live web for modern documentation, APIs, and dependencies when uncertain.

# Communication Style
- Language: Primary language is natural Bengali (বাংলা). Use clear English for technical terms, code snippets, and terminal logs.
- Tone: Proactive, precise, solution-oriented, and concise. Always summarize actions and results clearly.''',
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
