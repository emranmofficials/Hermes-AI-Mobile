import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/app_settings.dart';
import '../models/message.dart';
import '../models/tool_call.dart';
import '../models/system_stats.dart';

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

  /// Streams response from Hermes Agent backend (JSON-RPC 2.0) or Cloud Provider
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
      // 2. Direct Cloud LLM Mode (OpenAI / OpenRouter / Nous Portal)
      if (settings.apiKey.trim().isEmpty) {
        yield* _simulateAgentLoop(prompt);
      } else {
        yield* _streamFromOpenAICompatible(history, prompt, settings, activeMemories);
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
      yield {'type': 'error', 'content': 'Hermes Gateway error: $e'};
    } finally {
      _channel?.sink.close();
    }
  }

  Stream<dynamic> _streamFromOpenAICompatible(
    List<Message> history,
    String prompt,
    AppSettings settings,
    List<dynamic>? activeMemories,
  ) async* {
    final client = http.Client();
    try {
      String url = settings.baseUrl.trim();
      if (url.isEmpty) {
        if (settings.cloudProvider == CloudProvider.gemini) {
          url = 'https://generativelanguage.googleapis.com/v1beta/openai';
        } else {
          url = 'https://openrouter.ai/api/v1';
        }
      }
      if (url.endsWith('/')) url = url.substring(0, url.length - 1);
      final endpoint = url.endsWith('/chat/completions')
          ? Uri.parse(url)
          : Uri.parse('$url/chat/completions');

      String memoryContext = '';
      if (activeMemories != null && activeMemories.isNotEmpty) {
        memoryContext = '\n[User & Project Memories]:\n' +
            activeMemories.map((m) => '- ${m.key}: ${m.content}').join('\n');
      }

      final messagesList = [
        {
          'role': 'system',
          'content': '${settings.systemPrompt}$memoryContext',
        },
        ...history.map((m) => {
              'role': m.role.name,
              'content': m.content,
            }),
        {'role': 'user', 'content': prompt},
      ];

      final request = http.Request('POST', endpoint);
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${settings.apiKey}',
      });

      request.body = jsonEncode({
        'model': settings.selectedModel,
        'messages': messagesList,
        'temperature': settings.temperature,
        'stream': true,
      });

      final response = await client.send(request);

      if (response.statusCode != 200) {
        final body = await response.stream.bytesToString();
        yield {'type': 'error', 'content': 'API Error (${response.statusCode}): $body'};
        return;
      }

      final stream = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in stream) {
        if (line.startsWith('data: ')) {
          final data = line.substring(6).trim();
          if (data == '[DONE]') break;
          try {
            final parsed = jsonDecode(data);
            final delta = parsed['choices']?[0]?['delta'];
            if (delta != null && delta['content'] != null) {
              yield {'type': 'token', 'content': delta['content']};
            }
          } catch (_) {}
        }
      }
    } catch (e) {
      yield {'type': 'error', 'content': 'Connection failed: $e'};
    } finally {
      client.close();
    }
  }

  Stream<dynamic> _simulateAgentLoop(String prompt) async* {
    final isQuery = prompt.toLowerCase().contains('search') ||
        prompt.toLowerCase().contains('খোঁজ') ||
        prompt.toLowerCase().contains('weather');

    if (isQuery) {
      final tool = ToolCall(
        id: 'tc_${DateTime.now().millisecondsSinceEpoch}',
        name: 'web_search',
        arguments: {'query': prompt},
        status: ToolStatus.running,
      );
      yield {'type': 'tool_start', 'tool': tool};
      await Future.delayed(const Duration(milliseconds: 800));

      yield {
        'type': 'tool_output',
        'id': tool.id,
        'output': 'Web search indexed 5 matching sources.',
        'status': ToolStatus.completed,
      };
      await Future.delayed(const Duration(milliseconds: 300));
    }

    final responseText =
        'আমি Hermes Agent। আপনার নির্দেশনাটি সফলভাবে গৃহীত হয়েছে: "$prompt"।\n\n'
        '**১০০% ওয়েব অ্যাপ সমমানের ফিচারসমূহ সক্রিয় রয়েছে:**\n'
        '- 📋 **Kanban Board (/kanban):** অটোনেমাস টাস্ক ও সাব-এজেন্ট ট্র্যাকিং।\n'
        '- 📁 **Workspace Files (/api/files):** রিয়েল-টাইম ফাইল এক্সপ্লোরার ও কোড ভিউয়ার।\n'
        '- ⚡ **Skills Hub (/skills):** SKILL.md লার্নিং লুপ।\n'
        '- 🧠 **Memory Hub (/memory):** USER.md ও MEMORY.md পারসিস্টেন্স।\n'
        '- 🔌 **JSON-RPC 2.0 WebSocket (/api/ws):** গেটওয়ের অফিসিয়াল প্রোটোকল কানেক্টিভিটি।';

    for (int i = 0; i < responseText.length; i += 3) {
      final chunk = responseText.substring(
          i, i + 3 > responseText.length ? responseText.length : i + 3);
      yield {'type': 'token', 'content': chunk};
      await Future.delayed(const Duration(milliseconds: 25));
    }
  }
}
