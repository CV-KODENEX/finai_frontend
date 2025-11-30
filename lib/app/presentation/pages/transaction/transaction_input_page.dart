import 'package:finai_frontend/app/domain/entities/category_item.dart';
import 'package:finai_frontend/app/domain/entities/transaction_item.dart';
import 'package:finai_frontend/core/database/category_db.dart';
import 'package:finai_frontend/core/database/transaction_db.dart';
import 'package:finai_frontend/core/util/navigation.dart';
import 'package:finai_frontend/core/util/preferences.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionInputPage extends StatefulWidget {
  const TransactionInputPage({super.key});

  @override
  State<TransactionInputPage> createState() => _TransactionInputPageState();
}

class _TransactionInputPageState extends State<TransactionInputPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _aiInputController = TextEditingController();

  String _type = 'EXPENSE'; // EXPENSE or INCOME
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  List<CategoryItem> _categories = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    String userId = await Prefs.getCurrentUserId ?? '';
    var cats = await CategoryDb.instance.getAll(userId);

    // Seed default categories if empty
    if (cats.isEmpty) {
      await _seedCategories(userId);
      cats = await CategoryDb.instance.getAll(userId);
    }

    setState(() {
      _categories = cats;
      if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first.name;
      }
    });
  }

  Future<void> _seedCategories(String userId) async {
    List<CategoryItem> defaults = [
      CategoryItem(
          name: 'Food',
          type: 'EXPENSE',
          icon: 'fastfood',
          color: 0xFFFF0000,
          userId: userId),
      CategoryItem(
          name: 'Transport',
          type: 'EXPENSE',
          icon: 'directions_car',
          color: 0xFF00FF00,
          userId: userId),
      CategoryItem(
          name: 'Salary',
          type: 'INCOME',
          icon: 'attach_money',
          color: 0xFF0000FF,
          userId: userId),
      CategoryItem(
          name: 'Shopping',
          type: 'EXPENSE',
          icon: 'shopping_bag',
          color: 0xFFFF00FF,
          userId: userId),
      CategoryItem(
          name: 'Entertainment',
          type: 'EXPENSE',
          icon: 'movie',
          color: 0xFFFFFF00,
          userId: userId),
    ];
    for (var c in defaults) {
      await CategoryDb.instance.insert(c);
    }
  }

  Future<void> _saveManual() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String userId = await Prefs.getCurrentUserId ?? '';

        TransactionItem item = TransactionItem(
          amount: double.parse(_amountController.text),
          type: _type,
          category: _selectedCategory,
          date: _selectedDate.toIso8601String(),
          note: _noteController.text,
          userId: userId,
        );

        await TransactionDb.instance.insert(item);
        navigateBack();
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

  Future<void> _processAI() async {
    if (_aiInputController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Mock AI processing
      // "Bought lunch 50000" -> Expense, Food, 50000
      String input = _aiInputController.text.toLowerCase();
      double amount = 0;
      String type = 'EXPENSE';
      String category = 'General';

      // Extract number
      RegExp regExp = RegExp(r'\d+');
      var match = regExp.firstMatch(input);
      if (match != null) {
        amount = double.parse(match.group(0)!);
      }

      if (input.contains('salary') || input.contains('income')) {
        type = 'INCOME';
        category = 'Salary';
      } else if (input.contains('food') ||
          input.contains('lunch') ||
          input.contains('dinner')) {
        category = 'Food';
      } else if (input.contains('transport') ||
          input.contains('taxi') ||
          input.contains('gas')) {
        category = 'Transport';
      }

      String userId = await Prefs.getCurrentUserId ?? '';

      TransactionItem item = TransactionItem(
        amount: amount,
        type: type,
        category: category,
        date: DateTime.now().toIso8601String(),
        note: input,
        userId: userId,
      );

      await TransactionDb.instance.insert(item);
      navigateBack();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Manual'),
            Tab(text: 'AI Assistant'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildManualTab(),
          _buildAITab(),
        ],
      ),
    );
  }

  Widget _buildManualTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: RadioListTile(
                    title: const Text('Expense'),
                    value: 'EXPENSE',
                    groupValue: _type,
                    onChanged: (val) {
                      setState(() {
                        _type = val.toString();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile(
                    title: const Text('Income'),
                    value: 'INCOME',
                    groupValue: _type,
                    onChanged: (val) {
                      setState(() {
                        _type = val.toString();
                      });
                    },
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
              validator: (val) => val!.isEmpty ? 'Enter amount' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((c) {
                return DropdownMenuItem(
                  value: c.name,
                  child: Text(c.name ?? ''),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCategory = val;
                });
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                  'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveManual,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Save Transaction'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAITab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, size: 64, color: Colors.purple),
          const SizedBox(height: 16),
          const Text(
            'Tell me about your transaction',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Example: "Bought lunch for 50000" or "Received salary 5000000"',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _aiInputController,
            decoration: const InputDecoration(
              hintText: 'Type here...',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.mic),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _processAI,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Process with AI'),
            ),
          ),
        ],
      ),
    );
  }
}
