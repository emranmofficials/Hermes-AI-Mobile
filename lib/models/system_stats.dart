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
  };

  factory SystemStats.fromJson(Map<String, dynamic> json) {
    return SystemStats(
      cpuUsagePercent: (json['cpuUsagePercent'] as num?)?.toDouble() ?? 0.0,
      ramUsagePercent: (json['ramUsagePercent'] as num?)?.toDouble() ?? 0.0,
      ramUsedMb: (json['ramUsedMb'] as num?)?.toInt() ?? 0,
      ramTotalMb: (json['ramTotalMb'] as num?)?.toInt() ?? 0,
      activeTasksCount: (json['activeTasksCount'] as num?)?.toInt() ?? 0,
      totalSubagents: (json['totalSubagents'] as num?)?.toInt() ?? 0,
      uptimeSeconds: (json['uptimeSeconds'] as num?)?.toInt() ?? 0,
      isGatewayOnline: json['isGatewayOnline'] as bool? ?? false,
      gatewayVersion: json['gatewayVersion'] as String? ?? 'Unknown',
    );
  }
}
