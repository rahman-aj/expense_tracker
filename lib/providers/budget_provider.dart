import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/budget.dart';
import '../services/storage_service.dart';
import './expense_provider.dart';
import './storage_provider.dart';

class BudgetNotifier extends StateNotifier<MonthlyBudget?> {
  final StorageService _storageService;

  BudgetNotifier(this._storageService) : super(null) {
    _loadCurrentBudget();
  }

  Future<void> _loadCurrentBudget() async {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    state = _storageService.getBudget(currentMonth);
  }

  Future<void> setBudget(double amount, DateTime month) async {
    final budget = MonthlyBudget(amount: amount, month: month);
    await _storageService.setBudget(budget);
    state = budget;
  }

  Future<void> loadBudget(DateTime month) async {
    state = _storageService.getBudget(month);
  }
}

final budgetProvider =
    StateNotifierProvider<BudgetNotifier, MonthlyBudget?>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return BudgetNotifier(storageService);
});

/// Reads the current month’s budget directly
final currentMonthBudgetProvider = Provider<MonthlyBudget?>(
  (ref) => ref.watch(budgetProvider),
);

/// Remaining budget for the current month
final remainingBudgetProvider = Provider<double>((ref) {
  final budget = ref.watch(currentMonthBudgetProvider);
  final totalSpent = ref.watch(totalSpentProvider);
  return budget == null ? 0.0 : budget.amount - totalSpent;
});

/// Budget usage progress (0.0 → 1.0)
final budgetProgressProvider = Provider<double>((ref) {
  final budget = ref.watch(currentMonthBudgetProvider);
  final totalSpent = ref.watch(totalSpentProvider);

  if (budget == null || budget.amount == 0) return 0.0;
  return (totalSpent / budget.amount).clamp(0.0, 1.0);
});