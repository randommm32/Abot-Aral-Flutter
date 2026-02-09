import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/student_widgets/quiz_option.dart';
import 'quiz_result_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AssessmentQuestionsPage extends StatefulWidget {
  final String courseTitle;
  final String quizTitle;

  const AssessmentQuestionsPage({
    super.key,
    required this.courseTitle,
    required this.quizTitle,
  });

  @override
  State<AssessmentQuestionsPage> createState() =>
      _AssessmentQuestionsPageState();
}

class _AssessmentQuestionsPageState extends State<AssessmentQuestionsPage> {
  int _currentQuestion = 0;
  final int _totalQuestions = 3;
  int? _selectedOption;
  final List<int?> _answers = [null, null, null];

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Choose the correct word: I ____ a book.',
      'options': ['reads', 'read', 'reading', 'readed'],
      'correctAnswer': 1,
    },
    {
      'question': 'Which word is a noun?',
      'options': ['run', 'happy', 'book', 'quickly'],
      'correctAnswer': 2,
    },
    {
      'question':
          'Liam found a small red box in the classroom on left. The box had picture of a cat on it and was sitting quietly on the carpet and began to stare at Liam for a while. As Liam sat up and got interested, the cat began to rub against Liam. After he had the whole entry by himself, Liam sat on his tiny chair in the EDT lounge where he did not know now many.',
      'subtitle': 'What is so important every day.',
      'subtitle2': 'She goes to school every day.',
      'subtitle3': 'She goes to school more dis.',
      'options': [],
      'isLongForm': true,
    },
  ];

  void _selectOption(int index) {
    setState(() {
      _selectedOption = index;
      _answers[_currentQuestion] = index;
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < _totalQuestions - 1) {
      setState(() {
        _currentQuestion++;
        _selectedOption = _answers[_currentQuestion];
      });
    }
  }

  void _submitQuiz() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultPage(
          courseTitle: widget.courseTitle,
          quizTitle: widget.quizTitle,
          score: 1,
          totalQuestions: _totalQuestions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];
    final isLongForm = question['isLongForm'] == true;

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
          onPressed: () => Navigator.pop(context),
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
            padding: EdgeInsets.only(right: 30),
            constraints: const BoxConstraints(),
          ),
        ],
      ),

      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.courseTitle,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'English and Filipino',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textHint
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Question Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question number
                  Text(
                    '${_currentQuestion + 1}. ${isLongForm ? '' : question['question']}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (isLongForm) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.accent1,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.accent2),
                      ),
                      child: Text(
                        question['question'],
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.6,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      question['subtitle'] ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question['subtitle2'] ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question['subtitle3'] ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 20),
                    ...List.generate((question['options'] as List).length, (
                      index,
                    ) {
                      final options = question['options'] as List;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: QuizOption(
                          label: String.fromCharCode(65 + index),
                          text: options[index],
                          state: _selectedOption == index
                              ? QuizOptionState.selected
                              : QuizOptionState.normal,
                          onTap: () => _selectOption(index),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
          // Bottom button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _currentQuestion == _totalQuestions - 1
                      ? _submitQuiz
                      : _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _currentQuestion == _totalQuestions - 1 ? 'Submit' : 'Next',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
