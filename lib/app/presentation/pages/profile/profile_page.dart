import 'dart:ui';

import 'package:finai_frontend/app/presentation/pages/category/category_list_page.dart';
import 'package:finai_frontend/app/presentation/pages/welcome/welcome_page.dart';
import 'package:finai_frontend/core/style/app_theme.dart';
import 'package:finai_frontend/core/util/navigation.dart';
import 'package:finai_frontend/core/util/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = 'User';
  bool isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final name = await Prefs.getUserName;
    final darkMode = await Prefs.getIsDarkMode;
    setState(() {
      userName = name ?? 'User';
      isDarkMode = darkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark.withOpacity(0.8),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: Text(
          'USER PROFILE',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textWhite,
                letterSpacing: 1.5,
              ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.backgroundBlack,
                    Color(0xFF050510),
                  ],
                ),
              ),
            ),
          ),

          ListView(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
            children: [
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppTheme.primaryNeon, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryNeon.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                            'https://ui-avatars.com/api/?name=User&background=000000&color=00FFFF'),
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1.05, 1.05)),
                    const SizedBox(height: 16),
                    Text(
                      userName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textWhite,
                        letterSpacing: 2,
                        fontFamily: 'Orbitron',
                      ),
                    ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNeon.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.primaryNeon.withOpacity(0.3)),
                      ),
                      child: const Text(
                        'LEVEL 1 USER',
                        style: TextStyle(
                          color: AppTheme.primaryNeon,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _buildSectionHeader('SYSTEM SETTINGS'),
              const SizedBox(height: 16),
              _buildGlassTile(
                icon: Icons.person_outline,
                title: 'EDIT IDENTITY',
                onTap: () {
                  // TODO: Implement Edit Profile
                },
              ),
              const SizedBox(height: 12),
              _buildGlassTile(
                icon: Icons.dark_mode_outlined,
                title: 'DARK MODE',
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (value) async {
                    setState(() {
                      isDarkMode = value;
                    });
                    await Prefs.setIsDarkMode(value);
                    Get.changeThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light);
                  },
                  activeColor: AppTheme.primaryNeon,
                  activeTrackColor: AppTheme.primaryNeon.withOpacity(0.3),
                ),
              ),
              const SizedBox(height: 12),
              _buildGlassTile(
                icon: Icons.language,
                title: 'LANGUAGE PROTOCOL',
                subtitle: Get.locale?.languageCode == 'id'
                    ? 'BAHASA INDONESIA'
                    : 'ENGLISH',
                onTap: () {
                  _showLanguageDialog();
                },
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('DATA MANAGEMENT'),
              const SizedBox(height: 16),
              _buildGlassTile(
                icon: Icons.category_outlined,
                title: 'CATEGORY CONFIG',
                onTap: () {
                  navigateTo(const CategoryListPage());
                },
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                  color: Colors.red.withOpacity(0.1),
                ),
                child: ListTile(
                  leading:
                      const Icon(Icons.power_settings_new, color: Colors.red),
                  title: const Text(
                    'TERMINATE SESSION',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  onTap: () async {
                    await PreferencesHelper.setBool('isLoggedIn', false);
                    navigateOffAll(const WelcomePage());
                  },
                ),
              ).animate().fadeIn().slideY(begin: 0.2, end: 0),
              const SizedBox(height: 100), // Bottom padding for nav bar
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.textGrey,
        fontSize: 12,
        letterSpacing: 2,
        fontWeight: FontWeight.bold,
      ),
    ).animate().fadeIn();
  }

  Widget _buildGlassTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryNeon),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                    color: AppTheme.textGrey.withOpacity(0.8), fontSize: 12),
              )
            : null,
        trailing: trailing ??
            const Icon(Icons.arrow_forward_ios,
                color: AppTheme.textGrey, size: 16),
        onTap: onTap,
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            backgroundColor: AppTheme.surfaceDark.withOpacity(0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: AppTheme.primaryNeon.withOpacity(0.3)),
            ),
            title: Text(
              'SELECT PROTOCOL',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryNeon,
                    letterSpacing: 1.5,
                  ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('ENGLISH',
                      style: TextStyle(color: Colors.white)),
                  leading: const Icon(Icons.language, color: AppTheme.textGrey),
                  onTap: () async {
                    Get.updateLocale(const Locale('en', 'US'));
                    await Prefs.setLanguage('en');
                    setState(() {});
                    Navigator.pop(context);
                  },
                ),
                Divider(color: Colors.white.withOpacity(0.1)),
                ListTile(
                  title: const Text('BAHASA INDONESIA',
                      style: TextStyle(color: Colors.white)),
                  leading: const Icon(Icons.language, color: AppTheme.textGrey),
                  onTap: () async {
                    Get.updateLocale(const Locale('id', 'ID'));
                    await Prefs.setLanguage('id');
                    setState(() {});
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
