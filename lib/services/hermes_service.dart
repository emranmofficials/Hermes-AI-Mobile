import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/app_settings.dart';
import '../models/message.dart';
import '../models/tool_call.dart';
import '../models/system_stats.dart';
import 'tool_executor.dart';

class HermesService {
  WebSocketChannel? _channel;
  int _requestId = 0;

  /// Fetch real-time system stats from Hermes backend or generate live local metrics
  Future<SystemStats> fetchSystemStats(AppSettings settings) async {
    if (settings.connectionMode == ConnectionMode.hermesGateway) {
      try {
        final host = Uri.parse(settings.gatewayUrl).host;
        final port = Uri.parse(settings.gatewayUrl).port;
        final res = await http.get(Uri.parse('http://$host:$port/api/system/stats'));
        if (res.statusCode == 200) {
          return SystemStats.fromJson(jsonDecode(res.body));
        }
      } catch (_) {}
    }
    return SystemStats();
  }

  /// Streams response from Hermes Agent backend (JSON-RPC 2.0) or Cloud Provider with real autonomous tools
  Stream<dynamic> sendMessage({
    required List<Message> history,
    required String prompt,
    required AppSettings settings,
    List<dynamic>? activeSkills,
    List<dynamic>? activeMemories,
  }) async* {
    if (settings.connectionMode == ConnectionMode.hermesGateway) {
      // 1. Official Gateway Mode (JSON-RPC 2.0 over WebSocket)
      yield* _streamFromJsonRpcGateway(history, prompt, settings);
    } else {
      // 2. Direct Cloud LLM Mode with Real On-Device Tool Execution Engine
      if (settings.apiKey.trim().isEmpty) {
        yield {
          'type': 'token',
          'content': '⚠️ **API Key পাওয়া যায়নি!**\n\n'
              'Hermes Agent দিয়ে আসল এআই রেসপন্স ও টার্মিনাল/ফাইল প্রসেসিং করতে অনুগ্রহ করে একটি কার্যকর API Key প্রদান করুন:\n\n'
              '1. **Google Gemini (ফ্রি ও দ্রুততম):**\n'
              '   - [Google AI Studio](https://aistudio.google.com/app/apikey) থেকে ফ্রি এপিআই কি নিন।\n'
              '   - অ্যাপের **Suite > Environment Secrets** অথবা **Config** ট্যাবে গিয়ে **GEMINI_API_KEY** ঘরে পেস্ট করুন।\n\n'
              '2. **OpenRouter / Nous Portal:**\n'
              '   - OpenRouter Key দিয়ে Hermes 3 Llama-405B বা অন্যান্য মডেল ব্যবহার করতে পারেন।\n\n'
              '3. **Hermes Gateway (Local Termux):**\n'
              '   - টার্মাক্সে লোকাল গেটওয়ে চালু থাকলে Config থেকে **Hermes Gateway** মোড নির্বাচন করুন।',
        };
        return;
      }

      if (settings.cloudProvider == CloudProvider.gemini) {
        yield* _streamFromGeminiNativeWithTools(history, prompt, settings, activeMemories);
      } else {
        yield* _streamFromOpenAICompatibleWithTools(history, prompt, settings, activeMemories);
      }
    }
  }

  Stream<dynamic> _streamFromJsonRpcGateway(
    List<Message> history,
    String prompt,
    AppSettings settings,
  ) async* {
    try {
      final uri = Uri.parse(settings.gatewayUrl);
      _channel = WebSocketChannel.connect(uri);
      final currentReqId = ++_requestId;

      // Official JSON-RPC 2.0 request payload
      final jsonRpcRequest = {
        'jsonrpc': '2.0',
        'id': currentReqId,
        'method': 'chat.stream',
        'params': {
          'prompt': prompt,
          'token': settings.gatewayToken,
          'model': settings.selectedModel,
          'temperature': settings.temperature,
          'history': history.map((m) => {'role': m.role.name, 'content': m.content}).toList(),
        },
      };

      _channel!.sink.add(jsonEncode(jsonRpcRequest));

      await for (final rawMsg in _channel!.stream) {
        final parsed = jsonDecode(rawMsg);

        // Handle JSON-RPC error
        if (parsed['error'] != null) {
          yield {'type': 'error', 'content': parsed['error']['message'] ?? 'JSON-RPC Error'};
          break;
        }

        final result = parsed['result'] ?? parsed;
        final event = result['event']; // 'token', 'tool_start', 'tool_output', 'done'

        if (event == 'token') {
          yield {'type': 'token', 'content': result['data']};
        } else if (event == 'tool_start') {
          yield {
            'type': 'tool_start',
            'tool': ToolCall(
              id: result['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
              name: result['name'] ?? 'tool',
              arguments: Map<String, dynamic>.from(result['arguments'] ?? {}),
              status: ToolStatus.running,
            ),
          };
        } else if (event == 'tool_output') {
          yield {
            'type': 'tool_output',
            'id': result['id'],
            'output': result['output'],
            'status': result['status'] == 'error' ? ToolStatus.error : ToolStatus.completed,
          };
        } else if (event == 'done' || parsed['id'] == currentReqId && result['status'] == 'completed') {
          break;
        }
      }
    } catch (e) {
      yield {'type': 'error', 'content': 'Hermes Gateway error: $e\n\nEnsure Termux gateway is active on ${settings.gatewayUrl}.'};
    } finally {
      _channel?.sink.close();
    }
  }

  String _buildSystemPrompt(AppSettings settings, List<dynamic>? activeMemories) {
    String memoryContext = '';
    if (activeMemories != null && activeMemories.isNotEmpty) {
      memoryContext = '\n\n[Active Persistent Memories]:\n' +
          activeMemories.map((m) => '- ${m.key}: ${m.content}').join('\n');
    }

    return '''${settings.systemPrompt}$memoryContext

# REAL AUTONOMOUS ON-DEVICE TOOLS (TERMUX / ANDROID)
You have direct access to REAL execution tools on the user's Android phone:
1. `bash`: Run real shell commands (e.g. ls, mkdir, cd, python, git, curl, ps).
   Argument: `{"command": "command_to_run"}`
2. `write_file`: Create or edit real files on the filesystem.
   Argument: `{"path": "file_path", "content": "contents"}`
3. `read_file`: Read real file content from disk.
   Argument: `{"path": "file_path"}`
4. `list_files`: List real directory contents.
   Argument: `{"path": "directory_path"}`
5. `web_search`: Search the live web.
   Argument: `{"query": "search query"}`

To execute a tool, you MUST output this XML tag format:
<tool_call>
{"name": "tool_name", "arguments": {"arg": "val"}}
</tool_call>

Whenever the user asks you to perform a task (e.g. check files, run commands, create scripts, research), call the appropriate tool, inspect the real result, and explain your answer in natural Bengali (বাংলা).''';
  }

  /// Official Google Gemini Native REST Streaming with On-Device Tool Execution Loop
  Stream<dynamic> _streamFromGeminiNativeWithTools(
    List<Message> history,
    String prompt,
    AppSettings settings,
    List<dynamic>? activeMemories,
  ) async* {
    final client = http.Client();
    try {
      var modelName = settings.selectedModel.trim();
      if (modelName.startsWith('models/')) {
        modelName = modelName.replaceFirst('models/', '');
      }
      // Migrate legacy/deprecated models (1.5, 2.0, 2.5, 3.1-pro) to current active models
      if (modelName.isEmpty ||
          modelName.contains('hermes') ||
          modelName.contains('llama') ||
          modelName.contains('1.5') ||
          modelName.contains('2.0') ||
          modelName.contains('2.5') ||
          modelName.contains('3.1-pro')) {
        modelName = 'gemini-3.8-flash';
      }

      final endpoint = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$modelName:streamGenerateContent?alt=sse&key=${settings.apiKey}',
      );

      final systemPrompt = _buildSystemPrompt(settings, activeMemories);

      final contents = [
        ...history.map((m) => {
              'role': m.role == MessageRole.user ? 'user' : 'model',
              'parts': [
                {'text': m.content}
              ],
            }),
        {
          'role': 'user',
          'parts': [
            {'text': prompt}
          ],
        }
      ];

      final requestBody = {
        'systemInstruction': {
          'parts': [
            {'text': systemPrompt}
          ]
        },
        'contents': contents,
        'generationConfig': {
          'temperature': settings.temperature,
        },
      };

      final request = http.Request('POST', endpoint);
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(requestBody);

      var response = await client.send(request);

      if (response.statusCode != 200) {
        final body = await response.stream.bytesToString();
        // If 503 (high demand) or 404: Auto-fallback to gemini-3.5-flash-lite or gemini-3.1-flash-lite
        if (response.statusCode == 503 || response.statusCode == 404) {
          yield {
            'type': 'token',
            'content': '⚡ *[Google Gemini ($modelName) সাময়িক ব্যস্ত (HTTP 503)। অটোমেটিক হাই-ক্যাপাসিটি মডেল gemini-3.5-flash-lite এ সুইচ করা হচ্ছে...]*\n\n'
          };

          final fallbackEndpoint = Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash-lite:streamGenerateContent?alt=sse&key=${settings.apiKey}',
          );
          final fallbackReq = http.Request('POST', fallbackEndpoint);
          fallbackReq.headers['Content-Type'] = 'application/json';
          fallbackReq.body = jsonEncode(requestBody);
          response = await client.send(fallbackReq);

          if (response.statusCode != 200) {
            // Second fallback to gemini-3.1-flash-lite
            final secondFallbackEndpoint = Uri.parse(
              'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:streamGenerateContent?alt=sse&key=${settings.apiKey}',
            );
            final secondReq = http.Request('POST', secondFallbackEndpoint);
            secondReq.headers['Content-Type'] = 'application/json';
            secondReq.body = jsonEncode(requestBody);
            response = await client.send(secondReq);

            if (response.statusCode != 200) {
              final secondBody = await response.stream.bytesToString();
              yield {'type': 'error', 'content': 'Gemini Fallback Error (${response.statusCode}): $secondBody'};
              return;
            }
          }
        } else {
          yield {'type': 'error', 'content': 'Gemini API Error (${response.statusCode}): $body'};
          return;
        }
      }

      final stream = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      StringBuffer fullResponse = StringBuffer();

      await for (final line in stream) {
        if (line.startsWith('data: ')) {
          final data = line.substring(6).trim();
          if (data.isEmpty) continue;
          try {
            final parsed = jsonDecode(data);
            final candidates = parsed['candidates'] as List<dynamic>?;
            if (candidates != null && candidates.isNotEmpty) {
              final parts = candidates[0]['content']?['parts'] as List<dynamic>?;
              if (parts != null) {
                for (final part in parts) {
                  final text = part['text'];
                  if (text != null) {
                    fullResponse.write(text);
                    yield {'type': 'token', 'content': text};
                  }
                }
              }
            }
          } catch (_) {}
        }
      }

      // Check if model called an autonomous tool
      final rawText = fullResponse.toString();
      final toolCallMatch = RegExp(r'<tool_call>(.*?)</tool_call>', dotAll: true).firstMatch(rawText);

      if (toolCallMatch != null) {
        final jsonStr = toolCallMatch.group(1)?.trim() ?? '{}';
        try {
          final toolJson = jsonDecode(jsonStr);
          final toolName = toolJson['name']?.toString() ?? 'tool';
          final toolArgs = Map<String, dynamic>.from(toolJson['arguments'] ?? {});
          final toolId = 'tc_${DateTime.now().millisecondsSinceEpoch}';

          final tool = ToolCall(
            id: toolId,
            name: toolName,
            arguments: toolArgs,
            status: ToolStatus.running,
          );
          yield {'type': 'tool_start', 'tool': tool};

          // REAL ON-DEVICE EXECUTION!
          final toolResult = await ToolExecutor.executeTool(
            name: toolName,
            arguments: toolArgs,
          );

          yield {
            'type': 'tool_output',
            'id': toolId,
            'output': toolResult['output'] ?? '',
            'status': toolResult['status'] == 'completed' ? ToolStatus.completed : ToolStatus.error,
          };

          // Second turn: Feed real tool output back to Gemini
          yield {'type': 'token', 'content': '\n\n'};
          final followUpContents = [
            ...contents,
            {
              'role': 'model',
              'parts': [
                {'text': rawText}
              ]
            },
            {
              'role': 'user',
              'parts': [
                {
                  'text': '<tool_response>\n${toolResult['output']}\n</tool_response>\n'
                      'Explain the result to the user in Bengali (বাংলা).'
                }
              ]
            }
          ];

          final followUpReq = http.Request('POST', endpoint);
          followUpReq.headers['Content-Type'] = 'application/json';
          followUpReq.body = jsonEncode({
            'systemInstruction': {
              'parts': [
                {'text': systemPrompt}
              ]
            },
            'contents': followUpContents,
            'generationConfig': {'temperature': settings.temperature},
          });

          final followUpResp = await client.send(followUpReq);
          if (followUpResp.statusCode == 200) {
            final followUpStream = followUpResp.stream
                .transform(utf8.decoder)
                .transform(const LineSplitter());

            await for (final line in followUpStream) {
              if (line.startsWith('data: ')) {
                final d = line.substring(6).trim();
                if (d.isEmpty) continue;
                try {
                  final p = jsonDecode(d);
                  final cands = p['candidates'] as List<dynamic>?;
                  if (cands != null && cands.isNotEmpty) {
                    final prts = cands[0]['content']?['parts'] as List<dynamic>?;
                    if (prts != null) {
                      for (final pt in prts) {
                        final t = pt['text'];
                        if (t != null) yield {'type': 'token', 'content': t};
                      }
                    }
                  }
                } catch (_) {}
              }
            }
          }
        } catch (e) {
          yield {'type': 'token', 'content': '\n⚠️ Tool parsing error: $e'};
        }
      }
    } catch (e) {
      yield {'type': 'error', 'content': 'Gemini Connection error: $e'};
    } finally {
      client.close();
    }
  }

  /// OpenAI / OpenRouter streaming with On-Device Tool Execution Loop
  Stream<dynamic> _streamFromOpenAICompatibleWithTools(
    List<Message> history,
    String prompt,
    AppSettings settings,
    List<dynamic>? activeMemories,
  ) async* {
    final client = http.Client();
    try {
      String url = settings.baseUrl.trim();
      if (url.isEmpty) url = 'https://openrouter.ai/api/v1';
      if (url.endsWith('/')) url = url.substring(0, url.length - 1);
      final endpoint = url.endsWith('/chat/completions')
          ? Uri.parse(url)
          : Uri.parse('$url/chat/completions');

      final systemPrompt = _buildSystemPrompt(settings, activeMemories);

      final messagesList = [
        {'role': 'system', 'content': systemPrompt},
        ...history.map((m) => {'role': m.role.name, 'content': m.content}),
        {'role': 'user', 'content': prompt},
      ];

      final requestBody = {
        'model': settings.selectedModel,
        'messages': messagesList,
        'temperature': settings.temperature,
        'stream': true,
      };

      final request = http.Request('POST', endpoint);
      request.headers['Content-Type'] = 'application/json';
      request.headers['Authorization'] = 'Bearer ${settings.apiKey}';
      request.headers['HTTP-Referer'] = 'https://hermes.nousresearch.com';
      request.headers['X-Title'] = 'Hermes AI Mobile';
      request.body = jsonEncode(requestBody);

      final response = await client.send(request);

      if (response.statusCode != 200) {
        final body = await response.stream.bytesToString();
        yield {'type': 'error', 'content': 'API Error (${response.statusCode}): $body'};
        return;
      }

      final stream = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      StringBuffer fullResponse = StringBuffer();

      await for (final line in stream) {
        if (line.startsWith('data: ')) {
          final data = line.substring(6).trim();
          if (data == '[DONE]') break;
          try {
            final parsed = jsonDecode(data);
            final delta = parsed['choices']?[0]?['delta'];
            if (delta != null && delta['content'] != null) {
              final text = delta['content'];
              fullResponse.write(text);
              yield {'type': 'token', 'content': text};
            }
          } catch (_) {}
        }
      }

      // Check if tool was invoked
      final rawText = fullResponse.toString();
      final toolCallMatch = RegExp(r'<tool_call>(.*?)</tool_call>', dotAll: true).firstMatch(rawText);

      if (toolCallMatch != null) {
        final jsonStr = toolCallMatch.group(1)?.trim() ?? '{}';
        try {
          final toolJson = jsonDecode(jsonStr);
          final toolName = toolJson['name']?.toString() ?? 'tool';
          final toolArgs = Map<String, dynamic>.from(toolJson['arguments'] ?? {});
          final toolId = 'tc_${DateTime.now().millisecondsSinceEpoch}';

          yield {
            'type': 'tool_start',
            'tool': ToolCall(
              id: toolId,
              name: toolName,
              arguments: toolArgs,
              status: ToolStatus.running,
            )
          };

          // REAL EXECUTION!
          final toolResult = await ToolExecutor.executeTool(
            name: toolName,
            arguments: toolArgs,
          );

          yield {
            'type': 'tool_output',
            'id': toolId,
            'output': toolResult['output'] ?? '',
            'status': toolResult['status'] == 'completed' ? ToolStatus.completed : ToolStatus.error,
          };
        } catch (e) {
          yield {'type': 'token', 'content': '\n⚠️ Tool execution error: $e'};
        }
      }
    } catch (e) {
      yield {'type': 'error', 'content': 'Connection failed: $e'};
    } finally {
      client.close();
    }
  }
}
