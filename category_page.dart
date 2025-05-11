import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // untuk encode/decode JSON

class CategoryPage extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final Function(List<Map<String, dynamic>>) onCategoryUpdated;

  const CategoryPage({
    super.key,
    required this.categories,
    required this.onCategoryUpdated,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late List<Map<String, dynamic>> localCategories;

  @override
  void initState() {
    super.initState();
    localCategories = List.from(widget.categories);
    _loadCategoriesFromPrefs(); // Memuat data saat awal
  }

  Future<void> _saveCategoriesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(localCategories.map((cat) {
      return {
        'name': cat['name'],
        'color': cat['color'].value, // simpan integer dari warna
      };
    }).toList());
    await prefs.setString('categories', encoded);
  }

  Future<void> _loadCategoriesFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('categories');
    if (data != null) {
      final decoded = jsonDecode(data) as List;
      setState(() {
        localCategories = decoded.map((item) {
          return {
            'name': item['name'],
            'color': Color(item['color']),
          };
        }).toList();
      });
      widget.onCategoryUpdated(localCategories);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Center(
                    child: Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFE9E9E9),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: ListView.builder(
                  itemCount: localCategories.length,
                  itemBuilder: (context, index) {
                    final category = localCategories[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: category['color'],
                        ),
                        title: Text(category['name']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditCategoryDialog(category, index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Color.fromARGB(255, 228, 71, 71)),
                              onPressed: () => _deleteCategory(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: _showAddCategoryDialog,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Category Name'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _pickColor((color) {
                  selectedColor = color;
                }),
                child: const Text('Pick Color'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  localCategories.add({
                    'name': nameController.text,
                    'color': selectedColor,
                  });
                });
                widget.onCategoryUpdated(localCategories);
                _saveCategoriesToPrefs(); // Simpan perubahan
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(Map<String, dynamic> category, int index) {
    final nameController = TextEditingController(text: category['name']);
    Color selectedColor = category['color'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Category'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Category Name'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _pickColor((color) {
                  selectedColor = color;
                }),
                child: const Text('Pick New Color'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  localCategories[index] = {
                    'name': nameController.text,
                    'color': selectedColor,
                  };
                });
                widget.onCategoryUpdated(localCategories);
                _saveCategoriesToPrefs(); // Simpan perubahan
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(int index) {
    setState(() {
      localCategories.removeAt(index);
    });
    widget.onCategoryUpdated(localCategories);
    _saveCategoriesToPrefs(); // Simpan perubahan
  }

  void _pickColor(Function(Color) onColorPicked) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a Color'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Wrap(
                spacing: 10,
                children: [
                  _colorCircle(Colors.blue, onColorPicked),
                  _colorCircle(Colors.green, onColorPicked),
                  _colorCircle(Colors.amber, onColorPicked),
                  _colorCircle(Colors.red, onColorPicked),
                  _colorCircle(Colors.purple, onColorPicked),
                  _colorCircle(Colors.orange, onColorPicked),
                  _colorCircle(Colors.teal, onColorPicked),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _colorCircle(Color color, Function(Color) onColorPicked) {
    return GestureDetector(
      onTap: () {
        onColorPicked(color);
        Navigator.of(context).pop();
      },
      child: CircleAvatar(
        backgroundColor: color,
        radius: 15,
      ),
    );
  }
}
