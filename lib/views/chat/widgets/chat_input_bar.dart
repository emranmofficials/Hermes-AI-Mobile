import 'package:flutter/material.dart';
import '../../../../core/theme/hermes_theme.dart';

class ChatInputBar extends StatefulWidget {
  final Function(String) onSendMessage;
  final bool isStreaming;
  final VoidCallback? onCancelStream;

  const ChatInputBar({
    super.key,
    required this.onSendMessage,
    this.isStreaming = false,
    this.onCancelStream,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isStreaming) return;
    widget.onSendMessage(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 12 : 16,
      ),
      decoration: const BoxDecoration(
        color: HermesTheme.surface,
        border: Border(
          top: BorderSide(color: HermesTheme.cardBorder, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quick action suggestion chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  _chip('🌐 Search Web', () {
                    _controller.text = 'Search web for: ';
                    _controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: _controller.text.length));
                  }),
                  _chip('💻 Terminal', () {
                    _controller.text = 'Run command: ';
                    _controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: _controller.text.length));
                  }),
                  _chip('🧠 Learn Skill', () {
                    _controller.text = 'Learn a new skill for: ';
                    _controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: _controller.text.length));
                  }),
                  _chip('📝 Code Help', () {
                    _controller.text = 'Write a clean Flutter implementation for: ';
                    _controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: _controller.text.length));
                  }),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: HermesTheme.cardColor,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: HermesTheme.cardBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.flash_on_rounded, size: 20, color: HermesTheme.primary),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Autonomous Mode Active: Skills & Tools Enabled'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            maxLines: 5,
                            minLines: 1,
                            style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'Ask Hermes or instruct an agent action...',
                              hintStyle: TextStyle(color: HermesTheme.textMuted, fontSize: 13),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            onSubmitted: (_) => _submit(),
                          ),
                        ),
                        if (_hasText)
                          IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: HermesTheme.textMuted),
                            onPressed: () => _controller.clear(),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Send or Stop button
                widget.isStreaming
                    ? InkWell(
                        onTap: widget.onCancelStream,
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: HermesTheme.danger.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: HermesTheme.danger),
                          ),
                          child: const Icon(Icons.stop_rounded, color: HermesTheme.danger, size: 22),
                        ),
                      )
                    : InkWell(
                        onTap: _hasText ? _submit : null,
                        borderRadius: BorderRadius.circular(22),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: _hasText
                                ? const LinearGradient(
                                    colors: [HermesTheme.primary, HermesTheme.accent],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: _hasText ? null : HermesTheme.cardColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _hasText ? Colors.transparent : HermesTheme.cardBorder,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_upward_rounded,
                            color: _hasText ? Colors.white : HermesTheme.textMuted,
                            size: 20,
                          ),
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: HermesTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HermesTheme.cardBorder),
          ),
          child: Text(
            label,
            style: const TextStyle(color: HermesTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
