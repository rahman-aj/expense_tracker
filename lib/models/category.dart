import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 2)
class ExpenseCategory {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int? recommendedPercentage;

  @HiveField(2)
  final bool isFixed;

  ExpenseCategory({
    required this.name,
    this.recommendedPercentage,
    required this.isFixed,
  });

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      name: json['name'] ?? '',
      recommendedPercentage: json['recommendedPercentage'],
      isFixed: json['isFixed'] ?? false,
    );
  }
}