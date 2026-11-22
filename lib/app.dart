import 'package:flutter/material.dart';
import 'core/storage/local_storage.dart';
import 'core/theme/hermes_theme.dart';
import 'models/app_settings.dart';
import 'models/kanban_task.dart';
import 'models/memory_item.dart';
import 'models/skill.dart';
import 'models/workspace_file.dart';
import 'models/system_stats.dart';
import 'models/mcp_server.dart';
import 'models/channel_config.dart';
import 'models/agent_profile.dart';
import 'models/cron_job.dart';
import 'models/env_secret.dart';
import 'models/analytics_data.dart';
import 'models/system_log.dart';
import 'services/hermes_service.dart';
import 'views/chat/chat_screen.dart';
import 'views/kanban/kanban_screen.dart';
import 'views/files/files_screen.dart';
import 'views/skills/skills_screen.dart';
import 'views/hub/control_center_screen.dart';
import 'views/mcp/mcp_screen.dart';
import 'views/channels/channels_screen.dart';
import 'views/profiles/profiles_screen.dart';
import 'views/cron/cron_screen.dart';
import 'views/env/env_screen.dart';
import 'views/analytics/analytics_screen.dart';
import 'views/logs/logs_screen.dart';
import 'views/system/system_screen.dart';
import 'views/pairing/pairing_screen.dart';
import 'views/memory/memory_screen.dart';
import 'views/settings/settings_screen.dart';

class HermesApp extends StatefulWidget {
  const HermesApp({super.key});

  @override
  State<HermesApp> createState() => _HermesAppState();
}

class _HermesAppState extends State<HermesApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  int _currentIndex = 0;
  AppSettings _settings = AppSettings();
  List<Skill> _skills = [];
  List<MemoryItem> _memories = [];
  List<KanbanTask> _tasks = [];
  List<WorkspaceFile> _files = [];
  List<McpServer> _mcpServers = [];
  ChannelConfig _channelConfig = ChannelConfig();
  List<AgentProfile> _profiles = [];
  String _activeProfileId = 'prof_generalist';
  List<CronJob> _cronJobs = [];
  List<EnvSecret> _secrets = [];
  AnalyticsData _analytics = AnalyticsData();
  List<SystemLog> _logs = [];
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
    final mcp = await LocalStorage.loadMcpServers();
    final ch = await LocalStorage.loadChannelConfig();
    final prof = await LocalStorage.loadProfiles();
    final activeProf = await LocalStorage.getActiveProfileId();
    final cron = await LocalStorage.loadCronJobs();
    final sec = await LocalStorage.loadEnvSecrets(s);
    final an = await LocalStorage.loadAnalytics();
    final lg = await LocalStorage.loadLogs();
    final stats = await _hermesService.fetchSystemStats(s);

    setState(() {
      _settings = s;
      _skills = sk;
      _memories = mem;
      _tasks = tsk;
      _files = fls;
      _mcpServers = mcp;
      _channelConfig = ch;
      _profiles = prof;
      _activeProfileId = activeProf;
      _cronJobs = cron;
      _secrets = sec;
      _analytics = an;
      _logs = lg;
      _systemStats = stats;
      _isLoading = false;
    });
  }

  void _onSaveSettings(AppSettings newSettings) {
    setState(() => _settings = newSettings);
    LocalStorage.saveSettings(newSettings);
  }

  // MCP Servers
  void _onAddMcpServer(McpServer server) {
    setState(() => _mcpServers.add(server));
    LocalStorage.saveMcpServers(_mcpServers);
  }

  void _onUpdateMcpServer(McpServer server) {
    setState(() {
      final idx = _mcpServers.indexWhere((s) => s.id == server.id);
      if (idx != -1) _mcpServers[idx] = server;
    });
    LocalStorage.saveMcpServers(_mcpServers);
  }

  void _onDeleteMcpServer(String id) {
    setState(() => _mcpServers.removeWhere((s) => s.id == id));
    LocalStorage.saveMcpServers(_mcpServers);
  }

  // Channels
  void _onSaveChannelConfig(ChannelConfig cfg) {
    setState(() => _channelConfig = cfg);
    LocalStorage.saveChannelConfig(cfg);
  }

  // Profiles
  void _onSelectProfile(String id) {
    setState(() => _activeProfileId = id);
    LocalStorage.setActiveProfileId(id);
    final prof = _profiles.firstWhere((p) => p.id == id, orElse: () => _profiles.first);
    if (prof.preferredModel.isNotEmpty) {
      _settings.selectedModel = prof.preferredModel;
      LocalStorage.saveSettings(_settings);
    }
  }

  void _onAddProfile(AgentProfile profile) {
    setState(() => _profiles.add(profile));
    LocalStorage.saveProfiles(_profiles);
  }

  void _onUpdateProfile(AgentProfile profile) {
    setState(() {
      final idx = _profiles.indexWhere((p) => p.id == profile.id);
      if (idx != -1) _profiles[idx] = profile;
    });
    LocalStorage.saveProfiles(_profiles);
  }

  void _onDeleteProfile(String id) {
    setState(() => _profiles.removeWhere((p) => p.id == id));
    LocalStorage.saveProfiles(_profiles);
  }

  // Cron Jobs
  void _onAddCronJob(CronJob job) {
    setState(() => _cronJobs.add(job));
    LocalStorage.saveCronJobs(_cronJobs);
  }

  void _onUpdateCronJob(CronJob job) {
    setState(() {
      final idx = _cronJobs.indexWhere((j) => j.id == job.id);
      if (idx != -1) _cronJobs[idx] = job;
    });
    LocalStorage.saveCronJobs(_cronJobs);
  }

  void _onDeleteCronJob(String id) {
    setState(() => _cronJobs.removeWhere((j) => j.id == id));
    LocalStorage.saveCronJobs(_cronJobs);
  }

  // Env Secrets
  void _onSaveSecrets(List<EnvSecret> secrets) {
    setState(() => _secrets = secrets);
    LocalStorage.saveEnvSecrets(secrets);
  }

  // Analytics
  void _onSaveAnalytics(AnalyticsData data) {
    setState(() => _analytics = data);
    LocalStorage.saveAnalytics(data);
  }

  // Logs
  void _onClearLogs() {
    setState(() => _logs.clear());
    LocalStorage.clearLogs();
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

  // System Stats Refresh
  Future<void> _refreshSystemStats() async {
    final stats = await _hermesService.fetchSystemStats(_settings);
    setState(() => _systemStats = stats);
  }

  void _handleOpenModule(String module) {
    final ctx = _navigatorKey.currentContext;
    if (ctx == null) return;

    Widget target;
    switch (module) {
      case 'mcp':
        target = McpScreen(
          servers: _mcpServers,
          onAddServer: _onAddMcpServer,
          onUpdateServer: _onUpdateMcpServer,
          onDeleteServer: _onDeleteMcpServer,
        );
        break;
      case 'channels':
        target = ChannelsScreen(
          config: _channelConfig,
          onSaveConfig: _onSaveChannelConfig,
        );
        break;
      case 'profiles':
        target = ProfilesScreen(
          profiles: _profiles,
          activeProfileId: _activeProfileId,
          onSelectProfile: _onSelectProfile,
          onAddProfile: _onAddProfile,
          onUpdateProfile: _onUpdateProfile,
          onDeleteProfile: _onDeleteProfile,
        );
        break;
      case 'cron':
        target = CronScreen(
          jobs: _cronJobs,
          onAddJob: _onAddCronJob,
          onUpdateJob: _onUpdateCronJob,
          onDeleteJob: _onDeleteCronJob,
        );
        break;
      case 'env':
        target = EnvScreen(
          secrets: _secrets,
          onSaveSecrets: _onSaveSecrets,
          onSyncSettings: _onSaveSettings,
          settings: _settings,
        );
        break;
      case 'analytics':
        target = AnalyticsScreen(
          analytics: _analytics,
          onSaveAnalytics: _onSaveAnalytics,
        );
        break;
      case 'logs':
        target = LogsScreen(
          logs: _logs,
          onClearLogs: _onClearLogs,
        );
        break;
      case 'system':
        target = SystemScreen(
          stats: _systemStats,
          onRefresh: _refreshSystemStats,
        );
        break;
      case 'pairing':
        target = PairingScreen(
          gatewayUrl: _settings.gatewayUrl,
          onUpdateGatewayUrl: (url) {
            _settings.gatewayUrl = url;
            _onSaveSettings(_settings);
          },
        );
        break;
      case 'memory':
        target = MemoryScreen(
          memories: _memories,
          onAddMemory: _onAddMemory,
          onDeleteMemory: _onDeleteMemory,
        );
        break;
      default:
        setState(() => _currentIndex = 4);
        return;
    }

    Navigator.push(ctx, MaterialPageRoute(builder: (_) => target));
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
        onOpenModule: _handleOpenModule,
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
      ControlCenterScreen(
        settings: _settings,
        onSaveSettings: _onSaveSettings,
        mcpServers: _mcpServers,
        onAddMcpServer: _onAddMcpServer,
        onUpdateMcpServer: _onUpdateMcpServer,
        onDeleteMcpServer: _onDeleteMcpServer,
        channelConfig: _channelConfig,
        onSaveChannelConfig: _onSaveChannelConfig,
        profiles: _profiles,
        activeProfileId: _activeProfileId,
        onSelectProfile: _onSelectProfile,
        onAddProfile: _onAddProfile,
        onUpdateProfile: _onUpdateProfile,
        onDeleteProfile: _onDeleteProfile,
        cronJobs: _cronJobs,
        onAddCronJob: _onAddCronJob,
        onUpdateCronJob: _onUpdateCronJob,
        onDeleteCronJob: _onDeleteCronJob,
        secrets: _secrets,
        onSaveSecrets: _onSaveSecrets,
        analytics: _analytics,
        onSaveAnalytics: _onSaveAnalytics,
        logs: _logs,
        onClearLogs: _onClearLogs,
        systemStats: _systemStats,
        onRefreshSystemStats: _refreshSystemStats,
        memories: _memories,
        onAddMemory: _onAddMemory,
        onDeleteMemory: _onDeleteMemory,
      ),
    ];

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Hermes Agent',
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
              icon: Icon(Icons.dashboard_customize_outlined),
              activeIcon: Icon(Icons.dashboard_customize_rounded),
              label: 'Suite',
            ),
          ],
        ),
      ),
    );
  }
}
