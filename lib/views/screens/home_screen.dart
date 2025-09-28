import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/expense_provider.dart';
import '../../providers/category_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/expense_list.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            tooltip: 'Filter expenses',
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, ref),
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final _expenses = ref.watch(expenseProvider); // triggers rebuilds
          final filter = ref.read(expenseProvider.notifier).filterCategory;
          return Column(
            children: [
              BalanceCard(),
              if (filter != null)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Chip(
                        label: Text('Category: $filter'),
                        deleteIcon: const Icon(Icons.clear),
                        onDeleted: () =>
                            ref.read(expenseProvider.notifier).clearFilter(),
                        backgroundColor: Colors.blue.shade100,
                        labelStyle: const TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              const Expanded(child: ExpenseList()),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Expense',
        onPressed: () { /*TODO: navigate to add expense screen*/ },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    final expenseNotifier = ref.read(expenseProvider.notifier);
    final categoriesAsync = ref.watch(categoryProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Category'),
        content: categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => const Text('Error loading categories'),
          data: (categories) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (categories.isEmpty)
                    const Text('No categories available')
                  else
                    Column(
                      children: [
                        ...categories.map((category) => ListTile(
                              dense: true,
                              title: Text(category.name),
                              onTap: () {
                                expenseNotifier.setFilter(category.name);
                                Navigator.pop(context);
                              },
                            )),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}