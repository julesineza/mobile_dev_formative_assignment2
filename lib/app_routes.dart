import 'package:flutter/material.dart';

import 'screens/welcome.dart';
import 'screens/sign_in.dart';
import 'screens/sign_up.dart';
import 'screens/StudentHome.dart';
import 'screens/submit_report.dart';

class AppRoutes {
  static const String welcome = '/welcome';
  static const String signUp = '/signUp';
  static const String signIn = '/signIn';
  static const String studentHome = '/studentHome';
  static const String submitReport = '/submitReport';

  static final Map<String, WidgetBuilder> routes = {
    signIn: (context) => const SignIn(),
    signUp: (context) => const SignUp(),
    welcome: (context) => const WelcomeScreen(),
    studentHome: (context) => const StudentHome(),
    submitReport: (context) => const SubmitReport(),
  };
}
