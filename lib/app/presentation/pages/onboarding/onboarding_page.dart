import 'package:finai_frontend/app/domain/entities/budget_item.dart';
import 'package:finai_frontend/app/domain/entities/goal_item.dart';
import 'package:finai_frontend/core/database/budget_db.dart';
import 'package:finai_frontend/core/database/goal_db.dart';
import 'package:finai_frontend/core/util/navigation.dart';
import 'package:finai_frontend/core/util/preferences.dart';
import 'package:finai_frontend/app/presentation/pages/login/login_page.dart';
import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _incomeController = TextEditingController();
  final _savingsGoalController = TextEditingController();
  bool _isLoading = false;

  Future<void> _finishOnboarding() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String userId = await Prefs.getCurrentUserId ?? '';

        if (_incomeController.text.isNotEmpty) {
          double income = double.tryParse(_incomeController.text) ?? 0;

          await BudgetDb.instance.insert(BudgetItem(
            amount: income,
            period: 'MONTHLY',
            category: 'General', // Default category
            userId: userId,
          ));
        }

        // Save Savings Goal
        if (_savingsGoalController.text.isNotEmpty) {
          double goal = double.tryParse(_savingsGoalController.text) ?? 0;
          await GoalDb.instance.insert(GoalItem(
            name: 'Initial Savings Goal',
            targetAmount: goal,
            currentAmount: 0,
            deadline: DateTime.now()
                .add(const Duration(days: 365))
                .toIso8601String(), // Default 1 year
            userId: userId,
          ));
        }

        // Mark onboarding as done (optional, or just go to Home)
        navigateOffAll(const LoginPage());
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
      appBar: AppBar(
        title: const Text('Getting Started'),
        actions: [
          TextButton(
            onPressed: () {
              navigateOffAll(const LoginPage());
            },
            child: const Text('Skip', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Let\'s set up your financial profile.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _incomeController,
                  decoration: const InputDecoration(
                    labelText: 'Estimated Monthly Budget / Income',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _savingsGoalController,
                  decoration: const InputDecoration(
                    labelText: 'Savings Goal (Optional)',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _finishOnboarding,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Finish Setup'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
