import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../controllers/dashboard_controller.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'local_analysis_screen.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _analyticsData;
  String? _error;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];
  DateTime? _lastLoadTime;
  Timer? _debounceTimer;
  bool _isRefreshing = false;
  Map<String, double>? _categoryPerformance;
  Timer? _categoryUpdateTimer;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadAnalytics();
    _loadCategoryPerformance();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _categoryUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final productsAsyncValue = ref.read(productsStreamProvider);
      productsAsyncValue.whenData((products) {
        final categories = products.map((p) => p.category).toSet().toList();
        if (mounted) {
          setState(() {
            _categories = ['All', ...categories];
          });
        }
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> _loadCategoryPerformance() async {
    try {
      final controller = ref.read(dashboardControllerProvider);
      final performance = await controller.getCategoryPerformance(
        startDate: _startDate,
        endDate: _endDate,
      );

      if (mounted) {
        setState(() {
          _categoryPerformance = performance;
        });
      }
    } catch (e) {
      debugPrint('Error loading category performance: $e');
    }
  }

  void _scheduleCategoryUpdate() {
    _categoryUpdateTimer?.cancel();
    _categoryUpdateTimer = Timer(const Duration(seconds: 5), () {
      _loadCategoryPerformance();
    });
  }

  Future<void> _loadAnalytics() async {
    if (_isLoading && !_isRefreshing) {
      debugPrint('Analytics load already in progress, skipping...');
      return;
    }

    final now = DateTime.now();
    if (_lastLoadTime != null &&
        _analyticsData != null &&
        now.difference(_lastLoadTime!).inMinutes < 5 &&
        !_isRefreshing) {
      debugPrint('Analytics data is still fresh, skipping reload...');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final controller = ref.read(dashboardControllerProvider);
      debugPrint('Loading analytics data...');
      debugPrint('Start date: $_startDate');
      debugPrint('End date: $_endDate');
      debugPrint('Selected category: $_selectedCategory');

      // Load analytics and category performance in parallel
      final results = await Future.wait([
        controller.getAnalytics(
          startDate: _startDate,
          endDate: _endDate,
          category: _selectedCategory == 'All' ? null : _selectedCategory,
        ),
        controller.getCategoryPerformance(
          startDate: _startDate,
          endDate: _endDate,
        ),
      ]);

      final data = results[0];
      final categoryPerformance = results[1] as Map<String, double>;

      debugPrint('Analytics data loaded: ${data != null}');

      if (mounted) {
        setState(() {
          _analyticsData = data;
          _categoryPerformance = categoryPerformance;
          _isLoading = false;
          _isRefreshing = false;
          _lastLoadTime = now;
        });
      }

      // Schedule next category performance update
      _scheduleCategoryUpdate();
    } catch (e, stackTrace) {
      debugPrint('Error loading analytics: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  void _debouncedLoadAnalytics() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _loadAnalytics();
    });
  }

  Future<void> _refreshAnalytics() async {
    if (_isLoading) return;

    setState(() {
      _isRefreshing = true;
    });

    await _loadAnalytics();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
            dialogTheme: DialogThemeData(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      debugPrint('Date range selected: ${picked.start} to ${picked.end}');

      // Normalize dates to start/end of day to ensure proper comparison
      final normalizedStart =
          DateTime(picked.start.year, picked.start.month, picked.start.day);
      final normalizedEnd = DateTime(picked.end.year, picked.end.month,
          picked.end.day, 23, 59, 59 // Set to end of day
          );

      setState(() {
        _startDate = normalizedStart;
        _endDate = normalizedEnd;
        _lastLoadTime = null; // Force data refresh
      });

      // Use a small delay to ensure UI updates before loading
      Future.delayed(const Duration(milliseconds: 100), () {
        _loadAnalytics(); // Directly load analytics instead of debounced
      });
    }
  }

  void _selectPresetDateRange(String preset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    DateTime start;
    DateTime end = endOfDay; // Default end to today end of day

    debugPrint('Selecting preset date range: $preset');

    setState(() {
      switch (preset) {
        case 'Today':
          start = today;
          break;
        case 'Last 7 Days':
          start = today.subtract(const Duration(days: 6));
          break;
        case 'Last 30 Days':
          start = today.subtract(const Duration(days: 29));
          break;
        case 'This Month':
          start = DateTime(now.year, now.month, 1);
          break;
        case 'Last Month':
          start = DateTime(now.year, now.month - 1, 1);
          end = DateTime(now.year, now.month, 0, 23, 59, 59);
          break;
        case 'This Year':
          start = DateTime(now.year, 1, 1);
          break;
        default:
          start = today.subtract(const Duration(days: 29));
      }

      _startDate = start;
      _endDate = end;
      _lastLoadTime = null; // Force data refresh
    });

    debugPrint('Date range set to: $_startDate to $_endDate');

    // Use a small delay to ensure UI updates before loading
    Future.delayed(const Duration(milliseconds: 100), () {
      _loadAnalytics(); // Directly load analytics instead of debounced
    });
  }

  void _onCategoryChanged(String? category) {
    if (category != null) {
      setState(() {
        _selectedCategory = category;
      });
      _debouncedLoadAnalytics();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(dashboardControllerProvider);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    // Use streams for real-time updates
    final salesAsync = ref.watch(salesStreamProvider);
    final productsAsync = ref.watch(productsStreamProvider);

    // Update analytics when data changes, but only if not already loading
    salesAsync.whenData((sales) {
      if (!_isLoading && mounted) {
        _debouncedLoadAnalytics();
      }
    });

    productsAsync.whenData((products) {
      if (!_isLoading && mounted) {
        _debouncedLoadAnalytics();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDateRange,
            tooltip: 'Select Date Range',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAnalytics,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.eco),
            onPressed: () => context.go('/analytics/sustainability'),
            tooltip: 'Sustainability',
          ),
          IconButton(
            icon: const Icon(Icons.insights),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LocalAnalysisScreen(),
                ),
              );
            },
            tooltip: 'Local Data Analysis',
          ),
        ],
      ),
      body: _isLoading && !_isRefreshing
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading analytics',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          _error!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _refreshAnalytics,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : _analyticsData == null || _analyticsData!.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No data available',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Text(
                              'Start adding products and making sales\nto see analytics',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshAnalytics,
                      child: _buildAnalyticsContent(isSmallScreen),
                    ),
    );
  }

  Widget _buildAnalyticsContent(bool isSmallScreen) {
    return LayoutBuilder(builder: (context, constraints) {
      final padding = EdgeInsets.symmetric(
        horizontal: constraints.maxWidth * 0.05,
        vertical: 16,
      );

      return ListView(
        padding: padding,
        children: [
          _buildDateRangeCard(context),
          const SizedBox(height: 16),
          _buildSummaryCard(
            context,
            title: 'Sales Overview',
            total: (_analyticsData!['sales']['total'] as num).toDouble(),
            average: (_analyticsData!['sales']['average'] as num).toDouble(),
            peakDay:
                _analyticsData!['sales']['peakDay'] as Map<String, dynamic>,
            totalItems: _analyticsData!['sales']['totalItems'] as int,
            avgOrderValue:
                (_analyticsData!['sales']['avgOrderValue'] as num).toDouble(),
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 16),
          _buildLineChartCard(context, isSmallScreen),
          const SizedBox(height: 16),
          if (_analyticsData!['sales']['byCategory'] != null) ...[
            _buildPieChartCard(
              context,
              title: 'Sales by Category',
              data: _analyticsData!['sales']['byCategory']
                      as Map<String, double>? ??
                  {},
              controller: ref.watch(dashboardControllerProvider),
              isSmallScreen: isSmallScreen,
            ),
            const SizedBox(height: 16),
          ],
          _buildSummaryCard(
            context,
            title: 'Profit Overview',
            total: (_analyticsData!['profit'] as num).toDouble(),
            average: (_analyticsData!['profit'] as num).toDouble() /
                (_analyticsData!['period']['days'] as int),
            isProfit: true,
            isSmallScreen: isSmallScreen,
          ),
        ],
      );
    });
  }

  Widget _buildDateRangeCard(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.date_range,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Date Range',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            isSmallScreen
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _selectDateRange,
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Custom Range'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _selectDateRange,
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Custom Range'),
                      ),
                    ],
                  ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 8,
                children: [
                  _buildPresetButton('Today'),
                  _buildPresetButton('Last 7 Days'),
                  _buildPresetButton('Last 30 Days'),
                  _buildPresetButton('This Month'),
                  _buildPresetButton('Last Month'),
                  _buildPresetButton('This Year'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Filter by Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(
                    category,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: _onCategoryChanged,
              isExpanded: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetButton(String label) {
    bool isSelected = false;
    final now = DateTime.now();

    // Check if this preset is currently selected
    switch (label) {
      case 'Today':
        isSelected = _startDate.year == now.year &&
            _startDate.month == now.month &&
            _startDate.day == now.day;
        break;
      case 'Last 7 Days':
        final days7Ago = DateTime(now.year, now.month, now.day - 6);
        isSelected = _startDate.year == days7Ago.year &&
            _startDate.month == days7Ago.month &&
            _startDate.day == days7Ago.day;
        break;
      case 'Last 30 Days':
        final days30Ago = DateTime(now.year, now.month, now.day - 29);
        isSelected = _startDate.year == days30Ago.year &&
            _startDate.month == days30Ago.month &&
            _startDate.day == days30Ago.day;
        break;
      case 'This Month':
        isSelected = _startDate.year == now.year &&
            _startDate.month == now.month &&
            _startDate.day == 1;
        break;
      case 'Last Month':
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        isSelected = _startDate.year == lastMonth.year &&
            _startDate.month == lastMonth.month &&
            _startDate.day == 1;
        break;
      case 'This Year':
        isSelected = _startDate.year == now.year &&
            _startDate.month == 1 &&
            _startDate.day == 1;
        break;
    }

    return ElevatedButton(
      onPressed: () => _selectPresetDateRange(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: isSelected
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.primary,
        elevation: isSelected ? 2 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: Text(label),
    );
  }

  Widget _buildLineChartCard(BuildContext context, bool isSmallScreen) {
    final salesByDay = _analyticsData!['sales']['byDay'] as Map<String, double>;
    final dates = salesByDay.keys.toList()..sort();
    final values = dates.map((date) => salesByDay[date] ?? 0.0).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sales Trend',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sales Trend'),
                        content: const Text(
                          'This chart shows the daily sales trend for the selected period. '
                          'Hover over points to see exact values.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: isSmallScreen ? 1.2 : 1.8,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '₹${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < dates.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                dates[value.toInt()].split('-')[2],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        values.length,
                        (index) => FlSpot(index.toDouble(), values[index]),
                      ),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Theme.of(context).colorScheme.primary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required double total,
    required double average,
    bool isProfit = false,
    Map<String, dynamic>? peakDay,
    int? totalItems,
    double? avgOrderValue,
    bool isSmallScreen = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 16),
            isSmallScreen
                ? Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSummaryItem(
                            context,
                            title: 'Total',
                            value: total,
                            isProfit: isProfit,
                          ),
                          _buildSummaryItem(
                            context,
                            title: 'Average',
                            value: average,
                            isProfit: isProfit,
                          ),
                        ],
                      ),
                      if (peakDay != null) ...[
                        const SizedBox(height: 16),
                        _buildSummaryItem(
                          context,
                          title: 'Peak Day',
                          value: (peakDay['amount'] as num).toDouble(),
                          date: peakDay['date'] as String,
                          fullWidth: true,
                        ),
                      ],
                      if (totalItems != null || avgOrderValue != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (totalItems != null)
                              _buildSummaryItem(
                                context,
                                title: 'Items Sold',
                                value: totalItems.toDouble(),
                                isCount: true,
                              ),
                            if (avgOrderValue != null)
                              _buildSummaryItem(
                                context,
                                title: 'Avg Order',
                                value: avgOrderValue,
                              ),
                          ],
                        ),
                      ],
                    ],
                  )
                : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSummaryItem(
                            context,
                            title: 'Total',
                            value: total,
                            isProfit: isProfit,
                          ),
                          _buildSummaryItem(
                            context,
                            title: 'Average',
                            value: average,
                            isProfit: isProfit,
                          ),
                          if (peakDay != null)
                            _buildSummaryItem(
                              context,
                              title: 'Peak Day',
                              value: (peakDay['amount'] as num).toDouble(),
                              date: peakDay['date'] as String,
                            ),
                        ],
                      ),
                      if (totalItems != null || avgOrderValue != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            if (totalItems != null)
                              _buildSummaryItem(
                                context,
                                title: 'Items Sold',
                                value: totalItems.toDouble(),
                                isCount: true,
                              ),
                            if (avgOrderValue != null)
                              _buildSummaryItem(
                                context,
                                title: 'Avg Order',
                                value: avgOrderValue,
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required String title,
    required double value,
    bool isProfit = false,
    bool isCount = false,
    String? date,
    bool fullWidth = false,
  }) {
    final color = isProfit
        ? value >= 0
            ? Colors.green
            : Colors.red
        : Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: Column(
        crossAxisAlignment:
            fullWidth ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
            textAlign: fullWidth ? TextAlign.center : TextAlign.start,
          ),
          const SizedBox(height: 4),
          Text(
            date ??
                (isCount
                    ? value.toInt().toString()
                    : '₹${value.toStringAsFixed(2)}'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: fullWidth ? TextAlign.center : TextAlign.start,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard(
    BuildContext context, {
    required String title,
    required Map<String, double> data,
    required DashboardController controller,
    bool isSmallScreen = false,
  }) {
    // Check if data is empty and provide a default empty map if needed
    if (data.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
                      size: 48,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No category data available',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start making sales to see category performance',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Category Performance'),
                            content: const Text(
                              'This chart shows the distribution of sales across different product categories. '
                              'The size of each slice represents the percentage of total sales for that category.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        setState(() {
                          _categoryPerformance = null;
                        });
                        _loadCategoryPerformance();
                      },
                      tooltip: 'Refresh Category Data',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_categoryPerformance == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_categoryPerformance!.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
                      size: 48,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No category data available',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start making sales to see category performance',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final isVerySmallScreen = constraints.maxWidth < 400;
                  final chartSize = isVerySmallScreen
                      ? constraints.maxWidth * 0.8
                      : constraints.maxWidth * 0.6;

                  return Column(
                    children: [
                      Center(
                        child: SizedBox(
                          width: chartSize,
                          height: chartSize,
                          child: PieChart(
                            PieChartData(
                              sections: controller
                                  .getPieChartSections(_categoryPerformance!),
                              sectionsSpace: 2,
                              centerSpaceRadius: isVerySmallScreen ? 20 : 30,
                              startDegreeOffset: -90,
                              pieTouchData: PieTouchData(
                                touchCallback:
                                    (FlTouchEvent event, pieTouchResponse) {
                                  if (event is FlTapUpEvent) {
                                    if (pieTouchResponse?.touchedSection !=
                                        null) {
                                      final section =
                                          pieTouchResponse!.touchedSection!;
                                      final category =
                                          _categoryPerformance!.keys.elementAt(
                                              section.touchedSectionIndex);
                                      final value =
                                          _categoryPerformance![category] ??
                                              0.0;

                                      // Calculate total safely
                                      double total = 0.0;
                                      try {
                                        if (_categoryPerformance!.isNotEmpty) {
                                          total = _categoryPerformance!.values
                                              .fold(0.0, (a, b) => a + b);
                                        }
                                      } catch (e) {
                                        debugPrint(
                                            'Error calculating total: $e');
                                      }

                                      final percentage = total > 0
                                          ? (value / total * 100)
                                              .toStringAsFixed(1)
                                          : "0.0";

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              '$category: ₹${value.toStringAsFixed(2)} ($percentage%)'),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: isVerySmallScreen ? 8 : 16,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: _categoryPerformance!.entries.map((entry) {
                          // Calculate total safely
                          double total = 0.0;
                          try {
                            if (_categoryPerformance!.isNotEmpty) {
                              total = _categoryPerformance!.values
                                  .fold(0.0, (a, b) => a + b);
                            }
                          } catch (e) {
                            debugPrint('Error calculating total: $e');
                          }

                          final percentage = total > 0
                              ? (entry.value / total * 100).toStringAsFixed(1)
                              : "0.0";

                          return _buildLegendItem(
                            context,
                            title: entry.key,
                            value: entry.value,
                            total: total,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${entry.key}: ₹${entry.value.toStringAsFixed(2)} ($percentage%)'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context, {
    required String title,
    required double value,
    required double total,
    VoidCallback? onTap,
  }) {
    // Calculate percentage safely
    String percentage;
    if (total > 0) {
      percentage = (value / total * 100).toStringAsFixed(1);
    } else {
      percentage = "0.0";
    }

    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.primaries[title.hashCode % Colors.primaries.length],
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '$title ($percentage%)',
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
