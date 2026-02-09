import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import 'course_lessons_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Row(
                children: [
                  Text(
                    'Course',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      _showNotificationsDialog(context);
                    },
                    icon: SvgPicture.asset(
                        'assets/icons/bell.svg',
                        width: 24,
                        height: 24,
                      ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            // Course List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _CourseItem(
                    title: 'Learning Material 2',
                    subtitle: 'Science and Math',
                    progress: 0.54,
                    lessonCount: 14,
                    isCompleted: true,
                    onContinue: () =>
                        _navigateToCourse(context, 'Learning Material 2'),
                  ),
                  const SizedBox(height: 12),
                  _CourseItem(
                    title: 'Learning Material 2',
                    subtitle: 'Science and Math',
                    progress: 0.89,
                    lessonCount: 67,
                    showDownload: true,
                    onContinue: () =>
                        _navigateToCourse(context, 'Learning Material 2'),
                  ),
                  const SizedBox(height: 12),
                  _CourseItem(
                    title: 'Learning Material 2',
                    subtitle: 'Science and Math',
                    progress: 0.89,
                    lessonCount: 67,
                    isCompleted: true,
                    onContinue: () =>
                        _navigateToCourse(context, 'Learning Material 2'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCourse(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseLessonsPage(courseTitle: title),
      ),
    );
  }
}

class _CourseItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final int lessonCount;
  final bool isCompleted;
  final bool showDownload;
  final VoidCallback? onContinue;

  const _CourseItem({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.lessonCount,
    this.isCompleted = false,
    this.showDownload = false,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with checkmark
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                SvgPicture.asset(
                    'assets/icons/check-circle.svg',
                    width: 20,
                    height: 20,
                  ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress row
          Row(
            children: [
              Text(
                'Progress',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()} %',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.accent1,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          // Bottom row with lesson count and buttons
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/video.svg',
                width: 15,
                height: 15,
              ),
              const SizedBox(width: 4),
              Text(
                '$lessonCount Lessons',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              if (showDownload) ...[
                TextButton.icon(
                  onPressed: () {},
                  icon: SvgPicture.asset(
                    'assets/icons/download.svg',
                    width: 16,
                    height: 16,
                  ),
                  label: Text(
                    'Download',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              TextButton(
                onPressed: onContinue,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}

void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppColors.primary,
              child: Text(
                'Notifications',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _NotificationDialogItem(
                    title: 'A new course is available!',
                    time: '5 min ago',
                    dotColor: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  _NotificationDialogItem(
                    title: 'A new message from Mr. Whatsit',
                    time: '1 hour ago',
                    dotColor: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  _NotificationDialogItem(
                    title: 'Your assessment tasks is returned',
                    time: '2 hours ago',
                    dotColor: AppColors.accent3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

class _NotificationDialogItem extends StatelessWidget {
  final String title;
  final String time;
  final Color dotColor;

  const _NotificationDialogItem({
    required this.title,
    required this.time,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
