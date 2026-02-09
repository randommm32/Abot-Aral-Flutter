import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_colors.dart';
import 'chat_conversation_page.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Row(
                children: [
                  Text(
                    'Chat',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      _showNotificationsDialog(context);
                    },
                    icon: SvgPicture.asset(
                      'assets/icons/bell.svg',
                      width: 24,
                      height: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            // Chat List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _ChatListItem(
                    name: 'Ms. Karen Whitfield',
                    message:
                        'Please complete the English literacy quiz, the ...',
                    onTap: () =>
                        _navigateToConversation(context, 'Ms. Karen Whitfield'),
                  ),
                  _ChatListItem(
                    name: 'Mr. Anthony Ruiz',
                    message: 'Remember to choose only one option (a, b, c,...',
                    isItalic: true,
                    onTap: () =>
                        _navigateToConversation(context, 'Mr. Anthony Ruiz'),
                  ),
                  _ChatListItem(
                    name: 'Ms. Olivia Chen',
                    message: 'The quiz should be finished independently an...',
                    onTap: () =>
                        _navigateToConversation(context, 'Ms. Olivia Chen'),
                  ),
                  _ChatListItem(
                    name: 'Mr. Robert Klein',
                    message:
                        'If you have any questions about the instructio...',
                    onTap: () =>
                        _navigateToConversation(context, 'Mr. Robert Klein'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToConversation(BuildContext context, String contactName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatConversationPage(contactName: contactName),
      ),
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final String name;
  final String message;
  final bool isItalic;
  final VoidCallback? onTap;

  const _ChatListItem({
    required this.name,
    required this.message,
    this.isItalic = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accent1,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: Center(
                child: Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name and message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
