import 'package:flutter_riverpod/flutter_riverpod.dart';
import './expense_provider.dart';

/// Aggregates expenses by category for charting
final chartDataProvider = Provider<Map<String, double>>((ref) {
  final expenses = ref.watch(expenseProvider);

  return {
    for (final expense in expenses)
      expense.category: (expenses
          .where((e) => e.category == expense.category)
          .fold(0.0, (sum, e) => sum + e.amount))
  };
});