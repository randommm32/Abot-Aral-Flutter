import 'package:flutter/material.dart';
import '../../core/student_widgets/bottom_nav_bar.dart';
import 'home/home_page.dart';
import 'courses/courses_page.dart';
import 'progress/progress_page.dart';
import 'chat/chat_list_page.dart';
import 'profile/profile_page.dart';

/// Global navigator keys for each tab to enable nested navigation
final GlobalKey<NavigatorState> homeNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> coursesNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> progressNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> chatNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> profileNavigatorKey =
    GlobalKey<NavigatorState>();

/// Global key to access StudentShell state for tab switching
final GlobalKey<StudentShellState> studentShellKey =
    GlobalKey<StudentShellState>();

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => StudentShellState();
}

class StudentShellState extends State<StudentShell> {
  int _currentIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    homeNavigatorKey,
    coursesNavigatorKey,
    progressNavigatorKey,
    chatNavigatorKey,
    profileNavigatorKey,
  ];

  /// Switch to a specific tab by index
  void switchToTab(int index) {
    if (index >= 0 && index < _navigatorKeys.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _onTabTapped(int index) {
    // Always pop to first route when tapping any tab
    _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);

    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  // Handle back button press - pop from current navigator first
  Future<bool> _onWillPop() async {
    final navigator = _navigatorKeys[_currentIndex].currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
      return false; // Don't pop the main navigator
    }
    return true; // Allow the main navigator to pop (exit app)
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _TabNavigator(
              navigatorKey: homeNavigatorKey,
              child: const HomePage(),
            ),
            _TabNavigator(
              navigatorKey: coursesNavigatorKey,
              child: const CoursesPage(),
            ),
            _TabNavigator(
              navigatorKey: progressNavigatorKey,
              child: const ProgressPage(),
            ),
            _TabNavigator(
              navigatorKey: chatNavigatorKey,
              child: const ChatListPage(),
            ),
            _TabNavigator(
              navigatorKey: profileNavigatorKey,
              child: const ProfilePage(),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),
      ),
    );
  }
}

/// A widget that wraps each tab in its own Navigator for nested navigation
class _TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  const _TabNavigator({required this.navigatorKey, required this.child});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => child,
        );
      },
    );
  }
}
