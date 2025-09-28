import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../services/storage_service.dart';
import './storage_provider.dart';

class ExpenseNotifier extends StateNotifier<List<Expense>> {
  final StorageService _storageService;
  String _sortBy = 'date';
  String? _filterCategory;
  List<Expense> _allExpenses = [];

  ExpenseNotifier(this._storageService) : super([]) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    final expenses = _storageService.getExpenses();
    _allExpenses = expenses;
    state = _applySortingAndFiltering(expenses);
  }

  List<Expense> _applySortingAndFiltering(List<Expense> expenses) {
    var filteredExpenses = expenses;

    // Apply category filter
    if (_filterCategory != null) {
      filteredExpenses = filteredExpenses
          .where((expense) => expense.category == _filterCategory)
          .toList();
    }

    // Apply sorting
    filteredExpenses.sort((a, b) {
      if (_sortBy == 'date') {
        return b.date.compareTo(a.date); // Newest first
      } else {
        return b.amount.compareTo(a.amount); // Highest amount first
      }
    });

    return filteredExpenses;
  }

  Future<void> addExpense(Expense expense) async {
    await _storageService.saveExpense(expense);
    await loadExpenses();
  }

  Future<void> deleteExpense(String id) async {
    await _storageService.deleteExpense(id);
    await loadExpenses();
  }

  Future<void> updateExpense(Expense updatedExpense) async {
    await _storageService.updateExpense(updatedExpense);
    await loadExpenses();
  }

  void setSort(String sortBy) {
    _sortBy = sortBy;
    loadExpenses();
  }

  void setFilter(String? category) {
    _filterCategory = category;
    loadExpenses();
  }

  void clearFilter() {
    _filterCategory = null;
    loadExpenses();
  }

  // Getters for filtered data
  List<Expense> getExpensesByCategory(String category) {
    return state.where((expense) => expense.category == category).toList();
  }

  double getTotalSpent() {
    return state.fold(0, (sum, expense) => sum + expense.amount);
  }

  double getSpentByCategory(String category) {
    return getExpensesByCategory(category)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  List<String> get uniqueCategories {
    return state.map((expense) => expense.category).toSet().toList();
  }

  List<Expense> get allExpenses => _allExpenses;

  String get sortMode => _sortBy;

  String? get filterCategory => _filterCategory;
}

final expenseProvider =
    StateNotifierProvider<ExpenseNotifier, List<Expense>>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return ExpenseNotifier(storageService);
});

// Provider for total spent amount
final totalSpentProvider = Provider<double>((ref) {
  final expenses =
      ref.watch(expenseProvider); // 👈 Watch the state, not the notifier
  final now = DateTime.now();
  final currentMonth = DateTime(now.year, now.month);

  final monthExpenses = expenses
      .where((expense) =>
          expense.date.year == currentMonth.year &&
          expense.date.month == currentMonth.month)
      .toList();

  return monthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
});

// Provider for expenses by specific category
final expensesByCategoryProvider =
    Provider.family<List<Expense>, String>((ref, category) {
  final expenses = ref.watch(expenseProvider);
  return expenses.where((expense) => expense.category == category).toList();
});