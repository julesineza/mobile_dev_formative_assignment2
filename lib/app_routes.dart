import 'package:flutter/material.dart';

import 'screens/welcome.dart';
import 'screens/sign_in.dart';
import 'screens/sign_up.dart';
import 'screens/StudentHome.dart';
import 'screens/submit_report.dart';
import 'screens/exploreIssues.dart';
import 'screens/reportDetails.dart';
import 'screens/staff_dashboard.dart';
import 'screens/my_reports.dart';
import 'screens/profile.dart';
import 'models/issue.dart';

class AppRoutes {
  static const String welcome = '/welcome';
  static const String signUp = '/signUp';
  static const String signIn = '/signIn';
  static const String studentHome = '/studentHome';
  static const String submitReport = '/submitReport';
  static const String exploreIssues = '/exploreIssues';
  static const String reportDetails = '/reportDetails';
  static const String staffDashboard = '/staffDashboard';
  static const String staffReportDetails = '/staffReportDetails';
  static const String myReports = '/myReports';
  static const String profile = '/profile';

  static final Map<String, WidgetBuilder> routes = {
    signIn: (context) => const SignIn(),
    signUp: (context) => const SignUp(),
    welcome: (context) => const WelcomeScreen(),
    studentHome: (context) => const StudentHome(),
    submitReport: (context) => const SubmitReport(),
    exploreIssues: (context) => const ExploreIssues(),
    reportDetails: (context) => ReportDetails(
      issue: ModalRoute.of(context)!.settings.arguments! as Issue,
    ),
    staffDashboard: (context) => const StaffDashboard(),
    staffReportDetails: (context) => ReportDetails(
      issue: ModalRoute.of(context)!.settings.arguments! as Issue,
      staffMode: true,
    ),
    myReports: (context) => const MyReports(),
    profile: (context) => const Profile(),
  };
}
