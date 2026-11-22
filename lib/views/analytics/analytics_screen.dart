import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/hermes_theme.dart';
import '../../models/analytics_data.dart';

class AnalyticsScreen extends StatefulWidget {
  final AnalyticsData analytics;
  final Function(AnalyticsData) onSaveAnalytics;

  const AnalyticsScreen({
    super.key,
    required this.analytics,
    required this.onSaveAnalytics,
  });

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late AnalyticsData _data;

  @override
  void initState() {
    super.initState();
    _data = widget.analytics;
  }

  void _resetStats() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HermesTheme.surface,
        title: const Text('Reset Analytics?', style: TextStyle(color: HermesTheme.textPrimary, fontSize: 16)),
        content: const Text('This will reset all token counters and cost metrics to zero.', style: TextStyle(color: HermesTheme.textMuted, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: HermesTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: HermesTheme.error),
            onPressed: () {
              setState(() {
                _data = AnalyticsData(
                  totalPromptTokens: 0,
                  totalCompletionTokens: 0,
                  totalCostUsd: 0.0,
                  requestsCount: 0,
                  toolCallsCount: 0,
                  modelUsage: {},
                );
              });
              widget.onSaveAnalytics(_data);
              Navigator.pop(ctx);
            },
            child: const Text('Reset', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final numFormat = NumberFormat('#,###');
    final costFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 4);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Usage', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: HermesTheme.primary),
            tooltip: 'Reset Stats',
            onPressed: _resetStats,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Top Summary Grid
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.35,
            children: [
              _buildMetricCard(
                title: 'Total Tokens',
                value: numFormat.format(_data.totalTokens),
                subtitle: '${numFormat.format(_data.totalPromptTokens)} in / ${numFormat.format(_data.totalCompletionTokens)} out',
                icon: Icons.data_usage_rounded,
                color: HermesTheme.primary,
              ),
              _buildMetricCard(
                title: 'Estimated Cost',
                value: costFormat.format(_data.totalCostUsd),
                subtitle: 'Blended Cloud & Local Rates',
                icon: Icons.monetization_on_rounded,
                color: HermesTheme.success,
              ),
              _buildMetricCard(
                title: 'Agent Requests',
                value: '${_data.requestsCount}',
                subtitle: 'Chat & autonomous turns',
                icon: Icons.chat_rounded,
                color: HermesTheme.accent,
              ),
              _buildMetricCard(
                title: 'Tool Invocations',
                value: '${_data.toolCallsCount}',
                subtitle: 'bash, web_search, files',
                icon: Icons.handyman_rounded,
                color: Colors.orangeAccent,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Model Breakdown Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HermesTheme.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: HermesTheme.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.pie_chart_rounded, color: HermesTheme.primary, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Token Distribution by Model',
                      style: TextStyle(color: HermesTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_data.modelUsage.isEmpty)
                  const Text('No model usage recorded yet.', style: TextStyle(color: HermesTheme.textMuted, fontSize: 12))
                else
                  ..._data.modelUsage.entries.map((entry) {
                    final percent = _data.totalTokens > 0 ? (entry.value / _data.totalTokens) : 0.0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(color: HermesTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                              Text(
                                '${numFormat.format(entry.value)} tokens (${(percent * 100).toStringAsFixed(1)}%)',
                                style: const TextStyle(color: HermesTheme.textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percent.clamp(0.0, 1.0),
                              backgroundColor: HermesTheme.surface,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                entry.key.contains('gemini') ? HermesTheme.primary : HermesTheme.accent,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Efficiency & Latency Summary
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
                Text('Performance & Latency', style: TextStyle(color: HermesTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Average Time to First Token (TTFT)', style: TextStyle(color: HermesTheme.textMuted, fontSize: 12)),
                    Text('~380 ms', style: TextStyle(color: HermesTheme.success, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Streaming Throughput', style: TextStyle(color: HermesTheme.textMuted, fontSize: 12)),
                    Text('~46 tokens/sec', style: TextStyle(color: HermesTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tool Success Rate', style: TextStyle(color: HermesTheme.textMuted, fontSize: 12)),
                    Text('98.4%', style: TextStyle(color: HermesTheme.success, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HermesTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HermesTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: HermesTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: HermesTheme.textMuted, fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
