import 'package:flutter/material.dart';
import '../../core/theme/hermes_theme.dart';
import '../../models/session.dart';

class SessionsDrawer extends StatelessWidget {
  final List<Session> sessions;
  final String? activeSessionId;
  final Function(Session) onSelectSession;
  final VoidCallback onNewSession;
  final Function(String) onDeleteSession;

  const SessionsDrawer({
    super.key,
    required this.sessions,
    this.activeSessionId,
    required this.onSelectSession,
    required this.onNewSession,
    required this.onDeleteSession,
  });

  @override
  Widget build(BuildContext context) {
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
                    width: 36,
                    height: 36,
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
                        'Nous Research Mobile',
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
                  onNewSession();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Sessions List
            Expanded(
              child: sessions.isEmpty
                  ? const Center(
                      child: Text(
                        'No previous sessions',
                        style: TextStyle(color: HermesTheme.textMuted, fontSize: 13),
                      ),
                    )
                  : ListView.builder(
                      itemCount: sessions.length,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        final isActive = session.id == activeSessionId;

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
                                fontSize: 13,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 16, color: HermesTheme.textMuted),
                              onPressed: () => onDeleteSession(session.id),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              onSelectSession(session);
                            },
                          ),
                        );
                      },
                    ),
            ),
            const Divider(color: HermesTheme.cardBorder, height: 1),
            // Bottom Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    'Hermes Client v1.0.0',
                    style: TextStyle(color: HermesTheme.textMuted, fontSize: 11),
                  ),
                  const Spacer(),
                  const Text(
                    'Offline / Mobile',
                    style: TextStyle(color: HermesTheme.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
