import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/hermes_theme.dart';
import '../../models/cron_job.dart';

class CronScreen extends StatefulWidget {
  final List<CronJob> jobs;
  final Function(CronJob) onAddJob;
  final Function(CronJob) onUpdateJob;
  final Function(String) onDeleteJob;

  const CronScreen({
    super.key,
    required this.jobs,
    required this.onAddJob,
    required this.onUpdateJob,
    required this.onDeleteJob,
  });

  @override
  State<CronScreen> createState() => _CronScreenState();
}

class _CronScreenState extends State<CronScreen> {
  void _triggerJob(CronJob job) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Triggering "${job.name}"...'),
        duration: const Duration(seconds: 1),
      ),
    );

    Future.delayed(const Duration(milliseconds: 900), () {
      setState(() {
        job.lastRun = DateTime.now();
        job.lastOutput = 'Executed autonomously. Output dispatched to ${job.targetChannel}.';
      });
      widget.onUpdateJob(job);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: HermesTheme.success,
            content: Text('✓ "${job.name}" completed successfully!'),
          ),
        );
      }
    });
  }

  void _openAddJobDialog() {
    final nameCtrl = TextEditingController();
    final cronCtrl = TextEditingController(text: '0 9 * * *');
    final promptCtrl = TextEditingController();
    String channel = 'Chat';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: HermesTheme.surface,
          title: const Text('New Scheduled Task', style: TextStyle(color: HermesTheme.textPrimary, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                  decoration: const InputDecoration(labelText: 'Task Name', hintText: 'e.g. Daily Standup Report'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cronCtrl,
                  style: const TextStyle(color: HermesTheme.textPrimary, fontFamily: 'monospace', fontSize: 13),
                  decoration: const InputDecoration(labelText: 'Cron Expression', hintText: '0 9 * * * (Everyday at 9 AM)'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: channel,
                  dropdownColor: HermesTheme.cardColor,
                  style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                  decoration: const InputDecoration(labelText: 'Delivery Target Channel'),
                  items: const [
                    DropdownMenuItem(value: 'Chat', child: Text('Hermes App Chat')),
                    DropdownMenuItem(value: 'WhatsApp', child: Text('WhatsApp Relay')),
                    DropdownMenuItem(value: 'Telegram', child: Text('Telegram Bot')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDlgState(() => channel = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: promptCtrl,
                  maxLines: 3,
                  style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 12),
                  decoration: const InputDecoration(labelText: 'Prompt / Instruction Payload'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: HermesTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: HermesTheme.primary),
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                final newJob = CronJob(
                  id: 'cron_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text.trim(),
                  cronExpression: cronCtrl.text.trim(),
                  prompt: promptCtrl.text.trim(),
                  targetChannel: channel,
                  lastRun: null,
                  lastOutput: 'Scheduled. Awaiting trigger.',
                );
                widget.onAddJob(newJob);
                Navigator.pop(ctx);
              },
              child: const Text('Schedule', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cron Automations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: HermesTheme.primary),
            onPressed: _openAddJobDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: HermesTheme.primary,
        icon: const Icon(Icons.schedule_rounded, color: Colors.black),
        label: const Text('New Cron', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        onPressed: _openAddJobDialog,
      ),
      body: widget.jobs.isEmpty
          ? const Center(
              child: Text('No scheduled cron jobs.', style: TextStyle(color: HermesTheme.textMuted)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.jobs.length,
              itemBuilder: (context, index) {
                final job = widget.jobs[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: HermesTheme.cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: HermesTheme.cardBorder),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (job.isEnabled ? HermesTheme.primary : HermesTheme.textMuted).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.alarm_rounded,
                                color: job.isEnabled ? HermesTheme.primary : HermesTheme.textMuted,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    job.name,
                                    style: const TextStyle(
                                      color: HermesTheme.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: HermesTheme.surface,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          job.cronExpression,
                                          style: const TextStyle(color: HermesTheme.primary, fontFamily: 'monospace', fontSize: 10),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '→ ${job.targetChannel}',
                                        style: const TextStyle(color: HermesTheme.textMuted, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: job.isEnabled,
                              activeColor: HermesTheme.primary,
                              onChanged: (val) {
                                setState(() => job.isEnabled = val);
                                widget.onUpdateJob(job);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: HermesTheme.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Prompt: ${job.prompt}',
                                style: const TextStyle(color: HermesTheme.textSecondary, fontSize: 11),
                              ),
                              if (job.lastOutput.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'Last Log: ${job.lastOutput}',
                                  style: const TextStyle(color: HermesTheme.success, fontSize: 10),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              job.lastRun != null ? 'Last run: ${dateFormat.format(job.lastRun!)}' : 'Never executed',
                              style: const TextStyle(color: HermesTheme.textMuted, fontSize: 11),
                            ),
                            Row(
                              children: [
                                TextButton.icon(
                                  style: TextButton.styleFrom(foregroundColor: HermesTheme.primary),
                                  icon: const Icon(Icons.play_arrow_rounded, size: 16),
                                  label: const Text('Trigger Now', style: TextStyle(fontSize: 12)),
                                  onPressed: () => _triggerJob(job),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: HermesTheme.error, size: 18),
                                  onPressed: () => widget.onDeleteJob(job.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
