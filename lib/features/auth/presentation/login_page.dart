import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_logo.dart';
import '../data/auth_service.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final auth = AuthService();
  bool isLoading = false;

  void login() async {
    if (!mounted) return;
    
    setState(() => isLoading = true);
    
    try {
      await auth.signIn(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              
              // Logo
              const Center(
                child: AppLogo(size: 120),
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Title
              const Center(
                child: Text(
                  'Welcome Back!',
                  style: AppTextStyles.title,
                ),
              ),
              
              const SizedBox(height: AppSpacing.xs),
              
              Center(
                child: Text(
                  'Login to continue your learning journey',
                  style: AppTextStyles.body.copyWith(color: AppColors.grey),
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Email Field
              AppTextField(
                controller: emailController,
                label: 'Email',
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.grey),
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              // Password Field
              AppTextField(
                controller: passwordController,
                label: 'Password',
                hint: 'Enter your password',
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.grey),
              ),
              
              const SizedBox(height: AppSpacing.xs),
              
              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot Password?',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              // Login Button
              AppButton(
                text: 'Login',
                onPressed: login,
                isLoading: isLoading,
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.greyLight)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Text(
                      'OR',
                      style: AppTextStyles.caption.copyWith(color: AppColors.grey),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.greyLight)),
                ],
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Create Account Button
              AppButton(
                text: 'Create Account',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterPage(),
                    ),
                  );
                },
                isOutlined: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}