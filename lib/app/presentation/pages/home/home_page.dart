import 'package:finai_frontend/app/domain/entities/transaction_item.dart';
import 'package:finai_frontend/core/database/transaction_db.dart';
import 'package:finai_frontend/core/util/navigation.dart';
import 'package:finai_frontend/core/util/preferences.dart';
import 'package:finai_frontend/app/presentation/pages/chat/chat_page.dart';
import 'package:finai_frontend/app/presentation/pages/profile/profile_page.dart';
import 'package:finai_frontend/app/presentation/pages/stats/stats_page.dart';
import 'package:finai_frontend/app/presentation/pages/transaction/transaction_input_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<TransactionItem> _transactions = [];
  double _totalIncome = 0;
  double _totalExpense = 0;
  bool _isLoading = true;
  String _userName = 'User';

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
    String? name = await Prefs.getUserName;
    var list = await TransactionDb.instance.getAll(userId);

    double income = 0;
    double expense = 0;
    for (var item in list) {
      if (item.type == 'INCOME') {
        income += item.amount ?? 0;
      } else {
        expense += item.amount ?? 0;
      }
    }

    setState(() {
      _transactions = list;
      _totalIncome = income;
      _totalExpense = expense;
      _isLoading = false;
      _userName = name ?? 'User';
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeContent(),
      const ChatPage(),
      const StatsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                await navigateTo(const TransactionInputPage());
                _loadData(); // Refresh data after returning
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Halo, $_userName',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildSummaryCard(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _transactions.isEmpty
                    ? const Center(child: Text('No transactions yet'))
                    : ListView.builder(
                        itemCount: _transactions.length,
                        itemBuilder: (context, index) {
                          final item = _transactions[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: item.type == 'INCOME'
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2),
                              child: Icon(
                                item.type == 'INCOME'
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: item.type == 'INCOME'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            title: Text(item.category ?? 'General'),
                            subtitle: Text(item.note ?? ''),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${item.type == 'INCOME' ? '+' : '-'} Rp ${NumberFormat('#,###').format(item.amount)}',
                                  style: TextStyle(
                                    color: item.type == 'INCOME'
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  DateFormat('dd MMM').format(DateTime.parse(
                                      item.date ??
                                          DateTime.now().toIso8601String())),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Rp ${NumberFormat('#,###').format(_totalIncome - _totalExpense)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.arrow_downward,
                          color: Colors.white70, size: 16),
                      SizedBox(width: 4),
                      Text('Income', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${NumberFormat('#,###').format(_totalIncome)}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.arrow_upward, color: Colors.white70, size: 16),
                      SizedBox(width: 4),
                      Text('Expense', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${NumberFormat('#,###').format(_totalExpense)}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
