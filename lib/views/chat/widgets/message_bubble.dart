import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../core/theme/hermes_theme.dart';
import '../../../../models/message.dart';
import 'tool_call_card.dart';
import 'code_block_viewer.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final VoidCallback? onRetry;

  const MessageBubble({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 10, top: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: HermesTheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/icons/hermes_icon_64x64.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.auto_awesome, size: 18, color: Colors.white),
                ),
              ),
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Render any Tool Calls first
                if (message.toolCalls.isNotEmpty) ...[
                  ...message.toolCalls.map((t) => ToolCallCard(toolCall: t)),
                  const SizedBox(height: 6),
                ],
                // Message bubble container
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? HermesTheme.cardColor : HermesTheme.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: Border.all(
                      color: isUser ? HermesTheme.primary.withOpacity(0.4) : HermesTheme.cardBorder,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MarkdownBody(
                        data: message.content.isEmpty && message.isStreaming
                            ? '...'
                            : message.content,
                        selectable: true,
                        builders: {
                          'code': CodeElementBuilder(),
                        },
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(
                            color: HermesTheme.textPrimary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                          h1: const TextStyle(color: HermesTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                          h2: const TextStyle(color: HermesTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                          h3: const TextStyle(color: HermesTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                          code: const TextStyle(
                            backgroundColor: Color(0xFF1E2235),
                            color: HermesTheme.primary,
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                          codeblockDecoration: BoxDecoration(
                            color: const Color(0xFF0F121C),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: HermesTheme.cardBorder),
                          ),
                          tableBorder: TableBorder.all(color: HermesTheme.cardBorder),
                          tableHead: const TextStyle(fontWeight: FontWeight.bold, color: HermesTheme.textPrimary),
                          tableBody: const TextStyle(color: HermesTheme.textSecondary),
                        ),
                      ),
                      if (message.isStreaming) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: HermesTheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Generating...',
                              style: TextStyle(color: HermesTheme.primary, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Action toolbar below message
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: message.content));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Message copied!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: const Icon(Icons.copy_rounded, size: 14, color: HermesTheme.textMuted),
                      ),
                      if (!isUser && onRetry != null) ...[
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: onRetry,
                          child: const Icon(Icons.refresh_rounded, size: 14, color: HermesTheme.textMuted),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 10, top: 4),
              decoration: BoxDecoration(
                color: HermesTheme.cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: HermesTheme.cardBorder),
              ),
              child: const Icon(Icons.person_rounded, size: 18, color: HermesTheme.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(dynamic element, TextStyle? preferredStyle) {
    final text = element.textContent ?? '';
    if (text.contains('\n')) {
      String language = '';
      if (element.attributes != null && element.attributes['class'] != null) {
        language = (element.attributes['class'] as String).replaceFirst('language-', '');
      }
      return CodeBlockViewer(
        code: text,
        language: language,
      );
    }
    return null;
  }
}
