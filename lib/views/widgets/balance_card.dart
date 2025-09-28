import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/expense_provider.dart';

class BalanceCard extends ConsumerWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalSpent = ref.watch(totalSpentProvider);

    // Watch expenses to trigger rebuilds on add/edit/delete
    final expenses = ref.watch(expenseProvider);
    final filter = ref.read(expenseProvider.notifier).filterCategory;

    final filteredTotal = filter == null
        ? totalSpent
        : expenses
            .where((e) => e.category == filter)
            .fold(0.0, (sum, e) => sum + e.amount);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Left side: spent / budget info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('This Month', style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 6),
                    Text(
                      filter == null
                          ? 'Spent: \$${totalSpent.toStringAsFixed(2)}'
                          : 'Spent in $filter: \$${filteredTotal.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}