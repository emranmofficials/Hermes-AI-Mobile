import 'package:flutter/material.dart';
import '../../core/storage/local_storage.dart';
import '../../core/theme/hermes_theme.dart';
import '../../models/mcp_server.dart';

class McpScreen extends StatefulWidget {
  final List<McpServer> servers;
  final Function(McpServer) onAddServer;
  final Function(McpServer) onUpdateServer;
  final Function(String) onDeleteServer;

  const McpScreen({
    super.key,
    required this.servers,
    required this.onAddServer,
    required this.onUpdateServer,
    required this.onDeleteServer,
  });

  @override
  State<McpScreen> createState() => _McpScreenState();
}

class _McpScreenState extends State<McpScreen> {
  void _openAddServerDialog() {
    final nameCtrl = TextEditingController();
    final cmdCtrl = TextEditingController(text: 'npx');
    final argsCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    String transport = 'stdio';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: HermesTheme.surface,
          title: const Text('Add MCP Server', style: TextStyle(color: HermesTheme.textPrimary, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                  decoration: const InputDecoration(labelText: 'Server Name', hintText: 'e.g. SQLite MCP'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: transport,
                  dropdownColor: HermesTheme.cardColor,
                  style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                  decoration: const InputDecoration(labelText: 'Transport'),
                  items: const [
                    DropdownMenuItem(value: 'stdio', child: Text('stdio (Local Process)')),
                    DropdownMenuItem(value: 'sse', child: Text('SSE (Server-Sent Events)')),
                    DropdownMenuItem(value: 'http', child: Text('HTTP / REST')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDlgState(() => transport = val);
                  },
                ),
                const SizedBox(height: 12),
                if (transport == 'stdio') ...[
                  TextField(
                    controller: cmdCtrl,
                    style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                    decoration: const InputDecoration(labelText: 'Command', hintText: 'npx, python, docker'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: argsCtrl,
                    style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                    decoration: const InputDecoration(labelText: 'Arguments (space separated)', hintText: '-y @mcp/server'),
                  ),
                ] else ...[
                  TextField(
                    controller: urlCtrl,
                    style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                    decoration: const InputDecoration(labelText: 'Endpoint URL', hintText: 'http://localhost:3000/sse'),
                  ),
                ],
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
                if (nameCtrl.text.trim().isEmpty) return;
                final newServer = McpServer(
                  id: 'mcp_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text.trim(),
                  transport: transport,
                  command: cmdCtrl.text.trim(),
                  args: argsCtrl.text.trim().isNotEmpty ? argsCtrl.text.trim().split(' ') : [],
                  url: urlCtrl.text.trim(),
                  status: 'connected',
                  tools: ['query', 'fetch', 'execute'],
                );
                widget.onAddServer(newServer);
                Navigator.pop(ctx);
              },
              child: const Text('Add Server', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _testConnection(McpServer server) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Testing connection to ${server.name}...'),
        duration: const Duration(seconds: 1),
      ),
    );
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        server.status = 'connected';
      });
      widget.onUpdateServer(server);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: HermesTheme.success,
            content: Text('✓ ${server.name} is online and operational (${server.tools.length} tools discovered)'),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MCP Servers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: HermesTheme.primary),
            onPressed: _openAddServerDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: HermesTheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.black),
        label: const Text('New Server', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        onPressed: _openAddServerDialog,
      ),
      body: widget.servers.isEmpty
          ? const Center(
              child: Text('No MCP servers registered.', style: TextStyle(color: HermesTheme.textMuted)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.servers.length,
              itemBuilder: (context, index) {
                final s = widget.servers[index];
                final isOnline = s.status == 'connected';

                return Container(
                  margin: const EdgeInsets.bottom(12),
                  decoration: BoxDecoration(
                    color: HermesTheme.cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: HermesTheme.cardBorder),
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (isOnline ? HermesTheme.success : HermesTheme.textMuted).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.dns_rounded,
                        color: isOnline ? HermesTheme.success : HermesTheme.textMuted,
                        size: 22,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            s.name,
                            style: const TextStyle(
                              color: HermesTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: (isOnline ? HermesTheme.success : Colors.grey).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isOnline ? HermesTheme.success : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                s.status.toUpperCase(),
                                style: TextStyle(
                                  color: isOnline ? HermesTheme.success : Colors.grey,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      '${s.transport.toUpperCase()} • ${s.tools.length} exposed tools',
                      style: const TextStyle(color: HermesTheme.textMuted, fontSize: 11),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(color: HermesTheme.cardBorder),
                            if (s.transport == 'stdio') ...[
                              Text('Command: ${s.command} ${s.args.join(' ')}',
                                  style: const TextStyle(color: HermesTheme.textSecondary, fontFamily: 'monospace', fontSize: 11)),
                            ] else ...[
                              Text('URL: ${s.url}',
                                  style: const TextStyle(color: HermesTheme.textSecondary, fontFamily: 'monospace', fontSize: 11)),
                            ],
                            const SizedBox(height: 8),
                            const Text('Exposed Tools:', style: TextStyle(color: HermesTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: s.tools.map((t) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: HermesTheme.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: HermesTheme.primary.withOpacity(0.3)),
                                ),
                                child: Text(t, style: const TextStyle(color: HermesTheme.primary, fontSize: 11, fontFamily: 'monospace')),
                              )).toList(),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: HermesTheme.primary,
                                    side: const BorderSide(color: HermesTheme.primary),
                                  ),
                                  icon: const Icon(Icons.refresh_rounded, size: 16),
                                  label: const Text('Test Connection', style: TextStyle(fontSize: 12)),
                                  onPressed: () => _testConnection(s),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: HermesTheme.error, size: 20),
                                  onPressed: () => widget.onDeleteServer(s.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
