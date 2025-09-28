import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';

class ExpenseItem extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showDate;

  const ExpenseItem({
    super.key,
    required this.expense,
    this.onEdit,
    this.onDelete,
    this.showDate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        title: Text(
          '${expense.currency} ${expense.amount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(expense.category, style: const TextStyle(fontSize: 14)),
            if (showDate)
              Text(
                DateFormat('MMM dd, yyyy').format(expense.date),
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            if (expense.notes != null && expense.notes!.isNotEmpty)
              Text(expense.notes!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'edit' && onEdit != null) onEdit!();
            if (value == 'delete' && onDelete != null) onDelete!();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
                value: 'edit',
                child:
                    ListTile(leading: Icon(Icons.edit), title: Text('Edit'))),
            const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                    leading: Icon(Icons.delete), title: Text('Delete'))),
          ],
        ),
      ),
    );
  }
}