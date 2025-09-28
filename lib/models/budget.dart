import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 1)
class MonthlyBudget {
  @HiveField(0)
  final double amount;

  @HiveField(1)
  final DateTime month;

  MonthlyBudget({required this.amount, required this.month});
}