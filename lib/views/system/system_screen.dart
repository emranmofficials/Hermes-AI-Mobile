import 'package:flutter/material.dart';
import '../../core/theme/hermes_theme.dart';
import '../../models/system_stats.dart';

class SystemScreen extends StatefulWidget {
  final SystemStats stats;
  final Future<void> Function() onRefresh;

  const SystemScreen({
    super.key,
    required this.stats,
    required this.onRefresh,
  });

  @override
  State<SystemScreen> createState() => _SystemScreenState();
}

class _SystemScreenState extends State<SystemScreen> {
  bool _isRefreshing = false;

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await widget.onRefresh();
    if (mounted) {
      setState(() => _isRefreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: HermesTheme.success,
          content: Text('✓ System telemetry updated!'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Telemetry', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: HermesTheme.primary))
                : const Icon(Icons.refresh_rounded, color: HermesTheme.primary),
            onPressed: _isRefreshing ? null : _handleRefresh,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Gateway Health Status Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HermesTheme.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: HermesTheme.cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (s.isGatewayConnected ? HermesTheme.success : HermesTheme.error).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    s.isGatewayConnected ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                    color: s.isGatewayConnected ? HermesTheme.success : HermesTheme.error,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.isGatewayConnected ? 'Hermes Gateway Connected' : 'Gateway Offline (Standalone Mode)',
                        style: const TextStyle(color: HermesTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Gateway Latency: ${s.gatewayLatencyMs} ms • Local Termux Host',
                        style: const TextStyle(color: HermesTheme.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Hardware Gauges
          _buildHardwareGauge(
            title: 'CPU Utilization',
            percent: s.cpuUsagePercent / 100.0,
            displayValue: '${s.cpuUsagePercent.toStringAsFixed(1)}%',
            icon: Icons.memory_rounded,
            color: s.cpuUsagePercent > 80 ? HermesTheme.error : HermesTheme.primary,
          ),
          const SizedBox(height: 12),
          _buildHardwareGauge(
            title: 'Memory (RAM)',
            percent: s.memoryUsagePercent / 100.0,
            displayValue: '${s.memoryUsagePercent.toStringAsFixed(1)}%',
            subtitle: '${s.memoryUsedMb} MB used of ${s.memoryTotalMb} MB',
            icon: Icons.storage_rounded,
            color: s.memoryUsagePercent > 85 ? HermesTheme.error : HermesTheme.accent,
          ),
          const SizedBox(height: 12),
          _buildHardwareGauge(
            title: 'Internal Storage (Disk)',
            percent: s.diskUsagePercent / 100.0,
            displayValue: '${s.diskUsagePercent.toStringAsFixed(1)}%',
            subtitle: '${s.diskFreeGb} GB free',
            icon: Icons.pie_chart_outline_rounded,
            color: Colors.tealAccent,
          ),
          const SizedBox(height: 20),
          // Runtime Environment Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HermesTheme.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: HermesTheme.cardBorder),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Environment & Subagents', style: TextStyle(color: HermesTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Active Subagents', style: TextStyle(color: HermesTheme.textMuted, fontSize: 12)),
                    Text('2 running', style: TextStyle(color: HermesTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Task Execution Threads', style: TextStyle(color: HermesTheme.textMuted, fontSize: 12)),
                    Text('4 workers ready', style: TextStyle(color: HermesTheme.success, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('OS / Kernel', style: TextStyle(color: HermesTheme.textMuted, fontSize: 12)),
                    Text('Android Linux 64-bit (Termux)', style: TextStyle(color: HermesTheme.textPrimary, fontSize: 12)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Runtime Engine', style: TextStyle(color: HermesTheme.textMuted, fontSize: 12)),
                    Text('Flutter 3.29 + Dart AOT', style: TextStyle(color: HermesTheme.textPrimary, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHardwareGauge({
    required String title,
    required double percent,
    required String displayValue,
    String? subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HermesTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HermesTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(color: HermesTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              Text(
                displayValue,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              backgroundColor: HermesTheme.surface,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: HermesTheme.textMuted, fontSize: 11)),
          ],
        ],
      ),
    );
  }
}
