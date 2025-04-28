import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme/app_theme.dart';
import '../../controllers/dashboard_controller.dart';
import '../../models/product.dart';
import '../../models/sale.dart';

import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _salesSummary;
  DateTime? _lastLoadTime;

  @override
  void initState() {
    super.initState();
    // Initialize with default values
    _salesSummary = {
      'daily': {'total': 0.0, 'count': 0},
      'weekly': {'total': 0.0, 'count': 0},
      'monthly': {'total': 0.0, 'count': 0},
    };
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final controller = ref.read(dashboardControllerProvider);

      debugPrint('Loading dashboard data...');

      // Get fresh data
      final salesSummary = await controller
          .getSalesSummary()
          .timeout(const Duration(seconds: 5), onTimeout: () {
        debugPrint('getSalesSummary timeout');
        return {
          'daily': {'total': 0.0, 'count': 0},
          'weekly': {'total': 0.0, 'count': 0},
          'monthly': {'total': 0.0, 'count': 0},
        };
      });

      debugPrint('Sales summary loaded: $salesSummary');

      if (mounted) {
        setState(() {
          _salesSummary = salesSummary;
          _isLoading = false;
          _lastLoadTime = DateTime.now();
        });

        // Save the state
        await controller.saveSalesSummaryState(salesSummary);
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading dashboard data: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dashboard: $e'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadDashboardData,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use streams for real-time data
    final salesAsyncValue = ref.watch(salesStreamProvider);
    final productsAsyncValue = ref.watch(productsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Hi Anudeep',
              style: AppTheme.headingStyle.copyWith(fontSize: 20),
            ),
            const SizedBox(width: 8),
            const Text('🌱'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => context.go('/dashboard/employees'),
            tooltip: 'Manage Employees',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: productsAsyncValue.when(
          data: (products) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alerts Section
                  _buildAlertsCard(products),

                  // Quick Access Section
                  _buildSectionTitle('Quick Access'),
                  _buildQuickAccessCards(),
                  const SizedBox(height: 24),

                  // Eco Score and Sales Summary
                  _buildEcoScoreCard(context),
                  _buildSalesSummaryCards(),
                  const SizedBox(height: 24),

                  // Monthly Sales Bar Chart (New)
                  _buildSectionTitle('Monthly Sales Trend'),
                  _buildMonthlySalesBarChart(),
                  const SizedBox(height: 24),

                  // Product Trends
                  _buildSectionTitle('Product Trends'),
                  salesAsyncValue.when(
                    data: (sales) => _buildProductTrendsChart(sales, products),
                    loading: () => _buildShimmerChart(),
                    error: (err, stack) => _buildErrorWidget(
                      'Error loading product trends',
                      err.toString(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Weekly Comparison Chart (New)
                  _buildSectionTitle('Weekly Comparison'),
                  _buildWeeklyComparisonChart(),
                  const SizedBox(height: 24),

                  // Stock Alerts
                  _buildSectionTitle('Stock Alerts'),
                  _buildStockAlerts(products),
                  const SizedBox(height: 24),

                  // Category Performance
                  _buildSectionTitle('Category Performance'),
                  salesAsyncValue.when(
                    data: (sales) =>
                        _buildCategoryPerformanceChart(sales, products),
                    loading: () => _buildShimmerChart(),
                    error: (err, stack) => _buildErrorWidget(
                      'Error loading category performance',
                      err.toString(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Product Categories Pie Chart (New)
                  _buildSectionTitle('Product Categories'),
                  _buildCategoryDistributionPieChart(),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error loading products: $error'),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String title, String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildSalesSummaryCards() {
    if (_isLoading) {
      return _buildShimmerCards();
    }

    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            title: 'Today',
            value:
                '₹${_salesSummary?['daily']['total']?.toStringAsFixed(2) ?? '0'}',
            icon: Icons.today,
            color: AppTheme.ecoGradient.colors.first,
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .slideX(begin: -0.2, end: 0, duration: 600.ms),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _MetricCard(
            title: 'This Week',
            value:
                '₹${_salesSummary?['weekly']['total']?.toStringAsFixed(2) ?? '0'}',
            icon: Icons.calendar_view_week,
            color: AppTheme.solarGradient.colors.first,
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .slideX(begin: 0.2, end: 0, duration: 600.ms),
        ),
      ],
    );
  }

  Widget _buildEcoScoreCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.eco, color: Colors.green, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Eco Score',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 20,
              child: _AnimatedEcoProgress(
                value: 0.75,
                backgroundColor: Colors.grey[200]!,
                valueColor: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '75% CO₂ Reduction',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildShimmerCards() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTrendsChart(List<Sale> sales, List<Product> products) {
    if (sales.isEmpty || products.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No product trends available'),
          ),
        ),
      );
    }

    final controller = ref.read(dashboardControllerProvider);
    final productTrends = _getProductTrends(sales, products);

    if (productTrends.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No product trends available'),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: productTrends.isEmpty
              ? 10
              : productTrends
                      .map((group) => group.barRods.first.toY)
                      .reduce((a, b) => a > b ? a : b) *
                  1.2,
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  try {
                    if (value.toInt() >= productTrends.length) {
                      return const Text('');
                    }

                    if (products.isEmpty) {
                      return const Text('');
                    }

                    // Safe way to get product name
                    String productName = 'Item ${value.toInt() + 1}';
                    try {
                      final List<Product> matchingProducts = products
                          .where((p) => p.id == value.toString())
                          .toList();

                      if (matchingProducts.isNotEmpty) {
                        productName =
                            matchingProducts.first.name.split(' ').first;
                      }
                    } catch (e) {
                      debugPrint('Error getting product name: $e');
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        productName,
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  } catch (e) {
                    debugPrint('Error in bottom titles: $e');
                    return const Text('');
                  }
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: productTrends,
        ),
      ),
    );
  }

  List<BarChartGroupData> _getProductTrends(
      List<Sale> sales, List<Product> products) {
    try {
      if (sales.isEmpty || products.isEmpty) {
        return [];
      }

      final Map<String, int> productSales = {};

      for (var sale in sales) {
        try {
          productSales[sale.productId] =
              (productSales[sale.productId] ?? 0) + sale.quantity;
        } catch (e) {
          debugPrint('Error processing sale for trends: $e');
        }
      }

      if (productSales.isEmpty) return [];

      final sortedProducts = productSales.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final trends = List.generate(
        sortedProducts.take(5).length,
        (index) {
          try {
            // Safe lookup of product
            Product? product;
            try {
              product = products.firstWhere(
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

      return trends;
    } catch (e) {
      debugPrint('Error in getProductTrends: $e');
      return []; // Return empty list on error
    }
  }

  Widget _buildShimmerChart() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildStockAlerts(List<Product> products) {
    if (products.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No products found'),
        ),
      );
    }

    final lowStockProducts =
        products.where((product) => product.quantity < 10).toList();

    if (lowStockProducts.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No low stock alerts'),
        ),
      );
    }

    return Column(
      children: lowStockProducts.map((product) {
        final progress = product.quantity / 10; // Assuming threshold is 10
        return Card(
          child: ListTile(
            title: Text(product.name),
            subtitle: Text('${product.quantity} items remaining'),
            trailing: SizedBox(
              width: 100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    color: progress < 0.3
                        ? Colors.red
                        : progress < 0.7
                            ? Colors.orange
                            : Colors.green,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    progress < 0.3
                        ? 'Critical'
                        : progress < 0.7
                            ? 'Warning'
                            : 'Good',
                    style: TextStyle(
                      fontSize: 12,
                      color: progress < 0.3
                          ? Colors.red
                          : progress < 0.7
                              ? Colors.orange
                              : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.only(bottom: 8),
          ),
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDistributionPieChart() {
    final controller = ref.watch(dashboardControllerProvider);
    final categoryData = controller.getProductCategoryDistribution();

    if (categoryData.isEmpty) {
      return _buildEmptyDataCard("No category data available");
    }

    // Define consistent colors for categories
    final categoryColors = <String, Color>{};
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    // Assign colors to categories consistently
    int colorIndex = 0;
    for (final category in categoryData.keys) {
      categoryColors[category] = colors[colorIndex % colors.length];
      colorIndex++;
    }

    // Create pie chart sections with consistent colors
    final pieChartSections = categoryData.entries.map((entry) {
      final color = categoryColors[entry.key] ?? Colors.grey;
      return PieChartSectionData(
        value: entry.value,
        color: color,
        title: '',
        radius: 40,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 0),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(builder: (context, constraints) {
          // Make chart size responsive based on available width
          final isSmallScreen = constraints.maxWidth < 400;
          final chartHeight = isSmallScreen ? 180.0 : 220.0;
          final chartRadius = isSmallScreen ? 30.0 : 40.0;

          return Column(
            children: [
              SizedBox(
                height: chartHeight,
                child: PieChart(
                  PieChartData(
                    sections: pieChartSections,
                    sectionsSpace: 2,
                    centerSpaceRadius: chartRadius,
                    startDegreeOffset: -90,
                    // Add tooltip for better interaction
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        if (event is FlTapUpEvent &&
                            pieTouchResponse?.touchedSection != null) {
                          final section = pieTouchResponse!.touchedSection!;
                          final index = section.touchedSectionIndex;
                          final entry = categoryData.entries.elementAt(index);
                          final percentage = (entry.value /
                                  categoryData.values.reduce((a, b) => a + b) *
                                  100)
                              .toStringAsFixed(1);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${entry.key}: ${entry.value.toInt()} products ($percentage%)',
                                style: const TextStyle(color: Colors.white),
                              ),
                              duration: const Duration(seconds: 2),
                              backgroundColor: categoryColors[entry.key],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children:
                    _buildLegendItemsWithColors(categoryData, categoryColors),
              ),
            ],
          );
        }),
      ),
    );
  }

  List<Widget> _buildLegendItemsWithColors(
      Map<String, double> data, Map<String, Color> categoryColors) {
    final total = data.values.fold<double>(0, (sum, value) => sum + value);

    return data.entries.map((entry) {
      final color = categoryColors[entry.key] ?? Colors.grey;
      final percentage = (entry.value / total * 100).toStringAsFixed(1);

      return _buildLegendItem("${entry.key} ($percentage%)", color);
    }).toList();
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMonthlySalesBarChart() {
    final controller = ref.watch(dashboardControllerProvider);
    final monthlyData = controller.getMonthlySalesBarChart();

    if (monthlyData.isEmpty) {
      return _buildEmptyDataCard("No monthly sales data available");
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(builder: (context, constraints) {
          // Adjust chart height based on available width
          final chartHeight = constraints.maxWidth < 400 ? 180.0 : 200.0;
          final textSize = constraints.maxWidth < 400 ? 9.0 : 12.0;

          return SizedBox(
            height: chartHeight,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: monthlyData.isEmpty
                    ? 10
                    : monthlyData
                            .map((group) => group.barRods.first.toY)
                            .reduce((a, b) => a > b ? a : b) *
                        1.2,
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= monthlyData.length) {
                          return const Text('');
                        }

                        // Get the month label from the controller
                        final now = DateTime.now();
                        final month = DateTime(
                            now.year, now.month - (5 - value.toInt()), 1);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('MMM').format(month),
                            style: TextStyle(fontSize: textSize),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: constraints.maxWidth < 400 ? 30 : 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '₹${value.toInt()}',
                          style: TextStyle(fontSize: textSize),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: monthlyData.map((group) {
                  // Adjust bar width based on screen size
                  final barWidth = constraints.maxWidth < 400 ? 12.0 : 16.0;
                  return BarChartGroupData(
                    x: group.x,
                    barRods: [
                      BarChartRodData(
                        toY: group.barRods.first.toY,
                        color: Colors.blue,
                        width: barWidth,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWeeklyComparisonChart() {
    final controller = ref.watch(dashboardControllerProvider);
    final weeklyData = controller.getWeeklyComparisonBarChart();

    if (weeklyData.isEmpty) {
      return _buildEmptyDataCard("No weekly comparison data available");
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 400;
          final chartHeight = isSmallScreen ? 180.0 : 200.0;
          final textSize = isSmallScreen ? 9.0 : 12.0;
          final legendSpacing = isSmallScreen ? 8.0 : 16.0;

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem("This Week", Colors.blue),
                  SizedBox(width: legendSpacing),
                  _buildLegendItem("Last Week", Colors.grey),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: chartHeight,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: weeklyData.isEmpty
                        ? 10
                        : weeklyData
                                .map((group) => group.barRods
                                    .map((rod) => rod.toY)
                                    .reduce((a, b) => a > b ? a : b))
                                .reduce((a, b) => a > b ? a : b) *
                            1.2,
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = [
                              'Mon',
                              'Tue',
                              'Wed',
                              'Thu',
                              'Fri',
                              'Sat',
                              'Sun'
                            ];
                            final index = value.toInt();
                            if (index >= 0 && index < days.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  days[index],
                                  style: TextStyle(fontSize: textSize),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: isSmallScreen ? 30 : 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '₹${value.toInt()}',
                              style: TextStyle(fontSize: textSize),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: weeklyData.map((group) {
                      // Adjust bar width based on screen size
                      final barWidth = isSmallScreen ? 6.0 : 8.0;
                      return BarChartGroupData(
                        x: group.x,
                        barRods: [
                          BarChartRodData(
                            toY: group.barRods[0].toY,
                            color: Colors.blue,
                            width: barWidth,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          BarChartRodData(
                            toY: group.barRods[1].toY,
                            color: Colors.grey,
                            width: barWidth,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildEmptyDataCard(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            message,
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPerformanceChart(
      List<Sale> sales, List<Product> products) {
    final categoryPerformance = _calculateCategoryPerformance(sales, products);

    if (categoryPerformance.isEmpty) {
      return _buildEmptyDataCard("No category performance data available");
    }

    // Define consistent colors for categories
    final categoryColors = <String, Color>{};
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    // Assign colors to categories consistently
    int colorIndex = 0;
    for (final category in categoryPerformance.keys) {
      categoryColors[category] = colors[colorIndex % colors.length];
      colorIndex++;
    }

    // Create pie chart sections with consistent colors
    final pieChartSections = categoryPerformance.entries.map((entry) {
      final color = categoryColors[entry.key] ?? Colors.grey;
      return PieChartSectionData(
        value: entry.value,
        color: color,
        title: '',
        radius: 40,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 0),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(builder: (context, constraints) {
          // Make chart size responsive based on available width
          final isSmallScreen = constraints.maxWidth < 400;
          final chartHeight = isSmallScreen ? 180.0 : 220.0;
          final chartRadius = isSmallScreen ? 30.0 : 40.0;

          return Column(
            children: [
              SizedBox(
                height: chartHeight,
                child: PieChart(
                  PieChartData(
                    sections: pieChartSections,
                    sectionsSpace: 2,
                    centerSpaceRadius: chartRadius,
                    startDegreeOffset: -90,
                    // Add tooltip for better interaction
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        if (event is FlTapUpEvent &&
                            pieTouchResponse?.touchedSection != null) {
                          final section = pieTouchResponse!.touchedSection!;
                          final index = section.touchedSectionIndex;
                          final entry =
                              categoryPerformance.entries.elementAt(index);
                          final percentage = (entry.value /
                                  categoryPerformance.values
                                      .reduce((a, b) => a + b) *
                                  100)
                              .toStringAsFixed(1);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${entry.key}: ₹${entry.value.toStringAsFixed(2)} ($percentage%)',
                                style: const TextStyle(color: Colors.white),
                              ),
                              duration: const Duration(seconds: 2),
                              backgroundColor: categoryColors[entry.key],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _buildLegendItemsWithColors(
                    categoryPerformance, categoryColors),
              ),
            ],
          );
        }),
      ),
    );
  }

  Map<String, double> _calculateCategoryPerformance(
      List<Sale> sales, List<Product> products) {
    final Map<String, double> categoryTotals = {};

    for (var sale in sales) {
      try {
        Product? product;
        try {
          product = products.firstWhere(
            (p) => p.id == sale.productId,
            orElse: () => throw Exception('Product not found'),
          );
        } catch (e) {
          debugPrint('Product not found for sale with ID: ${sale.id}');
          continue;
        }

        final category =
            product.category.isEmpty ? 'Uncategorized' : product.category;
        categoryTotals[category] =
            (categoryTotals[category] ?? 0) + sale.totalAmount;
      } catch (e) {
        debugPrint('Error processing sale for category performance: $e');
      }
    }

    return categoryTotals;
  }

  // Add new widget to display alerts on the dashboard
  Widget _buildAlertsCard(List<Product> products) {
    final lowStockProducts =
        products.where((p) => p.quantity <= 10 && p.quantity > 0).toList();
    final outOfStockProducts = products.where((p) => p.quantity <= 0).toList();

    if (lowStockProducts.isEmpty && outOfStockProducts.isEmpty) {
      return const SizedBox(); // No alerts to show
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.7),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  'Alerts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (outOfStockProducts.isNotEmpty)
              _buildAlertItem(
                'Out of Stock',
                '${outOfStockProducts.length} products are out of stock',
                Icons.inventory_2_outlined,
                onTap: () => _showProductsDialog(
                    outOfStockProducts, 'Out of Stock Products'),
              ),
            if (outOfStockProducts.isNotEmpty && lowStockProducts.isNotEmpty)
              const Divider(),
            if (lowStockProducts.isNotEmpty)
              _buildAlertItem(
                'Low Stock',
                '${lowStockProducts.length} products are running low',
                Icons.trending_down,
                onTap: () =>
                    _showProductsDialog(lowStockProducts, 'Low Stock Products'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(String title, String message, IconData icon,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.onErrorContainer),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                  ),
                  Text(
                    message,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ],
        ),
      ),
    );
  }

  void _showProductsDialog(List<Product> products, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text(product.name),
                subtitle: Text('Quantity: ${product.quantity}'),
                trailing: Text('₹${product.price}'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/products'); // Navigate to products screen
            },
            child: const Text('Go to Products'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCards() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Employee Management Card
          _buildQuickAccessCard(
            title: 'Employees',
            icon: Icons.people,
            color: Colors.indigo,
            onTap: () => context.go('/dashboard/employees'),
          ),
          // Add more quick access cards as needed
          _buildQuickAccessCard(
            title: 'Inventory',
            icon: Icons.inventory,
            color: Colors.orange,
            onTap: () => context.go('/products'),
          ),
          _buildQuickAccessCard(
            title: 'Audio Rooms',
            icon: Icons.headset,
            color: Colors.green,
            onTap: () => context.go('/audio-rooms'),
          ),
          _buildQuickAccessCard(
            title: 'Analytics',
            icon: Icons.analytics,
            color: Colors.purple,
            onTap: () => context.go('/analytics'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(right: 16),
      color: color.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedEcoProgress extends StatefulWidget {
  final double value;
  final Color backgroundColor;
  final Color valueColor;

  const _AnimatedEcoProgress({
    required this.value,
    required this.backgroundColor,
    required this.valueColor,
  });

  @override
  State<_AnimatedEcoProgress> createState() => _AnimatedEcoProgressState();
}

class _AnimatedEcoProgressState extends State<_AnimatedEcoProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return LinearProgressIndicator(
          value: _animation.value,
          backgroundColor: widget.backgroundColor,
          valueColor: AlwaysStoppedAnimation<Color>(widget.valueColor),
          minHeight: 20,
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }
}
