import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'category_page.dart';
import 'focus_timer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final List<Map<String, dynamic>> tasks = [];
  final List<Map<String, dynamic>> finishedTasks = [];

  List<Map<String, dynamic>> categories = [
    {'name': 'Coursework', 'color': Colors.blue},
    {'name': 'Bootcamp', 'color': Colors.green},
    {'name': 'Workout', 'color': Colors.amber},
  ];

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTasksFromPrefs();
  }

  Future<void> _saveTasksToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedTasks = jsonEncode(tasks.map((task) => {
      'title': task['title'],
      'date': task['date'].toIso8601String(),
      'time': task['time'],
      'category': task['category'],
      'color': task['color'].value,
      'isDone': task['isDone'],
    }).toList());
    await prefs.setString('tasks', encodedTasks);
  }

  Future<void> _loadTasksFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedTasks = prefs.getString('tasks');
    if (encodedTasks != null) {
      final List decoded = jsonDecode(encodedTasks);
      setState(() {
        tasks.clear();
        for (var item in decoded) {
          tasks.add({
            'title': item['title'],
            'date': DateTime.parse(item['date']),
            'time': item['time'],
            'category': item['category'],
            'color': Color(item['color']),
            'isDone': item['isDone'],
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentIndex == 0 ? Colors.lightGreen : Colors.white,
      appBar: _currentIndex == 0
          ? AppBar(
              backgroundColor: Colors.purpleAccent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: const Text(
                'My To-Do List',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              centerTitle: true,
              elevation: 0,
            )
          : null,
      body: _buildBody(),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              backgroundColor: Colors.purpleAccent,
              onPressed: _showAddTaskDialog,
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Category'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Timer'),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return CategoryPage(
          categories: categories,
          onCategoryUpdated: (updatedCategories) {
            setState(() {
              categories = updatedCategories;
            });
          },
        );
      case 2:
        return const FocusTimerPage();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return Column(
      children: [
        const SizedBox(height: 5),
        _buildCalendar(),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFE9E9E9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: ListView(
                children: [
                  const SizedBox(height: 10),
                  _buildTaskSections(),
                  const SizedBox(height: 10),
                  _buildFinishedTasks(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      focusedDay: _focusedDay,
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(color: Color.fromARGB(255, 145, 141, 141), shape: BoxShape.circle),
        selectedDecoration: BoxDecoration(color: Colors.deepPurple, shape: BoxShape.circle),
        defaultTextStyle: TextStyle(color: Colors.white),
        weekendTextStyle: TextStyle(color: Colors.red),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        weekendStyle: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
    );
  }

  Widget _buildTaskSections() {
    Map<DateTime, List<Map<String, dynamic>>> groupedTasks = {};
    for (var task in tasks) {
      final taskDate = DateTime(task['date'].year, task['date'].month, task['date'].day);
      groupedTasks.putIfAbsent(taskDate, () => []).add(task);
    }

    List<Widget> sections = [];
    groupedTasks.forEach((date, taskList) {
      sections.add(_buildTaskSection(DateFormat('d MMMM yyyy', 'en').format(date), taskList));
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections,
    );
  }

  Widget _buildTaskSection(String title, List<Map<String, dynamic>> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...tasks.map((task) => _buildTaskItem(task)),
      ],
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    final formattedDate = DateFormat('d MMMM', 'en').format(task['date']);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 5,
          height: double.infinity,
          color: task['color'],
        ),
        title: Text(
          task['title'],
          style: task['isDone'] ? const TextStyle(decoration: TextDecoration.lineThrough) : null,
        ),
        subtitle: Text('$formattedDate • ${task['time']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit), onPressed: () => _showEditTaskDialog(task)),
            IconButton(
              icon: const Icon(Icons.delete, color: Color.fromARGB(255, 228, 71, 71)),
              onPressed: () {
                setState(() {
                  tasks.remove(task);
                  _saveTasksToPrefs();
                });
              },
            ),
            Checkbox(
              value: task['isDone'],
              onChanged: (value) {
                setState(() {
                  task['isDone'] = value ?? false;
                  if (task['isDone']) {
                    finishedTasks.add(task);
                    tasks.remove(task);
                  }
                  _saveTasksToPrefs();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinishedTasks() {
    if (finishedTasks.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Finished Tasks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...finishedTasks.map((task) => _buildFinishedTaskItem(task)),
      ],
    );
  }

  Widget _buildFinishedTaskItem(Map<String, dynamic> task) {
    final formattedDate = DateFormat('d MMMM', 'id').format(task['date']);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(task['title'], style: const TextStyle(decoration: TextDecoration.lineThrough)),
        subtitle: Text('$formattedDate • ${task['time']}'),
      ),
    );
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final timeController = TextEditingController();
    DateTime selectedDate = _selectedDay;
    String? selectedCategory = categories.isNotEmpty ? categories[0]['name'] : '';
    Color selectedColor = categories.isNotEmpty ? categories[0]['color'] : Colors.blue;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Task Title')),
              TextField(controller: timeController, decoration: const InputDecoration(labelText: 'Time (e.g. 19.00 - 21.00)')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category['name'],
                    child: Text(category['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedCategory = value;
                  selectedColor = categories.firstWhere((c) => c['name'] == value)['color'];
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                tasks.add({
                  'title': titleController.text,
                  'date': selectedDate,
                  'time': timeController.text,
                  'category': selectedCategory,
                  'color': selectedColor,
                  'isDone': false,
                });
                _saveTasksToPrefs();
              });
              Navigator.of(context).pop();
            },
            child: const Text('Add Task'),
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(Map<String, dynamic> task) {
    final titleController = TextEditingController(text: task['title']);
    final timeController = TextEditingController(text: task['time']);
    String? selectedCategory = task['category'];
    Color selectedColor = task['color'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Task Title')),
              TextField(controller: timeController, decoration: const InputDecoration(labelText: 'Time')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category['name'],
                    child: Text(category['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                    selectedColor = categories.firstWhere((c) => c['name'] == value)['color'];
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                task['title'] = titleController.text;
                task['time'] = timeController.text;
                task['category'] = selectedCategory;
                task['color'] = selectedColor;
                _saveTasksToPrefs();
              });
              Navigator.of(context).pop();
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}
