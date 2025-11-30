class TransactionItem {
  int? id;
  double? amount;
  String? type; // 'EXPENSE' or 'INCOME'
  String? category;
  String? date;
  String? note;
  String? userId;

  TransactionItem({
    this.id,
    this.amount,
    this.type,
    this.category,
    this.date,
    this.note,
    this.userId,
  });

  Map<String, dynamic> toDb() {
    return {
      'amount': amount,
      'type': type,
      'category': category,
      'date': date,
      'note': note,
      'userId': userId,
    };
  }

  factory TransactionItem.fromDb(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'],
      amount: map['amount'],
      type: map['type'],
      category: map['category'],
      date: map['date'],
      note: map['note'],
      userId: map['userId'],
    );
  }
}
