import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../models/expense.dart';
import '../../models/sale.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _dateFormat = DateFormat('MMM d, y');
  String _selectedPeriod = '7D';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddDialog(bool isExpense) {
    showDialog(
      context: context,
      builder: (context) => _AddEntryDialog(isExpense: isExpense),
    );
  }

  List<FlSpot> _getChartData(List<dynamic> entries, bool isExpense) {
    final now = DateTime.now();
    final days = _selectedPeriod == '7D' ? 7 : 30;
    final data = List.generate(days, (index) {
      final date = now.subtract(Duration(days: days - 1 - index));
      final dayEntries = entries.where((entry) =>
          entry.date.year == date.year &&
          entry.date.month == date.month &&
          entry.date.day == date.day);

      final amount = dayEntries.fold<double>(
        0,
        (sum, entry) => sum + (isExpense ? entry.amount : entry.totalAmount),
      );

      return FlSpot(index.toDouble(), amount);
    });
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses & Sales'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Expenses'),
            Tab(text: 'Sales'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ExpenseTab(
            onAddPressed: () => _showAddDialog(true),
            selectedPeriod: _selectedPeriod,
            onPeriodChanged: (value) => setState(() => _selectedPeriod = value),
            getChartData: (entries) => _getChartData(entries, true),
          ),
          _SalesTab(
            onAddPressed: () => _showAddDialog(false),
            selectedPeriod: _selectedPeriod,
            onPeriodChanged: (value) => setState(() => _selectedPeriod = value),
            getChartData: (entries) => _getChartData(entries, false),
          ),
        ],
      ),
    );
  }
}

class _ExpenseTab extends StatelessWidget {
  final VoidCallback onAddPressed;
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;
  final List<FlSpot> Function(List<Expense>) getChartData;

  const _ExpenseTab({
    required this.onAddPressed,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.getChartData,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Expense>('expenses').listenable(),
      builder: (context, Box<Expense> box, _) {
        final expenses = box.values.toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Total: \$${expenses.fold<double>(0, (sum, e) => sum + e.amount).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: '7D', label: Text('7D')),
                      ButtonSegment(value: '30D', label: Text('30D')),
                    ],
                    selected: {selectedPeriod},
                    onSelectionChanged: (values) =>
                        onPeriodChanged(values.first),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value % 5 != 0) return const Text('');
                            final date = DateTime.now().subtract(
                              Duration(
                                  days: (selectedPeriod == '7D' ? 7 : 30) -
                                      1 -
                                      value.toInt()),
                            );
                            return Text(
                              '${date.day}/${date.month}',
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: getChartData(expenses),
                        isCurved: true,
                        color: Theme.of(context).colorScheme.primary,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenses[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        child: const Icon(
                          Icons.remove,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(expense.description),
                      subtitle: Text(
                        '${expense.category} • ${DateFormat('MMM d, y').format(expense.date)}',
                      ),
                      trailing: Text(
                        '\$${expense.amount.toStringAsFixed(2)}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SalesTab extends StatelessWidget {
  final VoidCallback onAddPressed;
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;
  final List<FlSpot> Function(List<Sale>) getChartData;

  const _SalesTab({
    required this.onAddPressed,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.getChartData,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Sale>('sales').listenable(),
      builder: (context, Box<Sale> box, _) {
        final sales = box.values.toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Total: \$${sales.fold<double>(0, (sum, s) => sum + s.totalAmount).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: '7D', label: Text('7D')),
                      ButtonSegment(value: '30D', label: Text('30D')),
                    ],
                    selected: {selectedPeriod},
                    onSelectionChanged: (values) =>
                        onPeriodChanged(values.first),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value % 5 != 0) return const Text('');
                            final date = DateTime.now().subtract(
                              Duration(
                                  days: (selectedPeriod == '7D' ? 7 : 30) -
                                      1 -
                                      value.toInt()),
                            );
                            return Text(
                              '${date.day}/${date.month}',
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: getChartData(sales),
                        isCurved: true,
                        color: Theme.of(context).colorScheme.primary,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: sales.length,
                itemBuilder: (context, index) {
                  final sale = sales[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                      title: Text('Sale #${sale.id.substring(0, 6)}'),
                      subtitle: Text(
                        '${sale.quantity} items • ${DateFormat('MMM d, y').format(sale.date)}',
                      ),
                      trailing: Text(
                        '\$${sale.totalAmount.toStringAsFixed(2)}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AddEntryDialog extends StatefulWidget {
  final bool isExpense;

  const _AddEntryDialog({required this.isExpense});

  @override
  State<_AddEntryDialog> createState() => _AddEntryDialogState();
}

class _AddEntryDialogState extends State<_AddEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (widget.isExpense) {
      final expense = Expense.create(
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        category: _categoryController.text,
        date: _date,
      );
      Hive.box<Expense>('expenses').add(expense);
    } else {
      final sale = Sale.create(
        productId: 'manual',
        quantity: int.parse(_quantityController.text),
        unitPrice: double.parse(_amountController.text),
      );
      Hive.box<Sale>('sales').add(sale);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isExpense ? 'Add Expense' : 'Add Sale'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isExpense) ...[
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a category';
                    }
                    return null;
                  },
                ),
              ] else
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a quantity';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: widget.isExpense ? 'Amount' : 'Unit Price',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Date: ${DateFormat('MMM d, y').format(_date)}',
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _date = date);
                      }
                    },
                    child: const Text('Select Date'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
