import 'package:flutter/material.dart';
import 'menu_page.dart';


class WelcomeScreen extends StatelessWidget { 
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // warna BG app
      body: SafeArea( // agar tampilan penuh
        child: Center( // menempatkan widget ditengah layar
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const WelcomeContent(), // memanggil widget welcomescreen untuk menampilkan kontenn
          ),
        ),
      ),
    );
  }
}

// widget ini isinya konten utama 
class WelcomeContent extends StatelessWidget { 
  const WelcomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column( // pakai column untuk menyusun widget secara vertikal
      mainAxisAlignment: MainAxisAlignment.center, // menempatkan konten ditengah vertikal
      children: const [ // daftar widget yg bakal ditampilin di dlm column
        WelcomeImage(), // manggil widget welcomepage untuk menampilkan logo
        SizedBox(height: 20), // jarak vertikal antar elemen
        StartText(), // memanggil widget untuk menampilkan text
        SizedBox(height: 65), // jarak vertikal sebelum button
        LetsGoButton(), // manggil button untuk nampilkan button
      ],
    );
  }
}

// widget untuk menampilkan logo app
class WelcomeImage extends StatelessWidget {
  const WelcomeImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container( // pake container karna ini widget yg bisa diatur ukuran dan dekorasinya
      width: 250, // lebar gambar logo
      height: 260, // tinggi gambar logo
      decoration: const BoxDecoration( 
        image: DecorationImage(
          image: AssetImage('assets/images/logo.png'),
          fit: BoxFit.cover, // untuk gambar menutupi seluruh area container
        ),
      ),
    );
  }
}

// widget untuk menampilkan teks
class StartText extends StatelessWidget {
  const StartText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text( // pake widget teks untuk menampilkan teks
      'Start organizing your day \nlike a pro!',
      textAlign: TextAlign.center, // menempatkan teks ditengah
      style: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontFamily: 'Inter',
        fontWeight: FontWeight.bold,
        height: 1.5, // jarak antar baris tingginya 
      ),
    );
  }
}

// widget untuk menampilkan button letsgo
class LetsGoButton extends StatelessWidget {
  const LetsGoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox( // untuk ngatur ukuran tombol
      width: 250, // lebar tombol
      height: 60, // tinggi tombol
      child: ElevatedButton( 
        onPressed: () { // aksi pas di klik
          Navigator.push( // navigasi buttonnya
            context,
            MaterialPageRoute(builder: (_) => const MenuPage()), // mengarahkan ke hal berikutnya
          );
        },
        style: ElevatedButton.styleFrom( // styling buttonnya
          backgroundColor: Colors.purpleAccent, // warna button
          shape: RoundedRectangleBorder( // bentuknya
            borderRadius: BorderRadius.circular(90), // bordernya
          ),
        ),
        child: const Text( // teks yang ditampilkan di button
          'LET’S GO',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
