import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/models/expense.dart';

class ChartsScreen extends StatefulWidget {
  final List<Expense> expenses;
  const ChartsScreen({super.key, required this.expenses});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  DateTimeRange? _selectedRange;
  Map<String, double> _filteredData = {};
  late List<Color> _colors;

  @override
  void initState() {
    super.initState();
    _selectedRange = null;
    _filterData();
    _colors = _getColors(_filteredData.length);
  }

  void _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: _selectedRange,
    );
    if (picked != null) {
      setState(() {
        _selectedRange = picked;
        _fromDate = picked.start;
        _toDate = picked.end;
        _filterData();
      });
    }
  }

  void _filterData() {
    final from = _fromDate;
    final to = _toDate;
    final filtered = widget.expenses.where((e) {
      final expenseDate = DateTime(e.date.year, e.date.month, e.date.day);
      if (from != null &&
          expenseDate.isBefore(DateTime(from.year, from.month, from.day)))
        return false;
      if (to != null &&
          expenseDate.isAfter(DateTime(to.year, to.month, to.day)))
        return false;
      return true;
    });
    final Map<String, double> data = {};
    for (final e in filtered) {
      data[e.category] = (data[e.category] ?? 0) + e.amount;
    }
    _filteredData = data;
    _colors = _getColors(_filteredData.length);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    String rangeLabel;
    if (_selectedRange == null) {
      rangeLabel = 'Select Date Range';
    } else {
      rangeLabel =
          '${dateFormat.format(_selectedRange!.start)} - ${dateFormat.format(_selectedRange!.end)}';
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Expense Chart')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(rangeLabel),
                  onPressed: _pickDateRange,
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: SimplePieChart(data: _filteredData, colors: _colors),
            ),
          ),
          if (_filteredData.isNotEmpty)
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    for (int i = 0; i < _filteredData.length; i++)
                      _LegendItem(
                        color: _colors[i % _colors.length],
                        label: _filteredData.keys.elementAt(i),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Color> _getColors(int count) {
    return [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.cyan,
    ];
  }
}

class SimplePieChart extends StatelessWidget {
  final Map<String, double> data;
  final double size;
  final List<Color>? colors;
  const SimplePieChart(
      {super.key, required this.data, this.size = 200, this.colors});

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(0.0, (sum, value) => sum + value);
    if (total == 0) return Container();

    return CustomPaint(
      size: Size(size, size),
      painter: _PieChartPainter(data: data, total: total, colors: colors),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final Map<String, double> data;
  final double total;
  final List<Color>? colors;
  _PieChartPainter({required this.data, required this.total, this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final colorList = colors ?? _getColors(data.length);
    double startAngle = -90 * (3.14159 / 180); // Start from top
    int colorIndex = 0;
    data.forEach((category, value) {
      final sweepAngle = (value / total) * 360 * (3.14159 / 180);
      final paint = Paint()
        ..color = colorList[colorIndex % colorList.length]
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
      colorIndex++;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

List<Color> _getColors(int count) {
  return [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.teal,
    Colors.amber,
    Colors.cyan,
  ];
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}