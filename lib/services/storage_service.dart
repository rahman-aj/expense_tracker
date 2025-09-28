import 'package:hive/hive.dart';
import '../models/expense.dart';
import '../models/budget.dart';

class StorageService {
  static const String expensesBox = 'expenses';
  static const String budgetBox = 'budget';

  Future<void> init() async {
    await Hive.openBox<Expense>(expensesBox);
    await Hive.openBox<MonthlyBudget>(budgetBox);
  }

  // Expense operations
  Future<void> saveExpense(Expense expense) async {
    final box = Hive.box<Expense>(expensesBox);
    await box.put(expense.id, expense);
  }

  List<Expense> getExpenses() {
    final box = Hive.box<Expense>(expensesBox);
    return box.values.toList();
  }

  Future<void> deleteExpense(String id) async {
    final box = Hive.box<Expense>(expensesBox);
    await box.delete(id);
  }

  Future<void> updateExpense(Expense expense) async {
    final box = Hive.box<Expense>(expensesBox);
    await box.put(expense.id, expense);
  }

  // Budget operations
  Future<void> setBudget(MonthlyBudget budget) async {
    final box = Hive.box<MonthlyBudget>(budgetBox);
    final monthKey = '${budget.month.year}-${budget.month.month}';
    await box.put(monthKey, budget);
  }

  MonthlyBudget? getBudget(DateTime month) {
    final box = Hive.box<MonthlyBudget>(budgetBox);
    final monthKey = '${month.year}-${month.month}';
    return box.get(monthKey);
  }
}