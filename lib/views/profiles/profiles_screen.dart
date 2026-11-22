import 'package:flutter/material.dart';
import '../../core/storage/local_storage.dart';
import '../../core/theme/hermes_theme.dart';
import '../../models/agent_profile.dart';

class ProfilesScreen extends StatefulWidget {
  final List<AgentProfile> profiles;
  final String activeProfileId;
  final Function(String) onSelectProfile;
  final Function(AgentProfile) onAddProfile;
  final Function(AgentProfile) onUpdateProfile;
  final Function(String) onDeleteProfile;

  const ProfilesScreen({
    super.key,
    required this.profiles,
    required this.activeProfileId,
    required this.onSelectProfile,
    required this.onAddProfile,
    required this.onUpdateProfile,
    required this.onDeleteProfile,
  });

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  void _openSoulEditor(AgentProfile profile) {
    final soulCtrl = TextEditingController(text: profile.soulContent);
    final roleCtrl = TextEditingController(text: profile.role);
    final descCtrl = TextEditingController(text: profile.description);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: HermesTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology_rounded, color: HermesTheme.accent, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Soul Editor: ${profile.name}',
                  style: const TextStyle(color: HermesTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Customize the system prompt, behavior, tone, and autonomous reasoning persona.',
              style: TextStyle(color: HermesTheme.textMuted, fontSize: 11),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: roleCtrl,
              style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
              decoration: const InputDecoration(labelText: 'Agent Role Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
              decoration: const InputDecoration(labelText: 'Short Description'),
            ),
            const SizedBox(height: 12),
            const Text('System Prompt (SOUL.md):', style: TextStyle(color: HermesTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(
              controller: soulCtrl,
              maxLines: 7,
              style: const TextStyle(color: HermesTheme.textPrimary, fontFamily: 'monospace', fontSize: 12),
              decoration: const InputDecoration(
                hintText: 'Enter autonomous instructions, role guidelines, formatting rules...',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: HermesTheme.textMuted)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: HermesTheme.primary),
                  onPressed: () {
                    profile.role = roleCtrl.text.trim();
                    profile.description = descCtrl.text.trim();
                    profile.soulContent = soulCtrl.text.trim();
                    widget.onUpdateProfile(profile);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: HermesTheme.success,
                        content: Text('✓ Soul definition updated!'),
                      ),
                    );
                  },
                  child: const Text('Save Soul', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openCreateProfileDialog() {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final soulCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HermesTheme.surface,
        title: const Text('Create Agent Profile', style: TextStyle(color: HermesTheme.textPrimary, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                decoration: const InputDecoration(labelText: 'Profile Name', hintText: 'e.g. Flutter Specialist'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: roleCtrl,
                style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                decoration: const InputDecoration(labelText: 'Role', hintText: 'e.g. Senior Mobile Architect'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: soulCtrl,
                maxLines: 4,
                style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 12, fontFamily: 'monospace'),
                decoration: const InputDecoration(labelText: 'System Instructions (SOUL.md)'),
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
              if (nameCtrl.text.trim().isEmpty) return;
              final newP = AgentProfile(
                id: 'prof_${DateTime.now().millisecondsSinceEpoch}',
                name: nameCtrl.text.trim(),
                role: roleCtrl.text.trim(),
                description: descCtrl.text.trim(),
                soulContent: soulCtrl.text.trim().isNotEmpty
                    ? soulCtrl.text.trim()
                    : 'You are an autonomous Hermes agent. Deliver rigorous and tested output.',
              );
              widget.onAddProfile(newP);
              Navigator.pop(ctx);
            },
            child: const Text('Create', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'code':
        return Icons.code_rounded;
      case 'science':
        return Icons.science_rounded;
      case 'terminal':
        return Icons.terminal_rounded;
      default:
        return Icons.psychology_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Profiles & Soul', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: HermesTheme.primary),
            onPressed: _openCreateProfileDialog,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.profiles.length,
        itemBuilder: (context, index) {
          final p = widget.profiles[index];
          final isActive = p.id == widget.activeProfileId;

          return Container(
            margin: const EdgeInsets.bottom(12),
            decoration: BoxDecoration(
              color: HermesTheme.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive ? HermesTheme.primary : HermesTheme.cardBorder,
                width: isActive ? 1.5 : 1,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (isActive ? HermesTheme.primary : HermesTheme.accent).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getIconData(p.iconName), color: isActive ? HermesTheme.primary : HermesTheme.accent, size: 24),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      p.name,
                      style: const TextStyle(color: HermesTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: HermesTheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('ACTIVE', style: TextStyle(color: HermesTheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(p.role, style: const TextStyle(color: HermesTheme.primary, fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(p.description, style: const TextStyle(color: HermesTheme.textMuted, fontSize: 11)),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_note_rounded, color: HermesTheme.primary, size: 22),
                    tooltip: 'Edit Soul (SOUL.md)',
                    onPressed: () => _openSoulEditor(p),
                  ),
                  if (!isActive)
                    TextButton(
                      onPressed: () => widget.onSelectProfile(p.id),
                      child: const Text('Select', style: TextStyle(color: HermesTheme.primary, fontSize: 12)),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
