import 'package:flutter/material.dart';
import '../../core/theme/hermes_theme.dart';
import '../../models/memory_item.dart';

class MemoryScreen extends StatefulWidget {
  final List<MemoryItem> memories;
  final Function(MemoryItem) onAddMemory;
  final Function(String) onDeleteMemory;

  const MemoryScreen({
    super.key,
    required this.memories,
    required this.onAddMemory,
    required this.onDeleteMemory,
  });

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.memories.where((m) {
      if (_selectedCategory == 'all') return true;
      return m.category == _selectedCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Long-term Memory (MEMORY.md)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: HermesTheme.primary),
            onPressed: () => _showAddMemoryDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _chip('All Memories', 'all'),
                _chip('User Preferences', 'preference'),
                _chip('Project Rules', 'project'),
                _chip('Profile Context', 'user'),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No memories in this category',
                      style: TextStyle(color: HermesTheme.textMuted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: HermesTheme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: HermesTheme.cardBorder),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: HermesTheme.accent.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.psychology_rounded, size: 18, color: HermesTheme.accent),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        item.key,
                                        style: const TextStyle(
                                          color: HermesTheme.primary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        item.category.toUpperCase(),
                                        style: const TextStyle(
                                          color: HermesTheme.textMuted,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.content,
                                    style: const TextStyle(
                                      color: HermesTheme.textPrimary,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: HermesTheme.textMuted),
                              onPressed: () => widget.onDeleteMemory(item.id),
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

  Widget _chip(String label, String category) {
    final isSelected = _selectedCategory == category;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : HermesTheme.textSecondary,
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: HermesTheme.cardColor,
        selectedColor: HermesTheme.primary,
        checkmarkColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? HermesTheme.primary : HermesTheme.cardBorder,
          ),
        ),
        onSelected: (_) => setState(() => _selectedCategory = category),
      ),
    );
  }

  void _showAddMemoryDialog(BuildContext context) {
    final keyCtrl = TextEditingController();
    final valCtrl = TextEditingController();
    String category = 'preference';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: HermesTheme.surface,
          title: const Text('Remember New Fact (MEMORY.md)', style: TextStyle(color: HermesTheme.textPrimary, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: keyCtrl,
                style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                decoration: const InputDecoration(labelText: 'Key / Topic (e.g. user_language)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: valCtrl,
                maxLines: 3,
                style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                decoration: const InputDecoration(labelText: 'Fact / Requirement to remember'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: category,
                dropdownColor: HermesTheme.cardColor,
                style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(value: 'preference', child: Text('Preference')),
                  DropdownMenuItem(value: 'project', child: Text('Project Rule')),
                  DropdownMenuItem(value: 'user', child: Text('User Profile')),
                ],
                onChanged: (val) {
                  if (val != null) setDlgState(() => category = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: HermesTheme.textMuted)),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: HermesTheme.primary),
              child: const Text('Remember', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              onPressed: () {
                if (keyCtrl.text.trim().isNotEmpty && valCtrl.text.trim().isNotEmpty) {
                  final item = MemoryItem(
                    id: 'mem_${DateTime.now().millisecondsSinceEpoch}',
                    key: keyCtrl.text.trim(),
                    content: valCtrl.text.trim(),
                    category: category,
                  );
                  widget.onAddMemory(item);
                  Navigator.pop(ctx);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
