class Task {
  String title;
  bool isCompleted;
  String priority; // 'high', 'medium', 'low'
  String category; // 'personal', 'work', 'shopping', 'health', 'other'
  DateTime? dueDate;
  DateTime createdAt;

  Task({
    required this.title,
    this.isCompleted = false,
    this.priority = 'medium',
    this.category = 'personal',
    this.dueDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'title': title,
        'isCompleted': isCompleted,
        'priority': priority,
        'category': category,
        'dueDate': dueDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Task.fromMap(Map map) => Task(
        title: map['title'] ?? '',
        isCompleted: map['isCompleted'] ?? false,
        priority: map['priority'] ?? 'medium',
        category: map['category'] ?? 'personal',
        dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'])
            : DateTime.now(),
      );
}