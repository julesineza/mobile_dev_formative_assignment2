import 'package:flutter/material.dart';
import '../widgets/navbar.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Student Home Screen"),
      ),
      bottomNavigationBar: const CustomBottomNavBar (),
    );
  }
}