import 'package:expense_tracker/models/budget.dart';
import 'package:expense_tracker/models/category.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final storageInitializerProvider = FutureProvider<void>((ref) async {
  await Hive.initFlutter();

  Hive.registerAdapter(MonthlyBudgetAdapter());
  Hive.registerAdapter(ExpenseCategoryAdapter());
  Hive.registerAdapter(ExpenseAdapter());

  final storageService = ref.read(storageServiceProvider);
  await storageService.init();
});