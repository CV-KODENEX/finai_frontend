import 'package:finai_frontend/app/presentation/pages/category/category_list_page.dart';
import 'package:finai_frontend/app/presentation/pages/welcome/welcome_page.dart';
import 'package:finai_frontend/core/util/navigation.dart';
import 'package:finai_frontend/core/util/preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = 'User';
  bool isDarkMode = false;

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
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                      'https://ui-avatars.com/api/?name=User&background=random'), // Placeholder
                ),
                const SizedBox(height: 10),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Implement Edit Profile
            },
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            value: isDarkMode,
            onChanged: (value) async {
              setState(() {
                isDarkMode = value;
              });
              await Prefs.setIsDarkMode(value);
              Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: Text(Get.locale?.languageCode == 'id'
                ? 'Bahasa Indonesia'
                : 'English'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showLanguageDialog();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Manage Categories'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              navigateTo(const CategoryListPage());
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await PreferencesHelper.setBool('isLoggedIn', false);
              navigateOffAll(const WelcomePage());
            },
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                onTap: () async {
                  Get.updateLocale(const Locale('en', 'US'));
                  await Prefs.setLanguage('en');
                  setState(() {});
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Bahasa Indonesia'),
                onTap: () async {
                  Get.updateLocale(const Locale('id', 'ID'));
                  await Prefs.setLanguage('id');
                  setState(() {});
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
