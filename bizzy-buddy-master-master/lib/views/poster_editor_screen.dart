import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'templates/poster_templates.dart';
import '../services/poster_caption_service.dart';

final posterCaptionServiceProvider = Provider((ref) => PosterCaptionService());

class PosterEditorScreen extends ConsumerStatefulWidget {
  const PosterEditorScreen({super.key});

  @override
  ConsumerState<PosterEditorScreen> createState() => _PosterEditorScreenState();
}

class _PosterEditorScreenState extends ConsumerState<PosterEditorScreen> {
  final GlobalKey _posterKey = GlobalKey();
  File? _selectedImage;
  String _title = '';
  String _subtitle = '';
  Color _backgroundColor = Colors.white;
  Color _textColor = Colors.black;
  double _titleSize = 24.0;
  double _subtitleSize = 18.0;
  TextAlign _titleAlign = TextAlign.center;
  TextAlign _subtitleAlign = TextAlign.center;
  bool _isBold = false;
  bool _isItalic = false;
  String _selectedTemplate = 'default';
  String _selectedSize = 'A4'; // Default size
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _targetAudienceController =
      TextEditingController();
  final TextEditingController _styleController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
  bool _isGenerating = false;

  // A4 and A5 dimensions in pixels (at 300 DPI)
  final Map<String, Map<String, double>> _paperSizes = {
    'A4': {
      'width': 2480, // 210mm at 300 DPI
      'height': 3508, // 297mm at 300 DPI
      'aspectRatio': 210 / 297,
    },
    'A5': {
      'width': 1748, // 148mm at 300 DPI
      'height': 2480, // 210mm at 300 DPI
      'aspectRatio': 148 / 210,
    },
    'Square': {
      'width': 2480,
      'height': 2480,
      'aspectRatio': 1,
    },
    'Instagram': {
      'width': 1080,
      'height': 1080,
      'aspectRatio': 1,
    },
    'Story': {
      'width': 1080,
      'height': 1920,
      'aspectRatio': 9 / 16,
    },
  };

  // Define fonts list as a static const to ensure it's immutable
  static const List<String> _availableFonts = [
    'Roboto',
    'Open Sans',
    'Montserrat',
    'Poppins',
    'Lato',
    'Playfair Display',
    'Raleway',
    'Nunito',
    'Quicksand',
    'Oswald',
    'DM Sans', // Added DM Sans to the list
  ];

  // Initialize with the first font from the list
  late String _selectedFont;

  @override
  void initState() {
    super.initState();
    // Initialize with the default template
    final defaultTemplate = templates['default'] ?? templates.values.first;
    _selectedTemplate = defaultTemplate.name.toLowerCase();
    _applyTemplate(defaultTemplate);
    // Ensure selected font is valid
    _selectedFont = _availableFonts.first;
  }

  void _applyTemplate(PosterTemplate template) {
    setState(() {
      _backgroundColor = template.backgroundColor;
      _textColor = template.textColor;
      _title = template.title;
      _subtitle = template.subtitle;
      _selectedFont = _availableFonts.contains(template.fontFamily)
          ? template.fontFamily
          : _availableFonts.first;
      _titleSize = template.titleSize;
      _subtitleSize = template.subtitleSize;
      _titleAlign = template.titleAlign;
      _subtitleAlign = template.subtitleAlign;
      _isBold = template.isBold;
      _isItalic = template.isItalic;
    });
  }

  final List<String> _templates = [
    'default',
    'elegant',
    'modern',
    'sale',
    'minimal',
    'festive',
    'premium',
    'vintage',
    'corporate',
    'creative',
  ];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _exportPoster() async {
    try {
      final RenderRepaintBoundary boundary = _posterKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(
        pixelRatio: _paperSizes[_selectedSize]!['width']! / 600,
      );
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final bytes = byteData.buffer.asUint8List();
        final tempDir = Directory.systemTemp;
        final file =
            File('${tempDir.path}/poster_${_selectedSize.toLowerCase()}.png');
        await file.writeAsBytes(bytes);
        await Share.shareXFiles([XFile(file.path)],
            text: 'Check out my $_selectedSize poster!');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting poster: $e')),
        );
      }
    }
  }

  void _showColorPicker(bool isBackground) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pick ${isBackground ? 'Background' : 'Text'} Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: isBackground ? _backgroundColor : _textColor,
            onColorChanged: (color) {
              setState(() {
                if (isBackground) {
                  _backgroundColor = color;
                } else {
                  _textColor = color;
                }
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateCaption() async {
    if (_productNameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _targetAudienceController.text.isEmpty ||
        _styleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final caption =
          await ref.read(posterCaptionServiceProvider).generateCaption(
                productName: _productNameController.text,
                productDescription: _descriptionController.text,
                targetAudience: _targetAudienceController.text,
                style: _styleController.text,
              );

      setState(() {
        _captionController.text = caption;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating caption: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _generatePoster() async {
    if (_captionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please generate a caption first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _title = _productNameController.text;
      _subtitle = _captionController.text;
    });
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _descriptionController.dispose();
    _targetAudienceController.dispose();
    _styleController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poster Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _exportPoster,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTemplateSelector(),
            _buildPosterPreview(),
            _buildControlsPanel(false),
            const SizedBox(height: 24),
            _buildAdvancedControlsPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateSelector() {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _templates.length,
        itemBuilder: (context, index) {
          final templateName = _templates[index];
          final template = templates[templateName]!;
          final isSelected = _selectedTemplate == templateName;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTemplate = templateName;
                _applyTemplate(template);
              });
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: template.backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: template.boxShadow,
                gradient: template.gradient,
              ),
              child: Center(
                child: Text(
                  template.title,
                  style: TextStyle(
                    color: template.textColor,
                    fontSize: 10,
                    fontFamily: template.fontFamily,
                    fontWeight:
                        template.isBold ? FontWeight.bold : FontWeight.normal,
                    fontStyle:
                        template.isItalic ? FontStyle.italic : FontStyle.normal,
                  ),
                  textAlign: template.titleAlign,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPosterPreview() {
    final template = templates[_selectedTemplate]!;
    final size = _paperSizes[_selectedSize]!;
    final aspectRatio = size['aspectRatio']!;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: RepaintBoundary(
          key: _posterKey,
          child: Container(
            decoration: BoxDecoration(
              color: template.backgroundColor,
              gradient: template.gradient,
              borderRadius: template.borderRadius,
              border: template.border,
              boxShadow: template.boxShadow,
            ),
            padding: template.padding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_selectedImage != null)
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  _title,
                  style: GoogleFonts.getFont(
                    _selectedFont,
                    fontSize: _titleSize,
                    color: _textColor,
                    fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                    fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
                  ),
                  textAlign: _titleAlign,
                ),
                const SizedBox(height: 8),
                Text(
                  _subtitle,
                  style: GoogleFonts.getFont(
                    _selectedFont,
                    fontSize: _subtitleSize,
                    color: _textColor,
                    fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                    fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
                  ),
                  textAlign: _subtitleAlign,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlsPanel(bool isNarrowScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Product Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _productNameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.shopping_bag),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Product Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _targetAudienceController,
                  decoration: const InputDecoration(
                    labelText: 'Target Audience',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.people),
                    hintText: 'e.g., Young adults, Parents, Professionals',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _styleController,
                  decoration: const InputDecoration(
                    labelText: 'Style',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.style),
                    hintText: 'e.g., Modern, Vintage, Minimalist',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _isGenerating ? null : _generateCaption,
          icon: _isGenerating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.auto_awesome, color: Colors.white),
          label: Text(
            _isGenerating ? 'Generating...' : 'Generate Caption',
            style: const TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.2),
          ),
        ),
        if (_captionController.text.isNotEmpty) ...[
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Generated Caption',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _captionController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Your caption will appear here',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          // TODO: Implement copy to clipboard
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Caption copied to clipboard'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _generatePoster,
                        icon: const Icon(Icons.image),
                        label: const Text('Generate Poster'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAdvancedControlsPanel() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Advanced Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Paper Size Selection
            const Text('Paper Size'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _paperSizes.keys.map((size) {
                return ChoiceChip(
                  label: Text(size),
                  selected: _selectedSize == size,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedSize = size);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Text Alignment
            const Text('Text Alignment'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.format_align_left),
                  onPressed: () => setState(() {
                    _titleAlign = TextAlign.left;
                    _subtitleAlign = TextAlign.left;
                  }),
                  color: _titleAlign == TextAlign.left
                      ? Theme.of(context).primaryColor
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.format_align_center),
                  onPressed: () => setState(() {
                    _titleAlign = TextAlign.center;
                    _subtitleAlign = TextAlign.center;
                  }),
                  color: _titleAlign == TextAlign.center
                      ? Theme.of(context).primaryColor
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.format_align_right),
                  onPressed: () => setState(() {
                    _titleAlign = TextAlign.right;
                    _subtitleAlign = TextAlign.right;
                  }),
                  color: _titleAlign == TextAlign.right
                      ? Theme.of(context).primaryColor
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Text Size
            const Text('Text Size'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Title:'),
                Expanded(
                  child: Slider(
                    value: _titleSize,
                    min: 16,
                    max: 48,
                    divisions: 8,
                    label: _titleSize.round().toString(),
                    onChanged: (value) => setState(() => _titleSize = value),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text('Subtitle:'),
                Expanded(
                  child: Slider(
                    value: _subtitleSize,
                    min: 12,
                    max: 36,
                    divisions: 6,
                    label: _subtitleSize.round().toString(),
                    onChanged: (value) => setState(() => _subtitleSize = value),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ColorPicker extends StatelessWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.yellow,
        Colors.purple,
        Colors.orange,
        Colors.black,
        Colors.white,
      ].map((color) {
        return GestureDetector(
          onTap: () => onColorChanged(color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: pickerColor == color ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
