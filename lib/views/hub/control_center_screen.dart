import 'package:flutter/material.dart';
import '../../core/theme/hermes_theme.dart';
import '../../models/app_settings.dart';
import '../../models/mcp_server.dart';
import '../../models/channel_config.dart';
import '../../models/agent_profile.dart';
import '../../models/cron_job.dart';
import '../../models/env_secret.dart';
import '../../models/analytics_data.dart';
import '../../models/system_log.dart';
import '../../models/system_stats.dart';
import '../../models/memory_item.dart';

import '../mcp/mcp_screen.dart';
import '../channels/channels_screen.dart';
import '../profiles/profiles_screen.dart';
import '../cron/cron_screen.dart';
import '../env/env_screen.dart';
import '../analytics/analytics_screen.dart';
import '../logs/logs_screen.dart';
import '../system/system_screen.dart';
import '../pairing/pairing_screen.dart';
import '../memory/memory_screen.dart';
import '../settings/settings_screen.dart';

class ControlCenterScreen extends StatelessWidget {
  final AppSettings settings;
  final Function(AppSettings) onSaveSettings;
  final List<McpServer> mcpServers;
  final Function(McpServer) onAddMcpServer;
  final Function(McpServer) onUpdateMcpServer;
  final Function(String) onDeleteMcpServer;

  final ChannelConfig channelConfig;
  final Function(ChannelConfig) onSaveChannelConfig;

  final List<AgentProfile> profiles;
  final String activeProfileId;
  final Function(String) onSelectProfile;
  final Function(AgentProfile) onAddProfile;
  final Function(AgentProfile) onUpdateProfile;
  final Function(String) onDeleteProfile;

  final List<CronJob> cronJobs;
  final Function(CronJob) onAddCronJob;
  final Function(CronJob) onUpdateCronJob;
  final Function(String) onDeleteCronJob;

  final List<EnvSecret> secrets;
  final Function(List<EnvSecret>) onSaveSecrets;

  final AnalyticsData analytics;
  final Function(AnalyticsData) onSaveAnalytics;

  final List<SystemLog> logs;
  final VoidCallback onClearLogs;

  final SystemStats systemStats;
  final Future<void> Function() onRefreshSystemStats;

  final List<MemoryItem> memories;
  final Function(MemoryItem) onAddMemory;
  final Function(String) onDeleteMemory;

  const ControlCenterScreen({
    super.key,
    required this.settings,
    required this.onSaveSettings,
    required this.mcpServers,
    required this.onAddMcpServer,
    required this.onUpdateMcpServer,
    required this.onDeleteMcpServer,
    required this.channelConfig,
    required this.onSaveChannelConfig,
    required this.profiles,
    required this.activeProfileId,
    required this.onSelectProfile,
    required this.onAddProfile,
    required this.onUpdateProfile,
    required this.onDeleteProfile,
    required this.cronJobs,
    required this.onAddCronJob,
    required this.onUpdateCronJob,
    required this.onDeleteCronJob,
    required this.secrets,
    required this.onSaveSecrets,
    required this.analytics,
    required this.onSaveAnalytics,
    required this.logs,
    required this.onClearLogs,
    required this.systemStats,
    required this.onRefreshSystemStats,
    required this.memories,
    required this.onAddMemory,
    required this.onDeleteMemory,
  });

  @override
  Widget build(BuildContext context) {
    final activeProfile = profiles.firstWhere((p) => p.id == activeProfileId, orElse: () => profiles.first);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hermes Suite Hub', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Active Profile Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  HermesTheme.primary.withOpacity(0.15),
                  HermesTheme.accent.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: HermesTheme.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: HermesTheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.smart_toy_rounded, color: HermesTheme.primary, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            activeProfile.name,
                            style: const TextStyle(color: HermesTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: HermesTheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('ACTIVE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 9)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Model: ${settings.selectedModel.split('/').last}',
                        style: const TextStyle(color: HermesTheme.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.tune_rounded, color: HermesTheme.primary),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfilesScreen(
                          profiles: profiles,
                          activeProfileId: activeProfileId,
                          onSelectProfile: onSelectProfile,
                          onAddProfile: onAddProfile,
                          onUpdateProfile: onUpdateProfile,
                          onDeleteProfile: onDeleteProfile,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('SYSTEM MODULES & EXTENSIONS',
              style: TextStyle(color: HermesTheme.textMuted, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.1)),
          const SizedBox(height: 12),
          // MCP Server Card
          _buildHubTile(
            context: context,
            title: 'MCP Servers (Model Context Protocol)',
            subtitle: '${mcpServers.where((s) => s.status == 'connected').length} connected • ${mcpServers.length} total',
            icon: Icons.dns_rounded,
            iconColor: HermesTheme.primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => McpScreen(
                    servers: mcpServers,
                    onAddServer: onAddMcpServer,
                    onUpdateServer: onUpdateMcpServer,
                    onDeleteServer: onDeleteMcpServer,
                  ),
                ),
              );
            },
          ),
          // Channels Card
          _buildHubTile(
            context: context,
            title: 'Messaging Channels & Relays',
            subtitle: 'WhatsApp QR, Telegram bot, Discord, Slack',
            icon: Icons.hub_rounded,
            iconColor: const Color(0xFF25D366),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChannelsScreen(
                    config: channelConfig,
                    onSaveConfig: onSaveChannelConfig,
                  ),
                ),
              );
            },
          ),
          // Profiles Card
          _buildHubTile(
            context: context,
            title: 'Agent Profiles & Soul Builder',
            subtitle: '${profiles.length} personas configured • SOUL.md system editor',
            icon: Icons.psychology_rounded,
            iconColor: HermesTheme.accent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfilesScreen(
                    profiles: profiles,
                    activeProfileId: activeProfileId,
                    onSelectProfile: onSelectProfile,
                    onAddProfile: onAddProfile,
                    onUpdateProfile: onUpdateProfile,
                    onDeleteProfile: onDeleteProfile,
                  ),
                ),
              );
            },
          ),
          // Cron Automations Card
          _buildHubTile(
            context: context,
            title: 'Cron Automations & Scheduler',
            subtitle: '${cronJobs.where((j) => j.isEnabled).length} active jobs • Background triggers',
            icon: Icons.schedule_rounded,
            iconColor: Colors.orangeAccent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CronScreen(
                    jobs: cronJobs,
                    onAddJob: onAddCronJob,
                    onUpdateJob: onUpdateCronJob,
                    onDeleteJob: onDeleteCronJob,
                  ),
                ),
              );
            },
          ),
          // Env Secrets Card
          _buildHubTile(
            context: context,
            title: 'Environment Secrets & API Keys',
            subtitle: '${secrets.length} variables • Gemini, OpenRouter, Tavily, Serper',
            icon: Icons.vpn_key_rounded,
            iconColor: Colors.amberAccent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EnvScreen(
                    secrets: secrets,
                    onSaveSecrets: onSaveSecrets,
                    onSyncSettings: onSaveSettings,
                    settings: settings,
                  ),
                ),
              );
            },
          ),
          // Analytics Card
          _buildHubTile(
            context: context,
            title: 'Token Analytics & USD Costs',
            subtitle: '${analytics.totalTokens} tokens • \$${analytics.totalCostUsd.toStringAsFixed(4)} estimated',
            icon: Icons.bar_chart_rounded,
            iconColor: HermesTheme.success,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AnalyticsScreen(
                    analytics: analytics,
                    onSaveAnalytics: onSaveAnalytics,
                  ),
                ),
              );
            },
          ),
          // Execution Logs Card
          _buildHubTile(
            context: context,
            title: 'Live Execution & System Logs',
            subtitle: '${logs.length} logged events • Filter by ERROR, INFO, DEBUG',
            icon: Icons.receipt_long_rounded,
            iconColor: Colors.cyanAccent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LogsScreen(
                    logs: logs,
                    onClearLogs: onClearLogs,
                  ),
                ),
              );
            },
          ),
          // Telemetry Card
          _buildHubTile(
            context: context,
            title: 'System Telemetry & Hardware',
            subtitle: 'CPU: ${systemStats.cpuUsagePercent.toStringAsFixed(0)}% • RAM: ${systemStats.memoryUsagePercent.toStringAsFixed(0)}% • ${systemStats.gatewayLatencyMs}ms ping',
            icon: Icons.speed_rounded,
            iconColor: Colors.tealAccent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SystemScreen(
                    stats: systemStats,
                    onRefresh: onRefreshSystemStats,
                  ),
                ),
              );
            },
          ),
          // Device Pairing Card
          _buildHubTile(
            context: context,
            title: 'Device Pairing & Gateway Bridge',
            subtitle: 'QR code link with Desktop & Web dashboard',
            icon: Icons.qr_code_rounded,
            iconColor: Colors.purpleAccent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PairingScreen(
                    gatewayUrl: settings.gatewayUrl,
                    onUpdateGatewayUrl: (url) {
                      settings.gatewayUrl = url;
                      onSaveSettings(settings);
                    },
                  ),
                ),
              );
            },
          ),
          // Memory Card
          _buildHubTile(
            context: context,
            title: 'Persistent Memory (MEMORY.md)',
            subtitle: '${memories.length} facts remembered across sessions',
            icon: Icons.inventory_2_rounded,
            iconColor: Colors.pinkAccent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MemoryScreen(
                    memories: memories,
                    onAddMemory: onAddMemory,
                    onDeleteMemory: onDeleteMemory,
                  ),
                ),
              );
            },
          ),
          // General Config Card
          _buildHubTile(
            context: context,
            title: 'General Settings & AI Providers',
            subtitle: 'Model, Gateway IP, WebSocket, Temperature',
            icon: Icons.tune_rounded,
            iconColor: HermesTheme.textSecondary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: const Text('General Settings')),
                    body: SettingsScreen(
                      settings: settings,
                      onSaveSettings: onSaveSettings,
                      systemStats: systemStats,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHubTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: HermesTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HermesTheme.cardBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(color: HermesTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: HermesTheme.textMuted, fontSize: 11),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: HermesTheme.textMuted, size: 20),
        onTap: onTap,
      ),
    );
  }
}
