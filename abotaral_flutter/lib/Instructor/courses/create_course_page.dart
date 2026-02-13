import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'learning_material_details_page.dart';
import '../../core/constants/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/models/course_model.dart';

class CreateCoursePage extends StatefulWidget {
  const CreateCoursePage({super.key});

  @override
  State<CreateCoursePage> createState() => _CreateCoursePageState();
}

class _CreateCoursePageState extends State<CreateCoursePage> {
  final _titleController = TextEditingController();
  PlatformFile? _pickedFile;
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _maxLearnersController = TextEditingController();
  String _selectedDifficulty = 'Beginner';
  String? _selectedCategory;
  bool _isLoading = false;


  final List<String> _categories = [
    'English & Filipino',
    'Scientific and Critical Thinking Skills',
    'Mathematics and Problem Solving Skills',
    'Life and Career Skills',
    'Understanding Self and Society',
    'Digital Citizenship',
    'Others',
  ];

  final List<TextEditingController> _objectiveControllers = [
    TextEditingController(),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _maxLearnersController.dispose();
    for (var controller in _objectiveControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addObjective() {
    setState(() {
      _objectiveControllers.add(TextEditingController());
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null) {
      setState(() {
        _pickedFile = result.files.first;
      });
    }
  }

  Future<String?> _uploadCoverImage(String userId) async {
    if (_pickedFile == null) return null;

    try {
      final fileExt = _pickedFile!.extension ?? 'jpg';
      final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
      final filePath = '$userId/$fileName';

      if (_pickedFile!.bytes != null) {
        // Web upload (if supported)
        await Supabase.instance.client.storage
            .from('course_covers')
            .uploadBinary(filePath, _pickedFile!.bytes!);
      } else if (_pickedFile!.path != null) {
        // IO upload
        final file = File(_pickedFile!.path!);
        await Supabase.instance.client.storage
            .from('course_covers')
            .upload(filePath, file);
      }

      final imageUrl = Supabase.instance.client.storage
          .from('course_covers')
          .getPublicUrl(filePath);
      
      return imageUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      // Continue without image or rethrow? 
      // Rethrow to alert user
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> _createCourse() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _selectedCategory == null ||
        _durationController.text.isEmpty ||
        _maxLearnersController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      String? coverUrl;
      if (_pickedFile != null) {
        coverUrl = await _uploadCoverImage(user.id);
      }

      final course = Course(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory!,
        difficulty: _selectedDifficulty,
        duration: int.parse(_durationController.text),
        maxLearners: int.parse(_maxLearnersController.text),
        objectives: _objectiveControllers
            .map((c) => c.text)
            .where((text) => text.isNotEmpty)
            .toList(),
        facilitatorId: user.id,
        coverUrl: coverUrl,
      );

      final courseJson = course.toJson();
      debugPrint('Creating course with payload: $courseJson');

      await Supabase.instance.client
          .from('courses')
          .insert(courseJson);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); // Return to course list
    } catch (e) {
      debugPrint('Error creating course: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating course: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showCreateStrandDialog() {
    final courseTitle = _titleController.text.isEmpty
        ? 'this course'
        : '"${_titleController.text}"';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon and close button row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accent1,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(10),
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
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                'Create Strand?',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              // Description
              Text(
                'This will create $courseTitle and make it available for learner enrollment.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              // Buttons row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Close confirmation dialog
                        _createCourse(); // Start creation process
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Create Course',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
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
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Green Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Create New Course',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Set up your course details',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course Image (Placeholder for now)
                    Text(
                      'Course Image',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _pickFile,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.accent1,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.image_outlined,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _pickedFile != null
                                      ? 'Selected: ${_pickedFile!.name}'
                                      : 'Upload Cover Image',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _pickedFile != null
                                      ? '${(_pickedFile!.size / 1024).toStringAsFixed(2)} KB'
                                      : 'Recommended: 1200×630px',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Course Title
                    _buildLabel('Course Title', isRequired: true),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _titleController,
                      hint: 'e.g., Introduction to Digital Literacy',
                    ),
                    const SizedBox(height: 20),
                    // Course Description
                    _buildLabel('Course Description', isRequired: true),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _descriptionController,
                      hint: 'Describe what learners will gain from this course...',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 20),
                    // Category
                    _buildLabel('Category', isRequired: true),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                         filled: true,
                         fillColor: Colors.white,
                         contentPadding: const EdgeInsets.symmetric(
                           horizontal: 16,
                           vertical: 14,
                         ),
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
                           borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                         ),
                         hintText: 'Select category',
                         hintStyle: GoogleFonts.inter(
                           fontSize: 14,
                           color: AppColors.textSecondary,
                         ),
                      ),
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(
                            category,
                            style: GoogleFonts.inter(
                               fontSize: 14, color: AppColors.textPrimary),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Difficulty Level
                    _buildLabel('Difficulty Level'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _DifficultyChip(
                          label: 'Beginner',
                          isSelected: _selectedDifficulty == 'Beginner',
                          onTap: () => setState(() => _selectedDifficulty = 'Beginner'),
                        ),
                        const SizedBox(width: 8),
                        _DifficultyChip(
                          label: 'Intermediate',
                          isSelected: _selectedDifficulty == 'Intermediate',
                          onTap: () => setState(() => _selectedDifficulty = 'Intermediate'),
                        ),
                        const SizedBox(width: 8),
                        _DifficultyChip(
                          label: 'Advanced',
                          isSelected: _selectedDifficulty == 'Advanced',
                          onTap: () => setState(() => _selectedDifficulty = 'Advanced'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Duration and Max Learners
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Est. Duration (hours)'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _durationController,
                                hint: 'e.g., 20',
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Max Learners'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _maxLearnersController,
                                hint: 'e.g., 30',
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Learning Objectives
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel('Learning Objectives'),
                        GestureDetector(
                          onTap: _addObjective,
                          child: Text(
                            '+ Add Objective',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(
                      _objectiveControllers.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildTextField(
                          controller: _objectiveControllers[index],
                          hint: 'Objective ${index + 1}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Create strand Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _showCreateStrandDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/instructor_icons/save.svg',
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Create Strand',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Cancel Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
        ), // SafeArea
      ), // Scaffold
      if (_isLoading)
        Container(
          color: Colors.black54,
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
    ],
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        if (isRequired)
          Text(
            ' *',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
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
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}



class _DifficultyChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
