import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/theme/hermes_theme.dart';
import '../../../../models/tool_call.dart';

class ToolCallCard extends StatefulWidget {
  final ToolCall toolCall;

  const ToolCallCard({super.key, required this.toolCall});

  @override
  State<ToolCallCard> createState() => _ToolCallCardState();
}

class _ToolCallCardState extends State<ToolCallCard> {
  bool _isExpanded = false;

  IconData _getToolIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('search') || lower.contains('web')) {
      return Icons.travel_explore_rounded;
    }
    if (lower.contains('bash') || lower.contains('cmd') || lower.contains('terminal')) {
      return Icons.terminal_rounded;
    }
    if (lower.contains('file') || lower.contains('read') || lower.contains('write')) {
      return Icons.folder_open_rounded;
    }
    if (lower.contains('memory') || lower.contains('learn')) {
      return Icons.psychology_rounded;
    }
    return Icons.build_circle_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final tool = widget.toolCall;
    Color statusColor;
    String statusText;
    Widget statusIndicator;

    switch (tool.status) {
      case ToolStatus.running:
        statusColor = HermesTheme.warning;
        statusText = 'Running...';
        statusIndicator = const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(HermesTheme.warning),
          ),
        );
        break;
      case ToolStatus.completed:
        statusColor = HermesTheme.success;
        statusText = 'Completed';
        statusIndicator = const Icon(Icons.check_circle_rounded, size: 14, color: HermesTheme.success);
        break;
      case ToolStatus.error:
        statusColor = HermesTheme.danger;
        statusText = 'Failed';
        statusIndicator = const Icon(Icons.error_outline_rounded, size: 14, color: HermesTheme.danger);
        break;
      default:
        statusColor = HermesTheme.textMuted;
        statusText = 'Pending';
        statusIndicator = const Icon(Icons.hourglass_empty_rounded, size: 14, color: HermesTheme.textMuted);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: HermesTheme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: HermesTheme.cardBorder),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(_getToolIcon(tool.name), size: 18, color: HermesTheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tool.name,
                      style: const TextStyle(
                        color: HermesTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        statusIndicator,
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: HermesTheme.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(color: HermesTheme.cardBorder, height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tool.arguments.isNotEmpty) ...[
                    const Text(
                      'ARGUMENTS:',
                      style: TextStyle(
                        color: HermesTheme.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: HermesTheme.background,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        const JsonEncoder.withIndent('  ').convert(tool.arguments),
                        style: const TextStyle(
                          color: HermesTheme.textSecondary,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                  if (tool.output != null && tool.output!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'OUTPUT:',
                      style: TextStyle(
                        color: HermesTheme.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: HermesTheme.background,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tool.output!,
                        style: const TextStyle(
                          color: HermesTheme.textPrimary,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
