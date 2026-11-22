import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/storage/local_storage.dart';
import '../../core/theme/hermes_theme.dart';
import '../../models/app_settings.dart';
import '../../models/message.dart';
import '../../models/session.dart';
import '../../models/tool_call.dart';
import '../../models/system_log.dart';
import '../../services/hermes_service.dart';
import '../sessions/sessions_drawer.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final AppSettings settings;
  final VoidCallback onOpenSettings;
  final Function(String)? onOpenModule;

  const ChatScreen({
    super.key,
    required this.settings,
    required this.onOpenSettings,
    this.onOpenModule,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final HermesService _hermesService = HermesService();
  final Uuid _uuid = const Uuid();

  List<Session> _sessions = [];
  Session? _activeSession;
  List<Message> _messages = [];
  bool _isStreaming = false;
  StreamSubscription? _streamSub;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final loadedSessions = await LocalStorage.loadSessions();
    setState(() {
      _sessions = loadedSessions;
      if (_sessions.isNotEmpty) {
        _activeSession = _sessions.first;
      }
    });

    if (_activeSession != null) {
      await _loadMessagesForSession(_activeSession!.id);
    } else {
      _createNewSession();
    }
  }

  Future<void> _loadMessagesForSession(String sessionId) async {
    final msgs = await LocalStorage.loadMessages(sessionId);
    setState(() {
      _messages = msgs;
    });
    _scrollToBottom();
  }

  void _createNewSession() {
    final newSession = Session(
      id: _uuid.v4(),
      title: 'New Chat',
      modelId: widget.settings.selectedModel,
    );
    setState(() {
      _sessions.insert(0, newSession);
      _activeSession = newSession;
      _messages = [
        Message(
          id: _uuid.v4(),
          sessionId: newSession.id,
          role: MessageRole.assistant,
          content: 'Hello! I am **Hermes Agent** by Nous Research.\n\nI can assist you with coding, autonomous problem solving, web research, and reasoning. How can I help you today?',
        ),
      ];
    });
    LocalStorage.saveSessions(_sessions);
    LocalStorage.saveMessages(newSession.id, _messages);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage(String prompt) async {
    if (_activeSession == null) _createNewSession();

    final userMessage = Message(
      id: _uuid.v4(),
      sessionId: _activeSession!.id,
      role: MessageRole.user,
      content: prompt,
    );

    final assistantMessage = Message(
      id: _uuid.v4(),
      sessionId: _activeSession!.id,
      role: MessageRole.assistant,
      content: '',
      isStreaming: true,
    );

    setState(() {
      _messages.add(userMessage);
      _messages.add(assistantMessage);
      _isStreaming = true;

      // Update session title if first user prompt
      if (_messages.where((m) => m.role == MessageRole.user).length == 1) {
        _activeSession!.title = prompt.length > 28 ? '${prompt.substring(0, 28)}...' : prompt;
      }
      _activeSession!.updatedAt = DateTime.now();
      _activeSession!.previewText = prompt;
    });

    _scrollToBottom();
    LocalStorage.saveSessions(_sessions);
    LocalStorage.saveMessages(_activeSession!.id, _messages);

    LocalStorage.addLog(SystemLog(
      timestamp: DateTime.now(),
      level: 'INFO',
      tag: 'CHAT',
      message: 'User prompt: ${prompt.length > 35 ? "${prompt.substring(0, 35)}..." : prompt}',
    ));

    // Load active memories and skills for context
    final memories = await LocalStorage.loadMemories();
    final skills = await LocalStorage.loadSkills();

    _streamSub = _hermesService
        .sendMessage(
      history: _messages.sublist(0, _messages.length - 1),
      prompt: prompt,
      settings: widget.settings,
      activeMemories: memories,
      activeSkills: skills.where((s) => s.isEnabled).toList(),
    )
        .listen(
      (event) {
        if (!mounted) return;
        setState(() {
          final type = event['type'];
          if (type == 'token') {
            assistantMessage.content += event['content'];
          } else if (type == 'tool_start') {
            final ToolCall tool = event['tool'];
            assistantMessage.toolCalls.add(tool);
          } else if (type == 'tool_output') {
            final String id = event['id'];
            final idx = assistantMessage.toolCalls.indexWhere((t) => t.id == id);
            if (idx != -1) {
              assistantMessage.toolCalls[idx].output = event['output'];
              assistantMessage.toolCalls[idx].status = event['status'];
            }
          } else if (type == 'error') {
            assistantMessage.content += '\n\n⚠️ **Error:** ${event['content']}';
          }
        });
        _scrollToBottom();
      },
      onDone: () {
        if (!mounted) return;
        setState(() {
          assistantMessage.isStreaming = false;
          _isStreaming = false;
        });
        LocalStorage.saveMessages(_activeSession!.id, _messages);
      },
      onError: (err) {
        if (!mounted) return;
        setState(() {
          assistantMessage.content += '\n\n⚠️ **Stream error:** $err';
          assistantMessage.isStreaming = false;
          _isStreaming = false;
        });
        LocalStorage.saveMessages(_activeSession!.id, _messages);
      },
    );
  }

  void _cancelStream() {
    _streamSub?.cancel();
    setState(() {
      _isStreaming = false;
      if (_messages.isNotEmpty && _messages.last.isStreaming) {
        _messages.last.isStreaming = false;
      }
    });
    if (_activeSession != null) {
      LocalStorage.saveMessages(_activeSession!.id, _messages);
    }
  }

  void _openModelSwitcher(BuildContext context) {
    final models = [
      {'id': 'gemini-2.0-flash', 'desc': 'Fastest & Most Reliable (High Free Tier Availability)'},
      {'id': 'gemini-1.5-flash', 'desc': 'Rock-Solid Stable Fallback'},
      {'id': 'gemini-3.8-flash', 'desc': 'Latest Google Reasoning Model'},
      {'id': 'gemini-3.1-pro-preview', 'desc': 'Pro Reasoning Model (Paid Tier)'},
      {'id': 'nousresearch/hermes-3-llama-3.1-405b', 'desc': 'Nous Research OpenRouter Model'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: HermesTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.psychology_rounded, color: HermesTheme.primary, size: 22),
                SizedBox(width: 8),
                Text('Quick Model Switcher', style: TextStyle(color: HermesTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Switch active AI engine instantly. If Google returns HTTP 503 high demand, switch to gemini-2.0-flash.', style: TextStyle(color: HermesTheme.textMuted, fontSize: 11)),
            const SizedBox(height: 14),
            ...models.map((m) {
              final isSelected = widget.settings.selectedModel.contains(m['id']!);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected ? HermesTheme.cardColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isSelected ? HermesTheme.primary : HermesTheme.cardBorder),
                ),
                child: ListTile(
                  dense: true,
                  title: Text(m['id']!, style: TextStyle(color: isSelected ? HermesTheme.primary : HermesTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text(m['desc']!, style: const TextStyle(color: HermesTheme.textMuted, fontSize: 10)),
                  trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: HermesTheme.primary, size: 18) : null,
                  onTap: () {
                    setState(() {
                      widget.settings.selectedModel = m['id']!;
                    });
                    LocalStorage.saveSettings(widget.settings);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: HermesTheme.success,
                        content: Text('✓ Switched active model to ${m['id']}'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final modelName = widget.settings.selectedModel.split('/').last;

    return Scaffold(
      key: _scaffoldKey,
      drawer: SessionsDrawer(
        sessions: _sessions,
        activeSessionId: _activeSession?.id,
        onSelectSession: (session) {
          setState(() => _activeSession = session);
          _loadMessagesForSession(session.id);
        },
        onNewSession: _createNewSession,
        onDeleteSession: (sessionId) {
          setState(() {
            _sessions.removeWhere((s) => s.id == sessionId);
            if (_activeSession?.id == sessionId) {
              if (_sessions.isNotEmpty) {
                _activeSession = _sessions.first;
                _loadMessagesForSession(_activeSession!.id);
              } else {
                _createNewSession();
              }
            }
          });
          LocalStorage.saveSessions(_sessions);
        },
        onOpenModule: widget.onOpenModule,
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: HermesTheme.textPrimary),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _activeSession?.title ?? 'Hermes Agent',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            InkWell(
              onTap: () => _openModelSwitcher(context),
              borderRadius: BorderRadius.circular(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: HermesTheme.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    modelName,
                    style: const TextStyle(
                      color: HermesTheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 14, color: HermesTheme.primary),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: HermesTheme.primary),
            onPressed: _createNewSession,
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: HermesTheme.textSecondary),
            onPressed: widget.onOpenSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text('Start a conversation', style: TextStyle(color: HermesTheme.textMuted)),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return MessageBubble(
                        message: message,
                        onRetry: message.role == MessageRole.assistant
                            ? () {
                                if (index > 0 && _messages[index - 1].role == MessageRole.user) {
                                  _handleSendMessage(_messages[index - 1].content);
                                }
                              }
                            : null,
                      );
                    },
                  ),
          ),
          ChatInputBar(
            onSendMessage: _handleSendMessage,
            isStreaming: _isStreaming,
            onCancelStream: _cancelStream,
          ),
        ],
      ),
    );
  }
}
