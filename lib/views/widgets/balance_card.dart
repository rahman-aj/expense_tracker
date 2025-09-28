import 'package:expense_tracker/common/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/budget_provider.dart';
import '../../providers/expense_provider.dart';

class BalanceCard extends ConsumerWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = ref.watch(currentMonthBudgetProvider);
    final totalSpent = ref.watch(totalSpentProvider);
    final remaining = ref.watch(remainingBudgetProvider);
    final progress = ref.watch(budgetProgressProvider);

    // Watch expenses to trigger rebuilds on add/edit/delete
    final expenses = ref.watch(expenseProvider);
    final filter = ref.read(expenseProvider.notifier).filterCategory;

    final filteredTotal = filter == null
        ? totalSpent
        : expenses
            .where((e) => e.category == filter)
            .fold(0.0, (sum, e) => sum + e.amount);

    final hasBudget = budget != null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: hasBudget
            ? null
            : () {
                // Navigate to set monthly budget
                Navigator.pushNamed(context, AppConstants.budget);
              },
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
                    const SizedBox(height: 6),
                    if (!hasBudget) ...[
                      Row(
                        children: [
                          const Icon(Icons.info_outline,
                              size: 16, color: Colors.blueGrey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No monthly budget set. Tap to set one.',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Text('Budget: \$${budget.amount.toStringAsFixed(2)}'),
                      const SizedBox(height: 4),
                      Text(
                        'Remaining: ${remaining < 0 ? '-\$${remaining.abs().toStringAsFixed(2)}' : '\$${remaining.toStringAsFixed(2)}'}',
                        style: TextStyle(
                          color: remaining < 0 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ],
                ),
              ),

              // Right side: settings button
              IconButton(
                key: const Key('balance_settings_button'),
                tooltip: 'Budget settings',
                onPressed: () {
                  Navigator.pushNamed(context, AppConstants.budget);
                },
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}