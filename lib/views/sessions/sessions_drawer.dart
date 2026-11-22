import 'package:flutter/material.dart';
import '../../core/theme/hermes_theme.dart';
import '../../models/session.dart';

class SessionsDrawer extends StatefulWidget {
  final List<Session> sessions;
  final String? activeSessionId;
  final Function(Session) onSelectSession;
  final VoidCallback onNewSession;
  final Function(String) onDeleteSession;
  final Function(String)? onOpenModule; // e.g. 'mcp', 'channels', 'profiles', etc.

  const SessionsDrawer({
    super.key,
    required this.sessions,
    this.activeSessionId,
    required this.onSelectSession,
    required this.onNewSession,
    required this.onDeleteSession,
    this.onOpenModule,
  });

  @override
  State<SessionsDrawer> createState() => _SessionsDrawerState();
}

class _SessionsDrawerState extends State<SessionsDrawer> {
  String _search = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSessions = widget.sessions.where((s) {
      if (_search.isEmpty) return true;
      return s.title.toLowerCase().contains(_search.toLowerCase());
    }).toList();

    return Drawer(
      backgroundColor: HermesTheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Header / App Identity
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/icons/hermes_icon_64x64.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hermes Agent',
                        style: TextStyle(
                          color: HermesTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Nous Research Mobile Suite',
                        style: TextStyle(
                          color: HermesTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: HermesTheme.cardBorder, height: 1),
            // + New Chat Button
            Padding(
              padding: const EdgeInsets.all(12),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  widget.onNewSession();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        HermesTheme.primary.withOpacity(0.15),
                        HermesTheme.accent.withOpacity(0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: HermesTheme.primary.withOpacity(0.4)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded, color: HermesTheme.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'New Chat Session',
                        style: TextStyle(
                          color: HermesTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Search Box for sessions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Search sessions...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 16, color: HermesTheme.textMuted),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 14, color: HermesTheme.textMuted),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _search = '');
                          },
                        )
                      : null,
                ),
                onChanged: (val) => setState(() => _search = val),
              ),
            ),
            // Sessions List
            Expanded(
              child: filteredSessions.isEmpty
                  ? const Center(
                      child: Text(
                        'No sessions found',
                        style: TextStyle(color: HermesTheme.textMuted, fontSize: 12),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredSessions.length,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemBuilder: (context, index) {
                        final session = filteredSessions[index];
                        final isActive = session.id == widget.activeSessionId;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            color: isActive ? HermesTheme.cardColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isActive ? HermesTheme.primary.withOpacity(0.5) : Colors.transparent,
                            ),
                          ),
                          child: ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            leading: Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 16,
                              color: isActive ? HermesTheme.primary : HermesTheme.textMuted,
                            ),
                            title: Text(
                              session.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isActive ? HermesTheme.textPrimary : HermesTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 16, color: HermesTheme.textMuted),
                              onPressed: () => widget.onDeleteSession(session.id),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              widget.onSelectSession(session);
                            },
                          ),
                        );
                      },
                    ),
            ),
            const Divider(color: HermesTheme.cardBorder, height: 1),
            // Quick Access Navigation
            if (widget.onOpenModule != null)
              Container(
                color: HermesTheme.cardColor,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    _buildQuickAction(
                      icon: Icons.dns_rounded,
                      color: HermesTheme.primary,
                      label: 'MCP Servers',
                      onTap: () {
                        Navigator.pop(context);
                        widget.onOpenModule!('mcp');
                      },
                    ),
                    _buildQuickAction(
                      icon: Icons.qr_code_scanner_rounded,
                      color: const Color(0xFF25D366),
                      label: 'WhatsApp & Relays',
                      onTap: () {
                        Navigator.pop(context);
                        widget.onOpenModule!('channels');
                      },
                    ),
                    _buildQuickAction(
                      icon: Icons.psychology_rounded,
                      color: HermesTheme.accent,
                      label: 'Agent Profiles & Soul',
                      onTap: () {
                        Navigator.pop(context);
                        widget.onOpenModule!('profiles');
                      },
                    ),
                    _buildQuickAction(
                      icon: Icons.schedule_rounded,
                      color: Colors.orangeAccent,
                      label: 'Cron Automations',
                      onTap: () {
                        Navigator.pop(context);
                        widget.onOpenModule!('cron');
                      },
                    ),
                  ],
                ),
              ),
            const Divider(color: HermesTheme.cardBorder, height: 1),
            // Bottom Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: HermesTheme.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Hermes Suite v1.0.6',
                    style: TextStyle(color: HermesTheme.textMuted, fontSize: 11),
                  ),
                  const Spacer(),
                  const Text(
                    '100% Web Parity',
                    style: TextStyle(color: HermesTheme.primary, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: HermesTheme.textSecondary, fontSize: 12)),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: HermesTheme.textMuted, size: 16),
          ],
        ),
      ),
    );
  }
}
