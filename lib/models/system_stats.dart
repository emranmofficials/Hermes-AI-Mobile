class SystemStats {
  final double cpuUsagePercent;
  final double ramUsagePercent;
  final int ramUsedMb;
  final int ramTotalMb;
  final int activeTasksCount;
  final int totalSubagents;
  final int uptimeSeconds;
  final bool isGatewayOnline;
  final String gatewayVersion;
  final double diskUsagePercent;
  final double diskFreeGb;
  final int gatewayLatencyMs;

  double get memoryUsagePercent => ramUsagePercent;
  int get memoryUsedMb => ramUsedMb;
  int get memoryTotalMb => ramTotalMb;
  bool get isGatewayConnected => isGatewayOnline;

  SystemStats({
    this.cpuUsagePercent = 14.5,
    this.ramUsagePercent = 42.0,
    this.ramUsedMb = 3450,
    this.ramTotalMb = 8192,
    this.activeTasksCount = 2,
    this.totalSubagents = 1,
    this.uptimeSeconds = 38400,
    this.isGatewayOnline = true,
    this.gatewayVersion = 'hermes-core 0.0.1 (FastAPI/JSON-RPC 2.0)',
    this.diskUsagePercent = 34.0,
    this.diskFreeGb = 48.5,
    this.gatewayLatencyMs = 18,
  });

  Map<String, dynamic> toJson() => {
    'cpuUsagePercent': cpuUsagePercent,
    'ramUsagePercent': ramUsagePercent,
    'ramUsedMb': ramUsedMb,
    'ramTotalMb': ramTotalMb,
    'activeTasksCount': activeTasksCount,
    'totalSubagents': totalSubagents,
    'uptimeSeconds': uptimeSeconds,
    'isGatewayOnline': isGatewayOnline,
    'gatewayVersion': gatewayVersion,
    'diskUsagePercent': diskUsagePercent,
    'diskFreeGb': diskFreeGb,
    'gatewayLatencyMs': gatewayLatencyMs,
  };

  factory SystemStats.fromJson(Map<String, dynamic> json) {
    return SystemStats(
      cpuUsagePercent: (json['cpuUsagePercent'] as num?)?.toDouble() ?? 14.5,
      ramUsagePercent: (json['ramUsagePercent'] as num?)?.toDouble() ?? 42.0,
      ramUsedMb: (json['ramUsedMb'] as num?)?.toInt() ?? 3450,
      ramTotalMb: (json['ramTotalMb'] as num?)?.toInt() ?? 8192,
      activeTasksCount: (json['activeTasksCount'] as num?)?.toInt() ?? 2,
      totalSubagents: (json['totalSubagents'] as num?)?.toInt() ?? 1,
      uptimeSeconds: (json['uptimeSeconds'] as num?)?.toInt() ?? 38400,
      isGatewayOnline: json['isGatewayOnline'] as bool? ?? true,
      gatewayVersion: json['gatewayVersion'] as String? ?? 'hermes-core 0.0.1 (FastAPI/JSON-RPC 2.0)',
      diskUsagePercent: (json['diskUsagePercent'] as num?)?.toDouble() ?? 34.0,
      diskFreeGb: (json['diskFreeGb'] as num?)?.toDouble() ?? 48.5,
      gatewayLatencyMs: (json['gatewayLatencyMs'] as num?)?.toInt() ?? 18,
    );
  }
}
