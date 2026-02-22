import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/senior_text_field.dart';
import 'personal_info_screen.dart';

/// LoginScreen - Entry point for user authentication.
///
/// Features:
/// - Email signup/login
/// - Continue as Guest option
/// - Google/Apple sign-in buttons
/// - Terms of Service links
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _navigateToOnboarding() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const PersonalInfoScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // App Title
              Text(
                'DiaMetrics',
                style: SeniorTheme.headingStyle.copyWith(
                  fontSize: 36,
                  color: const Color(0xFF40C4AA), // Teal from prototype
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle
              Text(
                'Create an account',
                style: SeniorTheme.headingStyle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your email to sign up for this app',
                style: SeniorTheme.bodyStyle.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              // Email Field
              SeniorTextField(
                controller: _emailController,
                hint: 'email@domain.com',
                keyboardType: TextInputType.emailAddress,
                semanticLabel: 'Email address',
              ),
              const SizedBox(height: 16),
              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _navigateToOnboarding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Continue', style: SeniorTheme.buttonTextStyle),
                ),
              ),
              const SizedBox(height: 16),
              // Continue as Guest Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _navigateToOnboarding,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Continue as Guest',
                    style: SeniorTheme.buttonTextStyle.copyWith(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Divider with "or"
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade400)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: SeniorTheme.bodyStyle.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade400)),
                ],
              ),
              const SizedBox(height: 24),
              // Google Sign In
              _buildSocialButton(
                icon: Icons.g_mobiledata,
                label: 'Continue with Google',
                onPressed: () {
                  // TODO: Implement Google sign-in
                  _navigateToOnboarding();
                },
              ),
              const SizedBox(height: 12),
              // Apple Sign In
              _buildSocialButton(
                icon: Icons.apple,
                label: 'Continue with Apple',
                onPressed: () {
                  // TODO: Implement Apple sign-in
                  _navigateToOnboarding();
                },
              ),
              const Spacer(flex: 1),
              // Terms of Service
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text.rich(
                  TextSpan(
                    text: 'By clicking continue, you agree to our ',
                    style: SeniorTheme.bodyStyle.copyWith(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    children: [
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24, color: Colors.black),
        label: Text(
          label,
          style: SeniorTheme.bodyStyle.copyWith(fontWeight: FontWeight.w500),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
