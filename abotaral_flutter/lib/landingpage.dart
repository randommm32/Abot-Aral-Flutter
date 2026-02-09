import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'student/auth/sign_in_page.dart';
import 'Instructor/auth/sign_in_page.dart';

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
    await Future.delayed(Duration(seconds: 5)); // Simulate loading

    // Navigate to the sign in page, replacing the current route
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
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
