import 'dart:convert';
import 'package:crypto/crypto.dart';

class LoginController {
  // Database sederhana (Hardcoded)
  bool isLocked = false;
  int _attempts = 1;
  String logInformasi = "Login Gagal! Gunakan admin/123 atau alex/456";


  // Map untuk menyimpan username dan password yang sudah di-hash
  final Map<String, String> _pengguna = {
    "admin" : hashPassword("123"),
    "alex" : hashPassword("456")
  };

  // Fungsi untuk hashing password
  static String hashPassword(String password){
    return sha256.convert(utf8.encode(password)).toString();
  }

  // fungsi untuk memberikan jeda waktu 10 detik setelah 3 kali percobaan login gagal
  void _lockLogin() {
    isLocked = true;

    Future.delayed(const Duration(seconds: 10), () {
      _attempts = 1;
      isLocked = false;
    });
  }

  // fungsi untuk validasi pengguna, apakah pengguna terdaftar atau tidak
  bool validasiPengguna(String username, String password) {
    return _pengguna.containsKey(username) && _pengguna[username] == password;
  }

  // fungsi untuk melakukan login, mengembalikan true jika login berhasil, false jika gagal
  bool login(String username, String password) {
    // Hashing password yang dimasukkan pengguna
    String hassingPassword = hashPassword(password);
    
    // Cek apakah login sedang terkunci
    if (isLocked) {
      return false;
    }

    // Validasi pengguna dengan password yang sudah di-hash
    if (validasiPengguna(username, hassingPassword)) {
      _attempts =0; 
      return true;
    }

    // Jika login gagal, tambahkan jumlah percobaan
    _attempts += 1;

    // Jika attemps melebihi batas, kunci login
    if (_attempts > 3) {
      _lockLogin();
    }
    
    return false;
  }

}
