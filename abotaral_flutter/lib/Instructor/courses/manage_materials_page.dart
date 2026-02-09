import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_colors.dart';
import 'upload_materials_page.dart';

class ManageMaterialsPage extends StatelessWidget {
  final String learningMaterialTitle;

  const ManageMaterialsPage({super.key, required this.learningMaterialTitle});

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
                decoration: BoxDecoration(color: AppColors.primary),
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
                            color: Colors.white.withAlpha(230),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Manage Materials',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      learningMaterialTitle,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withAlpha(200),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

                Container(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: // Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: _HeaderStatCard(
                            value: '4',
                            label: 'Total Files',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _HeaderStatCard(
                            value: '202',
                            label: 'Total Views',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _HeaderStatCard(
                            value: '97',
                            label: 'Downloads',
                          ),
                        ),
                      ],
                    ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search materials...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textSecondary,
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
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Upload New Material Button
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UploadMaterialsPage(
                                courseTitle: 'Learning Strand',
                                learningMaterialTitle: learningMaterialTitle,
                              ),
                            ),
                          );
                        },
                        icon: SvgPicture.asset(
                          'assets/instructor_icons/plus.svg',
                          width: 18,
                          height: 18,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        label: Text(
                          'Upload New Material',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // All Materials Section
                    Text(
                      'All Materials (4)',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Material Items
                    _MaterialCard(
                      title: 'Week 1 Reading Assignment',
                      fileName: 'English_Adjectives.pdf',
                      fileSize: '2.3 MB',
                      uploadDate: 'Jan 15, 2026',
                      views: 45,
                      downloads: 28,
                    ),
                    const SizedBox(height: 12),
                    _MaterialCard(
                      title: 'Grammar Practice Exercises',
                      fileName: 'Reading_Exercise.pdf',
                      fileSize: '1.8 MB',
                      uploadDate: 'Jan 20, 2026',
                      views: 38,
                      downloads: 22,
                    ),
                    const SizedBox(height: 12),
                    _MaterialCard(
                      title: 'Vocabulary Lists',
                      fileName: 'Vocabulary_List.pdf',
                      fileSize: '850 KB',
                      uploadDate: 'Jan 22, 2026',
                      views: 52,
                      downloads: 35,
                    ),
                    const SizedBox(height: 12),
                    _MaterialCard(
                      title: 'Pronunciation Guide Video',
                      fileName: 'pronunciation.mp4',
                      fileSize: '45 MB',
                      uploadDate: 'Jan 25, 2026',
                      views: 67,
                      downloads: 12,
                      isVideo: true,
                    ),
                    const SizedBox(height: 24),
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

class _HeaderStatCard extends StatelessWidget {
  final String value;
  final String label;

  const _HeaderStatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.accent1,
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
              color: AppColors.primary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final String title;
  final String fileName;
  final String fileSize;
  final String uploadDate;
  final int views;
  final int downloads;
  final bool isVideo;

  const _MaterialCard({
    required this.title,
    required this.fileName,
    required this.fileSize,
    required this.uploadDate,
    required this.views,
    required this.downloads,
    this.isVideo = false,
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isVideo ? const Color(0xFFDCFCE7) : AppColors.accent1,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    isVideo
                        ? 'assets/icons/video.svg'
                        : 'assets/icons/file-text.svg',
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(
                      isVideo ? AppColors.primary : AppColors.primary,
                      BlendMode.srcIn,
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
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$fileName • $fileSize',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Uploaded: $uploadDate',
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
          const SizedBox(height: 12),
          // Stats Row
          Row(
            children: [
              SvgPicture.asset(
                'assets/instructor_icons/view.svg',
                width: 14,
                height: 14,
                colorFilter: const ColorFilter.mode(
                  AppColors.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '$views views',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              SvgPicture.asset(
                'assets/icons/download.svg',
                width: 14,
                height: 14,
                colorFilter: const ColorFilter.mode(
                  AppColors.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '$downloads downloads',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Action Buttons Row
          Row(
            children: [
              _ActionChip(
                icon: 'assets/icons/download.svg',
                label: 'Download',
                backgroundColor: AppColors.accent1,
                textColor: AppColors.primary,
                onTap: () {},
              ),
              const SizedBox(width: 8),
              _ActionChip(
                icon: 'assets/instructor_icons/edit.svg',
                label: 'Edit',
                backgroundColor: AppColors.scaffoldBackground,
                textColor: AppColors.textSecondary,
                onTap: () {},
              ),
              const SizedBox(width: 8),
              _ActionChip(
                icon: 'assets/instructor_icons/delete.svg',
                label: 'Delete',
                backgroundColor: const Color(0xFFFEE2E2),
                textColor: const Color(0xFFEF4444),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              icon,
              width: 14,
              height: 14,
              colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
