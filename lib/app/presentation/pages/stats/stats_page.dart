import 'package:finai_frontend/app/domain/entities/budget_item.dart';
import 'package:finai_frontend/app/domain/entities/goal_item.dart';
import 'package:finai_frontend/core/database/budget_db.dart';
import 'package:finai_frontend/core/database/goal_db.dart';
import 'package:finai_frontend/core/util/preferences.dart';
import 'package:flutter/material.dart';
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
        return AlertDialog(
          title: const Text('Add Savings Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Goal Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                    labelText: 'Target Amount', prefixText: 'Rp '),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
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
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financial Stats')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAIInsightCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'Budgets',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _budgets.isEmpty
                      ? const Text('No budgets set.')
                      : Column(
                          children:
                              _budgets.map((b) => _buildBudgetCard(b)).toList(),
                        ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Savings Goals',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.blue),
                        onPressed: _addGoal,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _goals.isEmpty
                      ? const Text('No goals set.')
                      : Column(
                          children:
                              _goals.map((g) => _buildGoalCard(g)).toList(),
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildAIInsightCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.purple),
              SizedBox(width: 8),
              Text(
                'AI Daily Insight',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Your spending on "Food" is 15% lower than last week. Great job sticking to your budget! Consider moving the savings to your "Holiday" goal.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(BudgetItem budget) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              budget.category ?? 'General Budget',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
                'Limit: Rp ${NumberFormat('#,###').format(budget.amount)} / ${budget.period}'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.4, // Mock value for now
              backgroundColor: Colors.grey.shade200,
              color: Colors.blue,
            ),
            const SizedBox(height: 4),
            const Text('40% used',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(GoalItem goal) {
    double progress = (goal.currentAmount ?? 0) / (goal.targetAmount ?? 1);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  goal.name ?? 'Goal',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Rp ${NumberFormat('#,###').format(goal.currentAmount)} / ${NumberFormat('#,###').format(goal.targetAmount)}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              color: Colors.green,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () async {
                  // Add funds logic (mock)
                  goal.currentAmount = (goal.currentAmount ?? 0) + 50000;
                  await GoalDb.instance.update(goal);
                  _loadData();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(80, 30),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text('Add Rp 50k'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
