import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController(); // Kontroler untuk nama
  final TextEditingController _ageController = TextEditingController(); // Kontroler untuk umur
  String _selectedGender = 'Male'; // Gender default yang dipilih

  @override
  void initState() {
    super.initState();
    _loadProfile(); // Memuat data profil dari SharedPreferences
  }

  // Fungsi untuk memuat data profil yang sudah disimpan
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance(); // Mengambil instance SharedPreferences
    setState(() {
      _nameController.text = prefs.getString('name') ?? ''; // Memuat nama dari SharedPreferences
      _ageController.text = prefs.getString('age') ?? ''; // Memuat umur dari SharedPreferences
      _selectedGender = prefs.getString('gender') ?? 'Male'; // Memuat gender dari SharedPreferences
    });
  }

  // Fungsi untuk menyimpan data profil
  Future<void> _saveProfile() async {
    final name = _nameController.text.trim(); // Mengambil nama dari kontroler
    final age = _ageController.text.trim(); // Mengambil umur dari kontroler
    final gender = _selectedGender; // Mengambil gender yang dipilih

    // Mengecek apakah semua field sudah diisi
    if (name.isEmpty || age.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')), // Menampilkan pesan error jika ada field yang kosong
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance(); // Mengambil instance SharedPreferences
    await prefs.setString('name', name); // Menyimpan nama ke SharedPreferences
    await prefs.setString('age', age); // Menyimpan umur ke SharedPreferences
    await prefs.setString('gender', gender); // Menyimpan gender ke SharedPreferences

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile saved!')), // Menampilkan pesan berhasil disimpan
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,  // Warna latar belakang AppBar
        centerTitle: true,
        title: Text(
          'My Profile',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Kembali ke menu utama
          },
        ),
      ),
      body: Container(
        color: Colors.white, // Warna latar belakang halaman
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Menyusun widget di tengah
          children: [
            CircleAvatar(
              radius: 100, // Ukuran avatar lingkaran
              backgroundColor: Colors.grey, // Warna latar belakang avatar
              child: Icon(
                Icons.person,
                size: 85, // Ukuran ikon dalam avatar
                color: Colors.white, // Warna ikon avatar
              ),
            ),
            SizedBox(height: 40),
            SizedBox(height: 40),
            TextField(
              controller: _nameController, // Menghubungkan TextField dengan kontroler nama
              decoration: InputDecoration(
                labelText: 'Name', // Label untuk field nama
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _ageController, // Menghubungkan TextField dengan kontroler umur
              keyboardType: TextInputType.number, // Tipe input untuk angka
              decoration: InputDecoration(
                labelText: 'Age', // Label untuk field umur
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedGender, // Menampilkan gender yang dipilih
              decoration: InputDecoration(
                labelText: 'Gender', // Label untuk field gender
                border: OutlineInputBorder(),
              ),
              items: ['Male', 'Female', 'Other']
                  .map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender), // Menampilkan pilihan gender
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value!; // Mengubah gender yang dipilih
                });
              },
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveProfile, // Menyimpan profil ketika tombol ditekan
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), // Ukuran tombol
                backgroundColor: Colors.amber, // Warna tombol
              ),
              child: Text(
                'Save',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
