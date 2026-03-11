import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../widgets/task_tile.dart';
import '../widgets/task_form_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Task> tasks = [];
  late Box box;
  String _searchQuery = '';
  String _filterCategory = 'all';
  bool _showCompleted = true;
  late AnimationController _fabAnim;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fabAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _loadTasks();
  }

  @override
  void dispose() {
    _fabAnim.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadTasks() async {
    box = await Hive.openBox('todoBox');
    List stored = box.get('tasks', defaultValue: []);
    setState(() {
      tasks = stored
          .map((e) => Task.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    });
    _fabAnim.forward();
  }

  void _saveTasks() =>
      box.put('tasks', tasks.map((e) => e.toMap()).toList());

  List<Task> get _filtered {
    return tasks.where((t) {
      final matchSearch =
          t.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchCat =
          _filterCategory == 'all' || t.category == _filterCategory;
      final matchDone = _showCompleted || !t.isCompleted;
      return matchSearch && matchCat && matchDone;
    }).toList()
      ..sort((a, b) {
        if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
        const order = {'high': 0, 'medium': 1, 'low': 2};
        return (order[a.priority] ?? 1).compareTo(order[b.priority] ?? 1);
      });
  }

  int get _completedCount => tasks.where((t) => t.isCompleted).length;
  int get _overdueCount => tasks.where((t) {
        if (t.dueDate == null || t.isCompleted) return false;
        return t.dueDate!.isBefore(DateTime.now());
      }).length;

  void _openForm({Task? existing, int? realIndex}) async {
    final result = await showModalBottomSheet<Task>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskFormSheet(existing: existing),
    );
    if (result != null) {
      setState(() {
        if (realIndex != null) {
          tasks[realIndex] = result;
        } else {
          tasks.add(result);
        }
      });
      _saveTasks();
    }
  }

  void _toggle(int filteredIndex, bool? value) {
    final real = tasks.indexOf(_filtered[filteredIndex]);
    setState(() => tasks[real].isCompleted = value!);
    _saveTasks();
  }

  void _delete(int filteredIndex) {
    final real = tasks.indexOf(_filtered[filteredIndex]);
    setState(() => tasks.removeAt(real));
    _saveTasks();
  }

  void _edit(int filteredIndex) {
    final real = tasks.indexOf(_filtered[filteredIndex]);
    _openForm(existing: tasks[real], realIndex: real);
  }

  Widget _chip(String value, String label, {Color? color}) {
    final sel = _filterCategory == value;
    final c = color ?? const Color(0xFFFF6B6B);
    return GestureDetector(
      onTap: () => setState(() => _filterCategory = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: sel ? c.withValues(alpha: 0.2) : const Color(0xFF1A1D27),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: sel ? c : const Color(0xFF2A2D3E), width: 1.5),
        ),
        child: Text(label,
            style: TextStyle(
                color: sel ? c : const Color(0xFF8B8FA8),
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('My Tasks',
                            style: TextStyle(
                                color: Color(0xFFF0F0F5),
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5)),
                        const SizedBox(height: 4),
                        Text(
                          '$_completedCount of ${tasks.length} completed'
                          '${_overdueCount > 0 ? ' · $_overdueCount overdue' : ''}',
                          style: TextStyle(
                              color: _overdueCount > 0
                                  ? const Color(0xFFFF6B6B)
                                  : const Color(0xFF8B8FA8),
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _showCompleted = !_showCompleted),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: const Color(0xFF1A1D27),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2A2D3E))),
                      child: Icon(
                          _showCompleted
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: const Color(0xFF8B8FA8),
                          size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Progress bar
            if (tasks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _completedCount / tasks.length,
                    backgroundColor: const Color(0xFF2A2D3E),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFFF6B6B)),
                    minHeight: 4,
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(
                    color: Color(0xFFF0F0F5), fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: Color(0xFF8B8FA8), size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: const Icon(Icons.close_rounded,
                              color: Color(0xFF8B8FA8), size: 18))
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Category filter chips
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _chip('all', 'All'),
                  _chip('personal', 'Personal',
                      color: const Color(0xFF7B8CDE)),
                  _chip('work', 'Work', color: const Color(0xFFFF6B6B)),
                  _chip('shopping', 'Shopping',
                      color: const Color(0xFFFFB347)),
                  _chip('health', 'Health', color: const Color(0xFF6BCB77)),
                  _chip('other', 'Other', color: const Color(0xFFB47BDE)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Task list
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                              tasks.isEmpty
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.search_off_rounded,
                              size: 56,
                              color: const Color(0xFF2A2D3E)),
                          const SizedBox(height: 16),
                          Text(
                            tasks.isEmpty
                                ? 'No tasks yet\nTap + to add one'
                                : 'No tasks match your filters',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Color(0xFF8B8FA8),
                                fontSize: 15,
                                height: 1.6),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        return TweenAnimationBuilder<double>(
                          key: ValueKey(filtered[i].createdAt),
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(
                              milliseconds: 200 + (i * 40).clamp(0, 400)),
                          builder: (ctx, v, child) => Opacity(
                            opacity: v,
                            child: Transform.translate(
                                offset: Offset(0, 20 * (1 - v)),
                                child: child),
                          ),
                          child: TaskTile(
                            task: filtered[i],
                            onChanged: (v) => _toggle(i, v),
                            onDelete: () => _delete(i),
                            onEdit: () => _edit(i),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(parent: _fabAnim, curve: Curves.elasticOut),
        child: FloatingActionButton.extended(
          onPressed: _openForm,
          backgroundColor: const Color(0xFFFF6B6B),
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Task',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}