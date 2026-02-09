import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

enum QuizOptionState { normal, selected, correct, incorrect }

class QuizOption extends StatelessWidget {
  final String label;
  final String text;
  final QuizOptionState state;
  final VoidCallback? onTap;

  const QuizOption({
    super.key,
    required this.label,
    required this.text,
    this.state = QuizOptionState.normal,
    this.onTap,
  });

  Color get _backgroundColor {
    switch (state) {
      case QuizOptionState.selected:
        return AppColors.accent1;
      case QuizOptionState.correct:
        return AppColors.success.withValues(alpha: 0.1);
      case QuizOptionState.incorrect:
        return AppColors.error.withValues(alpha: 0.1);
      default:
        return Colors.white;
    }
  }

  Color get _borderColor {
    switch (state) {
      case QuizOptionState.selected:
        return AppColors.primary;
      case QuizOptionState.correct:
        return AppColors.success;
      case QuizOptionState.incorrect:
        return AppColors.error;
      default:
        return AppColors.border;
    }
  }

  Color get _radioColor {
    switch (state) {
      case QuizOptionState.selected:
        return AppColors.primary;
      case QuizOptionState.correct:
        return AppColors.success;
      case QuizOptionState.incorrect:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _radioColor, width: 2),
                color: state != QuizOptionState.normal
                    ? _radioColor
                    : Colors.transparent,
              ),
              child: state != QuizOptionState.normal
                  ? Icon(
                      state == QuizOptionState.correct
                          ? Icons.check
                          : state == QuizOptionState.incorrect
                          ? Icons.close
                          : Icons.circle,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
