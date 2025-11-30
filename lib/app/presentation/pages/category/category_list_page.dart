import 'package:finai_frontend/app/domain/entities/category_item.dart';
import 'package:finai_frontend/core/database/category_db.dart';
import 'package:finai_frontend/core/util/preferences.dart';
import 'package:flutter/material.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  List<CategoryItem> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });
    String userId = await Prefs.getCurrentUserId ?? '';
    var list = await CategoryDb.instance.getAll(userId);
    setState(() {
      _categories = list;
      _isLoading = false;
    });
  }

  Future<void> _addCategory() async {
    final nameController = TextEditingController();
    String type = 'EXPENSE';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(value: 'EXPENSE', child: Text('Expense')),
                  DropdownMenuItem(value: 'INCOME', child: Text('Income')),
                ],
                onChanged: (val) {
                  type = val!;
                },
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
                if (nameController.text.isNotEmpty) {
                  String userId = await Prefs.getCurrentUserId ?? '';
                  await CategoryDb.instance.insert(CategoryItem(
                    name: nameController.text,
                    type: type,
                    icon: 'category', // Default icon
                    color: 0xFF000000, // Default color
                    userId: userId,
                  ));
                  Navigator.pop(context);
                  _loadCategories();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCategory(int id) async {
    await CategoryDb.instance.delete(id);
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final item = _categories[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        item.type == 'INCOME' ? Colors.green : Colors.red,
                    child: Icon(
                      item.type == 'INCOME'
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(item.name ?? ''),
                  subtitle: Text(item.type ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCategory(item.id!),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        child: const Icon(Icons.add),
      ),
    );
  }
}
