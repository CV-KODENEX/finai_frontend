import 'dart:ui';

import 'package:finai_frontend/app/domain/entities/budget_item.dart';
import 'package:finai_frontend/app/domain/entities/goal_item.dart';
import 'package:finai_frontend/core/database/budget_db.dart';
import 'package:finai_frontend/core/database/goal_db.dart';
import 'package:finai_frontend/core/style/app_theme.dart';
import 'package:finai_frontend/core/util/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  List<BudgetItem> _budgets = [];
  List<GoalItem> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    String userId = await Prefs.getCurrentUserId ?? '';
    var budgets = await BudgetDb.instance.getAll(userId);
    var goals = await GoalDb.instance.getAll(userId);

    setState(() {
      _budgets = budgets;
      _goals = goals;
      _isLoading = false;
    });
  }

  Future<void> _addGoal() async {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    await showDialog(
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
              'NEW TARGET',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryNeon,
                    letterSpacing: 1.5,
                  ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'GOAL NAME',
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'TARGET AMOUNT',
                    prefixText: 'Rp ',
                    prefixIcon: Icon(Icons.monetization_on_outlined),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ABORT',
                    style: TextStyle(color: AppTheme.textGrey)),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty &&
                      amountController.text.isNotEmpty) {
                    String userId = await Prefs.getCurrentUserId ?? '';
                    await GoalDb.instance.insert(GoalItem(
                      name: nameController.text,
                      targetAmount: double.tryParse(amountController.text) ?? 0,
                      currentAmount: 0,
                      deadline: DateTime.now()
                          .add(const Duration(days: 365))
                          .toIso8601String(),
                      userId: userId,
                    ));
                    Navigator.pop(context);
                    _loadData();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNeon,
                  foregroundColor: Colors.black,
                ),
                child: const Text('INITIALIZE'),
              ),
            ],
          ),
        );
      },
    );
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
          'FINANCIAL OVERVIEW',
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

          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryNeon))
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAIInsightCard()
                          .animate()
                          .fadeIn()
                          .slideY(begin: -0.2, end: 0),
                      const SizedBox(height: 32),
                      Text(
                        'BUDGET PROTOCOLS',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppTheme.textGrey,
                              letterSpacing: 2,
                            ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 16),
                      _budgets.isEmpty
                          ? _buildEmptyState('No active budget protocols')
                          : Column(
                              children: _budgets
                                  .map((b) => _buildBudgetCard(b))
                                  .toList(),
                            ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'SAVINGS TARGETS',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: AppTheme.textGrey,
                                  letterSpacing: 2,
                                ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline,
                                color: AppTheme.primaryNeon),
                            onPressed: _addGoal,
                          ),
                        ],
                      ).animate().fadeIn(delay: 400.ms),
                      const SizedBox(height: 16),
                      _goals.isEmpty
                          ? _buildEmptyState('No savings targets initialized')
                          : Column(
                              children:
                                  _goals.map((g) => _buildGoalCard(g)).toList(),
                            ),
                      const SizedBox(height: 80), // Bottom padding for nav bar
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: AppTheme.textGrey.withOpacity(0.5)),
      ),
    ).animate().fadeIn();
  }

  Widget _buildAIInsightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.secondaryNeon.withOpacity(0.15),
            AppTheme.backgroundBlack,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.secondaryNeon.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondaryNeon.withOpacity(0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryNeon.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome,
                    color: AppTheme.secondaryNeon, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI ANALYSIS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryNeon,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your spending on "Food" is 15% lower than last week. Optimal efficiency detected. Recommendation: Allocate surplus to "Holiday" target.',
            style: TextStyle(
                fontSize: 14,
                color: AppTheme.textWhite.withOpacity(0.9),
                height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(BudgetItem budget) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  budget.category ?? 'GENERAL',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNeon.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppTheme.primaryNeon.withOpacity(0.3)),
                  ),
                  child: Text(
                    budget.period ?? 'MONTHLY',
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.primaryNeon),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('USAGE',
                    style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                Text(
                  'Rp ${NumberFormat('#,###').format(budget.amount)} LIMIT',
                  style:
                      const TextStyle(color: AppTheme.textGrey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0.4, // Mock value
                backgroundColor: Colors.white.withOpacity(0.1),
                color: AppTheme.primaryNeon,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '40%',
                style: TextStyle(
                    fontSize: 12, color: AppTheme.primaryNeon.withOpacity(0.8)),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.2, end: 0);
  }

  Widget _buildGoalCard(GoalItem goal) {
    double progress = (goal.currentAmount ?? 0) / (goal.targetAmount ?? 1);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  goal.name ?? 'TARGET',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                Icon(Icons.flag,
                    color: AppTheme.accentPink.withOpacity(0.7), size: 20),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rp ${NumberFormat.compact().format(goal.currentAmount)}',
                  style: const TextStyle(
                      color: AppTheme.accentPink, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Rp ${NumberFormat.compact().format(goal.targetAmount)}',
                  style: const TextStyle(color: AppTheme.textGrey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.1),
                color: AppTheme.accentPink,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  // Add funds logic (mock)
                  goal.currentAmount = (goal.currentAmount ?? 0) + 50000;
                  await GoalDb.instance.update(goal);
                  _loadData();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.accentPink,
                  side: BorderSide(color: AppTheme.accentPink.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('INJECT FUNDS (+50k)'),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.2, end: 0);
  }
}
