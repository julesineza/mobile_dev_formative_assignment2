import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../core/constants/colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 22),
              Row(
                children: [
                  const Icon(
                    Icons.location_city_outlined,
                    color: AppColors.primaryBlue,
                    size: 27,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'CampusCare',
                    style: textTheme.titleLarge?.copyWith(
                      color: AppColors.text,
                      fontSize: 23,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 82),
              Text(
                'A better campus.\nStarts with you.',
                style: textTheme.displaySmall?.copyWith(
                  color: AppColors.text,
                  fontSize: 43,
                  height: 1.12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Spot an issue, let us know, and follow it '
                'through. Small reports make a real difference.',
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.secondaryText,
                  fontSize: 21,
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 45),
              SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, AppRoutes.signUp),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_forward, size: 23),
                      SizedBox(width: 15),
                      Text(
                        'Get started',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.secondaryText,
                        fontSize: 18,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.signIn,
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

            ],
          ),
        ),
      ),
    );
  }
}

class InfoItem extends StatelessWidget {
  const InfoItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 29),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.text,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
                  fontSize: 17,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
