class BudgetItem {
  int? id;
  double? amount;
  String? period; // 'MONTHLY', 'WEEKLY', etc.
  String? category; // Category name or ID
  String? userId;

  BudgetItem({
    this.id,
    this.amount,
    this.period,
    this.category,
    this.userId,
  });

  Map<String, dynamic> toDb() {
    return {
      'amount': amount,
      'period': period,
      'category': category,
      'userId': userId,
    };
  }

  factory BudgetItem.fromDb(Map<String, dynamic> map) {
    return BudgetItem(
      id: map['id'],
      amount: map['amount'],
      period: map['period'],
      category: map['category'],
      userId: map['userId'],
    );
  }
}
