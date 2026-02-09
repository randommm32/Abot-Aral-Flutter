import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EnrolledLearnersPage extends StatefulWidget {
  final String courseTitle;
  final String courseSubtitle;

  const EnrolledLearnersPage({
    super.key,
    required this.courseTitle,
    required this.courseSubtitle,
  });

  @override
  State<EnrolledLearnersPage> createState() => _EnrolledLearnersPageState();
}

class _EnrolledLearnersPageState extends State<EnrolledLearnersPage> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<_LearnerData> _allLearners = [
    _LearnerData(
      name: 'Maria Santos',
      lrn: 'LRN: 202601234567',
      progress: 85,
      status: 'Active',
      lastActive: 'Active 2 hours ago',
    ),
    _LearnerData(
      name: 'Juan dela Cruz',
      lrn: 'LRN: 202601234568',
      progress: 72,
      status: 'Active',
      lastActive: 'Active 1 day ago',
    ),
    _LearnerData(
      name: 'Ana Reyes',
      lrn: 'LRN: 202601234569',
      progress: 45,
      status: 'At Risk',
      lastActive: 'Active 3 days ago',
    ),
    _LearnerData(
      name: 'Pedro Garcia',
      lrn: 'LRN: 202601234570',
      progress: 91,
      status: 'Active',
      lastActive: 'Active 5 hours ago',
    ),
    _LearnerData(
      name: 'Rosa Cruz',
      lrn: 'LRN: 202601234571',
      progress: 68,
      status: 'Active',
      lastActive: 'Active 1 day ago',
    ),
    _LearnerData(
      name: 'Carlos Mendoza',
      lrn: 'LRN: 202601234572',
      progress: 38,
      status: 'At Risk',
      lastActive: 'Active 5 days ago',
    ),
    _LearnerData(
      name: 'Sofia Torres',
      lrn: 'LRN: 202601234573',
      progress: 79,
      status: 'Active',
      lastActive: 'Active 4 hours ago',
    ),
    _LearnerData(
      name: 'Miguel Flores',
      lrn: 'LRN: 202601234574',
      progress: 15,
      status: 'Inactive',
      lastActive: 'Active 1 week ago',
    ),
  ];

  List<_LearnerData> get _filteredLearners {
    var learners = _allLearners;
    if (_selectedFilter != 'All') {
      learners = learners.where((l) => l.status == _selectedFilter).toList();
    }
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      learners = learners
          .where(
            (l) =>
                l.name.toLowerCase().contains(query) ||
                l.lrn.toLowerCase().contains(query),
          )
          .toList();
    }
    return learners;
  }

  int get _activeCount =>
      _allLearners.where((l) => l.status == 'Active').length;
  int get _atRiskCount =>
      _allLearners.where((l) => l.status == 'At Risk').length;
  int get _inactiveCount =>
      _allLearners.where((l) => l.status == 'Inactive').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Green Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: AppColors.primary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button row
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: SvgPicture.asset(
                            'assets/icons/arrow-left.svg',
                            width: 24,
                            height: 24,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Learning Strands',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Enrolled Learners',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.courseTitle,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Summary Stats
              Container(
                color: Colors.white,
                padding: EdgeInsets.only(left:20, right: 20, top: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryStatCard(
                        value: '${_allLearners.length}',
                        label: 'Total',
                        color: AppColors.textPrimary,
                        bgColor: const Color(0xFFF3F4F6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryStatCard(
                        value: '$_activeCount',
                        label: 'Active',
                        color: AppColors.primary,
                        bgColor: AppColors.accent1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryStatCard(
                        value: '$_atRiskCount',
                        label: 'At Risk',
                        color: const Color(0xFFF59E0B),
                        bgColor: const Color(0xFFFEF3C7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryStatCard(
                        value: '$_inactiveCount',
                        label: 'Inactive',
                        color: const Color(0xFFEF4444),
                        bgColor: const Color(0xFFFEE2E2),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search by name or reference number...',
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
                            label: 'All (${_allLearners.length})',
                            isSelected: _selectedFilter == 'All',
                            onTap: () =>
                                setState(() => _selectedFilter = 'All'),
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: _FilterTab(
                            label: 'Inactive ($_inactiveCount)',
                            isSelected: _selectedFilter == 'Inactive',
                            onTap: () =>
                                setState(() => _selectedFilter = 'Inactive'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.primary),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/instructor_icons/mail.svg',
                                    width: 18,
                                    height: 18,
                                    colorFilter: const ColorFilter.mode(
                                      AppColors.primary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Message All',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/instructor_icons/plus.svg',
                                    width: 18,
                                    height: 18,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Enroll New',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Learners List
                    Text(
                      'Learners (${_filteredLearners.length})',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._filteredLearners.map(
                      (learner) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _LearnerCard(learner: learner),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearnerData {
  final String name;
  final String lrn;
  final int progress;
  final String status;
  final String lastActive;

  const _LearnerData({
    required this.name,
    required this.lrn,
    required this.progress,
    required this.status,
    required this.lastActive,
  });
}

class _SummaryStatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color bgColor;

  const _SummaryStatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _LearnerCard extends StatelessWidget {
  final _LearnerData learner;

  const _LearnerCard({required this.learner});

  Color get _statusColor {
    switch (learner.status) {
      case 'Active':
        return AppColors.primary;
      case 'At Risk':
        return const Color(0xFFF59E0B);
      case 'Inactive':
        return const Color(0xFFEF4444);
      default:
        return AppColors.textSecondary;
    }
  }

  Color get _statusBgColor {
    switch (learner.status) {
      case 'Active':
        return AppColors.accent1;
      case 'At Risk':
        return const Color(0xFFFEF3C7);
      case 'Inactive':
        return const Color(0xFFFEE2E2);
      default:
        return AppColors.scaffoldBackground;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar - always accent3
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accent3,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                learner.name.split(' ').map((n) => n[0]).take(2).join(),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Main content column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  learner.name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                // LRN
                Text(
                  learner.lrn,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
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
                    SvgPicture.asset(
                      'assets/icons/trending-up.svg',
                      width: 14,
                      height: 14,
                      colorFilter: const ColorFilter.mode(
                        AppColors.accent3,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${learner.progress}%',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Progress Bar
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.accent1,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: learner.progress / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.accent3,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Status badge and Last Active text
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _statusBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        learner.status,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• ${learner.lastActive}',
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
          const SizedBox(width: 8),
          // Chevron icon on the right
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
            size: 24,
          ),
        ],
      ),
    );
  }
}
