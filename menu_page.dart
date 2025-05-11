import 'package:flutter/material.dart';
import 'package:get_noted/screens/pofile_page.dart';
import 'todo_home_page.dart';
import 'journaling_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan SafeArea untuk memastikan konten tidak terhalang oleh area sistem seperti status bar
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 40), // Memberikan jarak vertikal
              const Text(
                'Menu', // Teks judul halaman
                style: TextStyle(
                  fontSize: 45, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)), // Menambahkan warna putih pada font
              ),
              const SizedBox(height: 40), // Memberikan jarak vertikal setelah judul
              ElevatedButton(
                onPressed: () {
                  // Navigasi menuju halaman To-do List ketika tombol ditekan
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TodoHomePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent, // Mengubah latar belakang tombol
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  minimumSize: Size(20, 20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.check_box, color: Colors.white, size: 30), // Menambahkan ikon di sebelah kiri
                    SizedBox(width: 10), // Memberikan jarak antara ikon dan teks
                    Text(
                      'To-do List', // Teks di dalam tombol
                      style: TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)), // Font berwarna white
                  ],
                ),
              ),
              const SizedBox(height: 50, width: 100), // Memberikan jarak vertikal untuk tombol berikutnya
              ElevatedButton(
                onPressed: () {
                  // Navigasi menuju halaman Journaling ketika tombol ditekan
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const JournalingPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent, // Mengubah latar belakang tombol menjadi putih
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  minimumSize: Size(20, 20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.book, color: Colors.white, size: 30), // Ikon untuk My Diary
                    SizedBox(width: 10), // Memberikan jarak antara ikon dan teks
                    Text(
                      'My Diary', // Teks di dalam tombol
                      style: TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)), // Font berwarna white
                  ],
                ),
              ),
              const SizedBox(height: 50, width: 100), // Memberikan jarak vertikal untuk tombol berikutnya
              ElevatedButton(
                onPressed: () {
                  // Navigasi menuju halaman Profile ketika tombol ditekan
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfilePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent, // Mengubah latar belakang tombol menjadi putih
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  minimumSize: Size(20, 20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.person, color: Colors.white, size: 30), // Ikon untuk Profile
                    SizedBox(width: 10), // Memberikan jarak antara ikon dan teks
                    Text(
                      'Profile', // Teks di dalam tombol
                      style: TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)), // Font berwarna white
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white, // Mengubah warna latar belakang halaman menjadi purple accent
    );
  }
}
