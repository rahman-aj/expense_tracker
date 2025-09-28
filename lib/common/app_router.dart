import 'package:flutter/material.dart';
import '../views/screens/home_screen.dart';
import '../views/screens/add_expense_screen.dart';
import '../views/screens/budget_screen.dart';
import '../views/screens/charts_screen.dart';
import '../models/expense.dart';
import 'app_constants.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppConstants.addExpense:
        return MaterialPageRoute(builder: (_) => const AddExpenseScreen());
      case AppConstants.budget:
        return MaterialPageRoute(builder: (_) => const BudgetScreen());
      case AppConstants.charts:
        final expenses = settings.arguments as List<Expense>? ?? [];
        return MaterialPageRoute(
            builder: (_) => ChartsScreen(expenses: expenses));
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Unknown Route')),
          ),
        );
    }
  }
}