import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../core/constants/colors.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../core/constants/user_role.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _userService = UserService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final user = await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (user == null) {
        throw const FormatException('Unable to identify this account.');
      }
      final profile = await _userService.getUser(user.uid);
      if (profile == null) {
        await _authService.signOut();
        throw const FormatException('Your account profile could not be found.');
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        profile.role == UserRole.teacher
            ? AppRoutes.staffDashboard
            : AppRoutes.studentHome,
      );
    } on FormatException catch (error) {
      _showError(error.message);
    } on FirebaseAuthException catch (error) {
      _showError(error.message ?? 'Unable to sign in.');
    } catch (_) {
      _showError('Unable to sign in. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _AuthCard(
              title: 'Welcome back',
              subtitle: 'Sign in to continue to Campus Report.',
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'School email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Enter your email'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _isPasswordVisible = !_isPasswordVisible,
                          ),
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter your password'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        _isSubmitting ? null : _signIn();
                      },
                      child: Text(_isSubmitting ? 'Signing in...' : 'Sign in'),
                    ),
                    const SizedBox(height: 12),
                    _AuthLink(
                      prompt: 'Don\'t have an account?',
                      label: 'Sign up',
                      onPressed: () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.signUp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: Card(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryBlue,
                child: Icon(
                  Icons.school_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 24),
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 28),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthLink extends StatelessWidget {
  const _AuthLink({
    required this.prompt,
    required this.label,
    required this.onPressed,
  });

  final String prompt;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(prompt, style: Theme.of(context).textTheme.bodyMedium),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(foregroundColor: AppColors.primaryBlue),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
