import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/budget_provider.dart';
import '../../providers/expense_provider.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  final _budgetController = TextEditingController();
  String _selectedCurrency = 'USD';
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(budgetProvider.notifier).loadBudget(_selectedMonth);
    });
  }

  @override
  Widget build(BuildContext context) {
    final budget = ref.watch(budgetProvider);
    final totalSpent = ref.watch(totalSpentProvider);
    final remainingBudget = ref.watch(remainingBudgetProvider);
    final budgetProgress = ref.watch(budgetProgressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Budget')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month Picker
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select Month',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      ListTile(
                        title: Text(
                            DateFormat('MMMM yyyy').format(_selectedMonth)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final picked = await _showMonthYearPicker(
                              context, _selectedMonth);
                          if (picked != null) {
                            setState(() => _selectedMonth = picked);
                            ref
                                .read(budgetProvider.notifier)
                                .loadBudget(_selectedMonth);
                            _budgetController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Budget Input
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Set Budget',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _budgetController,
                        decoration: InputDecoration(
                          labelText: 'Budget Amount',
                          border: const OutlineInputBorder(),
                          prefixText: _selectedCurrency.isNotEmpty
                              ? '$_selectedCurrency '
                              : null,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                      const SizedBox(height: 16),

                      // Currency Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCurrency,
                        decoration: const InputDecoration(
                          labelText: 'Currency',
                          border: OutlineInputBorder(),
                        ),
                        items: ['USD', 'EUR', 'MYR', 'JPY']
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCurrency = value!;
                          });
                        },
                      ),

                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _setBudget,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          child: Text('Set Budget'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Budget Overview
              if (budget != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Budget Overview',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 16),
                        _buildBudgetItem('Monthly Budget',
                            '$_selectedCurrency ${budget.amount.toStringAsFixed(2)}'),
                        _buildBudgetItem('Total Spent',
                            '$_selectedCurrency ${totalSpent.toStringAsFixed(2)}'),
                        _buildBudgetItem(
                          'Remaining',
                          '$_selectedCurrency ${remainingBudget < 0 ? '-${remainingBudget.abs().toStringAsFixed(2)}' : remainingBudget.toStringAsFixed(2)}',
                          color:
                              remainingBudget >= 0 ? Colors.green : Colors.red,
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: budgetProgress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            budgetProgress > 0.8 ? Colors.red : Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(budgetProgress * 100).toStringAsFixed(1)}% of budget used',
                          style: TextStyle(
                            color:
                                budgetProgress > 0.8 ? Colors.red : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.account_balance_wallet,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(
                          'No budget set for ${DateFormat('MMMM yyyy').format(_selectedMonth)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetItem(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value,
              style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Future<DateTime?> _showMonthYearPicker(
      BuildContext context, DateTime selectedDate) async {
    int selectedYear = selectedDate.year;

    return showDialog<DateTime>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_left),
                    onPressed: () => setState(() => selectedYear--),
                  ),
                  Text('$selectedYear'),
                  IconButton(
                    icon: const Icon(Icons.arrow_right),
                    onPressed: () => setState(() => selectedYear++),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  children: List.generate(12, (index) {
                    final month = DateTime(selectedYear, index + 1);
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context, month);
                      },
                      child: Center(
                        child: Text(
                          DateFormat.MMMM().format(month),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _setBudget() {
    FocusScope.of(context).unfocus();

    if (_budgetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a budget amount')));
      return;
    }

    final amount = double.tryParse(_budgetController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid budget amount')));
      return;
    }

    ref.read(budgetProvider.notifier).setBudget(amount, _selectedMonth);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Budget for ${DateFormat('MMMM yyyy').format(_selectedMonth)} set to $_selectedCurrency ${amount.toStringAsFixed(2)}'),
      ),
    );

    _budgetController.clear();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }
}