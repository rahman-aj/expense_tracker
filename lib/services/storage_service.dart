import 'package:hive/hive.dart';
import '../models/expense.dart';

class StorageService {
  static const String expensesBox = 'expenses';
  static const String budgetBox = 'budget';

  Future<void> init() async {
    await Hive.openBox<Expense>(expensesBox);
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
}