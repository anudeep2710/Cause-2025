import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:avatar_glow/avatar_glow.dart';
import '../../models/product.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class SmartInputScreen extends ConsumerStatefulWidget {
  const SmartInputScreen({super.key});

  @override
  ConsumerState<SmartInputScreen> createState() => _SmartInputScreenState();
}

class _SmartInputScreenState extends ConsumerState<SmartInputScreen> {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Parsed product details
  String _productName = '';
  double _price = 0.0;
  String _category = '';
  int _quantity = 1;
  Map<String, String> _additionalDetails = {};

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _scrollToTextInput() {
    // Wait for the UI to build and then scroll to the text input section
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          300, // Approximate position of the text input
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (error) => debugPrint('Speech recognition error: $error'),
        onStatus: (status) => debugPrint('Speech recognition status: $status'),
      );
      setState(() {});
    } catch (e) {
      debugPrint('Error initializing speech recognition: $e');
      setState(() {
        _speechEnabled = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      await _startListening();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Microphone permission is required for speech recognition'),
          ),
        );
      }
    }
  }

  Future<void> _startListening() async {
    final micPermission = await Permission.microphone.status;

    if (!micPermission.isGranted) {
      await _requestPermission();
      return;
    }

    if (!_speechEnabled) {
      await _initSpeech();
    }

    try {
      if (_speechEnabled) {
        setState(() => _isListening = true);
        await _speechToText.listen(
          onResult: _onSpeechResult,
          localeId: 'en_US',
          listenMode: stt.ListenMode.confirmation,
          cancelOnError: true,
          partialResults: true,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Speech recognition is not available'),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error starting speech recognition: $e');
      setState(() => _isListening = false);
    }
  }

  Future<void> _stopListening() async {
    try {
      await _speechToText.stop();
      setState(() => _isListening = false);
    } catch (e) {
      debugPrint('Error stopping speech recognition: $e');
    }
  }

  void _onSpeechResult(dynamic result) {
    setState(() {
      _lastWords = result.recognizedWords;
      _parseInput(_lastWords);
    });
  }

  void _parseInput(String input) {
    try {
      debugPrint('Raw input: $input'); // Debug log for raw input

      // Extract price (looking for word "price" or currency symbols)
      final priceRegex = RegExp(
          r'(?:price|Price)\s+(\d+(?:\.\d{1,2})?)|(?:₹|Rs\.?|rs\.?)\s*(\d+(?:\.\d{1,2})?)\b',
          caseSensitive: false);
      final priceMatch = priceRegex.firstMatch(input);
      if (priceMatch != null) {
        // Get the price from either the first or second group (whichever is not null)
        final priceStr = priceMatch.group(1) ?? priceMatch.group(2);
        if (priceStr != null) {
          _price = double.parse(priceStr);
          debugPrint('Found price: $_price'); // Debug log for price
        }
      }

      // Extract quantity (if specified)
      final quantityRegex =
          RegExp(r'(\d+)\s*(piece|pc|pcs|items?|qty)', caseSensitive: false);
      final quantityMatch = quantityRegex.firstMatch(input);
      if (quantityMatch != null) {
        _quantity = int.parse(quantityMatch.group(1)!);
        debugPrint('Found quantity: $_quantity'); // Debug log for quantity
      }

      // Extract category (assuming "under" keyword)
      final categoryRegex = RegExp(r'under\s+(\w+)', caseSensitive: false);
      final categoryMatch = categoryRegex.firstMatch(input);
      if (categoryMatch != null) {
        _category = categoryMatch.group(1)!;
        debugPrint('Found category: $_category'); // Debug log for category
      }

      // Extract additional details
      final sizeRegex = RegExp(r'size\s+(\w+)', caseSensitive: false);
      final sizeMatch = sizeRegex.firstMatch(input);
      if (sizeMatch != null) {
        _additionalDetails['size'] = sizeMatch.group(1)!;
        debugPrint('Found size: ${sizeMatch.group(1)}'); // Debug log for size
      }

      final colorRegex = RegExp(r'colou?r\s+(\w+)', caseSensitive: false);
      final colorMatch = colorRegex.firstMatch(input);
      if (colorMatch != null) {
        _additionalDetails['color'] = colorMatch.group(1)!;
        debugPrint(
            'Found color: ${colorMatch.group(1)}'); // Debug log for color
      }

      // Extract product name (everything before price, category, or other details)
      var nameEndIndexes = [
        input.length,
        priceMatch?.start ?? input.length,
        categoryMatch?.start ?? input.length,
        quantityMatch?.start ?? input.length,
        sizeMatch?.start ?? input.length,
        colorMatch?.start ?? input.length,
        input.toLowerCase().contains(' price ')
            ? input.toLowerCase().indexOf(' price ')
            : input.length,
      ];

      var nameEndIndex =
          nameEndIndexes.reduce((curr, next) => curr < next ? curr : next);
      var name = input.substring(0, nameEndIndex).trim();

      // Remove "add" prefix if present
      if (name.toLowerCase().startsWith('add')) {
        name = name.substring(3).trim();
      }

      _productName = name;
      debugPrint('Extracted name: $_productName'); // Debug log for name

      setState(() {});

      // Debug log for all parsed values
      debugPrint('Final parsed values:');
      debugPrint('Name: $_productName');
      debugPrint('Price: $_price');
      debugPrint('Category: $_category');
      debugPrint('Quantity: $_quantity');
      debugPrint('Additional Details: $_additionalDetails');
    } catch (e) {
      debugPrint('Error parsing input: $e');
    }
  }

  Future<void> _saveProduct() async {
    if (_productName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a product name')),
      );
      return;
    }

    if (_price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a valid price')),
      );
      return;
    }

    final product = Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _productName,
      price: _price,
      quantity: _quantity,
      category: _category.isEmpty ? 'Uncategorized' : _category,
      description:
          _additionalDetails.isEmpty ? null : _additionalDetails.toString(),
      createdAt: DateTime.now(),
    );

    // Save product using Hive
    final box = Hive.box<Product>('products');
    await box.add(product);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product saved: ${product.name} - ₹${product.price}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // Clear form
    setState(() {
      _productName = '';
      _price = 0;
      _quantity = 1;
      _category = '';
      _additionalDetails = {};
      _textController.clear();
      _lastWords = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProduct,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Card with Instructions
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Voice Assistant Tips',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('• Tap the mic button and speak clearly'),
                    const Text('• Say "Add [product name], price [amount]"'),
                    const Text('• For categories say "under [category]"'),
                    const Text('• You can specify "quantity [number]"'),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.keyboard),
                        label: const Text('Use keyboard instead'),
                        onPressed: () {
                          // Focus on the text input field
                          FocusScope.of(context).requestFocus(FocusNode());
                          _scrollToTextInput();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Voice Input Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      '🎤 Voice Input',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AvatarGlow(
                      animate: _isListening,
                      glowColor: Theme.of(context).primaryColor,
                      endRadius: 75.0,
                      duration: const Duration(milliseconds: 2000),
                      repeatPauseDuration: const Duration(milliseconds: 100),
                      repeat: true,
                      child: FloatingActionButton(
                        onPressed: _speechEnabled
                            ? _isListening
                                ? _stopListening
                                : _startListening
                            : null,
                        child: Icon(_isListening ? Icons.mic : Icons.mic_none),
                      ),
                    ),
                    if (_lastWords.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'Recognized: $_lastWords',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Manual Text Input Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '⌨️ Text Input',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Type product details...',
                        helperText:
                            'Example: Add Red T-shirt, ₹499, under Clothing, size Medium',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: _parseInput,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Parsed Results Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '📝 Product Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildEditableField('Name', _productName, (value) {
                      setState(() => _productName = value);
                    }),
                    _buildEditableField('Price', _price.toString(), (value) {
                      setState(() => _price = double.tryParse(value) ?? 0);
                    }),
                    _buildEditableField('Quantity', _quantity.toString(),
                        (value) {
                      setState(() => _quantity = int.tryParse(value) ?? 1);
                    }),
                    _buildEditableField('Category', _category, (value) {
                      setState(() => _category = value);
                    }),
                    if (_additionalDetails.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Additional Details:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ..._additionalDetails.entries.map(
                        (entry) => _buildEditableField(
                          entry.key.toUpperCase(),
                          entry.value,
                          (value) {
                            setState(() {
                              _additionalDetails[entry.key] = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    String value,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        controller: TextEditingController(text: value)
          ..selection = TextSelection.fromPosition(
            TextPosition(offset: value.length),
          ),
        onChanged: onChanged,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
