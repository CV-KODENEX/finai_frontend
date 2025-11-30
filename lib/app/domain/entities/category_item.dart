class CategoryItem {
  int? id;
  String? name;
  String? type; // 'EXPENSE' or 'INCOME'
  String? icon;
  int? color;
  String? userId;

  CategoryItem({
    this.id,
    this.name,
    this.type,
    this.icon,
    this.color,
    this.userId,
  });

  Map<String, dynamic> toDb() {
    return {
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'userId': userId,
    };
  }

  factory CategoryItem.fromDb(Map<String, dynamic> map) {
    return CategoryItem(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      icon: map['icon'],
      color: map['color'],
      userId: map['userId'],
    );
  }
}
