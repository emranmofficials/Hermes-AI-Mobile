import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ToolExecutor {
  static String? _cachedWorkspaceDir;

  static Future<String> getWorkspaceDir() async {
    if (_cachedWorkspaceDir != null) return _cachedWorkspaceDir!;
    try {
      // Prefer app external storage or documents directory
      final dir = await getExternalStorageDirectory();
      if (dir != null) {
        _cachedWorkspaceDir = dir.path;
        return dir.path;
      }
      final docs = await getApplicationDocumentsDirectory();
      _cachedWorkspaceDir = docs.path;
      return docs.path;
    } catch (_) {
      return '/data/user/0/ai.antigem/files/home';
    }
  }

  /// Executes an autonomous tool call and returns the real result
  static Future<Map<String, dynamic>> executeTool({
    required String name,
    required Map<String, dynamic> arguments,
  }) async {
    final workspace = await getWorkspaceDir();

    switch (name.toLowerCase()) {
      case 'bash':
      case 'terminal':
      case 'sh':
      case 'shell':
      case 'execute_command':
        final cmd = arguments['command'] ?? arguments['cmd'] ?? '';
        return await _runBash(cmd.toString(), workspace);

      case 'write_file':
      case 'create_file':
      case 'edit_file':
        final path = arguments['path'] ?? arguments['filepath'] ?? arguments['file'] ?? '';
        final content = arguments['content'] ?? arguments['text'] ?? '';
        return await _writeFile(path.toString(), content.toString(), workspace);

      case 'read_file':
      case 'view_file':
        final path = arguments['path'] ?? arguments['filepath'] ?? arguments['file'] ?? '';
        return await _readFile(path.toString(), workspace);

      case 'list_files':
      case 'ls':
      case 'list_directory':
        final path = arguments['path'] ?? '.';
        return await _listFiles(path.toString(), workspace);

      case 'web_search':
      case 'search':
        final query = arguments['query'] ?? arguments['q'] ?? '';
        return await _webSearch(query.toString());

      default:
        return {
          'status': 'error',
          'output': 'Unknown tool: $name. Available tools: bash, write_file, read_file, list_files, web_search',
        };
    }
  }

  /// Runs real shell command via Process.run
  static Future<Map<String, dynamic>> _runBash(String command, String workspace) async {
    if (command.trim().isEmpty) {
      return {'status': 'error', 'output': 'Command cannot be empty'};
    }

    try {
      // Run in user workspace or fallback to sh
      final result = await Process.run(
        'sh',
        ['-c', command],
        workingDirectory: Directory(workspace).existsSync() ? workspace : null,
        environment: Platform.environment,
      );

      final stdout = result.stdout.toString();
      final stderr = result.stderr.toString();
      final exitCode = result.exitCode;

      String combined = '';
      if (stdout.trim().isNotEmpty) combined += stdout.trim();
      if (stderr.trim().isNotEmpty) {
        if (combined.isNotEmpty) combined += '\n\n';
        combined += 'Error / stderr:\n${stderr.trim()}';
      }
      if (combined.isEmpty) {
        combined = '(Command executed successfully with exit code $exitCode)';
      }

      return {
        'status': exitCode == 0 ? 'completed' : 'error',
        'output': combined,
        'exitCode': exitCode,
      };
    } catch (e) {
      return {
        'status': 'error',
        'output': 'Execution failure: $e',
      };
    }
  }

  /// Writes real file to filesystem
  static Future<Map<String, dynamic>> _writeFile(String path, String content, String workspace) async {
    if (path.trim().isEmpty) {
      return {'status': 'error', 'output': 'File path cannot be empty'};
    }

    try {
      String resolvedPath = path;
      if (!path.startsWith('/')) {
        resolvedPath = '$workspace/$path';
      }

      final file = File(resolvedPath);
      await file.parent.create(recursive: true);
      await file.writeAsString(content);

      return {
        'status': 'completed',
        'output': 'File saved successfully: $resolvedPath (${content.length} characters)',
      };
    } catch (e) {
      return {
        'status': 'error',
        'output': 'Failed to write file "$path": $e',
      };
    }
  }

  /// Reads real file from filesystem
  static Future<Map<String, dynamic>> _readFile(String path, String workspace) async {
    if (path.trim().isEmpty) {
      return {'status': 'error', 'output': 'File path cannot be empty'};
    }

    try {
      String resolvedPath = path;
      if (!path.startsWith('/')) {
        resolvedPath = '$workspace/$path';
      }

      final file = File(resolvedPath);
      if (!await file.exists()) {
        return {
          'status': 'error',
          'output': 'File does not exist: $resolvedPath',
        };
      }

      final content = await file.readAsString();
      return {
        'status': 'completed',
        'output': content,
      };
    } catch (e) {
      return {
        'status': 'error',
        'output': 'Failed to read file "$path": $e',
      };
    }
  }

  /// Lists files in directory
  static Future<Map<String, dynamic>> _listFiles(String path, String workspace) async {
    try {
      String targetPath = path == '.' ? workspace : (path.startsWith('/') ? path : '$workspace/$path');
      final dir = Directory(targetPath);
      if (!await dir.exists()) {
        return {'status': 'error', 'output': 'Directory does not exist: $targetPath'};
      }

      final entities = await dir.list().toList();
      final lines = entities.map((e) {
        final isDir = e is Directory;
        final name = e.path.split('/').last;
        return '${isDir ? "[DIR] " : "      "} $name';
      }).toList();

      return {
        'status': 'completed',
        'output': lines.isEmpty ? '(Empty directory)' : lines.join('\n'),
      };
    } catch (e) {
      return {
        'status': 'error',
        'output': 'Failed to list directory: $e',
      };
    }
  }

  /// Real live web search
  static Future<Map<String, dynamic>> _webSearch(String query) async {
    if (query.trim().isEmpty) {
      return {'status': 'error', 'output': 'Search query cannot be empty'};
    }

    try {
      // Use DuckDuckGo HTML API for fast real-time search results
      final url = Uri.parse('https://html.duckduckgo.com/html/?q=${Uri.encodeComponent(query)}');
      final res = await http.get(url, headers: {
        'User-Agent': 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36',
      }).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final body = res.body;
        final matches = RegExp(r'<a class="result__snippet[^>]*>(.*?)<\/a>', dotAll: true).allMatches(body);

        final snippets = <String>[];
        int count = 1;
        for (final m in matches) {
          if (count > 3) break;
          final raw = m.group(1) ?? '';
          final text = raw.replaceAll(RegExp(r'<[^>]*>'), '').trim();
          if (text.isNotEmpty) {
            snippets.add('[$count] $text');
            count++;
          }
        }

        if (snippets.isNotEmpty) {
          return {
            'status': 'completed',
            'output': 'Search Results for "$query":\n\n${snippets.join("\n\n")}',
          };
        }
      }

      return {
        'status': 'completed',
        'output': 'Web search executed for "$query". No direct textual snippets extracted.',
      };
    } catch (e) {
      return {
        'status': 'error',
        'output': 'Web search failed: $e',
      };
    }
  }
}
