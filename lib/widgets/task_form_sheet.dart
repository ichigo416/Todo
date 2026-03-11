import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskFormSheet extends StatefulWidget {
  final Task? existing;
  const TaskFormSheet({super.key, this.existing});

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  late TextEditingController _ctrl;
  late String _priority;
  late String _category;
  DateTime? _dueDate;

  static const _categoryColors = {
    'personal': Color(0xFF7B8CDE),
    'work': Color(0xFFFF6B6B),
    'shopping': Color(0xFFFFB347),
    'health': Color(0xFF6BCB77),
    'other': Color(0xFFB47BDE),
  };

  static const _categoryIcons = {
    'personal': Icons.person_rounded,
    'work': Icons.work_rounded,
    'shopping': Icons.shopping_bag_rounded,
    'health': Icons.favorite_rounded,
    'other': Icons.tag_rounded,
  };

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.existing?.title ?? '');
    _priority = widget.existing?.priority ?? 'medium';
    _category = widget.existing?.category ?? 'personal';
    _dueDate = widget.existing?.dueDate;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _priorityBtn(String value, String label, Color color) {
    final sel = _priority == value;
    return GestureDetector(
      onTap: () => setState(() => _priority = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? color.withValues(alpha: 0.2) : const Color(0xFF252836),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: sel ? color : Colors.transparent, width: 1.5),
        ),
        child: Text(label,
            style: TextStyle(
                color: sel ? color : const Color(0xFF8B8FA8),
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _categoryBtn(String value) {
    final sel = _category == value;
    final color = _categoryColors[value] ?? _categoryColors['other']!;
    final icon = _categoryIcons[value] ?? Icons.tag_rounded;
    return GestureDetector(
      onTap: () => setState(() => _category = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? color.withValues(alpha: 0.2) : const Color(0xFF252836),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: sel ? color : Colors.transparent, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: sel ? color : const Color(0xFF8B8FA8)),
            const SizedBox(width: 6),
            Text(value,
                style: TextStyle(
                    color: sel ? color : const Color(0xFF8B8FA8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: Color(0xFF1A1D27),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFF2A2D3E),
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),

          Text(widget.existing != null ? 'Edit Task' : 'New Task',
              style: const TextStyle(
                  color: Color(0xFFF0F0F5),
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),

          TextField(
            controller: _ctrl,
            autofocus: true,
            style: const TextStyle(color: Color(0xFFF0F0F5), fontSize: 15),
            decoration: const InputDecoration(hintText: 'What needs to be done?'),
          ),
          const SizedBox(height: 20),

          const Text('PRIORITY',
              style: TextStyle(
                  color: Color(0xFF8B8FA8),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1)),
          const SizedBox(height: 10),
          Row(children: [
            _priorityBtn('high', '🔴 High', const Color(0xFFFF6B6B)),
            const SizedBox(width: 8),
            _priorityBtn('medium', '🟡 Medium', const Color(0xFFFFB347)),
            const SizedBox(width: 8),
            _priorityBtn('low', '🟢 Low', const Color(0xFF6BCB77)),
          ]),
          const SizedBox(height: 20),

          const Text('CATEGORY',
              style: TextStyle(
                  color: Color(0xFF8B8FA8),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: ['personal', 'work', 'shopping', 'health', 'other']
                .map(_categoryBtn)
                .toList(),
          ),
          const SizedBox(height: 20),

          const Text('DUE DATE',
              style: TextStyle(
                  color: Color(0xFF8B8FA8),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _dueDate ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 1)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.dark(
                        primary: Color(0xFFFF6B6B),
                        surface: Color(0xFF252836)),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) setState(() => _dueDate = picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF252836),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: _dueDate != null
                        ? const Color(0xFFFF6B6B).withValues(alpha: 0.4)
                        : const Color(0xFF2A2D3E)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 16,
                      color: _dueDate != null
                          ? const Color(0xFFFF6B6B)
                          : const Color(0xFF8B8FA8)),
                  const SizedBox(width: 10),
                  Text(
                    _dueDate != null
                        ? DateFormat('EEEE, MMM d yyyy').format(_dueDate!)
                        : 'No due date',
                    style: TextStyle(
                        color: _dueDate != null
                            ? const Color(0xFFF0F0F5)
                            : const Color(0xFF8B8FA8),
                        fontSize: 14),
                  ),
                  const Spacer(),
                  if (_dueDate != null)
                    GestureDetector(
                      onTap: () => setState(() => _dueDate = null),
                      child: const Icon(Icons.close_rounded,
                          size: 16, color: Color(0xFF8B8FA8)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_ctrl.text.trim().isEmpty) return;
                Navigator.pop(context,
                  Task(
                    title: _ctrl.text.trim(),
                    priority: _priority,
                    category: _category,
                    dueDate: _dueDate,
                    isCompleted: widget.existing?.isCompleted ?? false,
                    createdAt: widget.existing?.createdAt,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                widget.existing != null ? 'Save Changes' : 'Add Task',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}