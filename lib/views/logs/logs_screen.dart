import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/storage/local_storage.dart';
import '../../core/theme/hermes_theme.dart';
import '../../models/system_log.dart';

class LogsScreen extends StatefulWidget {
  final List<SystemLog> logs;
  final VoidCallback onClearLogs;

  const LogsScreen({
    super.key,
    required this.logs,
    required this.onClearLogs,
  });

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  String _selectedLevel = 'ALL';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _getLevelColor(String level) {
    switch (level.toUpperCase()) {
      case 'ERROR':
        return HermesTheme.error;
      case 'WARN':
        return Colors.orangeAccent;
      case 'DEBUG':
        return HermesTheme.accent;
      default:
        return HermesTheme.primary;
    }
  }

  void _copyAllLogs() {
    final text = widget.logs.map((l) => '[${l.timestamp.toIso8601String()}] [${l.level}] [${l.tag}] ${l.message}').join('\n');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: HermesTheme.success,
        content: Text('✓ Logs copied to clipboard!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm:ss');

    final filteredLogs = widget.logs.where((l) {
      if (_selectedLevel != 'ALL' && l.level.toUpperCase() != _selectedLevel) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return l.message.toLowerCase().contains(q) || l.tag.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Execution Logs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded, color: HermesTheme.primary),
            tooltip: 'Copy All',
            onPressed: _copyAllLogs,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: HermesTheme.error),
            tooltip: 'Clear Logs',
            onPressed: widget.onClearLogs,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: HermesTheme.surface,
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search logs...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 18, color: HermesTheme.textMuted),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 16, color: HermesTheme.textMuted),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['ALL', 'INFO', 'WARN', 'ERROR', 'DEBUG'].map((level) {
                      final isSelected = _selectedLevel == level;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(level, style: TextStyle(fontSize: 11, color: isSelected ? Colors.black : HermesTheme.textPrimary, fontWeight: FontWeight.bold)),
                          selected: isSelected,
                          selectedColor: HermesTheme.primary,
                          backgroundColor: HermesTheme.cardColor,
                          onSelected: (_) => setState(() => _selectedLevel = level),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // Logs Stream
          Expanded(
            child: filteredLogs.isEmpty
                ? const Center(
                    child: Text('No logs match query.', style: TextStyle(color: HermesTheme.textMuted)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      final color = _getLevelColor(log.level);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: HermesTheme.cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: HermesTheme.cardBorder),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              timeFormat.format(log.timestamp),
                              style: const TextStyle(color: HermesTheme.textMuted, fontFamily: 'monospace', fontSize: 10),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                log.level,
                                style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: HermesTheme.surface,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                log.tag,
                                style: const TextStyle(color: HermesTheme.textSecondary, fontFamily: 'monospace', fontSize: 9),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SelectableText(
                                log.message,
                                style: const TextStyle(color: HermesTheme.textPrimary, fontFamily: 'monospace', fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
