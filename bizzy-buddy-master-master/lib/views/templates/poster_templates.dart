import 'package:flutter/material.dart';

class PosterTemplate {
  final String name;
  final Color backgroundColor;
  final Color textColor;
  final String title;
  final String subtitle;
  final String fontFamily;
  final double titleSize;
  final double subtitleSize;
  final TextAlign titleAlign;
  final TextAlign subtitleAlign;
  final bool isBold;
  final bool isItalic;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final Border? border;
  final EdgeInsets padding;

  const PosterTemplate({
    required this.name,
    required this.backgroundColor,
    required this.textColor,
    required this.title,
    required this.subtitle,
    required this.fontFamily,
    required this.titleSize,
    required this.subtitleSize,
    required this.titleAlign,
    required this.subtitleAlign,
    required this.isBold,
    required this.isItalic,
    this.boxShadow,
    this.gradient,
    this.borderRadius,
    this.border,
    this.padding = const EdgeInsets.all(24),
  });
}

final Map<String, PosterTemplate> templates = {
  'default': const PosterTemplate(
    name: 'Default',
    backgroundColor: Colors.white,
    textColor: Colors.black,
    title: 'Your Title Here',
    subtitle: 'Your subtitle goes here',
    fontFamily: 'Roboto',
    titleSize: 32,
    subtitleSize: 18,
    titleAlign: TextAlign.center,
    subtitleAlign: TextAlign.center,
    isBold: true,
    isItalic: false,
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  ),
  'elegant': const PosterTemplate(
    name: 'Elegant',
    backgroundColor: Color(0xFFF8F8F8),
    textColor: Color(0xFF2C3E50),
    title: 'Elegant Design',
    subtitle: 'Sophisticated and timeless',
    fontFamily: 'Playfair Display',
    titleSize: 36,
    subtitleSize: 20,
    titleAlign: TextAlign.center,
    subtitleAlign: TextAlign.center,
    isBold: true,
    isItalic: true,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF8F8F8), Color(0xFFE8E8E8)],
    ),
    borderRadius: BorderRadius.all(Radius.circular(8)),
    border: Border(
      top: BorderSide(color: Color(0xFF2C3E50), width: 2),
      bottom: BorderSide(color: Color(0xFF2C3E50), width: 2),
    ),
  ),
  'modern': const PosterTemplate(
    name: 'Modern',
    backgroundColor: Color(0xFF1A1A1A),
    textColor: Colors.white,
    title: 'Modern Style',
    subtitle: 'Clean and contemporary',
    fontFamily: 'Montserrat',
    titleSize: 40,
    subtitleSize: 18,
    titleAlign: TextAlign.center,
    subtitleAlign: TextAlign.center,
    isBold: true,
    isItalic: false,
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 15,
        offset: Offset(0, 8),
      ),
    ],
  ),
  'sale': PosterTemplate(
    name: 'Sale',
    backgroundColor: const Color(0xFFFF4B4B),
    textColor: Colors.white,
    title: 'SALE!',
    subtitle: 'Limited time offer',
    fontFamily: 'Oswald',
    titleSize: 48,
    subtitleSize: 24,
    titleAlign: TextAlign.center,
    subtitleAlign: TextAlign.center,
    isBold: true,
    isItalic: false,
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFF4B4B), Color(0xFFFF7676)],
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.red.withOpacity(0.3),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  ),
  'minimal': const PosterTemplate(
    name: 'Minimal',
    backgroundColor: Colors.white,
    textColor: Color(0xFF333333),
    title: 'Minimal Design',
    subtitle: 'Less is more',
    fontFamily: 'Raleway',
    titleSize: 32,
    subtitleSize: 16,
    titleAlign: TextAlign.center,
    subtitleAlign: TextAlign.center,
    isBold: false,
    isItalic: false,
    border: Border(
      left: BorderSide(color: Color(0xFF333333), width: 1),
      right: BorderSide(color: Color(0xFF333333), width: 1),
    ),
  ),
  'festive': PosterTemplate(
    name: 'Festive',
    backgroundColor: const Color(0xFF4CAF50),
    textColor: Colors.white,
    title: 'Festive Special',
    subtitle: 'Celebrate with us',
    fontFamily: 'Quicksand',
    titleSize: 42,
    subtitleSize: 20,
    titleAlign: TextAlign.center,
    subtitleAlign: TextAlign.center,
    isBold: true,
    isItalic: false,
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.green.withOpacity(0.3),
        blurRadius: 15,
        offset: const Offset(0, 8),
      ),
    ],
  ),
  'premium': const PosterTemplate(
    name: 'Premium',
    backgroundColor: Color(0xFF2C3E50),
    textColor: Color(0xFFECF0F1),
    title: 'Premium Quality',
    subtitle: 'Exclusive collection',
    fontFamily: 'Poppins',
    titleSize: 38,
    subtitleSize: 20,
    titleAlign: TextAlign.center,
    subtitleAlign: TextAlign.center,
    isBold: true,
    isItalic: false,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 20,
        offset: Offset(0, 10),
      ),
    ],
  ),
  'vintage': PosterTemplate(
    name: 'Vintage',
    backgroundColor: const Color(0xFFF5E6D3),
    textColor: const Color(0xFF8B4513),
    title: 'Vintage Style',
    subtitle: 'Classic elegance',
    fontFamily: 'Playfair Display',
    titleSize: 36,
    subtitleSize: 18,
    titleAlign: TextAlign.center,
    subtitleAlign: TextAlign.center,
    isBold: true,
    isItalic: true,
    border: Border.all(color: const Color(0xFF8B4513), width: 2),
    borderRadius: const BorderRadius.all(Radius.circular(8)),
  ),
  'corporate': const PosterTemplate(
    name: 'Corporate',
    backgroundColor: Color(0xFFF5F5F5),
    textColor: Color(0xFF1A237E),
    title: 'Corporate',
    subtitle: 'Professional excellence',
    fontFamily: 'Roboto',
    titleSize: 34,
    subtitleSize: 18,
    titleAlign: TextAlign.center,
    subtitleAlign: TextAlign.center,
    isBold: true,
    isItalic: false,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
    ),
    border: Border(
      bottom: BorderSide(color: Color(0xFF1A237E), width: 3),
    ),
  ),
  'creative': PosterTemplate(
    name: 'Creative',
    backgroundColor: const Color(0xFF9C27B0),
    textColor: Colors.white,
    title: 'Creative Design',
    subtitle: 'Think outside the box',
    fontFamily: 'DM Sans',
    titleSize: 40,
    subtitleSize: 20,
    titleAlign: TextAlign.center,
    subtitleAlign: TextAlign.center,
    isBold: true,
    isItalic: false,
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.purple.withOpacity(0.3),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  ),
  'summer': PosterTemplate(
    name: 'Summer',
    backgroundColor: const Color(0xFFFF9800),
    textColor: Colors.white,
    title: 'Summer Vibes',
    subtitle: 'Hot deals for hot days',
    fontFamily: 'Quicksand',
    titleSize: 42,
    subtitleSize: 20,
    titleAlign: TextAlign.center,
    subtitleAlign: TextAlign.center,
    isBold: true,
    isItalic: false,
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.orange.withOpacity(0.3),
        blurRadius: 15,
        offset: const Offset(0, 8),
      ),
    ],
  ),
  'winter': PosterTemplate(
    name: 'Winter',
    backgroundColor: const Color(0xFF2196F3),
    textColor: Colors.white,
    title: 'Winter Special',
    subtitle: 'Cozy up with our offers',
    fontFamily: 'Montserrat',
    titleSize: 38,
    subtitleSize: 20,
    titleAlign: TextAlign.center,
    subtitleAlign: TextAlign.center,
    isBold: true,
    isItalic: false,
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.blue.withOpacity(0.3),
        blurRadius: 15,
        offset: const Offset(0, 8),
      ),
    ],
  ),
  'spring': PosterTemplate(
    name: 'Spring',
    backgroundColor: const Color(0xFF4CAF50),
    textColor: Colors.white,
    title: 'Spring Collection',
    subtitle: 'Fresh new arrivals',
    fontFamily: 'Raleway',
    titleSize: 40,
    subtitleSize: 20,
    titleAlign: TextAlign.center,
    subtitleAlign: TextAlign.center,
    isBold: true,
    isItalic: false,
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.green.withOpacity(0.3),
        blurRadius: 15,
        offset: const Offset(0, 8),
      ),
    ],
  ),
  'autumn': PosterTemplate(
    name: 'Autumn',
    backgroundColor: const Color(0xFF795548),
    textColor: Colors.white,
    title: 'Autumn Special',
    subtitle: 'Warm and cozy deals',
    fontFamily: 'Playfair Display',
    titleSize: 38,
    subtitleSize: 20,
    titleAlign: TextAlign.center,
    subtitleAlign: TextAlign.center,
    isBold: true,
    isItalic: true,
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF795548), Color(0xFFA1887F)],
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.brown.withOpacity(0.3),
        blurRadius: 15,
        offset: const Offset(0, 8),
      ),
    ],
  ),
};
