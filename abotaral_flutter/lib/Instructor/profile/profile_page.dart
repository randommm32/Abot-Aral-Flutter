import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/models/user_model.dart';
import '../auth/sign_in_page.dart';
import 'edit_profile_page.dart';

import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  UserModel? _user;

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
            _user = UserModel.fromJson({
              ...data,
              'email': email,
            });
            _isLoading = false;
          });
        }
      } catch (e) {
        // Fallback if relationship doesn't exist or other error
        debugPrint('Error fetching joined profile: $e');
        final data = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', userId)
            .single();

        if (mounted) {
          setState(() {
            _user = UserModel.fromJson({
              ...data,
              'email': email,
            });
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

  Future<void> _showEditInfoDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => _EditProfileDialog(user: _user),
    );

    if (result == true) {
      _getProfile();
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Log Out?',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(dialogContext),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "Are you sure you want to log out? You'll need to sign in again to access your account.",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(dialogContext),
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
                      onTap: () async {
                        try {
                          Navigator.pop(dialogContext);
                          await Supabase.instance.client.auth.signOut();
                          if (context.mounted) {
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const SignInPage(),
                              ),
                              (route) => false,
                            );
                          }
                        } catch (e) {
                          debugPrint('Error signing out: $e');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Log Out',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Green Header with profile info
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
                          'Profile',
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
                    const SizedBox(height: 20),
                    // Profile info
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.accent3,
                            shape: BoxShape.circle,
                            image: _user?.avatarUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(_user!.avatarUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _user?.avatarUrl == null
                              ? Center(
                                  child: Text(
                                    _user?.initials ?? 'T',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _user?.fullName ?? 'Instructor',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: _showEditInfoDialog,
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.3),
                                        shape: BoxShape.circle,
                                      ),
                                      child: SvgPicture.asset(
                                        'assets/instructor_icons/edit.svg',
                                        width: 12,
                                        height: 12,
                                        colorFilter: const ColorFilter.mode(
                                          Colors.white,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _user?.role ?? 'ALS Facilitator',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                              if (_user?.facilitatorProfile?.specialization != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  _user!.facilitatorProfile!.specialization!,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/instructor_icons/pin.svg',
                                    width: 12,
                                    height: 12,
                                    colorFilter: ColorFilter.mode(
                                      Colors.white.withValues(alpha: 0.7),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _user?.facilitatorProfile?.workplaceAssignment ?? 'No Workplace Assigned',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.white.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Stats Grid
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Row 1
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: 'assets/icons/users.svg',
                            label: 'Total Learners',
                            value: '24',
                            subtext: 'Across 4 courses',
                            color: AppColors.primary,
                            bgColor: AppColors.accent1,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: 'assets/icons/book-open.svg',
                            label: 'Active Courses',
                            value: '4',
                            subtext: '23 total modules',
                            color: AppColors.primary,
                            bgColor: AppColors.accent1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Stats Row 2
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: 'assets/instructor_icons/calendar.svg',
                            label: 'Sessions Held',
                            value: '48',
                            subtext: 'This semester',
                            color: AppColors.primary,
                            bgColor: AppColors.accent1,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: 'assets/icons/award.svg',
                            label: 'Completion Rate',
                            value: '87%',
                            subtext: 'Average across courses',
                            color: AppColors.primary,
                            bgColor: AppColors.accent1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Contact Information
                    Text(
                      'Contact Information',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ContactCard(
                      icon: 'assets/instructor_icons/mail.svg',
                      label: 'Email',
                      value: _user?.email ?? 'Scanning...',
                    ),
                    const SizedBox(height: 8),
                    _ContactCard(
                      icon: 'assets/instructor_icons/phone.svg',
                      label: 'Phone',
                      value: '+63 912 345 6789', // TODO: Add to UserModel
                    ),
                    const SizedBox(height: 8),
                    _ContactCard(
                      icon: 'assets/instructor_icons/pin.svg',
                      label: 'Office Location',
                      value: _user?.facilitatorProfile?.workplaceAssignment ?? 'Not Assigned', 
                    ),
                    const SizedBox(height: 24),

                    // Settings
                    Text(
                      'Settings',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SettingsItem(
                      icon: 'assets/instructor_icons/settings.svg',
                      label: 'Account Settings',
                      onTap: () async {
                        final bool? result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const InstructorEditProfilePage(),
                          ),
                        );
                        
                        if (result == true) {
                          _getProfile();
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    _SettingsItem(
                      icon: 'assets/icons/bell.svg',
                      label: 'Notifications',
                      onTap: () {},
                    ),
                    const SizedBox(height: 8),
                    _SettingsItem(
                      icon: 'assets/instructor_icons/helpsupport.svg',
                      label: 'Help & Support',
                      onTap: () {},
                    ),
                    const SizedBox(height: 8),
                    _LogoutItem(onTap: () => _showLogoutDialog(context)),
                    const SizedBox(height: 32),

                    Column(
                      children: [
                        Text(
                          'ALS AbotAral App v1.0.0',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Department of Education - Philippines',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
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

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String subtext;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtext,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                icon,
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: color.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _ContactCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accent1,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                icon,
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
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
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
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

class _SettingsItem extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.accent1,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  icon,
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutItem extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutItem({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.logout, size: 18, color: Color(0xFFEF4444)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Log Out',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFEF4444),
                ),
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

class _EditProfileDialog extends StatefulWidget {
  final UserModel? user;
  const _EditProfileDialog({this.user});

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late TextEditingController _firstNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _suffixController;
  
  bool _isLoading = false;
  String? _avatarUrl;
  File? _imageFile;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user?.firstName);
    _middleNameController = TextEditingController(text: widget.user?.middleName);
    _lastNameController = TextEditingController(text: widget.user?.lastName);
    _suffixController = TextEditingController(text: widget.user?.suffix);
    _avatarUrl = widget.user?.avatarUrl;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _suffixController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
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
    } catch (e) {
        debugPrint('Error picking image: $e');
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

      await Supabase.instance.client
          .from('profiles')
          .update(updates)
          .eq('id', userId);

      if (mounted) {
        Navigator.pop(context, true);
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
  Widget build(BuildContext context) {
    return Dialog(
       backgroundColor: Colors.white,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
       child: SingleChildScrollView(
         padding: const EdgeInsets.all(24),
         child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                Text(
                    'Edit Info',
                    style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                    ),
                ),
                const SizedBox(height: 24),
                // Avatar
                GestureDetector(
                    onTap: _pickImage,
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
                                ? const Center(child: Icon(Icons.person, size: 40, color: Colors.white))
                                : null,
                            ),
                            Positioned(
                                bottom: 0,
                                right: 0,
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
                        ],
                    ),
                ),
                const SizedBox(height: 24),
                _buildTextField('First Name', _firstNameController),
                const SizedBox(height: 12),
                _buildTextField('Middle Name', _middleNameController),
                const SizedBox(height: 12),
                _buildTextField('Last Name', _lastNameController),
                const SizedBox(height: 12),
                _buildTextField('Suffix', _suffixController),
                const SizedBox(height: 24),
                Row(
                    children: [
                        Expanded(
                            child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.border),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textPrimary)),
                            ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            child: ElevatedButton(
                                onPressed: _isLoading ? null : _saveChanges,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: _isLoading 
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : Text('Save', style: GoogleFonts.inter(color: Colors.white)),
                            ),
                        ),
                    ],
                )
            ],
         ),
       ),
    );
  }
  
  Widget _buildTextField(String label, TextEditingController controller) {
      return TextField(
          controller: controller,
          decoration: InputDecoration(
              labelText: label,
              labelStyle: GoogleFonts.inter(color: AppColors.textSecondary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
      );
  }
}
