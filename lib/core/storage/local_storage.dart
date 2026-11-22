import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/session.dart';
import '../../models/message.dart';
import '../../models/skill.dart';
import '../../models/memory_item.dart';
import '../../models/app_settings.dart';
import '../../models/kanban_task.dart';
import '../../models/workspace_file.dart';
import '../../models/mcp_server.dart';
import '../../models/channel_config.dart';
import '../../models/agent_profile.dart';
import '../../models/cron_job.dart';
import '../../models/env_secret.dart';
import '../../models/analytics_data.dart';
import '../../models/system_log.dart';

class LocalStorage {
  static const String _keySessions = 'hermes_sessions';
  static const String _keyMessagesPrefix = 'hermes_msgs_';
  static const String _keySkills = 'hermes_skills';
  static const String _keyMemories = 'hermes_memories';
  static const String _keySettings = 'hermes_settings';
  static const String _keyTasks = 'hermes_tasks';
  static const String _keyFiles = 'hermes_files';
  static const String _keyMcpServers = 'hermes_mcp_servers';
  static const String _keyChannels = 'hermes_channels';
  static const String _keyProfiles = 'hermes_profiles';
  static const String _keyActiveProfile = 'hermes_active_profile';
  static const String _keyCronJobs = 'hermes_cron_jobs';
  static const String _keyEnvSecrets = 'hermes_env_secrets';
  static const String _keyAnalytics = 'hermes_analytics';
  static const String _keyLogs = 'hermes_system_logs';

  // Tasks (Kanban)
  static Future<List<KanbanTask>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyTasks);
    if (list == null) return _defaultTasks();
    return list.map((e) => KanbanTask.fromJson(jsonDecode(e))).toList();
  }

  static Future<void> saveTasks(List<KanbanTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final list = tasks.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_keyTasks, list);
  }

  // Workspace Files
  static Future<List<WorkspaceFile>> loadWorkspaceFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyFiles);
    if (jsonStr == null) return _defaultWorkspaceFiles();
    try {
      final decoded = jsonDecode(jsonStr) as List;
      return decoded.map((e) => WorkspaceFile.fromJson(e)).toList();
    } catch (_) {
      return _defaultWorkspaceFiles();
    }
  }

  static Future<void> saveWorkspaceFiles(List<WorkspaceFile> files) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(files.map((e) => e.toJson()).toList());
    await prefs.setString(_keyFiles, jsonStr);
  }

  // App Settings
  static Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keySettings);
    if (jsonStr == null) return AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(jsonStr));
    } catch (_) {
      return AppSettings();
    }
  }

  static Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySettings, jsonEncode(settings.toJson()));
  }

  // Sessions
  static Future<List<Session>> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keySessions) ?? [];
    return list.map((e) => Session.fromJson(jsonDecode(e))).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  static Future<void> saveSessions(List<Session> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    final list = sessions.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_keySessions, list);
  }

  // Messages per session
  static Future<List<Message>> loadMessages(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('$_keyMessagesPrefix$sessionId') ?? [];
    return list.map((e) => Message.fromJson(jsonDecode(e))).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  static Future<void> saveMessages(String sessionId, List<Message> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final list = messages.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('$_keyMessagesPrefix$sessionId', list);
  }

  // Skills
  static Future<List<Skill>> loadSkills() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keySkills);
    if (list == null) return _defaultSkills();
    return list.map((e) => Skill.fromJson(jsonDecode(e))).toList();
  }

  static Future<void> saveSkills(List<Skill> skills) async {
    final prefs = await SharedPreferences.getInstance();
    final list = skills.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_keySkills, list);
  }

  // Memories
  static Future<List<MemoryItem>> loadMemories() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyMemories);
    if (list == null) return _defaultMemories();
    return list.map((e) => MemoryItem.fromJson(jsonDecode(e))).toList();
  }

  static Future<void> saveMemories(List<MemoryItem> memories) async {
    final prefs = await SharedPreferences.getInstance();
    final list = memories.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_keyMemories, list);
  }

  // MCP Servers
  static Future<List<McpServer>> loadMcpServers() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyMcpServers);
    if (list == null) return _defaultMcpServers();
    return list.map((e) => McpServer.fromJson(jsonDecode(e))).toList();
  }

  static Future<void> saveMcpServers(List<McpServer> servers) async {
    final prefs = await SharedPreferences.getInstance();
    final list = servers.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_keyMcpServers, list);
  }

  // Channels
  static Future<ChannelConfig> loadChannelConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyChannels);
    if (jsonStr == null) return _defaultChannelConfig();
    try {
      return ChannelConfig.fromJson(jsonDecode(jsonStr));
    } catch (_) {
      return _defaultChannelConfig();
    }
  }

  static Future<void> saveChannelConfig(ChannelConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyChannels, jsonEncode(config.toJson()));
  }

  // Profiles
  static Future<List<AgentProfile>> loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyProfiles);
    if (list == null) return _defaultProfiles();
    return list.map((e) => AgentProfile.fromJson(jsonDecode(e))).toList();
  }

  static Future<void> saveProfiles(List<AgentProfile> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    final list = profiles.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_keyProfiles, list);
  }

  static Future<String> getActiveProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyActiveProfile) ?? 'prof_generalist';
  }

  static Future<void> setActiveProfileId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyActiveProfile, id);
  }

  // Cron Jobs
  static Future<List<CronJob>> loadCronJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyCronJobs);
    if (list == null) return _defaultCronJobs();
    return list.map((e) => CronJob.fromJson(jsonDecode(e))).toList();
  }

  static Future<void> saveCronJobs(List<CronJob> jobs) async {
    final prefs = await SharedPreferences.getInstance();
    final list = jobs.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_keyCronJobs, list);
  }

  // Env Secrets
  static Future<List<EnvSecret>> loadEnvSecrets(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyEnvSecrets);
    if (list == null) return _defaultEnvSecrets(settings);
    final secrets = list.map((e) => EnvSecret.fromJson(jsonDecode(e))).toList();
    // Ensure GEMINI_API_KEY reflects settings if present
    final geminiSec = secrets.firstWhere((s) => s.key == 'GEMINI_API_KEY', orElse: () => EnvSecret(key: 'GEMINI_API_KEY', value: settings.geminiApiKey));
    if (settings.geminiApiKey.isNotEmpty && geminiSec.value.isEmpty) {
      geminiSec.value = settings.geminiApiKey;
    }
    return secrets;
  }

  static Future<void> saveEnvSecrets(List<EnvSecret> secrets) async {
    final prefs = await SharedPreferences.getInstance();
    final list = secrets.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_keyEnvSecrets, list);
  }

  // Analytics
  static Future<AnalyticsData> loadAnalytics() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyAnalytics);
    if (jsonStr == null) return AnalyticsData();
    try {
      return AnalyticsData.fromJson(jsonDecode(jsonStr));
    } catch (_) {
      return AnalyticsData();
    }
  }

  static Future<void> saveAnalytics(AnalyticsData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAnalytics, jsonEncode(data.toJson()));
  }

  // Logs
  static Future<List<SystemLog>> loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyLogs);
    if (list == null) return _defaultLogs();
    return list.map((e) => SystemLog.fromJson(jsonDecode(e))).toList();
  }

  static Future<void> addLog(SystemLog log) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyLogs) ?? [];
    list.insert(0, jsonEncode(log.toJson()));
    if (list.length > 200) list.removeLast(); // keep last 200 lines
    await prefs.setStringList(_keyLogs, list);
  }

  static Future<void> clearLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLogs);
  }

  // Defaults
  static List<Skill> _defaultSkills() {
    return [
      Skill(
        id: 'skill_web_search',
        name: 'Web Research & Fact Check',
        description: 'Performs live internet queries and synthesizes factual answers.',
        trigger: 'Search live web, current news, sports, or documentation',
        instructions: 'Call web search tool, summarize facts with citations.',
        category: 'Web',
      ),
      Skill(
        id: 'skill_code_gen',
        name: 'Autonomous Code Refactoring',
        description: 'Analyzes, explains, refactors, and generates production code.',
        trigger: 'Code writing, debugging, architectural design',
        instructions: 'Deliver clean, tested, documented code with explanation.',
        category: 'Development',
      ),
      Skill(
        id: 'skill_memory_store',
        name: 'Self-Learning Memory Loop',
        description: 'Automatically detects user preferences and saves them to long-term memory.',
        trigger: 'User shares personal preferences or rules',
        instructions: 'Store key fact silently into MEMORY.md.',
        category: 'Core',
      ),
    ];
  }

  static List<MemoryItem> _defaultMemories() {
    return [
      MemoryItem(
        id: 'mem_1',
        key: 'User Preferences',
        content: 'Preferred response language: Bengali (বাংলা).\nFramework: Flutter 3+ Dart.',
        category: 'preference',
      ),
      MemoryItem(
        id: 'mem_2',
        key: 'Agent Persona',
        content: 'Hermes 3 / Nous Research autonomous coding and reasoning assistant.',
        category: 'system',
      ),
      MemoryItem(
        id: 'mem_3',
        key: 'Active Architecture',
        content: 'Autonomous task planning loop with tool execution (bash, web_search, files).',
        category: 'project',
      ),
    ];
  }

  static List<KanbanTask> _defaultTasks() {
    return [
      KanbanTask(
        id: 'task_1',
        title: 'Setup Hermes Agent Core',
        description: 'Verify local environment, check python wheels and load configuration.',
        status: TaskStatus.done,
        priority: TaskPriority.high,
        logs: ['Checking python 3.11...', 'Environment valid.', 'Bootstrap complete.'],
      ),
      KanbanTask(
        id: 'task_2',
        title: 'Continuous Autonomous Learning Loop',
        description: 'Monitor user interactions, identify recurring workflows, and distill into SKILL.md.',
        status: TaskStatus.inProgress,
        priority: TaskPriority.critical,
        assignedSubagent: 'Hermes Learner 01',
        logs: ['Watching chat stream...', 'Candidate pattern detected: Dart build.'],
      ),
      KanbanTask(
        id: 'task_3',
        title: 'Review Project Security & Permissions',
        description: 'Audit file access boundaries and external API token scopes.',
        status: TaskStatus.todo,
        priority: TaskPriority.medium,
      ),
    ];
  }

  static List<WorkspaceFile> _defaultWorkspaceFiles() {
    return [
      WorkspaceFile(
        name: 'scripts',
        path: '/scripts',
        isDirectory: true,
        children: [
          WorkspaceFile(
            name: 'install.sh',
            path: '/scripts/install.sh',
            isDirectory: false,
            size: 2048,
            extension: 'sh',
            content: '#!/bin/bash\necho "Initializing Hermes Agent on Linux/Android..."\n',
          ),
          WorkspaceFile(
            name: 'install.ps1',
            path: '/scripts/install.ps1',
            isDirectory: false,
            size: 3120,
            extension: 'ps1',
            content: 'Write-Host "Hermes Setup for Windows starting..."',
          ),
        ],
      ),
      WorkspaceFile(
        name: 'SKILL.md',
        path: '/SKILL.md',
        isDirectory: false,
        size: 1540,
        extension: 'md',
        content: '# Hermes Dynamic Skills Library\n\n- auto-cleaning\n- web-research\n- terminal-automation\n',
      ),
      WorkspaceFile(
        name: 'MEMORY.md',
        path: '/MEMORY.md',
        isDirectory: false,
        size: 890,
        extension: 'md',
        content: '### User Facts\n- Language: Bengali (বাংলা)\n- Framework: Flutter\n',
      ),
      WorkspaceFile(
        name: 'hermes.config.json',
        path: '/hermes.config.json',
        isDirectory: false,
        size: 450,
        extension: 'json',
        content: '{\n  "version": "0.0.1",\n  "autonomous": true,\n  "gateway_port": 8000\n}\n',
      ),
    ];
  }

  static List<McpServer> _defaultMcpServers() {
    return [
      McpServer(
        id: 'mcp_filesystem',
        name: 'Filesystem MCP',
        transport: 'stdio',
        command: 'npx',
        args: ['-y', '@modelcontextprotocol/server-filesystem', '/data/user/0/ai.antigem'],
        isEnabled: true,
        tools: ['read_file', 'write_file', 'list_directory', 'directory_tree'],
        status: 'connected',
      ),
      McpServer(
        id: 'mcp_github',
        name: 'GitHub MCP',
        transport: 'stdio',
        command: 'npx',
        args: ['-y', '@modelcontextprotocol/server-github'],
        isEnabled: true,
        tools: ['get_repo', 'create_issue', 'search_repositories', 'push_files'],
        status: 'connected',
      ),
      McpServer(
        id: 'mcp_brave',
        name: 'Brave Search MCP',
        transport: 'stdio',
        command: 'npx',
        args: ['-y', '@modelcontextprotocol/server-brave-search'],
        isEnabled: true,
        tools: ['brave_web_search', 'brave_local_search'],
        status: 'connected',
      ),
      McpServer(
        id: 'mcp_postgres',
        name: 'PostgreSQL MCP',
        transport: 'stdio',
        command: 'npx',
        args: ['-y', '@modelcontextprotocol/server-postgres', 'postgresql://localhost/hermes'],
        isEnabled: false,
        tools: ['query', 'list_tables', 'describe_table'],
        status: 'disconnected',
      ),
      McpServer(
        id: 'mcp_memory',
        name: 'Memory Graph MCP',
        transport: 'stdio',
        command: 'npx',
        args: ['-y', '@modelcontextprotocol/server-memory'],
        isEnabled: true,
        tools: ['read_graph', 'create_entities', 'open_nodes'],
        status: 'connected',
      ),
    ];
  }

  static ChannelConfig _defaultChannelConfig() {
    return ChannelConfig(
      whatsAppEnabled: true,
      whatsAppPhone: '+880 1700-000000',
      whatsAppStatus: 'connected',
      whatsAppQrData: 'HERMES-WA-PAIRING-SESSION-ACTIVE',
      telegramEnabled: true,
      telegramToken: '719283746:AAHg98q21kdsl9_sample_token',
      telegramUsername: '@HermesAgentBot',
      telegramStatus: 'connected',
      telegramAllowlist: ['@nousresearch', '@emranm'],
      discordEnabled: false,
      discordStatus: 'disconnected',
      slackEnabled: false,
      slackStatus: 'disconnected',
    );
  }

  static List<AgentProfile> _defaultProfiles() {
    return [
      AgentProfile(
        id: 'prof_generalist',
        name: 'Hermes Generalist',
        role: 'Autonomous Assistant & Problem Solver',
        description: 'Balanced profile for reasoning, coding, autonomous tool use, and web research.',
        soulContent: 'You are Hermes Agent by Nous Research. Be concise, rigorous, and direct. Solve coding, planning, and knowledge tasks autonomously.',
        preferredModel: 'gemini-3.8-flash',
        isDefault: true,
        iconName: 'psychology',
      ),
      AgentProfile(
        id: 'prof_architect',
        name: 'Software Architect',
        role: 'Fullstack & Clean Code Specialist',
        description: 'Optimized for Flutter, Python, TypeScript, system design, test-driven development, and refactoring.',
        soulContent: 'You are a Senior Software Architect specializing in clean code, solid principles, test coverage, and high-performance algorithms.',
        preferredModel: 'gemini-3.8-flash',
        isDefault: false,
        iconName: 'code',
      ),
      AgentProfile(
        id: 'prof_researcher',
        name: 'Scientific Researcher',
        role: 'Deep Fact-Finding & Literature Search',
        description: 'Specialized in multi-source fact retrieval, arXiv synthesis, and data structuring.',
        soulContent: 'You are an academic researcher. Always prioritize primary source evidence, provide full citations, and avoid unverified assumptions.',
        preferredModel: 'gemini-3.8-flash',
        isDefault: false,
        iconName: 'science',
      ),
      AgentProfile(
        id: 'prof_devops',
        name: 'DevOps & Linux Admin',
        role: 'Infrastructure & Shell Automator',
        description: 'Expert in Termux, Linux bash scripting, Docker containers, CI/CD, and server maintenance.',
        soulContent: 'You are a Linux Systems Administrator. Prefer efficient bash commands, verify syntax, inspect logs, and handle errors defensively.',
        preferredModel: 'gemini-3.8-flash',
        isDefault: false,
        iconName: 'terminal',
      ),
    ];
  }

  static List<CronJob> _defaultCronJobs() {
    return [
      CronJob(
        id: 'cron_1',
        name: 'Morning Standup Briefing',
        cronExpression: '0 9 * * 1-5',
        prompt: 'Review active kanban tasks, pending PRs, and summarize today priorities.',
        targetChannel: 'Chat',
        isEnabled: true,
        lastRun: DateTime.now().subtract(const Duration(hours: 3)),
        lastOutput: 'Standup briefing generated: 3 tasks in progress, 1 ready for review.',
      ),
      CronJob(
        id: 'cron_2',
        name: 'Git Repository Health & Backup',
        cronExpression: '0 2 * * *',
        prompt: 'Check git status, commit uncommitted working trees, and push to remote.',
        targetChannel: 'Chat',
        isEnabled: true,
        lastRun: DateTime.now().subtract(const Duration(hours: 10)),
        lastOutput: 'Git working tree verified. All repositories up to date.',
      ),
      CronJob(
        id: 'cron_3',
        name: 'AI News & Model Benchmark Scan',
        cronExpression: '0 12 * * *',
        prompt: 'Fetch latest releases and benchmarks in open-source AI and Hermes ecosystem.',
        targetChannel: 'Telegram',
        isEnabled: false,
        lastRun: DateTime.now().subtract(const Duration(days: 1)),
        lastOutput: 'Dispatched digest with 4 updates to Telegram channel.',
      ),
      CronJob(
        id: 'cron_4',
        name: 'Long-Term Memory Auto-Curator',
        cronExpression: '0 0 * * 0',
        prompt: 'Distill weekly user interactions into persistent MEMORY.md updates.',
        targetChannel: 'Chat',
        isEnabled: true,
        lastRun: DateTime.now().subtract(const Duration(days: 2)),
        lastOutput: 'Curated 3 user preferences into storage.',
      ),
    ];
  }

  static List<EnvSecret> _defaultEnvSecrets(AppSettings settings) {
    return [
      EnvSecret(
        key: 'GEMINI_API_KEY',
        value: settings.geminiApiKey,
        category: 'LLM API Keys',
      ),
      EnvSecret(
        key: 'OPENROUTER_API_KEY',
        value: settings.openRouterApiKey,
        category: 'LLM API Keys',
      ),
      EnvSecret(
        key: 'OPENAI_API_KEY',
        value: '',
        category: 'LLM API Keys',
      ),
      EnvSecret(
        key: 'ANTHROPIC_API_KEY',
        value: '',
        category: 'LLM API Keys',
      ),
      EnvSecret(
        key: 'TAVILY_API_KEY',
        value: '',
        category: 'Search & Tools',
      ),
      EnvSecret(
        key: 'SERPER_API_KEY',
        value: '',
        category: 'Search & Tools',
      ),
      EnvSecret(
        key: 'GITHUB_TOKEN',
        value: '',
        category: 'Services',
      ),
      EnvSecret(
        key: 'SUPABASE_KEY',
        value: '',
        category: 'Database & Cloud',
      ),
      EnvSecret(
        key: 'FIREBASE_API_KEY',
        value: '',
        category: 'Database & Cloud',
      ),
    ];
  }

  static List<SystemLog> _defaultLogs() {
    final now = DateTime.now();
    return [
      SystemLog(
        timestamp: now.subtract(const Duration(minutes: 1)),
        level: 'INFO',
        tag: 'GATEWAY',
        message: 'Hermes Agent Mobile Gateway online. Connected to local runtime.',
      ),
      SystemLog(
        timestamp: now.subtract(const Duration(minutes: 2)),
        level: 'INFO',
        tag: 'MCP',
        message: 'Registered 5 MCP servers: Filesystem, GitHub, Brave, Postgres, Memory.',
      ),
      SystemLog(
        timestamp: now.subtract(const Duration(minutes: 5)),
        level: 'INFO',
        tag: 'CHANNELS',
        message: 'Telegram bot relay initialized as @HermesAgentBot.',
      ),
      SystemLog(
        timestamp: now.subtract(const Duration(minutes: 12)),
        level: 'DEBUG',
        tag: 'MODEL',
        message: 'Primary model set to Google Gemini (gemini-3.8-flash) native streaming.',
      ),
      SystemLog(
        timestamp: now.subtract(const Duration(minutes: 20)),
        level: 'INFO',
        tag: 'CRON',
        message: 'Loaded 4 automation schedules. Next trigger in 2 hours.',
      ),
    ];
  }
}
