import 'package:flutter/material.dart';
import '../../core/theme/hermes_theme.dart';
import '../../models/workspace_file.dart';
import '../chat/widgets/code_block_viewer.dart';

class FilesScreen extends StatefulWidget {
  final List<WorkspaceFile> files;
  final Function(WorkspaceFile) onAddFile;
  final Function(String) onDeleteFile;

  const FilesScreen({
    super.key,
    required this.files,
    required this.onAddFile,
    required this.onDeleteFile,
  });

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  IconData _getFileIcon(WorkspaceFile file) {
    if (file.isDirectory) return Icons.folder_rounded;
    final ext = file.extension?.toLowerCase() ?? '';
    if (ext == 'dart' || ext == 'js' || ext == 'ts' || ext == 'py') {
      return Icons.code_rounded;
    }
    if (ext == 'json' || ext == 'yaml' || ext == 'yml') {
      return Icons.data_object_rounded;
    }
    if (ext == 'md' || ext == 'txt') {
      return Icons.description_rounded;
    }
    if (ext == 'sh' || ext == 'ps1') {
      return Icons.terminal_rounded;
    }
    return Icons.insert_drive_file_rounded;
  }

  Color _getFileColor(WorkspaceFile file) {
    if (file.isDirectory) return HermesTheme.primary;
    final ext = file.extension?.toLowerCase() ?? '';
    if (ext == 'dart') return const Color(0xFF00B4AB);
    if (ext == 'py') return const Color(0xFFFFD43B);
    if (ext == 'js' || ext == 'ts') return const Color(0xFFF7DF1E);
    if (ext == 'json') return HermesTheme.warning;
    if (ext == 'sh' || ext == 'ps1') return HermesTheme.success;
    return HermesTheme.textMuted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workspace Files (/api/files)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.note_add_rounded, color: HermesTheme.primary),
            onPressed: () => _showCreateFileDialog(context),
          ),
        ],
      ),
      body: widget.files.isEmpty
          ? const Center(
              child: Text('Workspace directory is empty.', style: TextStyle(color: HermesTheme.textMuted)),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: widget.files.map((f) => _buildFileNode(f, 0)).toList(),
            ),
    );
  }

  Widget _buildFileNode(WorkspaceFile file, int depth) {
    final paddingLeft = depth * 16.0;

    if (file.isDirectory) {
      return Padding(
        padding: EdgeInsets.only(left: paddingLeft, bottom: 4),
        child: ExpansionTile(
          collapsedIconColor: HermesTheme.textMuted,
          iconColor: HermesTheme.primary,
          leading: Icon(Icons.folder_rounded, color: HermesTheme.primary, size: 20),
          title: Text(
            file.name,
            style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          children: file.children.map((child) => _buildFileNode(child, depth + 1)).toList(),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(left: paddingLeft, bottom: 4),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: HermesTheme.cardBorder, width: 0.5),
        ),
        tileColor: HermesTheme.cardColor,
        leading: Icon(_getFileIcon(file), color: _getFileColor(file), size: 18),
        title: Text(
          file.name,
          style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13, fontFamily: 'monospace'),
        ),
        subtitle: Text(
          '${(file.size / 1024).toStringAsFixed(1)} KB',
          style: const TextStyle(color: HermesTheme.textMuted, fontSize: 10),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded, size: 16, color: HermesTheme.textMuted),
          onPressed: () => widget.onDeleteFile(file.path),
        ),
        onTap: () => _openFileViewer(file),
      ),
    );
  }

  void _openFileViewer(WorkspaceFile file) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: HermesTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: HermesTheme.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(_getFileIcon(file), color: _getFileColor(file), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      file.path,
                      style: const TextStyle(
                        color: HermesTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: HermesTheme.textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(color: HermesTheme.cardBorder),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollCtrl,
                  child: CodeBlockViewer(
                    code: file.content ?? '// File is empty',
                    language: file.extension ?? 'txt',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateFileDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HermesTheme.surface,
        title: const Text('Create Workspace File', style: TextStyle(color: HermesTheme.textPrimary, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
              decoration: const InputDecoration(labelText: 'File Name (e.g. main.py)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: contentCtrl,
              maxLines: 4,
              style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13, fontFamily: 'monospace'),
              decoration: const InputDecoration(labelText: 'Initial Content'),
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
            child: const Text('Create', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                final name = nameCtrl.text.trim();
                final ext = name.contains('.') ? name.split('.').last : 'txt';
                final file = WorkspaceFile(
                  name: name,
                  path: '/$name',
                  isDirectory: false,
                  extension: ext,
                  size: contentCtrl.text.length,
                  content: contentCtrl.text,
                );
                widget.onAddFile(file);
                Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    );
  }
}
