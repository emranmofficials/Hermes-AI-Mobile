class McpServer {
  final String id;
  String name;
  String transport; // stdio, sse, http
  String command;
  List<String> args;
  String url;
  Map<String, String> env;
  bool isEnabled;
  List<String> tools;
  String status; // connected, disconnected, error

  McpServer({
    required this.id,
    required this.name,
    this.transport = 'stdio',
    this.command = '',
    List<String>? args,
    this.url = '',
    Map<String, String>? env,
    this.isEnabled = true,
    List<String>? tools,
    this.status = 'disconnected',
  })  : args = args ?? [],
        env = env ?? {},
        tools = tools ?? [];

  factory McpServer.fromJson(Map<String, dynamic> json) {
    return McpServer(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      transport: json['transport'] ?? 'stdio',
      command: json['command'] ?? '',
      args: (json['args'] as List?)?.map((e) => e.toString()).toList() ?? [],
      url: json['url'] ?? '',
      env: (json['env'] as Map?)?.map((k, v) => MapEntry(k.toString(), v.toString())) ?? {},
      isEnabled: json['isEnabled'] ?? true,
      tools: (json['tools'] as List?)?.map((e) => e.toString()).toList() ?? [],
      status: json['status'] ?? 'disconnected',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'transport': transport,
      'command': command,
      'args': args,
      'url': url,
      'env': env,
      'isEnabled': isEnabled,
      'tools': tools,
      'status': status,
    };
  }
}
