import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/session.dart';
import '../../models/message.dart';
import '../../models/skill.dart';
import '../../models/memory_item.dart';
import '../../models/app_settings.dart';
import '../../models/kanban_task.dart';
import '../../models/workspace_file.dart';

class LocalStorage {
  static const String _keySessions = 'hermes_sessions';
  static const String _keyMessagesPrefix = 'hermes_msgs_';
  static const String _keySkills = 'hermes_skills';
  static const String _keyMemories = 'hermes_memories';
  static const String _keySettings = 'hermes_settings';
  static const String _keyTasks = 'hermes_tasks';
  static const String _keyFiles = 'hermes_files';

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
}
