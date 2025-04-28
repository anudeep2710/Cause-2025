import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DiscountPosterTemplate extends StatelessWidget {
  final String title;
  final String discount;
  final String duration;
  final ImageProvider? logo;
  final Color primaryColor;
  final Color secondaryColor;
  final Color textColor;

  const DiscountPosterTemplate({
    super.key,
    required this.title,
    required this.discount,
    required this.duration,
    this.logo,
    this.primaryColor = Colors.redAccent,
    this.secondaryColor = Colors.deepOrange,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (logo != null)
            CircleAvatar(
              radius: 50,
              backgroundImage: logo,
              backgroundColor: Colors.white,
            ),
          const SizedBox(height: 20),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.bebasNeue(
              fontSize: 40,
              letterSpacing: 2,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '$discount%',
                style: GoogleFonts.robotoSlab(
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 3
                    ..color = Colors.white70,
                ),
              ),
              Text(
                '$discount%',
                style: GoogleFonts.robotoSlab(
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'LIMITED TIME ONLY',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white30),
            ),
            child: Text(
              duration,
              style: GoogleFonts.lato(
                fontSize: 18,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
