import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class InstructorEditProfilePage extends StatefulWidget {
  const InstructorEditProfilePage({super.key});

  @override
  State<InstructorEditProfilePage> createState() =>
      _InstructorEditProfilePageState();
}

class _InstructorEditProfilePageState extends State<InstructorEditProfilePage> {
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _suffixController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _workLocationController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = true;
  String? _avatarUrl;
  File? _imageFile;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  Future<void> _getProfile() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final email = Supabase.instance.client.auth.currentUser!.email ?? '';
      
      // Try fetching with joined facilitator profile
      try {
        final data = await Supabase.instance.client
            .from('profiles')
            .select('*, facilitator_profiles(*)')
            .eq('id', userId)
            .single();

        if (mounted) {
          setState(() {
            _firstNameController.text = data['first_name'] ?? '';
            _middleNameController.text = data['middle_name'] ?? '';
            _lastNameController.text = data['last_name'] ?? '';
            _suffixController.text = data['suffix'] ?? '';
            _avatarUrl = data['avatar_url'];
            _emailController.text = email;
            // Phone is still placeholder
            _phoneController.text = '+63 912 345 6789'; 
            
            // Fetch workplace from facilitator_profiles if available
            if (data['facilitator_profiles'] != null) {
              _workLocationController.text = data['facilitator_profiles']['workplace_assignment'] ?? '';
            } else {
              _workLocationController.text = '';
            }
            _isLoading = false;
          });
        }
      } catch (e) {
        // Fallback
        debugPrint('Error fetching joined profile: $e');
        final data = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', userId)
            .single();

        if (mounted) {
            setState(() {
            _firstNameController.text = data['first_name'] ?? '';
            _middleNameController.text = data['middle_name'] ?? '';
            _lastNameController.text = data['last_name'] ?? '';
            _suffixController.text = data['suffix'] ?? '';
            _avatarUrl = data['avatar_url'];
            _emailController.text = email;
            _phoneController.text = '+63 912 345 6789'; 
            _workLocationController.text = '';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      if (kIsWeb) {
         if (result.files.single.bytes != null) {
            setState(() {
              _imageBytes = result.files.single.bytes;
              _imageFile = null; 
            });
         }
      } else {
         if (result.files.single.path != null) {
            setState(() {
              _imageFile = File(result.files.single.path!);
              _imageBytes = null;
            });
         }
      }
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      
      String? newAvatarUrl;
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.png';

      if (kIsWeb && _imageBytes != null) {
        await Supabase.instance.client.storage
            .from('avatars')
            .uploadBinary(fileName, _imageBytes!);
        newAvatarUrl = Supabase.instance.client.storage
            .from('avatars')
            .getPublicUrl(fileName);
      } else if (!kIsWeb && _imageFile != null) {
        await Supabase.instance.client.storage
            .from('avatars')
            .upload(fileName, _imageFile!);
        newAvatarUrl = Supabase.instance.client.storage
            .from('avatars')
            .getPublicUrl(fileName);
      }

      final updates = <String, dynamic>{
        'first_name': _firstNameController.text.trim(),
        'middle_name': _middleNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'suffix': _suffixController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (newAvatarUrl != null) {
        updates['avatar_url'] = newAvatarUrl;
      }

      // Update Profile Data
      await Supabase.instance.client
          .from('profiles')
          .update(updates)
          .eq('id', userId);

      // Update Facilitator Profile (Workplace)
      if (_workLocationController.text.isNotEmpty) {
        await Supabase.instance.client.from('facilitator_profiles').upsert({
          'id': userId,
          'workplace_assignment': _workLocationController.text.trim(),
        });
      }

      // Update Auth Data (Email/Password)
      final UserAttributes attributes = UserAttributes(
        email: _emailController.text.trim() !=
                Supabase.instance.client.auth.currentUser?.email
            ? _emailController.text.trim()
            : null,
        password: _newPasswordController.text.isNotEmpty
            ? _newPasswordController.text
            : null,
      );

      // Only call updateUser if there are attribute changes
      if (attributes.email != null || attributes.password != null) {
        if (_newPasswordController.text.isNotEmpty &&
            _newPasswordController.text != _confirmPasswordController.text) {
          throw 'Passwords do not match';
        }
        await Supabase.instance.client.auth.updateUser(attributes);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context, true); // Go back and signal update
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _suffixController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _workLocationController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Text(
                    'Edit Profile',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture Section
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.accent3,
                              shape: BoxShape.circle,
                              image: (kIsWeb && _imageBytes != null)
                                  ? DecorationImage(
                                      image: MemoryImage(_imageBytes!),
                                      fit: BoxFit.cover,
                                    )
                                  : (_imageFile != null
                                      ? DecorationImage(
                                          image: FileImage(_imageFile!),
                                          fit: BoxFit.cover,
                                        )
                                      : (_avatarUrl != null
                                          ? DecorationImage(
                                              image: NetworkImage(_avatarUrl!),
                                              fit: BoxFit.cover,
                                            )
                                          : null)),
                            ),
                            child: (_imageFile == null && _imageBytes == null && _avatarUrl == null)
                                ? Center(
                                    child: Text(
                                      (_firstNameController.text.isNotEmpty
                                              ? _firstNameController.text[0]
                                              : 'I')
                                          .toUpperCase(),
                                      style: GoogleFonts.inter(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.background,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name Fields
                    _buildLabel('First Name'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _firstNameController,
                      hintText: 'First Name',
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('Middle Name'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _middleNameController,
                      hintText: 'Middle Name',
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('Last Name'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _lastNameController,
                      hintText: 'Last Name',
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('Suffix'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _suffixController,
                      hintText: 'Suffix (Optional)',
                    ),
                    const SizedBox(height: 20),

                    // Email Address Field
                    _buildLabel('Email Address'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _emailController,
                      hintText: 'Enter email address',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),

                    // Phone Number Field
                    _buildLabel('Phone Number'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _phoneController,
                      hintText: 'Enter phone number',
                      keyboardType: TextInputType.phone,
                      readOnly: true, // Until added to DB
                    ),
                    const SizedBox(height: 20),

                    // Work Location Field
                    _buildLabel('Work Location'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _workLocationController,
                      hintText: 'Enter work location',
                    ),
                    const SizedBox(height: 20),

                    // Current Password Field
                    _buildLabel('Current Password'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _currentPasswordController,
                      hintText: 'Enter current password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),

                    // New Password Field
                    _buildLabel('New Password'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _newPasswordController,
                      hintText: 'Enter new password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),

                    // Confirm New Password Field
                    _buildLabel('Confirm New Password'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Re-enter new password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),

                    // Password Requirements
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password Requirements:',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildRequirement('At least 8 characters long'),
                          const SizedBox(height: 4),
                          _buildRequirement(
                            'Contains uppercase and lowercase letters',
                          ),
                          const SizedBox(height: 4),
                          _buildRequirement('Contains at least one number'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Save Changes Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => _showSaveChangesDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Save Changes',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType? keyboardType,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      readOnly: readOnly,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textHint),
        filled: true,
        fillColor: readOnly ? AppColors.inputFill.withValues(alpha: 0.5) : AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Row(
      children: [
        Text(
          '• ',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showSaveChangesDialog(BuildContext context) {
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
              // Check icon
              Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent1,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  'assets/icons/check-circle.svg',
                  height: 20,
                  width:  20,
                  colorFilter: ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Save Changes?',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        _saveChanges(); // Start save
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Save',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
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
}

