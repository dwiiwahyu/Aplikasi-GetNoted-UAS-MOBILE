import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Kelas model Note untuk menyimpan data catatan
class Note {
  String title;
  String content;
  DateTime date;

  Note({
    required this.title,
    required this.content,
    required this.date,
  });

  // Fungsi untuk mengonversi Note menjadi Map agar bisa disimpan ke SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
    };
  }

  // Fungsi untuk mengonversi Map menjadi Note
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      title: map['title'],
      content: map['content'],
      date: DateTime.parse(map['date']),
    );
  }
}

class JournalingPage extends StatefulWidget {
  const JournalingPage({super.key});

  @override
  State<JournalingPage> createState() => _JournalingPageState();
}

class _JournalingPageState extends State<JournalingPage> {
  // List untuk menyimpan semua catatan
  List<Note> notes = [];

  // Controller untuk input judul dan konten catatan
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  // Fungsi untuk memuat catatan dari SharedPreferences
  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesData = prefs.getString('notes');
    if (notesData != null) {
      final List<dynamic> notesList = jsonDecode(notesData);
      setState(() {
        notes = notesList.map((note) => Note.fromMap(note)).toList();
      });
    }
  }

  // Fungsi untuk menyimpan catatan ke SharedPreferences
  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> notesList = notes.map((note) => note.toMap()).toList();
    prefs.setString('notes', jsonEncode(notesList));
  }

  // Fungsi untuk menambahkan atau mengedit catatan
  void _addOrEditNote({Note? existingNote, int? index}) {
    if (existingNote != null) {
      _titleController.text = existingNote.title;
      _contentController.text = existingNote.content;
    } else {
      _titleController.clear();
      _contentController.clear();
    }

    // Dialog input untuk catatan baru atau edit catatan
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existingNote != null ? 'Edit Note' : 'New Note'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              // Input judul
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              // Input isi catatan
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          // Tombol batal
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          // Tombol simpan atau update catatan
          ElevatedButton(
            onPressed: () {
              setState(() {
                final note = Note(
                  title: _titleController.text,
                  content: _contentController.text,
                  date: DateTime.now(),
                );

                // Update jika catatan lama, tambah jika baru
                if (existingNote != null && index != null) {
                  notes[index] = note;
                } else {
                  notes.add(note);
                }
              });
              _saveNotes(); // Menyimpan catatan ke SharedPreferences
              Navigator.pop(context);
            },
            child: Text(existingNote != null ? 'Update' : 'Save'),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menghapus catatan
  void _deleteNote(int index) {
    setState(() {
      notes.removeAt(index);
    });
    _saveNotes(); // Menyimpan perubahan setelah penghapusan
  }

  @override
  void initState() {
    super.initState();
    _loadNotes(); // Memuat catatan saat aplikasi dimulai
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigasi kembali ke halaman sebelumnya
          },
        ),
        title: const Text(
          'My Diary',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          width: 10,
                          decoration: BoxDecoration(
                            color: Colors.pinkAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        title: Text(
                          note.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat('MMMM, d').format(note.date),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text(
                                  '${DateFormat('HH.mm').format(note.date)} - ${DateFormat('HH.mm').format(note.date.add(const Duration(hours: 2)))}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _addOrEditNote(existingNote: note, index: index);
                            } else if (value == 'delete') {
                              _deleteNote(index);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        onPressed: () => _addOrEditNote(),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }
}
