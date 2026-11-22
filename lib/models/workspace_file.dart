class WorkspaceFile {
  final String name;
  final String path;
  final bool isDirectory;
  final int size;
  final String? extension;
  String? content;
  List<WorkspaceFile> children;

  WorkspaceFile({
    required this.name,
    required this.path,
    required this.isDirectory,
    this.size = 0,
    this.extension,
    this.content,
    List<WorkspaceFile>? children,
  }) : children = children ?? [];

  Map<String, dynamic> toJson() => {
    'name': name,
    'path': path,
    'isDirectory': isDirectory,
    'size': size,
    'extension': extension,
    'content': content,
    'children': children.map((c) => c.toJson()).toList(),
  };

  factory WorkspaceFile.fromJson(Map<String, dynamic> json) {
    return WorkspaceFile(
      name: json['name'] as String,
      path: json['path'] as String,
      isDirectory: json['isDirectory'] as bool? ?? false,
      size: (json['size'] as num?)?.toInt() ?? 0,
      extension: json['extension'] as String?,
      content: json['content'] as String?,
      children: (json['children'] as List?)
              ?.map((c) => WorkspaceFile.fromJson(Map<String, dynamic>.from(c)))
              .toList() ??
          [],
    );
  }
}
