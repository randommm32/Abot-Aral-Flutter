import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'student_detail_page.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<_StudentData> _allStudents = [
    _StudentData(
      name: 'Juan dela Cruz',
      course: 'Learning Material 1',
      progress: 85,
      status: 'Active',
    ),
    _StudentData(
      name: 'Maria Santos',
      course: 'Digital Citizenship',
      progress: 92,
      status: 'Active',
    ),
    _StudentData(
      name: 'Pedro Reyes',
      course: 'Learning Material 1',
      progress: 67,
      status: 'At Risk',
    ),
    _StudentData(
      name: 'Ana Garcia',
      course: 'Math Basics',
      progress: 78,
      status: 'Active',
    ),
    _StudentData(
      name: 'Carlos Mendoza',
      course: 'Learning Material 2',
      progress: 45,
      status: 'At Risk',
    ),
    _StudentData(
      name: 'Sofia Rivera',
      course: 'Digital Citizenship',
      progress: 88,
      status: 'Active',
    ),
  ];

  List<_StudentData> get _filteredStudents {
    var students = _allStudents;
    if (_selectedFilter != 'All') {
      students = students.where((s) => s.status == _selectedFilter).toList();
    }
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      students = students
          .where(
            (s) =>
                s.name.toLowerCase().contains(query) ||
                s.course.toLowerCase().contains(query),
          )
          .toList();
    }
    return students;
  }

  int get _activeCount =>
      _allStudents.where((s) => s.status == 'Active').length;
  int get _atRiskCount =>
      _allStudents.where((s) => s.status == 'At Risk').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Green Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Bell
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Students',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showNotificationsDialog(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: SvgPicture.asset(
                            'assets/icons/bell.svg',
                            width: 25,
                            height: 25,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search students...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textHint,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: SvgPicture.asset(
                            'assets/instructor_icons/search.svg',
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                              AppColors.textSecondary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Filter Tabs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _FilterTab(
                          label: 'All (${_allStudents.length})',
                          isSelected: _selectedFilter == 'All',
                          onTap: () => setState(() => _selectedFilter = 'All'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _FilterTab(
                          label: 'Active ($_activeCount)',
                          isSelected: _selectedFilter == 'Active',
                          onTap: () =>
                              setState(() => _selectedFilter = 'Active'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _FilterTab(
                          label: 'At Risk ($_atRiskCount)',
                          isSelected: _selectedFilter == 'At Risk',
                          onTap: () =>
                              setState(() => _selectedFilter = 'At Risk'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Students List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _filteredStudents.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _StudentCard(student: _filteredStudents[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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

class _StudentData {
  final String name;
  final String course;
  final int progress;
  final String status;

  const _StudentData({
    required this.name,
    required this.course,
    required this.progress,
    required this.status,
  });
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.primary : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final _StudentData student;

  const _StudentCard({required this.student});

  Color get _progressColor {
    if (student.progress >= 70) return AppColors.accent3;
    if (student.progress >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentDetailPage(
              studentName: student.name,
              course: student.course,
              progress: student.progress,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accent3,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  student.name.split(' ').map((n) => n[0]).take(2).join(),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
                    student.name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    student.course,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Progress bar row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.accent1,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: student.progress / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _progressColor,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SvgPicture.asset(
                        'assets/icons/trending-up.svg',
                        width: 14,
                        height: 14,
                        colorFilter: ColorFilter.mode(
                          _progressColor,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${student.progress}%',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _progressColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Chevron
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
