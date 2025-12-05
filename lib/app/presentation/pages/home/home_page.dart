import 'dart:ui';

import 'package:finai_frontend/app/domain/entities/transaction_item.dart';
import 'package:finai_frontend/core/database/transaction_db.dart';
import 'package:finai_frontend/core/style/app_theme.dart';
import 'package:finai_frontend/core/util/navigation.dart';
import 'package:finai_frontend/core/util/preferences.dart';
import 'package:finai_frontend/app/presentation/pages/chat/chat_page.dart';
import 'package:finai_frontend/app/presentation/pages/profile/profile_page.dart';
import 'package:finai_frontend/app/presentation/pages/stats/stats_page.dart';
import 'package:finai_frontend/app/presentation/pages/transaction/transaction_input_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      extendBody: true,
      body: Stack(
        children: [
          // Background Gradient
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
          pages[_currentIndex],
        ],
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark.withOpacity(0.8),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              selectedItemColor: AppTheme.primaryNeon,
              unselectedItemColor: Colors.grey,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard_rounded), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.chat_bubble_outline), label: 'AI Chat'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.pie_chart_outline), label: 'Stats'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline), label: 'Profile'),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                await navigateTo(const TransactionInputPage());
                _loadData(); // Refresh data after returning
              },
              backgroundColor: AppTheme.primaryNeon,
              child: const Icon(Icons.add, color: Colors.black),
            ).animate().scale(delay: 500.ms)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.primaryNeon,
        backgroundColor: AppTheme.surfaceDark,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WELCOME BACK',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppTheme.textGrey,
                                    letterSpacing: 2,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userName.toUpperCase(),
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.primaryNeon),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryNeon.withOpacity(0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            backgroundColor: AppTheme.surfaceDark,
                            child:
                                Icon(Icons.person, color: AppTheme.primaryNeon),
                          ),
                        ),
                      ],
                    ).animate().fadeIn().moveY(begin: -20, end: 0),
                    const SizedBox(height: 24),
                    _buildSummaryCard().animate().fadeIn(delay: 200.ms).scale(),
                    const SizedBox(height: 24),
                    _buildAIInsights()
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .moveX(begin: -20, end: 0),
                    const SizedBox(height: 24),
                    Text(
                      'RECENT TRANSACTIONS',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppTheme.textGrey,
                            letterSpacing: 2,
                          ),
                    ).animate().fadeIn(delay: 600.ms),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _isLoading
                ? const SliverFillRemaining(
                    child: Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primaryNeon)),
                  )
                : _transactions.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long,
                                  size: 64,
                                  color: AppTheme.textGrey.withOpacity(0.3)),
                              const SizedBox(height: 16),
                              Text('No transactions yet',
                                  style: TextStyle(color: AppTheme.textGrey)),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = _transactions[index];
                            return _buildTransactionItem(item, index);
                          },
                          childCount: _transactions.length,
                        ),
                      ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark.withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryNeon.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL BALANCE',
                    style: TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 12,
                        letterSpacing: 1.5),
                  ),
                  Icon(Icons.account_balance_wallet_outlined,
                      color: AppTheme.primaryNeon.withOpacity(0.7)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Rp ${NumberFormat('#,###').format(_totalIncome - _totalExpense)}',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppTheme.textWhite,
                  shadows: [
                    Shadow(
                      color: AppTheme.primaryNeon.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'INCOME',
                      _totalIncome,
                      AppTheme.primaryNeon,
                      Icons.arrow_downward,
                    ),
                  ),
                  Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.1)),
                  Expanded(
                    child: _buildStatItem(
                      'EXPENSE',
                      _totalExpense,
                      AppTheme.accentPink,
                      Icons.arrow_upward,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, double amount, Color color, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Rp ${NumberFormat.compact().format(amount)}',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildAIInsights() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.secondaryNeon.withOpacity(0.2),
            AppTheme.primaryNeon.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.secondaryNeon.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.secondaryNeon.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.auto_awesome, color: AppTheme.secondaryNeon),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI INSIGHT',
                  style: TextStyle(
                    color: AppTheme.secondaryNeon,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Spending is 15% lower than last month. Good job!',
                  style: TextStyle(
                      color: AppTheme.textWhite.withOpacity(0.9), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(TransactionItem item, int index) {
    final isIncome = item.type == 'INCOME';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isIncome
                ? AppTheme.primaryNeon.withOpacity(0.1)
                : AppTheme.accentPink.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncome ? AppTheme.primaryNeon : AppTheme.accentPink,
            size: 20,
          ),
        ),
        title: Text(
          item.category ?? 'General',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          item.note ?? '',
          style: TextStyle(color: AppTheme.textGrey.withOpacity(0.7)),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isIncome ? '+' : '-'} Rp ${NumberFormat('#,###').format(item.amount)}',
              style: TextStyle(
                color: isIncome ? AppTheme.primaryNeon : AppTheme.accentPink,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd MMM').format(DateTime.parse(
                  item.date ?? DateTime.now().toIso8601String())),
              style: TextStyle(
                  fontSize: 12, color: AppTheme.textGrey.withOpacity(0.5)),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.2, end: 0);
  }
}
