import 'package:flutter/material.dart';
import 'core/storage/local_storage.dart';
import 'core/theme/hermes_theme.dart';
import 'models/app_settings.dart';
import 'models/kanban_task.dart';
import 'models/memory_item.dart';
import 'models/skill.dart';
import 'models/workspace_file.dart';
import 'models/system_stats.dart';
import 'services/hermes_service.dart';
import 'views/chat/chat_screen.dart';
import 'views/kanban/kanban_screen.dart';
import 'views/files/files_screen.dart';
import 'views/skills/skills_screen.dart';
import 'views/memory/memory_screen.dart';
import 'views/settings/settings_screen.dart';

class HermesApp extends StatefulWidget {
  const HermesApp({super.key});

  @override
  State<HermesApp> createState() => _HermesAppState();
}

class _HermesAppState extends State<HermesApp> {
  int _currentIndex = 0;
  AppSettings _settings = AppSettings();
  List<Skill> _skills = [];
  List<MemoryItem> _memories = [];
  List<KanbanTask> _tasks = [];
  List<WorkspaceFile> _files = [];
  SystemStats _systemStats = SystemStats();
  bool _isLoading = true;
  final HermesService _hermesService = HermesService();

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final s = await LocalStorage.loadSettings();
    final sk = await LocalStorage.loadSkills();
    final mem = await LocalStorage.loadMemories();
    final tsk = await LocalStorage.loadTasks();
    final fls = await LocalStorage.loadWorkspaceFiles();
    final stats = await _hermesService.fetchSystemStats(s);

    setState(() {
      _settings = s;
      _skills = sk;
      _memories = mem;
      _tasks = tsk;
      _files = fls;
      _systemStats = stats;
      _isLoading = false;
    });
  }

  void _onSaveSettings(AppSettings newSettings) {
    setState(() => _settings = newSettings);
    LocalStorage.saveSettings(newSettings);
  }

  // Skills
  void _onAddSkill(Skill skill) {
    setState(() => _skills.add(skill));
    LocalStorage.saveSkills(_skills);
  }

  void _onToggleSkill(Skill skill) {
    setState(() => skill.isEnabled = !skill.isEnabled);
    LocalStorage.saveSkills(_skills);
  }

  void _onDeleteSkill(String id) {
    setState(() => _skills.removeWhere((s) => s.id == id));
    LocalStorage.saveSkills(_skills);
  }

  // Memory
  void _onAddMemory(MemoryItem item) {
    setState(() => _memories.insert(0, item));
    LocalStorage.saveMemories(_memories);
  }

  void _onDeleteMemory(String id) {
    setState(() => _memories.removeWhere((m) => m.id == id));
    LocalStorage.saveMemories(_memories);
  }

  // Kanban Tasks
  void _onAddTask(KanbanTask task) {
    setState(() => _tasks.insert(0, task));
    LocalStorage.saveTasks(_tasks);
  }

  void _onUpdateTaskStatus(KanbanTask task, TaskStatus newStatus) {
    setState(() {
      task.status = newStatus;
      task.updatedAt = DateTime.now();
      task.logs.add('Moved to ${newStatus.name.toUpperCase()}');
    });
    LocalStorage.saveTasks(_tasks);
  }

  void _onDeleteTask(String id) {
    setState(() => _tasks.removeWhere((t) => t.id == id));
    LocalStorage.saveTasks(_tasks);
  }

  // Files
  void _onAddFile(WorkspaceFile file) {
    setState(() => _files.insert(0, file));
    LocalStorage.saveWorkspaceFiles(_files);
  }

  void _onDeleteFile(String path) {
    setState(() => _files.removeWhere((f) => f.path == path));
    LocalStorage.saveWorkspaceFiles(_files);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: HermesTheme.darkTheme,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: HermesTheme.primary),
          ),
        ),
      );
    }

    final screens = [
      ChatScreen(
        settings: _settings,
        onOpenSettings: () => setState(() => _currentIndex = 4),
      ),
      KanbanScreen(
        tasks: _tasks,
        onAddTask: _onAddTask,
        onUpdateTaskStatus: _onUpdateTaskStatus,
        onDeleteTask: _onDeleteTask,
      ),
      FilesScreen(
        files: _files,
        onAddFile: _onAddFile,
        onDeleteFile: _onDeleteFile,
      ),
      SkillsScreen(
        skills: _skills,
        onAddSkill: _onAddSkill,
        onToggleSkill: _onToggleSkill,
        onDeleteSkill: _onDeleteSkill,
      ),
      // Settings & Telemetry & Memory
      Scaffold(
        appBar: AppBar(
          title: const Text('Agent Settings & Memory'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Quick navigation to Memory Hub
            Container(
              decoration: BoxDecoration(
                color: HermesTheme.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: HermesTheme.cardBorder),
              ),
              child: ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: HermesTheme.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.psychology_rounded, color: HermesTheme.accent, size: 20),
                ),
                title: const Text(
                  'Persistent Memory (MEMORY.md)',
                  style: TextStyle(color: HermesTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  '${_memories.length} facts & preferences remembered',
                  style: const TextStyle(color: HermesTheme.textMuted, fontSize: 11),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: HermesTheme.textMuted),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MemoryScreen(
                        memories: _memories,
                        onAddMemory: _onAddMemory,
                        onDeleteMemory: _onDeleteMemory,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Settings Body
            SizedBox(
              height: 600,
              child: SettingsScreen(
                settings: _settings,
                onSaveSettings: _onSaveSettings,
                systemStats: _systemStats,
              ),
            ),
          ],
        ),
      ),
    ];

    return MaterialApp(
      title: 'Hermes AI Mobile',
      debugShowCheckedModeBanner: false,
      theme: HermesTheme.darkTheme,
      home: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              activeIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.view_kanban_outlined),
              activeIcon: Icon(Icons.view_kanban_rounded),
              label: 'Kanban',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_outlined),
              activeIcon: Icon(Icons.folder_rounded),
              label: 'Files',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bolt_outlined),
              activeIcon: Icon(Icons.bolt_rounded),
              label: 'Skills',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tune_rounded),
              activeIcon: Icon(Icons.tune_rounded),
              label: 'Config',
            ),
          ],
        ),
      ),
    );
  }
}
