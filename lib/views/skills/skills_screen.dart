import 'package:flutter/material.dart';
import '../../core/theme/hermes_theme.dart';
import '../../models/skill.dart';

class SkillsScreen extends StatefulWidget {
  final List<Skill> skills;
  final Function(Skill) onAddSkill;
  final Function(Skill) onToggleSkill;
  final Function(String) onDeleteSkill;

  const SkillsScreen({
    super.key,
    required this.skills,
    required this.onAddSkill,
    required this.onToggleSkill,
    required this.onDeleteSkill,
  });

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.skills.where((s) {
      final q = _searchQuery.toLowerCase();
      return s.name.toLowerCase().contains(q) ||
          s.description.toLowerCase().contains(q) ||
          s.category.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learned Skills Hub (SKILL.md)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: HermesTheme.primary),
            onPressed: () => _showAddSkillDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Info Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search skills by name, trigger or category...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: HermesTheme.textMuted),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No skills found',
                      style: TextStyle(color: HermesTheme.textMuted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final skill = filtered[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: HermesTheme.cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: skill.isEnabled ? HermesTheme.cardBorder : HermesTheme.cardBorder.withOpacity(0.5),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: HermesTheme.primary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    skill.category,
                                    style: const TextStyle(
                                      color: HermesTheme.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Switch(
                                  value: skill.isEnabled,
                                  activeColor: HermesTheme.primary,
                                  onChanged: (_) => widget.onToggleSkill(skill),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              skill.name,
                              style: const TextStyle(
                                color: HermesTheme.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              skill.description,
                              style: const TextStyle(
                                color: HermesTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: HermesTheme.background,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.bolt_rounded, size: 14, color: HermesTheme.warning),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Trigger: ${skill.trigger}',
                                        style: const TextStyle(
                                          color: HermesTheme.textMuted,
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    skill.instructions,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: HermesTheme.textSecondary,
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
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

  void _showAddSkillDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final trigCtrl = TextEditingController();
    final instCtrl = TextEditingController();
    String category = 'Custom';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HermesTheme.surface,
        title: const Text('Add Custom Skill (SKILL.md)', style: TextStyle(color: HermesTheme.textPrimary, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                decoration: const InputDecoration(labelText: 'Skill Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descCtrl,
                style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: trigCtrl,
                style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                decoration: const InputDecoration(labelText: 'Trigger Keyword / Condition'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: instCtrl,
                maxLines: 3,
                style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                decoration: const InputDecoration(labelText: 'Instructions / Prompt Guidance'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: HermesTheme.textMuted)),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: HermesTheme.primary),
            child: const Text('Save Skill', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                final skill = Skill(
                  id: 'skill_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  trigger: trigCtrl.text.trim(),
                  instructions: instCtrl.text.trim(),
                  category: category,
                );
                widget.onAddSkill(skill);
                Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    );
  }
}
