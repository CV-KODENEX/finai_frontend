import 'dart:ui';

import 'package:finai_frontend/app/domain/entities/user.dart';
import 'package:finai_frontend/core/database/user_db.dart';
import 'package:finai_frontend/core/style/app_theme.dart';
import 'package:finai_frontend/core/util/navigation.dart';
import 'package:finai_frontend/core/util/preferences.dart';
import 'package:finai_frontend/app/presentation/pages/onboarding/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create user object
        User user = User(
          username: _usernameController.text,
          password: _passwordController.text,
          name: _nameController.text,
          role: 'user',
          userId: 0,
        );

        // Insert to DB
        await UserDb.instance.insertUser(user);

        await Prefs.setCurrentUserId(_usernameController.text);
        await Prefs.setUserName(_nameController.text);

        navigateOffAll(const OnboardingPage());
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryNeon),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background Elements
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    AppTheme.backgroundBlack,
                    Color(0xFF1A0A1A),
                  ],
                ),
              ),
            ),
          ),
          // Neon Glows
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentPink.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentPink.withOpacity(0.4),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            )
                .animate(
                    onPlay: (controller) => controller.repeat(reverse: true))
                .scale(
                    duration: 5.seconds,
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.2, 1.2)),
          ),

          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'NEW IDENTITY',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppTheme.textWhite,
                      shadows: [
                        Shadow(
                          color: AppTheme.accentPink.withOpacity(0.8),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms).moveY(begin: 20, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'JOIN THE FUTURE',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          letterSpacing: 4,
                          color: AppTheme.textGrey,
                        ),
                  ).animate().fadeIn(delay: 200.ms).moveY(begin: 20, end: 0),
                  const SizedBox(height: 48),

                  // Glassmorphic Form
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _nameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: 'FULL NAME',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _usernameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: 'USERNAME',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a username';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _passwordController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: 'PASSWORD',
                                  prefixIcon: Icon(Icons.lock_outline),
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.accentPink,
                                    shadowColor:
                                        AppTheme.accentPink.withOpacity(0.5),
                                    elevation: 10,
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white)
                                      : const Text('INITIATE REGISTRATION'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms).moveY(begin: 50, end: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
