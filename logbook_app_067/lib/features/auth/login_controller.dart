import 'dart:convert';
import 'package:crypto/crypto.dart';

class LoginController {
  bool isLocked = false;
  int _attempts = 1;
  final List<Map<String, String>> _penggunaList = [
    {
      'uid': 'user_001',
      'username': 'admin',
      'password': _hashPassword('123'),
      'role': 'Ketua',
      'teamId': 'MEKTRA_KLP_067',
    },
    {
      'uid': 'user_002',
      'username': 'alex',
      'password': _hashPassword('456'),
      'role': 'Anggota',
      'teamId': 'MEKTRA_KLP_067',
    },
    {
      'uid': 'user_003',
      'username': 'rehan',
      'password': _hashPassword('111'),
      'role': 'Asisten',
      'teamId': 'MEKTRA_KLP_067',
    },
  ];

  static String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  void _lockLogin() {
    isLocked = true;
    Future.delayed(const Duration(seconds: 10), () {
      _attempts = 1;
      isLocked = false;
    });
  }
  Map<String, String>? login(String username, String password) {
    if (isLocked) return null;

    final hashedPassword = _hashPassword(password);

    final user = _penggunaList.firstWhere(
      (u) => u['username'] == username && u['password'] == hashedPassword,
      orElse: () => {},
    );

    if (user.isNotEmpty) {
      _attempts = 0;
    
      return {
        'uid': user['uid']!,
        'username': user['username']!,
        'role': user['role']!,
        'teamId': user['teamId']!,
      };
    }

    _attempts += 1;
    if (_attempts > 3) {
      _lockLogin();
    }

    return null;
  }
}