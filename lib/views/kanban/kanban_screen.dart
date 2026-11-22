import 'package:flutter/material.dart';
import '../../core/theme/hermes_theme.dart';
import '../../models/kanban_task.dart';

class KanbanScreen extends StatefulWidget {
  final List<KanbanTask> tasks;
  final Function(KanbanTask) onAddTask;
  final Function(KanbanTask, TaskStatus) onUpdateTaskStatus;
  final Function(String) onDeleteTask;

  const KanbanScreen({
    super.key,
    required this.tasks,
    required this.onAddTask,
    required this.onUpdateTaskStatus,
    required this.onDeleteTask,
  });

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<TaskStatus> _columns = [
    TaskStatus.todo,
    TaskStatus.inProgress,
    TaskStatus.review,
    TaskStatus.done,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _columns.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _statusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'TO-DO';
      case TaskStatus.inProgress:
        return 'IN PROGRESS';
      case TaskStatus.review:
        return 'REVIEW';
      case TaskStatus.done:
        return 'DONE';
    }
  }

  Color _statusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return HermesTheme.textMuted;
      case TaskStatus.inProgress:
        return HermesTheme.primary;
      case TaskStatus.review:
        return HermesTheme.warning;
      case TaskStatus.done:
        return HermesTheme.success;
    }
  }

  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.critical:
        return HermesTheme.danger;
      case TaskPriority.high:
        return HermesTheme.warning;
      case TaskPriority.medium:
        return HermesTheme.primary;
      case TaskPriority.low:
        return HermesTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autonomous Tasks (/kanban)'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: HermesTheme.primary,
          labelColor: HermesTheme.primary,
          unselectedLabelColor: HermesTheme.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: _columns.map((col) {
            final count = widget.tasks.where((t) => t.status == col).length;
            return Tab(
              child: Row(
                children: [
                  Text(_statusLabel(col)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _statusColor(col).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: _statusColor(col),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task_rounded, color: HermesTheme.primary),
            onPressed: () => _showAddTaskDialog(context),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: _columns.map((col) {
          final columnTasks = widget.tasks.where((t) => t.status == col).toList();
          if (columnTasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 48, color: HermesTheme.cardBorder),
                  const SizedBox(height: 12),
                  Text(
                    'No tasks in ${_statusLabel(col)}',
                    style: const TextStyle(color: HermesTheme.textMuted, fontSize: 13),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: columnTasks.length,
            itemBuilder: (context, index) {
              final task = columnTasks[index];
              return _buildTaskCard(task);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTaskCard(KanbanTask task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: HermesTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HermesTheme.cardBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showTaskDetails(task),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _priorityColor(task.priority).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _priorityColor(task.priority).withOpacity(0.4)),
                    ),
                    child: Text(
                      task.priority.name.toUpperCase(),
                      style: TextStyle(
                        color: _priorityColor(task.priority),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (task.assignedSubagent != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: HermesTheme.accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.smart_toy_rounded, size: 10, color: HermesTheme.accent),
                          const SizedBox(width: 4),
                          Text(
                            task.assignedSubagent!,
                            style: const TextStyle(color: HermesTheme.accent, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Spacer(),
                  PopupMenuButton<TaskStatus>(
                    icon: const Icon(Icons.more_vert_rounded, size: 18, color: HermesTheme.textMuted),
                    color: HermesTheme.surface,
                    onSelected: (newStatus) => widget.onUpdateTaskStatus(task, newStatus),
                    itemBuilder: (ctx) => [
                      for (final s in TaskStatus.values)
                        PopupMenuItem(
                          value: s,
                          child: Text(
                            'Move to ${_statusLabel(s)}',
                            style: TextStyle(
                              color: s == task.status ? HermesTheme.primary : HermesTheme.textPrimary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task.title,
                style: const TextStyle(
                  color: HermesTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: HermesTheme.textSecondary, fontSize: 12),
              ),
              if (task.logs.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: HermesTheme.background,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.history_rounded, size: 12, color: HermesTheme.textMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          task.logs.last,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: HermesTheme.textMuted,
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskDetails(KanbanTask task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: HermesTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollCtrl) => ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: HermesTheme.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      color: HermesTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: HermesTheme.danger),
                  onPressed: () {
                    widget.onDeleteTask(task.id);
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              task.description,
              style: const TextStyle(color: HermesTheme.textSecondary, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),
            const Text(
              'AGENT EXECUTION LOGS',
              style: TextStyle(
                color: HermesTheme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: HermesTheme.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: HermesTheme.cardBorder),
              ),
              child: task.logs.isEmpty
                  ? const Text('No execution logs yet.', style: TextStyle(color: HermesTheme.textMuted, fontSize: 12))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: task.logs
                          .map((log) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '> $log',
                                  style: const TextStyle(
                                    color: HermesTheme.textPrimary,
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    TaskPriority priority = TaskPriority.medium;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: HermesTheme.surface,
          title: const Text('Add Autonomous Task', style: TextStyle(color: HermesTheme.textPrimary, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                decoration: const InputDecoration(labelText: 'Task Title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                decoration: const InputDecoration(labelText: 'Detailed Goal / Instructions'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TaskPriority>(
                value: priority,
                dropdownColor: HermesTheme.cardColor,
                style: const TextStyle(color: HermesTheme.textPrimary, fontSize: 13),
                decoration: const InputDecoration(labelText: 'Priority'),
                items: TaskPriority.values
                    .map((p) => DropdownMenuItem(value: p, child: Text(p.name.toUpperCase())))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setDlgState(() => priority = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: HermesTheme.textMuted)),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: HermesTheme.primary),
              child: const Text('Create Task', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              onPressed: () {
                if (titleCtrl.text.trim().isNotEmpty) {
                  final task = KanbanTask(
                    id: 'task_${DateTime.now().millisecondsSinceEpoch}',
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    priority: priority,
                    status: TaskStatus.todo,
                    logs: ['Task created in Kanban queue.'],
                  );
                  widget.onAddTask(task);
                  Navigator.pop(ctx);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
