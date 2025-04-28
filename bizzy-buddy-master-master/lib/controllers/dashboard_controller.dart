import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/expense.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Provide streams of the data for real-time updates
final salesStreamProvider = StreamProvider<List<Sale>>((ref) {
  final controller = ref.watch(dashboardControllerProvider);
  return controller.salesStream;
});

final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final controller = ref.watch(dashboardControllerProvider);
  return controller.productsStream;
});

final expensesStreamProvider = StreamProvider<List<Expense>>((ref) {
  final controller = ref.watch(dashboardControllerProvider);
  return controller.expensesStream;
});

final dashboardControllerProvider = Provider((ref) => DashboardController());

class DashboardController {
  // Stream controllers for real-time data
  final _salesStreamController = StreamController<List<Sale>>.broadcast();
  final _productsStreamController = StreamController<List<Product>>.broadcast();
  final _expensesStreamController = StreamController<List<Expense>>.broadcast();

  // Expose streams
  Stream<List<Sale>> get salesStream => _salesStreamController.stream;
  Stream<List<Product>> get productsStream => _productsStreamController.stream;
  Stream<List<Expense>> get expensesStream => _expensesStreamController.stream;

  // Hive box listeners - making them nullable to avoid LateInitializationError
  ValueListenable<Box<Sale>>? _salesBoxListenable;
  ValueListenable<Box<Product>>? _productsBoxListenable;
  ValueListenable<Box<Expense>>? _expensesBoxListenable;

  // State persistence
  Box? _dashboardStateBox;
  static const String _lastAnalyticsKey = 'last_analytics';
  static const String _lastSalesSummaryKey = 'last_sales_summary';
  static const String _lastCategoryPerformanceKey = 'last_category_performance';

  // Flag to track initialization
  bool _isInitialized = false;
  bool _isInitializing = false;

  DashboardController() {
    _initialize();
  }

  Future<void> _initialize() async {
    // Prevent multiple initializations
    if (_isInitialized || _isInitializing) {
      debugPrint(
          'Dashboard controller already initialized or initializing - skipping');
      return;
    }

    _isInitializing = true;

    try {
      await _initStatePersistence();
      await _initStreams();
      _isInitialized = true;
      debugPrint('DashboardController initialized successfully');
    } catch (e) {
      debugPrint('Error initializing DashboardController: $e');
      _isInitializing = false;
      // Retry initialization after a delay
      Future.delayed(const Duration(seconds: 2), _initialize);
    }

    _isInitializing = false;
  }

  Future<void> _initStatePersistence() async {
    try {
      _dashboardStateBox = await Hive.openBox('dashboard_state');
      debugPrint('Dashboard state box initialized successfully');
    } catch (e) {
      debugPrint('Error initializing dashboard state box: $e');
      // Retry opening the box
      await Future.delayed(const Duration(seconds: 1));
      _dashboardStateBox = await Hive.openBox('dashboard_state');
    }
  }

  Future<void> _initStreams() async {
    try {
      // Only initialize if not already initialized
      if (_salesBoxListenable == null) {
        _salesBoxListenable = Hive.box<Sale>('sales').listenable();
        _salesBoxListenable?.addListener(_updateSalesStream);
      }

      if (_productsBoxListenable == null) {
        _productsBoxListenable = Hive.box<Product>('products').listenable();
        _productsBoxListenable?.addListener(_updateProductsStream);
      }

      if (_expensesBoxListenable == null) {
        _expensesBoxListenable = Hive.box<Expense>('expenses').listenable();
        _expensesBoxListenable?.addListener(_updateExpensesStream);
      }

      // Initial update
      _updateSalesStream();
      _updateProductsStream();
      _updateExpensesStream();
    } catch (e) {
      debugPrint('Error initializing streams: $e');
      rethrow;
    }
  }

  void _updateSalesStream() {
    try {
      final salesBox = Hive.box<Sale>('sales');
      _salesStreamController.add(salesBox.values.toList());
    } catch (e) {
      debugPrint('Error updating sales stream: $e');
    }
  }

  void _updateProductsStream() {
    try {
      final productsBox = Hive.box<Product>('products');
      _productsStreamController.add(productsBox.values.toList());
    } catch (e) {
      debugPrint('Error updating products stream: $e');
    }
  }

  void _updateExpensesStream() {
    try {
      final expensesBox = Hive.box<Expense>('expenses');
      _expensesStreamController.add(expensesBox.values.toList());
    } catch (e) {
      debugPrint('Error updating expenses stream: $e');
    }
  }

  // Save analytics state
  Future<void> saveAnalyticsState(Map<String, dynamic> analytics) async {
    if (!_isInitialized) {
      debugPrint('DashboardController not initialized, retrying save...');
      await _initialize();
    }

    try {
      await _dashboardStateBox?.put('dashboard_state', analytics);
      debugPrint('Analytics state saved successfully');
    } catch (e) {
      debugPrint('Error saving analytics state: $e');
      // Retry saving after a delay
      await Future.delayed(const Duration(seconds: 1));
      await saveAnalyticsState(analytics);
    }
  }

  // Load analytics state
  Map<String, dynamic>? loadAnalyticsState() {
    if (!_isInitialized) {
      debugPrint('DashboardController not initialized, retrying load...');
      _initialize();
      return null;
    }

    try {
      return _dashboardStateBox?.get('dashboard_state');
    } catch (e) {
      debugPrint('Error loading analytics state: $e');
      return null;
    }
  }

  // Save sales summary state
  Future<void> saveSalesSummaryState(Map<String, dynamic> summary) async {
    if (!_isInitialized) {
      debugPrint('DashboardController not initialized, retrying save...');
      await _initialize();
    }

    try {
      await _dashboardStateBox?.put('last_sales_summary', summary);
      debugPrint('Sales summary state saved successfully');
    } catch (e) {
      debugPrint('Error saving sales summary state: $e');
      // Retry saving after a delay
      await Future.delayed(const Duration(seconds: 1));
      await saveSalesSummaryState(summary);
    }
  }

  // Load sales summary state
  Map<String, dynamic>? loadSalesSummaryState() {
    if (!_isInitialized) {
      debugPrint('DashboardController not initialized, retrying load...');
      _initialize();
      return null;
    }

    try {
      return _dashboardStateBox?.get('last_sales_summary');
    } catch (e) {
      debugPrint('Error loading sales summary state: $e');
      return null;
    }
  }

  // Save category performance state
  Future<void> saveCategoryPerformanceState(
      Map<String, double> performance) async {
    if (!_isInitialized) {
      debugPrint('DashboardController not initialized, retrying save...');
      await _initialize();
    }

    try {
      await _dashboardStateBox?.put('last_category_performance', performance);
      debugPrint('Category performance state saved successfully');
    } catch (e) {
      debugPrint('Error saving category performance state: $e');
      // Retry saving after a delay
      await Future.delayed(const Duration(seconds: 1));
      await saveCategoryPerformanceState(performance);
    }
  }

  // Load category performance state
  Map<String, double>? loadCategoryPerformanceState() {
    if (!_isInitialized) {
      debugPrint('DashboardController not initialized, retrying load...');
      _initialize();
      return null;
    }

    try {
      return _dashboardStateBox?.get('last_category_performance');
    } catch (e) {
      debugPrint('Error loading category performance state: $e');
      return null;
    }
  }

  void dispose() {
    _salesBoxListenable?.removeListener(_updateSalesStream);
    _productsBoxListenable?.removeListener(_updateProductsStream);
    _expensesBoxListenable?.removeListener(_updateExpensesStream);
    _salesStreamController.close();
    _productsStreamController.close();
    _expensesStreamController.close();
  }

  // Analytics Methods
  Future<Map<String, dynamic>> getAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
  }) async {
    try {
      debugPrint('Starting getAnalytics with dynamic processing...');
      final salesBox = Hive.box<Sale>('sales');
      final expensesBox = Hive.box<Expense>('expenses');
      final productsBox = Hive.box<Product>('products');
      final now = DateTime.now();

      // Default to last 30 days if no dates provided
      final start = startDate ?? now.subtract(const Duration(days: 30));
      final end = endDate ?? now;

      debugPrint(
          'Date range: ${start.toIso8601String()} to ${end.toIso8601String()}');

      // Process all data in parallel
      final results = await Future.wait([
        // Process sales
        Future(() {
          debugPrint('Processing sales in parallel...');
          return salesBox.values.where((sale) {
            try {
              final saleDate = DateTime(
                sale.date.year,
                sale.date.month,
                sale.date.day,
              );
              final startDate = DateTime(start.year, start.month, start.day);
              final endDate = DateTime(end.year, end.month, end.day);

              final dateInRange = (saleDate.isAfter(startDate) ||
                      saleDate.isAtSameMomentAs(startDate)) &&
                  (saleDate.isBefore(endDate) ||
                      saleDate.isAtSameMomentAs(endDate));

              if (category == null || category == 'All') return dateInRange;

              final product = productsBox.values.firstWhere(
                (p) => p.id == sale.productId,
                orElse: () => Product(
                  id: '',
                  name: 'Unknown',
                  price: 0,
                  quantity: 0,
                  category: 'Uncategorized',
                  description: null,
                  createdAt: DateTime.now(),
                ),
              );

              return dateInRange && product.category == category;
            } catch (e) {
              debugPrint('Error filtering sale: $e');
              return false;
            }
          }).toList();
        }),

        // Process expenses
        Future(() {
          debugPrint('Processing expenses in parallel...');
          return expensesBox.values.where((expense) {
            try {
              final expenseDate = DateTime(
                expense.date.year,
                expense.date.month,
                expense.date.day,
              );
              final startDate = DateTime(start.year, start.month, start.day);
              final endDate = DateTime(end.year, end.month, end.day);

              return (expenseDate.isAfter(startDate) ||
                      expenseDate.isAtSameMomentAs(startDate)) &&
                  (expenseDate.isBefore(endDate) ||
                      expenseDate.isAtSameMomentAs(endDate));
            } catch (e) {
              debugPrint('Error filtering expense: $e');
              return false;
            }
          }).toList();
        }),

        // Process products
        Future(() {
          debugPrint('Processing products in parallel...');
          return productsBox.values.toList();
        }),
      ]);

      final salesInRange = results[0] as List<Sale>;
      final expensesInRange = results[1] as List<Expense>;
      final allProducts = results[2] as List<Product>;

      debugPrint('Sales in range: ${salesInRange.length}');
      debugPrint('Expenses in range: ${expensesInRange.length}');
      debugPrint('Total products: ${allProducts.length}');

      // Process all calculations in parallel
      final calculations = await Future.wait([
        // Calculate totals and metrics
        Future(() {
          debugPrint('Processing totals and metrics...');
          final totalSales = salesInRange.fold<double>(
            0,
            (sum, sale) => sum + (sale.totalAmount ?? 0),
          );
          final totalExpenses = expensesInRange.fold<double>(
            0,
            (sum, expense) => sum + (expense.amount ?? 0),
          );
          final daysBetween = end.difference(start).inDays + 1;
          final avgDailySales = daysBetween > 0 ? totalSales / daysBetween : 0;
          final avgDailyExpenses =
              daysBetween > 0 ? totalExpenses / daysBetween : 0;
          final totalItemsSold = salesInRange.fold<int>(
            0,
            (sum, sale) => sum + (sale.quantity ?? 0),
          );
          final avgOrderValue =
              salesInRange.isNotEmpty ? totalSales / salesInRange.length : 0;

          return {
            'totalSales': totalSales,
            'totalExpenses': totalExpenses,
            'daysBetween': daysBetween,
            'avgDailySales': avgDailySales,
            'avgDailyExpenses': avgDailyExpenses,
            'totalItemsSold': totalItemsSold,
            'avgOrderValue': avgOrderValue,
          };
        }),

        // Process category data
        Future(() {
          debugPrint('Processing category data...');
          final salesByCategory = <String, double>{};
          final expensesByCategory = <String, double>{};
          final productMap = {for (var p in allProducts) p.id: p};

          // Process sales by category
          for (var sale in salesInRange) {
            final product = productMap[sale.productId] ??
                Product(
                  id: '',
                  name: 'Unknown',
                  price: 0,
                  quantity: 0,
                  category: 'Uncategorized',
                  description: null,
                  createdAt: DateTime.now(),
                );
            final category =
                product.category.isEmpty ? 'Uncategorized' : product.category;
            final amount = sale.totalAmount ?? 0;
            salesByCategory[category] =
                (salesByCategory[category] ?? 0) + amount;
          }

          // Process expenses by category
          for (var expense in expensesInRange) {
            final category =
                expense.category.isEmpty ? 'Uncategorized' : expense.category;
            final amount = expense.amount ?? 0;
            expensesByCategory[category] =
                (expensesByCategory[category] ?? 0) + amount;
          }

          return {
            'salesByCategory': salesByCategory,
            'expensesByCategory': expensesByCategory,
          };
        }),

        // Process daily data
        Future(() {
          debugPrint('Processing daily data...');
          final salesByDay = <String, double>{};
          final expensesByDay = <String, double>{};
          final dateFormat = DateFormat('yyyy-MM-dd');

          // Process sales by day
          for (var sale in salesInRange) {
            final dateKey = dateFormat.format(sale.date);
            final amount = sale.totalAmount ?? 0;
            salesByDay[dateKey] = (salesByDay[dateKey] ?? 0) + amount;
          }

          // Process expenses by day
          for (var expense in expensesInRange) {
            final dateKey = dateFormat.format(expense.date);
            final amount = expense.amount ?? 0;
            expensesByDay[dateKey] = (expensesByDay[dateKey] ?? 0) + amount;
          }

          // Find peak day
          final peakSaleDay = salesByDay.isEmpty
              ? {'date': 'No sales', 'amount': 0.0}
              : {
                  'date': salesByDay.entries
                      .reduce((a, b) => (a.value > b.value) ? a : b)
                      .key,
                  'amount': salesByDay.entries
                      .reduce((a, b) => (a.value > b.value) ? a : b)
                      .value,
                };

          return {
            'salesByDay': salesByDay,
            'expensesByDay': expensesByDay,
            'peakSaleDay': peakSaleDay,
          };
        }),
      ]);

      final metrics = calculations[0] as Map<String, dynamic>;
      final categories = calculations[1] as Map<String, dynamic>;
      final dailyData = calculations[2] as Map<String, dynamic>;

      final result = {
        'period': {
          'start': start,
          'end': end,
          'days': metrics['daysBetween'],
        },
        'sales': {
          'total': metrics['totalSales'],
          'average': metrics['avgDailySales'],
          'byCategory': categories['salesByCategory'],
          'byDay': dailyData['salesByDay'],
          'peakDay': dailyData['peakSaleDay'],
          'totalItems': metrics['totalItemsSold'],
          'avgOrderValue': metrics['avgOrderValue'],
        },
        'expenses': {
          'total': metrics['totalExpenses'],
          'average': metrics['avgDailyExpenses'],
          'byCategory': categories['expensesByCategory'],
          'byDay': dailyData['expensesByDay'],
        },
        'profit': ((metrics['totalSales'] as double?) ?? 0.0) -
            ((metrics['totalExpenses'] as double?) ?? 0.0),
      };

      debugPrint('Returning analytics data');
      return result;
    } catch (e, stackTrace) {
      debugPrint('Error in getAnalytics: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, double> _groupByCategory(Iterable<dynamic> items) {
    final Map<String, double> categoryTotals = {};
    final productsBox = Hive.box<Product>('products');

    debugPrint('Grouping by category. Number of items: ${items.length}');

    for (var item in items) {
      if (item is Sale) {
        try {
          // Find the product with proper error handling
          final product = productsBox.values.firstWhere(
            (p) => p.id == item.productId,
            orElse: () {
              debugPrint(
                  'Product not found for sale ${item.id} with productId ${item.productId}');
              return Product(
                id: '',
                name: 'Unknown Product',
                price: 0,
                quantity: 0,
                category: 'Uncategorized',
                description: null,
                createdAt: DateTime.now(),
              );
            },
          );

          final category =
              product.category.isEmpty ? 'Uncategorized' : product.category;
          final amount = item.totalAmount ?? 0;

          debugPrint('Found sale in category: $category for amount: $amount');
          categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
        } catch (e) {
          debugPrint('Error processing sale: $e');
          // Add to uncategorized instead of unknown
          final amount = item.totalAmount ?? 0;
          categoryTotals['Uncategorized'] =
              (categoryTotals['Uncategorized'] ?? 0) + amount;
        }
      } else if (item is Expense) {
        final category =
            item.category.isEmpty ? 'Uncategorized' : item.category;
        final amount = item.amount ?? 0;
        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
      }
    }

    debugPrint('Final category totals: $categoryTotals');
    return categoryTotals;
  }

  Map<String, double> _groupByDay(Iterable<dynamic> items) {
    final Map<String, double> dailyTotals = {};
    final dateFormat = DateFormat('yyyy-MM-dd');

    for (var item in items) {
      try {
        final date = item is Sale ? item.date : (item as Expense).date;
        final amount =
            item is Sale ? item.totalAmount : (item as Expense).amount;
        final dateKey = dateFormat.format(date);
        dailyTotals[dateKey] = (dailyTotals[dateKey] ?? 0) + amount;
      } catch (e) {
        debugPrint('Error processing item: $e');
        continue;
      }
    }

    return dailyTotals;
  }

  List<PieChartSectionData> getPieChartSections(Map<String, double> data) {
    if (data.isEmpty) {
      return [
        PieChartSectionData(
          value: 1,
          title: 'No Data',
          color: Colors.grey,
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ];
    }

    final total = data.values.fold<double>(0, (sum, value) => sum + value);
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
    ];

    return data.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      final colorIndex = data.keys.toList().indexOf(entry.key) % colors.length;

      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        color: colors[colorIndex],
      );
    }).toList();
  }

  // Sales Summary
  Future<Map<String, dynamic>> getSalesSummary() async {
    final salesBox = Hive.box<Sale>('sales');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    double dailyTotal = 0;
    double weeklyTotal = 0;
    double monthlyTotal = 0;
    int dailyCount = 0;
    int weeklyCount = 0;
    int monthlyCount = 0;

    for (var sale in salesBox.values) {
      final saleDate = DateTime(
        sale.date.year,
        sale.date.month,
        sale.date.day,
      );

      if (saleDate == today) {
        dailyTotal += sale.totalAmount;
        dailyCount++;
      }
      if (saleDate.isAfter(weekStart.subtract(const Duration(days: 1)))) {
        weeklyTotal += sale.totalAmount;
        weeklyCount++;
      }
      if (saleDate.isAfter(monthStart.subtract(const Duration(days: 1)))) {
        monthlyTotal += sale.totalAmount;
        monthlyCount++;
      }
    }

    return {
      'daily': {'total': dailyTotal, 'count': dailyCount},
      'weekly': {'total': weeklyTotal, 'count': weeklyCount},
      'monthly': {'total': monthlyTotal, 'count': monthlyCount},
    };
  }

  // Product Trends
  List<BarChartGroupData> getProductTrends() {
    try {
      final salesBox = Hive.box<Sale>('sales');
      final productsBox = Hive.box<Product>('products');

      debugPrint(
          'Getting product trends... Sales box length: ${salesBox.length}');

      if (salesBox.isEmpty || productsBox.isEmpty) {
        debugPrint('Sales or products box is empty');
        return [];
      }

      final Map<String, int> productSales = {};

      for (var sale in salesBox.values) {
        try {
          productSales[sale.productId] =
              (productSales[sale.productId] ?? 0) + sale.quantity;
        } catch (e) {
          debugPrint('Error processing sale for trends: $e');
        }
      }

      debugPrint('Product sales map: $productSales');

      if (productSales.isEmpty) return [];

      final sortedProducts = productSales.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      debugPrint('Sorted products length: ${sortedProducts.length}');

      final trends = List.generate(
        sortedProducts.take(5).length,
        (index) {
          try {
            // Safe lookup of product
            Product? product;
            try {
              product = productsBox.values.firstWhere(
                (p) => p.id == sortedProducts[index].key,
              );
            } catch (e) {
              debugPrint('Error finding product: $e');
              // Create a default product if not found
              product = Product(
                id: 'unknown',
                name: 'Unknown Product',
                price: 0,
                quantity: 0,
                category: 'Uncategorized',
                description: null,
                createdAt: DateTime.now(),
              );
            }

            final productName = product.name;
            debugPrint('Adding trend for product: $productName');

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: sortedProducts[index].value.toDouble(),
                  color: Colors.blue,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
              showingTooltipIndicators: [0],
            );
          } catch (e) {
            debugPrint('Error generating chart group: $e');
            // Return fallback chart group on error
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: 0,
                  color: Colors.grey,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }
        },
      );

      debugPrint('Generated ${trends.length} trend items');
      return trends;
    } catch (e, stackTrace) {
      debugPrint('Error in getProductTrends: $e');
      debugPrint('Stack trace: $stackTrace');
      return []; // Return empty list on error
    }
  }

  // Stock Alerts
  List<Product> getLowStockProducts({int threshold = 10}) {
    final productsBox = Hive.box<Product>('products');
    return productsBox.values
        .where((product) => product.quantity <= threshold)
        .toList()
      ..sort((a, b) => a.quantity.compareTo(b.quantity));
  }

  // Category Performance
  Future<Map<String, double>> getCategoryPerformance({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      debugPrint('Starting category performance calculation...');
      final salesBox = Hive.box<Sale>('sales');
      final productsBox = Hive.box<Product>('products');
      final Map<String, double> categoryTotals = {};
      final now = DateTime.now();

      // Default to last 30 days if no dates provided
      final start = startDate ?? now.subtract(const Duration(days: 30));
      final end = endDate ?? now;

      debugPrint(
          'Processing category performance for date range: ${start.toIso8601String()} to ${end.toIso8601String()}');

      // Create a map of products for faster lookups
      final productMap = {for (var p in productsBox.values) p.id: p};

      // Process sales in parallel
      final salesInRange = await Future(() {
        return salesBox.values.where((sale) {
          try {
            final saleDate = DateTime(
              sale.date.year,
              sale.date.month,
              sale.date.day,
            );
            final startDate = DateTime(start.year, start.month, start.day);
            final endDate = DateTime(end.year, end.month, end.day);

            return (saleDate.isAfter(startDate) ||
                    saleDate.isAtSameMomentAs(startDate)) &&
                (saleDate.isBefore(endDate) ||
                    saleDate.isAtSameMomentAs(endDate));
          } catch (e) {
            debugPrint('Error filtering sale: $e');
            return false;
          }
        }).toList();
      });

      debugPrint('Found ${salesInRange.length} sales in range');

      // Process categories in parallel
      await Future.wait([
        // Process sales by category
        Future(() {
          for (var sale in salesInRange) {
            try {
              final product = productMap[sale.productId] ??
                  Product(
                    id: '',
                    name: 'Unknown',
                    price: 0,
                    quantity: 0,
                    category: 'Uncategorized',
                    description: null,
                    createdAt: DateTime.now(),
                  );
              final category =
                  product.category.isEmpty ? 'Uncategorized' : product.category;
              final amount = sale.totalAmount ?? 0;
              categoryTotals[category] =
                  (categoryTotals[category] ?? 0) + amount;
            } catch (e) {
              debugPrint('Error processing sale for category: $e');
              final amount = sale.totalAmount ?? 0;
              categoryTotals['Uncategorized'] =
                  (categoryTotals['Uncategorized'] ?? 0) + amount;
            }
          }
        }),
      ]);

      debugPrint('Category totals: $categoryTotals');
      return categoryTotals;
    } catch (e, stackTrace) {
      debugPrint('Error in getCategoryPerformance: $e');
      debugPrint('Stack trace: $stackTrace');
      return {};
    }
  }

  // Search Sales
  List<Sale> searchSales({
    String? query,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
  }) {
    final salesBox = Hive.box<Sale>('sales');
    final productsBox = Hive.box<Product>('products');

    return salesBox.values.where((sale) {
      // Find the product associated with the sale
      Product? product;
      try {
        product = productsBox.values.firstWhere(
          (p) => p.id == sale.productId,
        );
      } catch (e) {
        // If product not found, skip this sale in search results
        return false;
      }

      // Check if the sale matches the search query
      bool matchesQuery = true;
      if (query != null && query.isNotEmpty) {
        final searchTerm = query.toLowerCase();
        matchesQuery = product.name.toLowerCase().contains(searchTerm) ||
            (sale.customerName?.toLowerCase().contains(searchTerm) ?? false);
      }

      // Check if the sale falls within the date range
      bool matchesDateRange = true;
      if (startDate != null) {
        matchesDateRange = matchesDateRange && sale.date.isAfter(startDate);
      }
      if (endDate != null) {
        matchesDateRange = matchesDateRange && sale.date.isBefore(endDate);
      }

      // Check if the sale amount is within the specified range
      bool matchesAmount = true;
      if (minAmount != null) {
        matchesAmount = matchesAmount && sale.totalAmount >= minAmount;
      }
      if (maxAmount != null) {
        matchesAmount = matchesAmount && sale.totalAmount <= maxAmount;
      }

      return matchesQuery && matchesDateRange && matchesAmount;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get Bar Chart data for monthly sales trend
  List<BarChartGroupData> getMonthlySalesBarChart() {
    try {
      final salesBox = Hive.box<Sale>('sales');
      final sales = salesBox.values.toList();

      // Group sales by month
      Map<String, double> monthlySales = {};
      final now = DateTime.now();

      // Get data for the last 6 months
      for (int i = 5; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        final monthKey = DateFormat('MMM yyyy').format(month);
        monthlySales[monthKey] = 0;
      }

      // Calculate sales for each month
      for (var sale in sales) {
        final saleMonth = DateFormat('MMM yyyy')
            .format(DateTime(sale.date.year, sale.date.month, 1));

        // Only include sales from the last 6 months
        if (monthlySales.containsKey(saleMonth)) {
          monthlySales[saleMonth] =
              (monthlySales[saleMonth] ?? 0) + (sale.totalAmount ?? 0);
        }
      }

      // Convert to bar chart data
      List<BarChartGroupData> result = [];
      int index = 0;

      for (var entry in monthlySales.entries) {
        result.add(
          BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: Colors.blue,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
        index++;
      }

      return result;
    } catch (e) {
      debugPrint('Error generating monthly sales bar chart: $e');
      return [];
    }
  }

  // Get Pie Chart data for product categories
  Map<String, double> getProductCategoryDistribution() {
    try {
      final productsBox = Hive.box<Product>('products');
      final products = productsBox.values.toList();

      // Count products by category
      Map<String, int> categoryCount = {};

      for (var product in products) {
        final category =
            product.category.isEmpty ? 'Uncategorized' : product.category;
        categoryCount[category] = (categoryCount[category] ?? 0) + 1;
      }

      // Convert to double values for pie chart
      Map<String, double> result = {};
      for (var entry in categoryCount.entries) {
        result[entry.key] = entry.value.toDouble();
      }

      return result;
    } catch (e) {
      debugPrint('Error generating product category distribution: $e');
      return {};
    }
  }

  // Get Pie Chart data for sales by payment method (mock data for now)
  Map<String, double> getSalesByPaymentMethod() {
    return {
      'Cash': 45.0,
      'Credit Card': 30.0,
      'UPI': 15.0,
      'Other': 10.0,
    };
  }

  // Get Bar Chart data for weekly revenue comparing current week vs last week
  List<BarChartGroupData> getWeeklyComparisonBarChart() {
    try {
      final salesBox = Hive.box<Sale>('sales');
      final sales = salesBox.values.toList();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Calculate the start of current and previous week
      final currentWeekStart =
          today.subtract(Duration(days: today.weekday - 1));
      final previousWeekStart =
          currentWeekStart.subtract(const Duration(days: 7));

      // Initialize data structures for daily totals
      Map<int, double> currentWeekData = {};
      Map<int, double> previousWeekData = {};

      // Initialize with zeros
      for (int i = 0; i < 7; i++) {
        currentWeekData[i] = 0;
        previousWeekData[i] = 0;
      }

      // Process each sale
      for (var sale in sales) {
        final saleDate =
            DateTime(sale.date.year, sale.date.month, sale.date.day);

        // Check if the sale is in the current week
        if (saleDate
                .isAfter(currentWeekStart.subtract(const Duration(days: 1))) &&
            saleDate.isBefore(currentWeekStart.add(const Duration(days: 7)))) {
          final dayIndex = saleDate.difference(currentWeekStart).inDays;
          if (dayIndex >= 0 && dayIndex < 7) {
            currentWeekData[dayIndex] =
                (currentWeekData[dayIndex] ?? 0) + (sale.totalAmount ?? 0);
          }
        }

        // Check if the sale is in the previous week
        else if (saleDate
                .isAfter(previousWeekStart.subtract(const Duration(days: 1))) &&
            saleDate.isBefore(previousWeekStart.add(const Duration(days: 7)))) {
          final dayIndex = saleDate.difference(previousWeekStart).inDays;
          if (dayIndex >= 0 && dayIndex < 7) {
            previousWeekData[dayIndex] =
                (previousWeekData[dayIndex] ?? 0) + (sale.totalAmount ?? 0);
          }
        }
      }

      // Convert to bar chart groups
      List<BarChartGroupData> result = [];

      for (int i = 0; i < 7; i++) {
        result.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: currentWeekData[i] ?? 0,
                color: Colors.blue,
                width: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              BarChartRodData(
                toY: previousWeekData[i] ?? 0,
                color: Colors.grey,
                width: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }

      return result;
    } catch (e) {
      debugPrint('Error generating weekly comparison bar chart: $e');
      return [];
    }
  }
}
