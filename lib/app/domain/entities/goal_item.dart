class GoalItem {
  int? id;
  String? name;
  double? targetAmount;
  double? currentAmount;
  String? deadline;
  String? userId;

  GoalItem({
    this.id,
    this.name,
    this.targetAmount,
    this.currentAmount,
    this.deadline,
    this.userId,
  });

  Map<String, dynamic> toDb() {
    return {
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline,
      'userId': userId,
    };
  }

  factory GoalItem.fromDb(Map<String, dynamic> map) {
    return GoalItem(
      id: map['id'],
      name: map['name'],
      targetAmount: map['targetAmount'],
      currentAmount: map['currentAmount'],
      deadline: map['deadline'],
      userId: map['userId'],
    );
  }
}
