import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/student_widgets/notification_item.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Notifications',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          NotificationItem(
            title: 'A New Course is available!',
            subtitle: 'Check out the new learning materials',
            time: '2:30 PM',
            isNew: true,
          ),
          SizedBox(height: 12),
          NotificationItem(
            title: 'New message from Mr. Khadafi',
            subtitle: 'Hello, how are you doing with the course?',
            time: '1 hour ago',
            isNew: true,
          ),
          SizedBox(height: 12),
          NotificationItem(
            title: 'Your assessment Exam is returned',
            subtitle: 'View your results now',
            time: '2 hours ago',
            isNew: false,
          ),
        ],
      ),
    );
  }
}
