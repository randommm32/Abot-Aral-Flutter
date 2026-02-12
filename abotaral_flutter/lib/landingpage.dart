import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
<<<<<<< HEAD
// import 'student/auth/sign_in_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Instructor/instructor_shell.dart';
import 'Instructor/auth/sign_in_page.dart';
=======
import 'student/auth/sign_in_page.dart';
// import 'Instructor/auth/sign_in_page.dart';
>>>>>>> 024509e95f917caf7cb37d85169e3f3a7eff21dd

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => LandingPageState();
}

class LandingPageState extends State<LandingPage> {

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Perform your data fetching here (e.g., API calls, database loading)
    await Future.delayed(const Duration(seconds: 2)); // Reduced delay for better UX

    final session = Supabase.instance.client.auth.currentSession;

    if (!mounted) return;

    if (session != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const InstructorShell()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignInPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/abotaral.png',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 20),
                Text(
                  'Abot Aral',
                  style: GoogleFonts.inter(
                    color: AppColors.background,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }
}
