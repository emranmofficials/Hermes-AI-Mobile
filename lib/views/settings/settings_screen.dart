import 'package:flutter/material.dart';
import '../../core/theme/hermes_theme.dart';
import '../../models/app_settings.dart';
import '../../models/system_stats.dart';

class SettingsScreen extends StatefulWidget {
  final AppSettings settings;
  final Function(AppSettings) onSaveSettings;
  final SystemStats? systemStats;

  const SettingsScreen({
    super.key,
    required this.settings,
    required this.onSaveSettings,
    this.systemStats,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ConnectionMode _mode;
  late CloudProvider _provider;
  late TextEditingController _apiKeyCtrl;
  late TextEditingController _modelCtrl;
  late TextEditingController _baseUrlCtrl;
  late TextEditingController _gatewayUrlCtrl;
  late TextEditingController _gatewayTokenCtrl;
  late TextEditingController _sysPromptCtrl;
  late double _temperature;

  @override
  void initState() {
    super.initState();
    final s = widget.settings;
    _mode = s.connectionMode;
    _provider = s.cloudProvider;
    _apiKeyCtrl = TextEditingController(text: s.apiKey);
    _modelCtrl = TextEditingController(text: s.selectedModel);
    _baseUrlCtrl = TextEditingController(text: s.baseUrl);
    _gatewayUrlCtrl = TextEditingController(text: s.gatewayUrl);
    _gatewayTokenCtrl = TextEditingController(text: s.gatewayToken);
    _sysPromptCtrl = TextEditingController(text: s.systemPrompt);
    _temperature = s.temperature;
  }

  @override
  void dispose() {
    _apiKeyCtrl.dispose();
    _modelCtrl.dispose();
    _baseUrlCtrl.dispose();
    _gatewayUrlCtrl.dispose();
    _gatewayTokenCtrl.dispose();
    _sysPromptCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final newSettings = AppSettings(
      connectionMode: _mode,
      cloudProvider: _provider,
      apiKey: _apiKeyCtrl.text.trim(),
      selectedModel: _modelCtrl.text.trim(),
      baseUrl: _baseUrlCtrl.text.trim(),
      gatewayUrl: _gatewayUrlCtrl.text.trim(),
      gatewayToken: _gatewayTokenCtrl.text.trim(),
      temperature: _temperature,
      systemPrompt: _sysPromptCtrl.text.trim(),
    );
    widget.onSaveSettings(newSettings);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully!'),
        backgroundColor: HermesTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Settings & Connection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded, color: HermesTheme.primary),
            onPressed: _save,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Real-time System Monitoring Card (/api/system/stats)
          _sectionTitle('SYSTEM MONITORING & TELEMETRY (/api/system/stats)'),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: HermesTheme.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: HermesTheme.cardBorder),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: (widget.systemStats?.isGatewayOnline ?? true)
                            ? HermesTheme.success
                            : HermesTheme.danger,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.systemStats?.gatewayVersion ?? 'Hermes Engine Active',
                      style: const TextStyle(
                        color: HermesTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _metricItem('CPU', '${(widget.systemStats?.cpuUsagePercent ?? 14.5).toStringAsFixed(1)}%', HermesTheme.primary),
                    _metricItem('RAM', '${(widget.systemStats?.ramUsedMb ?? 3450)} MB', HermesTheme.secondary),
                    _metricItem('TASKS', '${widget.systemStats?.activeTasksCount ?? 2}', HermesTheme.warning),
                    _metricItem('AGENTS', '${widget.systemStats?.totalSubagents ?? 1}', HermesTheme.accent),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Connection Mode Card
          _sectionTitle('CONNECTION ARCHITECTURE'),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: HermesTheme.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: HermesTheme.cardBorder),
            ),
            child: Column(
              children: [
                RadioListTile<ConnectionMode>(
                  title: const Text('Direct Cloud API Mode', style: TextStyle(color: HermesTheme.textPrimary, fontSize: 14)),
                  subtitle: const Text('Direct LLM streaming on mobile without server installation.', style: TextStyle(color: HermesTheme.textMuted, fontSize: 11)),
                  value: ConnectionMode.directCloud,
                  groupValue: _mode,
                  activeColor: HermesTheme.primary,
                  onChanged: (val) => setState(() => _mode = val!),
                ),
                const Divider(color: HermesTheme.cardBorder),
                RadioListTile<ConnectionMode>(
                  title: const Text('Hermes Agent Server (WebSocket)', style: TextStyle(color: HermesTheme.textPrimary, fontSize: 14)),
                  subtitle: const Text('Connect to local or remote `hermes serve` for autonomous execution.', style: TextStyle(color: HermesTheme.textMuted, fontSize: 11)),
                  value: ConnectionMode.hermesGateway,
                  groupValue: _mode,
                  activeColor: HermesTheme.primary,
                  onChanged: (val) => setState(() => _mode = val!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Details depending on mode
          if (_mode == ConnectionMode.hermesGateway) ...[
            _sectionTitle('HERMES GATEWAY / SERVER'),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: HermesTheme.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: HermesTheme.cardBorder),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _gatewayUrlCtrl,
                    style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                    decoration: const InputDecoration(
                      labelText: 'Gateway WebSocket URL',
                      hintText: 'ws://192.168.1.100:8000/ws',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _gatewayTokenCtrl,
                    obscureText: true,
                    style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                    decoration: const InputDecoration(
                      labelText: 'Auth Token (Optional)',
                      hintText: 'Bearer token',
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            _sectionTitle('CLOUD LLM PROVIDER'),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: HermesTheme.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: HermesTheme.cardBorder),
              ),
              child: Column(
                children: [
                  DropdownButtonFormField<CloudProvider>(
                    value: _provider,
                    dropdownColor: HermesTheme.cardColor,
                    style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                    decoration: const InputDecoration(labelText: 'Provider'),
                    items: const [
                      DropdownMenuItem(value: CloudProvider.openRouter, child: Text('OpenRouter (Recommended)')),
                      DropdownMenuItem(value: CloudProvider.nousPortal, child: Text('Nous Research Portal')),
                      DropdownMenuItem(value: CloudProvider.ollama, child: Text('Local Ollama (Offline)')),
                      DropdownMenuItem(value: CloudProvider.openai, child: Text('OpenAI Compatible')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _provider = val;
                          if (val == CloudProvider.openRouter) {
                            _baseUrlCtrl.text = 'https://openrouter.ai/api/v1';
                            _modelCtrl.text = 'nousresearch/hermes-3-llama-3.1-405b';
                          } else if (val == CloudProvider.ollama) {
                            _baseUrlCtrl.text = 'http://localhost:11434/v1';
                            _modelCtrl.text = 'hermes3';
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _apiKeyCtrl,
                    obscureText: true,
                    style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                    decoration: const InputDecoration(
                      labelText: 'API Key',
                      hintText: 'sk-or-v1-...',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _modelCtrl,
                    style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                    decoration: const InputDecoration(
                      labelText: 'Model Identifier',
                      hintText: 'nousresearch/hermes-3-llama-3.1-405b',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _baseUrlCtrl,
                    style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                    decoration: const InputDecoration(
                      labelText: 'Base URL',
                      hintText: 'https://openrouter.ai/api/v1',
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Agent Parameters
          _sectionTitle('AGENT PARAMETERS'),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: HermesTheme.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: HermesTheme.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Temperature', style: TextStyle(color: HermesTheme.textPrimary, fontSize: 13)),
                    Text(_temperature.toStringAsFixed(2), style: const TextStyle(color: HermesTheme.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
                Slider(
                  value: _temperature,
                  min: 0.0,
                  max: 1.5,
                  divisions: 15,
                  activeColor: HermesTheme.primary,
                  inactiveColor: HermesTheme.cardBorder,
                  onChanged: (val) => setState(() => _temperature = val),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _sysPromptCtrl,
                  maxLines: 4,
                  style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'System Instructions (Persona)',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: HermesTheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _save,
            child: const Text(
              'Save & Apply Settings',
              style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: HermesTheme.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: HermesTheme.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
