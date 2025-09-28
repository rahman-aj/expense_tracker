import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'expense_item.dart';
import '../../models/expense.dart';
import '../screens/add_expense_screen.dart';
import '../../providers/expense_provider.dart';

class ExpenseList extends ConsumerWidget {
  const ExpenseList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider);
    final notifier = ref.read(expenseProvider.notifier);
    final sortMode = notifier.sortMode;

    void toggleSort() {
      notifier.setSort(sortMode == 'date' ? 'amount' : 'date');
    }

    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No expenses yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first expense to get started',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: GestureDetector(
            onTap: toggleSort,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(sortMode == 'date' ? Icons.calendar_today : Icons.sort,
                    size: 18, color: Colors.blue),
                const SizedBox(width: 6),
                Text(
                  sortMode == 'date' ? 'Sort: Date' : 'Sort: Amount',
                  style: const TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: sortMode == 'amount'
              ? ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, i) {
                    final expense = expenses[i];
                    return ExpenseItem(
                      expense: expense,
                      showDate: true,
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddExpenseScreen(
                              key: const ValueKey('edit_\${expense.id}'),
                              expense: expense,
                            ),
                          ),
                        );
                      },
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Expense'),
                            content: const Text(
                                'Are you sure you want to delete this expense?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel')),
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Delete')),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          ref
                              .read(expenseProvider.notifier)
                              .deleteExpense(expense.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Expense deleted')));
                        }
                      },
                    );
                  },
                )
              : ListView.builder(
                  itemCount: _groupedKeys(expenses).length,
                  itemBuilder: (context, i) {
                    final dateKey = _groupedKeys(expenses)[i];
                    final dayExpenses = _groupedByDate(expenses)[dateKey]!;
                    final dateLabel = DateFormat('MMM dd, yyyy')
                        .format(dayExpenses.first.date);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Text(dateLabel,
                              style: Theme.of(context).textTheme.titleMedium),
                        ),
                        ...dayExpenses.map((expense) => ExpenseItem(
                              expense: expense,
                              showDate: false,
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddExpenseScreen(
                                      key: const ValueKey('edit_\${expense.id}'),
                                      expense: expense,
                                    ),
                                  ),
                                );
                              },
                              onDelete: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Expense'),
                                    content: const Text(
                                        'Are you sure you want to delete this expense?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text('Cancel')),
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: const Text('Delete')),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  ref
                                      .read(expenseProvider.notifier)
                                      .deleteExpense(expense.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Expense deleted')));
                                }
                              },
                            )),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Helper for grouping
  Map<String, List<Expense>> _groupedByDate(List<Expense> expenses) {
    final Map<String, List<Expense>> grouped = {};
    for (final expense in expenses) {
      final dateKey = DateFormat('yyyy-MM-dd').format(expense.date);
      grouped.putIfAbsent(dateKey, () => []).add(expense);
    }
    return grouped;
  }

  List<String> _groupedKeys(List<Expense> expenses) {
    final grouped = _groupedByDate(expenses);
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return sortedKeys;
  }
}