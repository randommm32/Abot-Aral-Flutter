import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'create_course_page.dart';
import 'learning_material_details_page.dart';
import 'manage_materials_page.dart';
import '../students/course_reports_page.dart';

class CourseTab extends StatefulWidget {
  const CourseTab({super.key});

  @override
  State<CourseTab> createState() => _CourseTabState();
}

class _CourseTabState extends State<CourseTab> {
  final _userId = Supabase.instance.client.auth.currentUser?.id;
  late Stream<List<Map<String, dynamic>>> _coursesStream;
  String _selectedSort = 'Date (Newest)';

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  void _initStream() {
    var query = Supabase.instance.client
        .from('courses')
        .stream(primaryKey: ['id'])
        .eq('facilitator_id', _userId!);

    if (_selectedSort == 'Date (Newest)') {
      _coursesStream = query.order('created_at', ascending: false);
    } else if (_selectedSort == 'Date (Oldest)') {
      _coursesStream = query.order('created_at', ascending: true);
    } else if (_selectedSort == 'Name (A-Z)') {
      _coursesStream = query.order('title', ascending: true);
    } else if (_selectedSort == 'Name (Z-A)') {
      _coursesStream = query.order('title', ascending: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Center(child: Text('Please log in'));
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Green Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.primary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row with Title and Bell
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Learning Strands',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: SvgPicture.asset(
                            'assets/icons/bell.svg',
                            width: 25,
                            height: 25,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          onPressed: () => _showNotificationsDialog(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Stats Row
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _coursesStream,
                      builder: (context, snapshot) {
                        final count = snapshot.data?.length ?? 0;
                        return Row(
                          children: [
                            Expanded(
                              child: _HeaderStatCard(
                                  value: count.toString(), label: 'Active'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _HeaderStatCard(
                                value: '55', // Placeholder for total learners
                                label: 'Learners',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _HeaderStatCard(
                                value: '23', // Placeholder for total modules
                                label: 'Modules',
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Create New Course Button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateCoursePage(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/instructor_icons/plus.svg',
                        width: 18,
                        height: 18,
                        colorFilter: const ColorFilter.mode(
                          AppColors.background,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Create New Course',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.background,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Active Courses Section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Active Courses',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            setState(() {
                              _selectedSort = value;
                              _initStream();
                            });
                          },
                          itemBuilder: (context) => [
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
                    const SizedBox(height: 16),
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _coursesStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final courses = snapshot.data!;
                        if (courses.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text('No courses yet. Create one!'),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: courses.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final course = courses[index];
                            return _LearningStrandCard(
                              title: course['title'] ?? 'Untitled',
                              subtitle: course['category'] ?? 'No category',
                              learners: course['max_learners'] ?? 0,
                              modules: 0, // TODO: Fetch module count
                              imageUrl: course['cover_image_url'],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        LearningMaterialDetailsPage(
                                      courseId: course['id'],
                                      courseTitle: course['title'],
                                      courseSubtitle: course['category'],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Quick Actions
                    Text(
                      'Quick Actions',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: 'assets/icons/file-text.svg',
                            label: 'Manage Materials',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ManageMaterialsPage(
                                        learningMaterialTitle:
                                            'Learning Material 1', // Placeholder
                                      ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: 'assets/instructor_icons/clipboard.svg',
                            label: 'View Reports',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CourseReportsPage(
                                    courseTitle: 'Learning Material 1', // Placeholder
                                    courseSubtitle: 'English and Filipino',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    // ... existing implementation ...
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
                    title: 'New submission from Juan dela Cruz',
                    time: '2 hours ago',
                    dotColor: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  _NotificationDialogItem(
                    title: 'Maria Santos completed Module 2',
                    time: '5 hours ago',
                    dotColor: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  _NotificationDialogItem(
                    title: 'Session reminder for tomorrow',
                    time: '1 day ago',
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
}

class _HeaderStatCard extends StatelessWidget {
  final String value;
  final String label;

  const _HeaderStatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningStrandCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int learners;
  final int modules;
  final String? imageUrl;
  final VoidCallback onTap;

  const _LearningStrandCard({
    required this.title,
    required this.subtitle,
    required this.learners,
    required this.modules,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Image or Book icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accent1,
                borderRadius: BorderRadius.circular(10),
                image: imageUrl != null && imageUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? null
                  : Center(
                      child: SvgPicture.asset(
                        'assets/icons/book-open.svg',
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          AppColors.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/users.svg',
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                          AppColors.textSecondary,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$learners learners',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SvgPicture.asset(
                        'assets/icons/file-text.svg',
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                          AppColors.textSecondary,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$modules modules',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 24),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accent1,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: SvgPicture.asset(
                  icon,
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
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
