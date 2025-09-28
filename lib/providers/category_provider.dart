import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/category.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>(
  (ref) => ApiService(
      baseUrl: "https://media.halogen.my"), // TODO: move to constants
);

final categoryProvider = FutureProvider<List<ExpenseCategory>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  final box = await Hive.openBox<ExpenseCategory>('categoriesBox');

  // Use cache if available
  final cached = box.values.toList();
  if (cached.isNotEmpty) {
    // Refresh in background, don’t block UI
    unawaited(() async {
      try {
        final fresh = await apiService.getCategories();
        await box.clear();
        await box.addAll(fresh);
      } catch (_) {
        // ignore API refresh errors silently
      }
    }());
    return cached;
  }

  // Otherwise, fetch from API
  final fresh = await apiService.getCategories();
  await box.clear();
  await box.addAll(fresh);
  return fresh;
});