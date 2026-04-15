import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_router.dart';
import '../../services/auth_service.dart';
import '../theme/app_theme.dart';

/// Login / Register screen.
///
/// Toggles between Sign In and Create Account modes in-place (no push).
/// Password reset triggers a snack-bar confirmation.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isRegister = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final auth = ref.read(authServiceProvider);
      if (_isRegister) {
        await auth.registerWithEmail(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );
      } else {
        await auth.signInWithEmail(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );
      }
      if (mounted) context.go(AppRoutes.dashboard);
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _friendlyError(e.code));
    } catch (e) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Enter your email above first.');
      return;
    }
    try {
      await ref.read(authServiceProvider).sendPasswordReset(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reset link sent to $email'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _friendlyError(e.code));
    }
  }

  String _friendlyError(String code) => switch (code) {
        'user-not-found'     => 'No account found with that email.',
        'wrong-password'     => 'Incorrect password.',
        'email-already-in-use' => 'An account already exists with this email.',
        'weak-password'      => 'Password must be at least 6 characters.',
        'invalid-email'      => 'Please enter a valid email address.',
        'too-many-requests'  => 'Too many attempts. Please try again later.',
        _                    => 'Authentication failed ($code).',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Logo(),
                const SizedBox(height: 32),
                _Card(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Mode toggle
                        _ModeToggle(
                          isRegister: _isRegister,
                          onToggle: () => setState(() {
                            _isRegister = !_isRegister;
                            _error = null;
                          }),
                        ),
                        const SizedBox(height: 20),

                        // Email
                        _InputField(
                          controller: _emailCtrl,
                          label: 'Email',
                          hint: 'you@example.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (!v.contains('@')) return 'Invalid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Password
                        _InputField(
                          controller: _passCtrl,
                          label: 'Password',
                          hint: '••••••••',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscurePass,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePass
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 18,
                              color: AppColors.textDisabled,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePass = !_obscurePass),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (v.length < 6) return 'Min 6 characters';
                            return null;
                          },
                        ),

                        // Confirm password (register only)
                        if (_isRegister) ...[
                          const SizedBox(height: 12),
                          _InputField(
                            controller: _confirmCtrl,
                            label: 'Confirm Password',
                            hint: '••••••••',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscureConfirm,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 18,
                                color: AppColors.textDisabled,
                              ),
                              onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm),
                            ),
                            validator: (v) {
                              if (v != _passCtrl.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ],

                        // Error message
                        if (_error != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.danger.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline_rounded,
                                    size: 14, color: AppColors.danger),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.danger,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Submit button
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.background,
                              disabledBackgroundColor:
                                  AppColors.accent.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.background,
                                    ),
                                  )
                                : Text(
                                    _isRegister
                                        ? 'Create Account'
                                        : 'Sign In',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),

                        // Forgot password (sign-in mode only)
                        if (!_isRegister) ...[
                          const SizedBox(height: 12),
                          Center(
                            child: GestureDetector(
                              onTap: _forgotPassword,
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textDisabled,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.textDisabled,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _TermsFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Logo / branding block
// ---------------------------------------------------------------------------

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(
                color: AppColors.accent.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.25),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Text('💎', style: TextStyle(fontSize: 32)),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'SLAB STACK',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.accent,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Your Pokémon TCG Vault',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: -0.1, end: 0);
  }
}

// ---------------------------------------------------------------------------
// Form card container
// ---------------------------------------------------------------------------

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 150.ms)
        .slideY(begin: 0.06, end: 0);
  }
}

// ---------------------------------------------------------------------------
// Sign In / Create Account toggle
// ---------------------------------------------------------------------------

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.isRegister, required this.onToggle});
  final bool isRegister;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _Tab(
            label: 'Sign In',
            selected: !isRegister,
            onTap: isRegister ? onToggle : null,
          ),
          _Tab(
            label: 'Create Account',
            selected: isRegister,
            onTap: !isRegister ? onToggle : null,
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.selected, this.onTap});
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.background : AppColors.textDisabled,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared input field
// ---------------------------------------------------------------------------

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: const TextStyle(
              fontSize: 14, color: AppColors.textPrimary),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                fontSize: 13, color: AppColors.textDisabled),
            prefixIcon:
                Icon(icon, size: 18, color: AppColors.textDisabled),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.accent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.danger, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.danger, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
                vertical: 14, horizontal: 14),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Terms footer
// ---------------------------------------------------------------------------

class _TermsFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text(
      'By continuing you agree to our Terms of Service\nand Privacy Policy.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 10,
        color: AppColors.textDisabled,
        height: 1.6,
      ),
    );
  }
}
