import 'package:flutter/material.dart';
import 'screens/welcome.dart';
import 'screens/sign_in.dart';
import 'screens/sign_up.dart';
import 'screens/StudentHome.dart';

class AppRoutes {
  static const String welcome = '/welcome';
  static const String signUp = '/signUp';
  static const String signIn = '/signIn';
  static const String studentHome = '/studentHome';

  static final Map<String, WidgetBuilder> routes = {
    signIn: (context) => const SignIn(),
    signUp: (context) => const SignUp(),
    welcome: (context) => const WelcomeScreen(),
    studentHome: (context) => const StudentHome(),

  };
}
