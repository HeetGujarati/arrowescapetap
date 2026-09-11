import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class StreakBadge extends StatelessWidget {
  final int days;

  const StreakBadge({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    final displayDays = days > 0 ? days : 1;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🔥', style: TextStyle(fontSize: 20))
            .animate(onPlay: (c) => c.repeat())
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.15, 1.15),
              duration: 900.ms,
              curve: Curves.easeInOut,
            )
            .then()
            .scale(
              begin: const Offset(1.15, 1.15),
              end: const Offset(0.9, 0.9),
              duration: 900.ms,
              curve: Curves.easeInOut,
            ),
        const SizedBox(width: 5),
        Text(
          '$displayDays',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFFF7A00),
          ),
        ),
      ],
    );
  }
}
