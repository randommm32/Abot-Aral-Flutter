import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class TakeAttendancePage extends StatefulWidget {
  final String courseTitle;
  final String sessionDate;
  final String sessionTime;
  final String location;

  const TakeAttendancePage({
    super.key,
    required this.courseTitle,
    this.sessionDate = 'Today, Jan 29, 2026',
    this.sessionTime = '2:00 PM - 4:00 PM',
    this.location = 'Barangay Hall, Room 3',
  });

  @override
  State<TakeAttendancePage> createState() => _TakeAttendancePageState();
}

class _TakeAttendancePageState extends State<TakeAttendancePage> {
  // Attendance status: 0 = not marked, 1 = present, 2 = late, 3 = absent
  final List<Map<String, dynamic>> _students = [
    {'name': 'Juan dela Cruz', 'initials': 'JD', 'status': 0},
    {'name': 'Maria Santos', 'initials': 'MS', 'status': 0},
    {'name': 'Pedro Reyes', 'initials': 'PR', 'status': 0},
    {'name': 'Ana Garcia', 'initials': 'AG', 'status': 0},
    {'name': 'Carlos Mendoza', 'initials': 'CM', 'status': 0},
    {'name': 'Sofia Rivera', 'initials': 'SR', 'status': 0},
    {'name': 'Miguel Torres', 'initials': 'MT', 'status': 0},
    {'name': 'Isabella Cruz', 'initials': 'IC', 'status': 0},
    {'name': 'Diego Ramirez', 'initials': 'DR', 'status': 0},
    {'name': 'Carmen Lopez', 'initials': 'CL', 'status': 0},
    {'name': 'Ricardo Fernandez', 'initials': 'RF', 'status': 0},
    {'name': 'Lucia Martinez', 'initials': 'LM', 'status': 0},
  ];

  final TextEditingController _notesController = TextEditingController();

  int get _presentCount => _students.where((s) => s['status'] == 1).length;
  int get _lateCount => _students.where((s) => s['status'] == 2).length;
  int get _absentCount => _students.where((s) => s['status'] == 3).length;
  int get _pendingCount => _students.where((s) => s['status'] == 0).length;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _updateStatus(int index, int status) {
    setState(() {
      _students[index]['status'] = status;
    });
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row: Check icon + Title on left, X button on right
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side: Check icon + Title
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent1,
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/check-circle.svg',
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(
                            AppColors.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Save Attendance?',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  // Right side: X button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Statement text left-aligned
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'This will save attendance for ${_students.length} students.\nPresent: $_presentCount, Absent: $_absentCount, Late: $_lateCount.',
                  textAlign: TextAlign.left,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Go back to home
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Attendance saved successfully!',
                              style: GoogleFonts.inter(),
                            ),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
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
                        'Save Attendance',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),

                  const SizedBox(height: 10),
                  Text(
                    'Take Attendance',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.courseTitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.background,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Session Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.accent1,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Column(
                        children: [
                          _SessionInfoItem(
                            icon: SvgPicture.asset(
                              'assets/instructor_icons/calendar.svg',
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(
                                AppColors.primary,
                                BlendMode.srcIn,
                              ),
                            ),
                            text: widget.sessionDate,
                          ),
                          const SizedBox(height: 8),
                          _SessionInfoItem(
                            icon: SvgPicture.asset(
                              'assets/icons/clock.svg',
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(
                                AppColors.primary,
                                BlendMode.srcIn,
                              ),
                            ),
                            text: widget.sessionTime,
                          ),
                          const SizedBox(height: 8),
                          _SessionInfoItem(
                            icon: SvgPicture.asset(
                              'assets/instructor_icons/pin.svg',
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(
                                AppColors.primary,
                                BlendMode.srcIn,
                              ),
                            ),
                            text: widget.location,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Stats Row
                    Row(
                      children: [
                        _StatBadge(
                          value: _presentCount.toString(),
                          label: 'Present',
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        _StatBadge(
                          value: _lateCount.toString(),
                          label: 'Late',
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        _StatBadge(
                          value: _absentCount.toString(),
                          label: 'Absent',
                          color: Colors.red,
                        ),
                        const SizedBox(width: 12),
                        _StatBadge(
                          value: _pendingCount.toString(),
                          label: 'Pending',
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Students Header
                    Text(
                      'Students (${_students.length})',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Students List
                    ...List.generate(_students.length, (index) {
                      final student = _students[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _StudentAttendanceCard(
                          name: student['name'],
                          initials: student['initials'],
                          status: student['status'],
                          onStatusChanged: (status) =>
                              _updateStatus(index, status),
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    // Session Notes
                    Text(
                      'Session Notes',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Add any notes about this session...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textHint,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pendingCount > 0 ? null : _showSaveDialog,
                icon: const Icon(Icons.check, size: 18),
                label: Text(
                  _pendingCount > 0
                      ? 'Mark $_pendingCount more to save'
                      : 'Save Attendance',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                  disabledForegroundColor: Colors.white.withOpacity(0.8),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            if (_pendingCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Please mark attendance for all students before saving',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SessionInfoItem extends StatelessWidget {
  final SvgPicture icon;
  final String text;

  const _SessionInfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatBadge({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
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

class _StudentAttendanceCard extends StatelessWidget {
  final String name;
  final String initials;
  final int status; // 0 = not marked, 1 = present, 2 = late, 3 = absent
  final Function(int) onStatusChanged;

  const _StudentAttendanceCard({
    required this.name,
    required this.initials,
    required this.status,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _AttendanceChip(
                label: 'Present',
                icon: Icons.check,
                isSelected: status == 1,
                color: AppColors.primary,
                onTap: () => onStatusChanged(1),
              ),
              const SizedBox(width: 8),
              _AttendanceChip(
                label: 'Late',
                icon: Icons.access_time,
                isSelected: status == 2,
                color: Colors.orange,
                onTap: () => onStatusChanged(2),
              ),
              const SizedBox(width: 8),
              _AttendanceChip(
                label: 'Absent',
                icon: Icons.close,
                isSelected: status == 3,
                color: Colors.red,
                onTap: () => onStatusChanged(3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _AttendanceChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? color : AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? color : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? color : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
