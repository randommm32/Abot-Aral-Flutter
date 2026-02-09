import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class LessonItem extends StatelessWidget {
  final String title;
  final String? fileType;
  final bool isCompleted;
  final VoidCallback? onTap;

  const LessonItem({
    super.key,
    required this.title,
    this.fileType,
    this.isCompleted = false,
    this.onTap,
  });

  Widget _getFileIcon() {
    switch (fileType?.toLowerCase()) {
      case 'pdf':
        return SvgPicture.asset(
          'assets/icons/file-text.svg',
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(
            AppColors.primary,
            BlendMode.srcIn,
          ),
        );
      case 'video':
        return Icon(
          Icons.play_circle_outline,
          color: AppColors.primary,
          size: 20,
        );
      case 'doc':
      case 'docx':
        return Icon(Icons.description, color: AppColors.primary, size: 20);
      default:
        return Icon(
          Icons.insert_drive_file_outlined,
          color: AppColors.primary,
          size: 20,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.accent1,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(child: _getFileIcon()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isCompleted)
              Icon(Icons.check_circle, color: AppColors.success, size: 20),
          ],
        ),
      ),
    );
  }
}
