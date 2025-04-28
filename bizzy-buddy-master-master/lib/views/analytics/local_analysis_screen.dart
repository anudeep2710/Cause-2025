import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../models/product.dart';
import '../../models/sale.dart';
import 'package:collection/collection.dart'; // For sumBy
import 'package:intl/intl.dart';

// Provider to easily access product data (can be defined elsewhere too)
final productBoxProvider = Provider((ref) => Hive.box<Product>('products'));
final salesBoxProvider = Provider((ref) => Hive.box<Sale>('sales'));

class LocalAnalysisScreen extends ConsumerStatefulWidget {
  const LocalAnalysisScreen({super.key});

  @override
  ConsumerState<LocalAnalysisScreen> createState() =>
      _LocalAnalysisScreenState();
}

class _LocalAnalysisScreenState extends ConsumerState<LocalAnalysisScreen> {
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Data for analysis
  late List<Product> products;
  late List<Sale> sales;
  late Map<String, dynamic> analysisData;

  @override
  void initState() {
    super.initState();
    _loadData();

    // Add initial welcome message
    _messages.add(
      ChatMessage(
        text:
            "Hello! I'm your business data assistant. Ask me questions about your products, sales, inventory, or business performance!",
        isUser: false,
      ),
    );

    // Add suggested questions with more options
    _messages.add(
      ChatMessage(
        text:
            "Here are some questions you can ask:\n• How many products do I have?\n• Which products are low in stock?\n• What's my best selling product?\n• Show me my sales summary\n• What categories do I have?\n• What was my revenue last month?\n• Do I have any out of stock items?\n• What's my most expensive product?",
        isUser: false,
        isSuggestion: true,
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    final productBox = ref.read(productBoxProvider);
    final salesBox = ref.read(salesBoxProvider);

    products = productBox.values.toList();
    sales = salesBox.values.toList();

    // Pre-compute some common analysis
    analysisData = _computeAnalysisData();
  }

  Map<String, dynamic> _computeAnalysisData() {
    // Total counts
    final totalProducts = products.length;

    // Category Breakdown
    final categoryCounts = products.groupListsBy((p) => p.category);
    final categorySummary =
        categoryCounts.map((key, value) => MapEntry(key, value.length));

    // Stock Analysis
    const lowStockThreshold = 10;
    final lowStockProducts = products
        .where((p) => p.quantity <= lowStockThreshold && p.quantity > 0)
        .toList();
    final outOfStockProducts = products.where((p) => p.quantity <= 0).toList();

    // Price Analysis
    final productsSortedByPrice = List<Product>.from(products)
      ..sort((a, b) => a.price.compareTo(b.price));
    final highestPriced =
        productsSortedByPrice.isNotEmpty ? productsSortedByPrice.last : null;
    final lowestPriced =
        productsSortedByPrice.isNotEmpty ? productsSortedByPrice.first : null;

    // Sales Analysis (Top Selling Products by Quantity)
    Map<String, int> salesByProductId = {};
    double totalRevenue = 0;
    if (sales.isNotEmpty) {
      for (var sale in sales) {
        salesByProductId.update(
            sale.productId, (value) => value + sale.quantity,
            ifAbsent: () => sale.quantity);

        final product =
            products.firstWhereOrNull((p) => p.id == sale.productId);
        if (product != null) {
          totalRevenue += sale.quantity * product.price;
        }
      }
    }

    // Sales by date
    final salesByDate =
        sales.groupListsBy((s) => DateFormat('yyyy-MM-dd').format(s.date));

    // Top products by sales count
    final topSellingProducts = salesByProductId.entries
        .map((entry) {
          final product = products.firstWhereOrNull((p) => p.id == entry.key);
          return product != null ? MapEntry(product, entry.value) : null;
        })
        .whereNotNull()
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'totalProducts': totalProducts,
      'categorySummary': categorySummary,
      'lowStockProducts': lowStockProducts,
      'outOfStockProducts': outOfStockProducts,
      'lowStockThreshold': lowStockThreshold,
      'highestPriced': highestPriced,
      'lowestPriced': lowestPriced,
      'totalSales': sales.length,
      'totalRevenue': totalRevenue,
      'topSellingProducts': topSellingProducts,
      'salesByDate': salesByDate,
    };
  }

  void _handleQuestion(String question) {
    if (question.trim().isEmpty) return;

    setState(() {
      // Add user message
      _messages.add(ChatMessage(text: question, isUser: true));
      _isLoading = true;
      _questionController.clear();
    });

    // Increased delay to 4 seconds for a more substantial feeling of "thinking"
    Future.delayed(const Duration(seconds: 4), () {
      final answer = _generateAnswer(question);

      setState(() {
        _messages.add(ChatMessage(text: answer, isUser: false));
        _isLoading = false;
      });

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    });
  }

  String _generateAnswer(String question) {
    // Convert question to lowercase for easier matching
    final q = question.toLowerCase();

    // More comprehensive pattern matching for questions

    // Product count questions
    if (_matchesAny(q, [
      'how many product',
      'total product',
      'count of product',
      'number of product',
      'product count',
      'inventory size',
      'inventory count'
    ])) {
      final count = analysisData['totalProducts'];
      return "You have $count products in your inventory.";
    }

    // Low stock questions
    else if (_matchesAny(q, [
      'low stock',
      'running out',
      'almost out',
      'which products are low',
      'need to restock',
      'reorder soon',
      'running low'
    ])) {
      final lowStock = analysisData['lowStockProducts'] as List<Product>;
      if (lowStock.isEmpty) {
        return "You don't have any products with low stock at the moment.";
      }

      final examples = lowStock
          .take(5)
          .map((p) => "• ${p.name}: ${p.quantity} left")
          .join('\n');
      return "You have ${lowStock.length} products with low stock (10 or fewer units):\n$examples${lowStock.length > 5 ? '\n(and ${lowStock.length - 5} more)' : ''}";
    }

    // Out of stock questions
    else if (_matchesAny(q, [
      'out of stock',
      'zero stock',
      'no stock',
      'completely out',
      'unavailable',
      'which products are out',
      'empty inventory'
    ])) {
      final outOfStock = analysisData['outOfStockProducts'] as List<Product>;
      if (outOfStock.isEmpty) {
        return "Good news! None of your products are out of stock.";
      }

      final examples = outOfStock.take(5).map((p) => "• ${p.name}").join('\n');
      return "You have ${outOfStock.length} out-of-stock products:\n$examples${outOfStock.length > 5 ? '\n(and ${outOfStock.length - 5} more)' : ''}";
    }

    // Top selling products questions
    else if (_matchesAny(q, [
      'best sell',
      'top sell',
      'popular product',
      'most sold',
      'highest selling',
      'what sells the most',
      'best performer',
      'best product',
      'customer favorite'
    ])) {
      final topProducts =
          analysisData['topSellingProducts'] as List<MapEntry<Product, int>>;
      if (topProducts.isEmpty) {
        return "You don't have any sales data yet to determine top-selling products.";
      }

      final top = topProducts.first;
      final topFive = topProducts
          .take(5)
          .map((e) => "• ${e.key.name}: ${e.value} units sold")
          .join('\n');

      return "Your best-selling product is ${top.key.name} with ${top.value} units sold.\n\nTop 5 products by sales:\n$topFive";
    }

    // Sales summary questions
    else if (_matchesAny(q, [
      'sales summary',
      'revenue',
      'how much have i sold',
      'total sales',
      'sales overview',
      'income',
      'earnings',
      'how is business',
      'business performance',
      'how much money',
      'money made'
    ])) {
      final totalSales = analysisData['totalSales'];
      final totalRevenue = analysisData['totalRevenue'] as double;

      if (totalSales == 0) {
        return "You haven't recorded any sales yet.";
      }

      // Calculate monthly sales if available
      final salesByDate =
          analysisData['salesByDate'] as Map<String, List<Sale>>;
      final currentMonth = DateTime.now().month;
      final currentYear = DateTime.now().year;
      double thisMonthRevenue = 0;
      int thisMonthSales = 0;

      salesByDate.forEach((dateStr, salesList) {
        final date = DateTime.parse(dateStr);
        if (date.month == currentMonth && date.year == currentYear) {
          thisMonthSales += salesList.length;

          for (var sale in salesList) {
            final product =
                products.firstWhereOrNull((p) => p.id == sale.productId);
            if (product != null) {
              thisMonthRevenue += sale.quantity * product.price;
            }
          }
        }
      });

      String monthlyInfo = "";
      if (thisMonthSales > 0) {
        monthlyInfo =
            "\n\nThis month: $thisMonthSales sales with revenue of ₹${thisMonthRevenue.toStringAsFixed(2)}.";
      }

      return "You've made $totalSales sales transactions with a total revenue of ₹${totalRevenue.toStringAsFixed(2)}.$monthlyInfo";
    }

    // Recent sales questions
    else if (_matchesAny(q, [
      'recent sales',
      'last sale',
      'latest transaction',
      'today sales',
      'this week sales',
      'sales today',
      'recent transactions'
    ])) {
      if (sales.isEmpty) {
        return "You haven't recorded any sales yet.";
      }

      // Sort sales by date (most recent first)
      final recentSales = List<Sale>.from(sales)
        ..sort((a, b) => b.date.compareTo(a.date));

      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todaySales =
          recentSales.where((s) => s.date.isAfter(todayStart)).length;

      final lastSale = recentSales.first;
      final productName =
          products.firstWhereOrNull((p) => p.id == lastSale.productId)?.name ??
              'Unknown Product';

      return "Your most recent sale was on ${DateFormat('MMM d, yyyy').format(lastSale.date)} for $productName (${lastSale.quantity} units).\n\nYou have $todaySales sales recorded today.";
    }

    // Categories questions
    else if (_matchesAny(q, [
      'categories',
      'types of product',
      'product types',
      'product groups',
      'what categories',
      'product classifications',
      'product segments'
    ])) {
      final categories = analysisData['categorySummary'] as Map<String, int>;
      if (categories.isEmpty) {
        return "You don't have any categorized products yet.";
      }

      final categoryList = categories.entries
          .map((e) => "• ${e.key}: ${e.value} products")
          .join('\n');

      return "You have products in these categories:\n$categoryList";
    }

    // Highest price questions
    else if (_matchesAny(q, [
      'highest price',
      'most expensive',
      'priciest',
      'costliest',
      'premium product',
      'luxury item',
      'high end'
    ])) {
      final product = analysisData['highestPriced'] as Product?;
      if (product == null) {
        return "You don't have any products in your inventory.";
      }

      return "Your most expensive product is ${product.name} priced at ₹${product.price}.";
    }

    // Lowest price questions
    else if (_matchesAny(q, [
      'lowest price',
      'cheapest',
      'least expensive',
      'budget',
      'affordable',
      'inexpensive',
      'low cost'
    ])) {
      final product = analysisData['lowestPriced'] as Product?;
      if (product == null) {
        return "You don't have any products in your inventory.";
      }

      return "Your lowest priced product is ${product.name} priced at ₹${product.price}.";
    }

    // Average price questions
    else if (_matchesAny(q, [
      'average price',
      'median price',
      'typical price',
      'price range',
      'normal price'
    ])) {
      if (products.isEmpty) {
        return "You don't have any products in your inventory.";
      }

      double totalPrice =
          products.fold(0, (sum, product) => sum + product.price);
      double avgPrice = totalPrice / products.length;

      double minPrice =
          products.map((p) => p.price).reduce((a, b) => a < b ? a : b);
      double maxPrice =
          products.map((p) => p.price).reduce((a, b) => a > b ? a : b);

      return "Your products have an average price of ₹${avgPrice.toStringAsFixed(2)}.\nPrice range: ₹$minPrice to ₹$maxPrice.";
    }

    // Inventory value questions
    else if (_matchesAny(q, [
      'inventory value',
      'stock value',
      'worth of inventory',
      'value of stock',
      'inventory worth',
      'warehouse value'
    ])) {
      if (products.isEmpty) {
        return "You don't have any products in your inventory.";
      }

      double totalValue = products.fold(
          0, (sum, product) => sum + (product.price * product.quantity));

      return "Your current inventory is valued at ₹${totalValue.toStringAsFixed(2)} based on ${products.length} products.";
    }

    // Greeting responses
    else if (_matchesAny(q, [
          'hello',
          'hi ',
          'hey',
          'greetings',
          'good morning',
          'good afternoon',
          'good evening'
        ]) ||
        q == 'hi') {
      return "Hello! How can I help analyze your business data today?";
    }

    // Thank you responses
    else if (_matchesAny(
        q, ['thank', 'thanks', 'appreciate', 'helpful', 'great job'])) {
      return "You're welcome! Let me know if you have more questions about your business data.";
    }

    // Data refresh requests
    else if (_matchesAny(q, [
      'refresh',
      'update data',
      'reload',
      'get latest',
      'synchronize',
      'sync data',
      'current data'
    ])) {
      _loadData();
      return "I've refreshed your business data. What would you like to know?";
    }

    // Help requests
    else if (_matchesAny(q, [
      'help',
      'what can you do',
      'commands',
      'features',
      'capabilities',
      'options',
      'available questions'
    ])) {
      return "I can answer questions about your business data such as:\n\n• Product inventory and stock levels\n• Sales performance and revenue\n• Best-selling products\n• Price analysis\n• Category breakdowns\n\nJust ask in natural language, and I'll try to provide insights based on your local data.";
    } else {
      // Fallback for unrecognized questions
      return "I'm not sure how to answer that question. You can ask me about your inventory, sales, product categories, or business performance. For example, try asking 'How many products do I have?' or 'What's my best selling product?'";
    }
  }

  // Helper method to check if a question matches any of the provided patterns
  bool _matchesAny(String question, List<String> patterns) {
    return patterns.any((pattern) => question.contains(pattern));
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Insights Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _loadData();
                _messages.add(
                  ChatMessage(
                    text: "I've refreshed your business data!",
                    isUser: false,
                  ),
                );
              });
              _scrollToBottom();
            },
            tooltip: 'Refresh Data',
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: products.isEmpty && sales.isEmpty
                  ? _buildEmptyState()
                  : _buildChatMessages(),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No business data available',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Start adding products and recording sales to get insights from your assistant.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Return to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessages() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).colorScheme.primary
              : message.isSuggestion
                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                  : Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser
                ? Theme.of(context).colorScheme.onPrimary
                : message.isSuggestion
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: _questionController,
                decoration: InputDecoration(
                  hintText: 'Ask a question about your business...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: _handleQuestion,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              margin: const EdgeInsets.only(bottom: 2),
              child: _isLoading
                  ? Container(
                      width: 48,
                      height: 48,
                      padding: const EdgeInsets.all(12),
                      child: const CircularProgressIndicator(strokeWidth: 3),
                    )
                  : SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () =>
                            _handleQuestion(_questionController.text),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isSuggestion;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isSuggestion = false,
  });
}
