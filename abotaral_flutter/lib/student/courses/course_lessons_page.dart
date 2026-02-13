import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/models/learning_material_model.dart';
import '../../core/models/module_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/course_model.dart';
import 'assessment_questions_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/student_widgets/lesson_item.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../chat/class_forum_page.dart';
import 'courses_page.dart';

class CourseLessonsPage extends StatefulWidget {
  final Course course;

  const CourseLessonsPage({super.key, required this.course});

  @override
  State<CourseLessonsPage> createState() => _CourseLessonsPageState();
}

class _CourseLessonsPageState extends State<CourseLessonsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/arrow-left.svg',
            width: 20,
            height: 20,
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CoursesPage()),
          ),
        ),
        title: Text(
          'Course',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showNotificationsDialog(context);
            },
            icon: SvgPicture.asset(
              'assets/icons/bell.svg',
              width: 24,
              height: 24,
            ),
            padding: EdgeInsets.only(right: 20),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.course.title,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'English and Filipino',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                // Tab Buttons
                Row(
                  children: [
                    Expanded(
                      child: _TabButton(
                        icon: SvgPicture.asset(
                          'assets/icons/book-open.svg',
                          width: 20,
                          height: 20,
                        ),
                        label: 'Lessons',
                        isSelected: _selectedTabIndex == 0,
                        onTap: () => _tabController.animateTo(0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TabButton(
                        icon: SvgPicture.asset(
                          'assets/icons/edit-2.svg',
                          width: 24,
                          height: 20,
                        ),
                        label: 'Assessments',
                        isSelected: _selectedTabIndex == 1,
                        onTap: () => _tabController.animateTo(1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _LessonsTab(course: widget.course),
                _AssessmentsTab(course: widget.course),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final SvgPicture icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                isSelected ? Colors.white : AppColors.textSecondary,
                BlendMode.srcIn,
              ),
              child: icon,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonsTab extends StatefulWidget {
  final Course course;

  const _LessonsTab({required this.course});

  @override
  State<_LessonsTab> createState() => _LessonsTabState();
}

class _LessonsTabState extends State<_LessonsTab> {
  bool _isLoading = true;
  List<Module> _modules = [];
  List<LearningMaterial> _materials = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final courseId = widget.course.id;
      if (courseId == null) return;

      // Fetch Modules
      final modulesData = await Supabase.instance.client
          .from('modules')
          .select()
          .eq('course_id', courseId)
          .order('order_index', ascending: true);

      final modules = (modulesData as List)
          .map((e) => Module.fromJson(e))
          .toList();

      // Fetch Course-level Materials (where module_id is null)
      final materialsData = await Supabase.instance.client
          .from('learning_materials')
          .select()
          .eq('course_id', courseId)
          .filter('module_id', 'is', null)
          .order('created_at', ascending: false);

      final materials = (materialsData as List)
          .map((e) => LearningMaterial.fromJson(e))
          .toList();

      if (mounted) {
        setState(() {
          _modules = modules;
          _materials = materials;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching lesson data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _launchDownloadUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch course material: $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured / Current Lesson Placeholder (Static for now or first module)
          _FeaturedLessonCard(),

          const SizedBox(height: 16),
          // Class Forum Button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ClassForumPage()),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/users.svg',
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Class Forum',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Lesson Materials Container
          if (_materials.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lesson materials',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _materials.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final material = _materials[index];
                      return LessonItem(
                        title: material.title,
                        fileType: material.fileType ?? 'file',
                        onTap: () => _launchDownloadUrl(material.fileUrl),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Course Content Container (Modules)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Course Content',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                if (_modules.isEmpty)
                  Text(
                    'No modules yet.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _modules.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final module = _modules[index];
                      return _ContentSection(
                        number: index + 1,
                        title: module.title,
                        duration: '14:30', // Placeholder duration
                        isCompleted: false, // Placeholder completion
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Module Progress Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Module Progress',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '0%', // Placeholder
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.0, // Placeholder
                    backgroundColor: AppColors.accent1,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '0 of ${_modules.length} lessons completed',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _FeaturedLessonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.accent1,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.pause,
                        color: AppColors.textSecondary,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Practical Examples',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Duration: 14:07',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}

class _ContentSection extends StatelessWidget {
  final int number;
  final String title;
  final String duration;
  final bool isCompleted;

  const _ContentSection({
    required this.number,
    required this.title,
    required this.duration,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Number circle
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.accent1 : AppColors.accent1,
              shape: BoxShape.circle,
              border: isCompleted
                  ? null
                  : Border.all(color: AppColors.textSecondary),
            ),
            child: Center(
              child: isCompleted
                  ? SvgPicture.asset(
                      'assets/icons/check-circle.svg',
                      width: 20,
                      height: 20,
                    )
                  : Text(
                      '$number',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
            ),
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
                Text(
                  duration,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssessmentsTab extends StatelessWidget {
  final Course course;

  const _AssessmentsTab({required this.course});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _AssessmentItem(
          title: 'Quiz 1',
          subtitle: 'English Sentences',
          buttonText: 'Start Quiz',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AssessmentQuestionsPage(
                  course: course,
                  quizTitle: 'Quiz 1', // TODO: Dynamic quizzes
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _AssessmentItem(
          title: 'Seatwork 1',
          subtitle: 'Essay Writing',
          buttonText: 'Start',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AssessmentQuestionsPage(
                  course: course,
                  quizTitle: 'Seatwork 1', // TODO: Dynamic seatworks
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AssessmentItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback? onTap;

  const _AssessmentItem({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    this.onTap,
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
          // Header with checkbox icon
          Row(
            children: [
              SvgPicture.asset('assets/icons/book.svg', width: 20, height: 20),
              const SizedBox(width: 8),
              Text(
                'Test your knowledge!',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Quiz title
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          // Subtitle
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          // Start button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
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
