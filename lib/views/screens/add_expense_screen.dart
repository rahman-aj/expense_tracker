import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import '../../providers/category_provider.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final Expense? expense;
  const AddExpenseScreen({super.key, this.expense});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final FocusNode _unfocusNode = FocusNode();

  String _selectedCategory = '';
  String _selectedCurrency = 'USD';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    if (expense != null) {
      _selectedCategory = expense.category;
      _selectedCurrency = expense.currency;
      _selectedDate = expense.date;
      _amountController.text = expense.amount.toString();
      _notesController.text = expense.notes ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryProvider);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Add Expense')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Category Dropdown
                  categoriesAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (e, s) => const Text('Error loading categories'),
                    data: (categories) {
                      if (_selectedCategory.isEmpty && categories.isNotEmpty) {
                        _selectedCategory = categories.first.name;
                      }

                      return DropdownButtonFormField<String>(
                        value: _selectedCategory.isEmpty
                            ? null
                            : _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category.name,
                            child: Row(
                              children: [Text(category.name)],
                            ),
                          );
                        }).toList(),
                        onTap: () => FocusScope.of(context).unfocus(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Amount
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      border: const OutlineInputBorder(),
                      prefixText: _selectedCurrency.isNotEmpty
                          ? '$_selectedCurrency '
                          : null,
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Currency
                  DropdownButtonFormField<String>(
                    value: _selectedCurrency,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(),
                    ),
                    items: ['USD', 'EUR', 'MYR', 'JPY']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onTap: () => FocusScope.of(context).unfocus(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCurrency = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Date picker (Date and Time)
                  ListTile(
                    title: const Text('Date'),
                    subtitle: Text(
                        DateFormat('yyyy-MM-dd – kk:mm').format(_selectedDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      final picked =
                          await _pickDateTime(context, _selectedDate);
                      FocusScope.of(context)
                          .requestFocus(_unfocusNode); // Forcefully unfocus
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Notes
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _saveExpense,
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      child: Text('Save Expense'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<DateTime?> _pickDateTime(
      BuildContext context, DateTime initialDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null) return DateTime(date.year, date.month, date.day);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      final expense = Expense(
        id: widget.expense?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        category: _selectedCategory,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        currency: _selectedCurrency,
      );

      if (widget.expense != null) {
        ref.read(expenseProvider.notifier).updateExpense(expense);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense updated successfully!')),
        );
      } else {
        ref.read(expenseProvider.notifier).addExpense(expense);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense added successfully!')),
        );
      }

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _unfocusNode.dispose();
    super.dispose();
  }
}