import 'package:flutter/material.dart';
import '../../core/theme/hermes_theme.dart';
import '../../models/app_settings.dart';
import '../../models/env_secret.dart';

class EnvScreen extends StatefulWidget {
  final List<EnvSecret> secrets;
  final Function(List<EnvSecret>) onSaveSecrets;
  final Function(AppSettings) onSyncSettings;
  final AppSettings settings;

  const EnvScreen({
    super.key,
    required this.secrets,
    required this.onSaveSecrets,
    required this.onSyncSettings,
    required this.settings,
  });

  @override
  State<EnvScreen> createState() => _EnvScreenState();
}

class _EnvScreenState extends State<EnvScreen> {
  late List<EnvSecret> _list;

  @override
  void initState() {
    super.initState();
    _list = List.from(widget.secrets);
  }

  void _openEditDialog(EnvSecret secret) {
    final valCtrl = TextEditingController(text: secret.value);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HermesTheme.surface,
        title: Text('Edit ${secret.key}', style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 15)),
        content: TextField(
          controller: valCtrl,
          style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13, fontFamily: 'monospace'),
          decoration: const InputDecoration(
            labelText: 'Secret Value / API Key',
            hintText: 'Enter API Key...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: HermesTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: HermesTheme.primary),
            onPressed: () {
              setState(() {
                secret.value = valCtrl.text.trim();
              });
              _persist();
              Navigator.pop(ctx);
            },
            child: const Text('Save', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openAddSecretDialog() {
    final keyCtrl = TextEditingController();
    final valCtrl = TextEditingController();
    String category = 'LLM API Keys';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: HermesTheme.surface,
          title: const Text('Add Environment Secret', style: TextStyle(color: HermesTheme.textPrimary, fontSize: 15)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: keyCtrl,
                  style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13, fontFamily: 'monospace'),
                  decoration: const InputDecoration(labelText: 'Key Name', hintText: 'e.g. COHERE_API_KEY'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  dropdownColor: HermesTheme.cardColor,
                  style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: 'LLM API Keys', child: Text('LLM API Keys')),
                    DropdownMenuItem(value: 'Search & Tools', child: Text('Search & Tools')),
                    DropdownMenuItem(value: 'Database & Cloud', child: Text('Database & Cloud')),
                    DropdownMenuItem(value: 'Services', child: Text('Services')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDlgState(() => category = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: valCtrl,
                  style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13, fontFamily: 'monospace'),
                  decoration: const InputDecoration(labelText: 'Value'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: HermesTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: HermesTheme.primary),
              onPressed: () {
                if (keyCtrl.text.trim().isEmpty) return;
                setState(() {
                  _list.add(
                    EnvSecret(
                      key: keyCtrl.text.trim().toUpperCase(),
                      value: valCtrl.text.trim(),
                      category: category,
                    ),
                  );
                });
                _persist();
                Navigator.pop(ctx);
              },
              child: const Text('Add', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _persist() {
    widget.onSaveSecrets(_list);

    // Sync GEMINI_API_KEY and OPENROUTER_API_KEY to AppSettings
    final gemini = _list.firstWhere((s) => s.key == 'GEMINI_API_KEY', orElse: () => EnvSecret(key: '', value: ''));
    final openrouter = _list.firstWhere((s) => s.key == 'OPENROUTER_API_KEY', orElse: () => EnvSecret(key: '', value: ''));

    final newSettings = widget.settings;
    if (gemini.value.isNotEmpty) newSettings.geminiApiKey = gemini.value;
    if (openrouter.value.isNotEmpty) newSettings.openRouterApiKey = openrouter.value;
    widget.onSyncSettings(newSettings);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: HermesTheme.success,
        content: Text('✓ Secrets updated and synchronized with Hermes Service!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Group by category
    final categories = _list.map((e) => e.category).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Environment & Secrets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: HermesTheme.primary),
            onPressed: _openAddSecretDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: HermesTheme.primary,
        icon: const Icon(Icons.vpn_key_rounded, color: Colors.black),
        label: const Text('New Secret', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        onPressed: _openAddSecretDialog,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: HermesTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: HermesTheme.primary.withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, color: HermesTheme.primary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Stored safely in device encrypted storage. Secrets are injected into Hermes agent tool calls and LLM providers.',
                    style: TextStyle(color: HermesTheme.textSecondary, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final cat in categories) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                cat.toUpperCase(),
                style: const TextStyle(
                  color: HermesTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            ..._list.where((s) => s.category == cat).map((s) {
              final hasValue = s.value.isNotEmpty;
              final displayValue = !hasValue
                  ? '(Not configured)'
                  : (s.isMasked
                      ? '••••••••••••••••••••'
                      : s.value);

              return Container(
                margin: const EdgeInsets.bottom(10),
                decoration: BoxDecoration(
                  color: HermesTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: HermesTheme.cardBorder),
                ),
                child: ListTile(
                  title: Text(
                    s.key,
                    style: const TextStyle(
                      color: HermesTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text(
                    displayValue,
                    style: TextStyle(
                      color: hasValue ? HermesTheme.textSecondary : HermesTheme.textMuted,
                      fontSize: 11,
                      fontFamily: hasValue ? 'monospace' : null,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasValue)
                        IconButton(
                          icon: Icon(
                            s.isMasked ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: HermesTheme.textMuted,
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() => s.isMasked = !s.isMasked);
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, color: HermesTheme.primary, size: 18),
                        onPressed: () => _openEditDialog(s),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: HermesTheme.error, size: 18),
                        onPressed: () {
                          setState(() => _list.remove(s));
                          _persist();
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
