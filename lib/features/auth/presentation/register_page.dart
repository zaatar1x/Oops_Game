import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../data/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final auth = AuthService();
  bool isLoading = false;

  void register() async {
    if (!mounted) return;
    
    setState(() => isLoading = true);
    
    try {
      final response = await auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
      );

      if (!mounted) return;
      
      // Check if email confirmation is required
      if (response.user != null) {
        // User created successfully, navigate back
        Navigator.pop(context);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        // Email confirmation required
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please check your email to confirm your account'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      }
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.greyDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Create Account',
                style: AppTextStyles.title,
              ),
              
              const SizedBox(height: AppSpacing.xs),
              
              Text(
                'Join Oops and start your learning adventure',
                style: AppTextStyles.body.copyWith(color: AppColors.grey),
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // First Name
              AppTextField(
                controller: firstNameController,
                label: 'First Name',
                hint: 'Enter your first name',
                prefixIcon: const Icon(Icons.person_outline, color: AppColors.grey),
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              // Last Name
              AppTextField(
                controller: lastNameController,
                label: 'Last Name',
                hint: 'Enter your last name',
                prefixIcon: const Icon(Icons.person_outline, color: AppColors.grey),
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              // Email
              AppTextField(
                controller: emailController,
                label: 'Email',
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.grey),
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              // Password
              AppTextField(
                controller: passwordController,
                label: 'Password',
                hint: 'Create a password',
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.grey),
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Sign Up Button
              AppButton(
                text: 'Sign Up',
                onPressed: register,
                isLoading: isLoading,
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              // Terms
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Text(
                    'By signing up, you agree to our Terms of Service and Privacy Policy',
                    style: AppTextStyles.caption.copyWith(color: AppColors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
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
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }
}