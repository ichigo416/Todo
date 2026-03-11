import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TaskTile({
    super.key,
    required this.task,
    required this.onChanged,
    required this.onDelete,
    required this.onEdit,
  });

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

  Color get _priorityColor {
    switch (task.priority) {
      case 'high': return const Color(0xFFFF6B6B);
      case 'low': return const Color(0xFF6BCB77);
      default: return const Color(0xFFFFB347);
    }
  }

  bool get _isOverdue =>
      task.dueDate != null &&
      !task.isCompleted &&
      task.dueDate!.isBefore(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final catColor =
        _categoryColors[task.category] ?? _categoryColors['other']!;
    final catIcon = _categoryIcons[task.category] ?? Icons.tag_rounded;

    return Dismissible(
      key: Key(task.createdAt.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
            color: const Color(0xFFFF6B6B).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_rounded,
            color: Color(0xFFFF6B6B), size: 24),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onEdit,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: task.isCompleted
                ? const Color(0xFF1A1D27).withValues(alpha: 0.5)
                : const Color(0xFF1A1D27),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: task.isCompleted
                    ? const Color(0xFF2A2D3E)
                    : _priorityColor.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Priority bar
                Container(
                  width: 3, height: 48,
                  decoration: BoxDecoration(
                      color: task.isCompleted
                          ? const Color(0xFF2A2D3E)
                          : _priorityColor,
                      borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(width: 12),

                // Checkbox
                GestureDetector(
                  onTap: () => onChanged(!task.isCompleted),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted
                          ? const Color(0xFFFF6B6B)
                          : Colors.transparent,
                      border: Border.all(
                          color: task.isCompleted
                              ? const Color(0xFFFF6B6B)
                              : const Color(0xFF8B8FA8),
                          width: 2),
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check_rounded,
                            size: 14, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.title,
                          style: TextStyle(
                              color: task.isCompleted
                                  ? const Color(0xFF8B8FA8)
                                  : const Color(0xFFF0F0F5),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: const Color(0xFF8B8FA8))),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // Category chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(catIcon, size: 10, color: catColor),
                                const SizedBox(width: 4),
                                Text(task.category,
                                    style: TextStyle(
                                        color: catColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          // Due date chip
                          if (task.dueDate != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                  color: _isOverdue
                                      ? const Color(0xFFFF6B6B).withValues(alpha: 0.15)
                                      : const Color(0xFF2A2D3E),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.calendar_today_rounded,
                                      size: 10,
                                      color: _isOverdue
                                          ? const Color(0xFFFF6B6B)
                                          : const Color(0xFF8B8FA8)),
                                  const SizedBox(width: 4),
                                  Text(
                                      DateFormat('MMM d').format(task.dueDate!),
                                      style: TextStyle(
                                          color: _isOverdue
                                              ? const Color(0xFFFF6B6B)
                                              : const Color(0xFF8B8FA8),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFF8B8FA8), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}