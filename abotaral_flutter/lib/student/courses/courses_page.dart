import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import 'course_lessons_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/models/course_model.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  late Stream<List<Map<String, dynamic>>> _coursesStream;
  String _selectedSort = 'Date (Newest)';

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  void _initStream() {
    var query = Supabase.instance.client.from('courses').stream(primaryKey: ['id']);

    if (_selectedSort == 'Date (Newest)') {
      _coursesStream = query.order('created_at', ascending: false);
    } else if (_selectedSort == 'Date (Oldest)') {
      _coursesStream = query.order('created_at', ascending: true);
    } else if (_selectedSort == 'Name (A-Z)') {
      _coursesStream = query.order('title', ascending: true);
    } else if (_selectedSort == 'Name (Z-A)') {
      _coursesStream = query.order('title', ascending: false);
    } else {
      // Default
      _coursesStream = query.order('created_at', ascending: false);
    }
    setState(() {});
  }

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
            // Sorting Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Courses',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      _selectedSort = value;
                      _initStream();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'Date (Newest)',
                        child: Text('Date (Newest)'),
                      ),
                      const PopupMenuItem(
                        value: 'Date (Oldest)',
                        child: Text('Date (Oldest)'),
                      ),
                      const PopupMenuItem(
                        value: 'Name (A-Z)',
                        child: Text('Name (A-Z)'),
                      ),
                      const PopupMenuItem(
                        value: 'Name (Z-A)',
                        child: Text('Name (Z-A)'),
                      ),
                    ],
                    child: Row(
                      children: [
                        Text(
                          _selectedSort,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Course List
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _coursesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final courses =
                      snapshot.data!.map((e) => Course.fromJson(e)).toList();

                  if (courses.isEmpty) {
                    return Center(
                      child: Text(
                        'No courses available.',
                        style: GoogleFonts.inter(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: courses.length,
                    separatorBuilder: (context, _) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      // TODO: Fetch progress for this student
                      return _CourseItem(
                        title: course.title,
                        subtitle: course.category,
                        progress: 0.0, // Default to 0 for now
                        lessonCount: 0, // TODO: Fetch lesson count
                        isCompleted: false,
                        onContinue: () => _navigateToCourse(context, course),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCourse(BuildContext context, Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseLessonsPage(course: course),
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
  final VoidCallback? onContinue;

  const _CourseItem({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.lessonCount,
    this.isCompleted = false,
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
      builder: (_) => Dialog(
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
