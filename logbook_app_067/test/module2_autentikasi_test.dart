// // test/module2_login_test.dart

// import 'package:flutter_test/flutter_test.dart';
// import 'package:logbook_app_067/features/auth/login_controller.dart';

// void main() {
//   var actual, expected;

//   group('Module 2 - LoginController', () {
//     late LoginController controller;

//     setUp(() {
//       // (1) Arrange
//       controller = LoginController();
//     });
    
//     test('verify password hashing', () {
//       // (2) Act
//       final hash1 = LoginController.hashPassword('123');
//       final hash2 = LoginController.hashPassword('123');

//       // (3) Assert
//       expect(hash1, hash2, reason: 'Hash should be consistent');
//     });

//     test('login with valid credentials', () {
//       // (2) Act
//       actual = controller.login('admin', '123');

//       // (3) Assert
//       expect(actual, isNotNull, reason: 'User should be returned');
//       expect(actual['username'], 'admin');
//     });

//     test('login with wrong username', () {
//       final expected = null;  
//       // (2) Act
//       actual = controller.login('salah_user', '123');

//       // (3) Assert
//       expect(actual, expected, reason: 'Login should fail');
//     });

//     test('login with wrong password', () {
//       final expected = null;

//       // (2) Act
//       actual = controller.login('admin', 'salah_pass');

//       // (3) Assert
//       expect(actual, expected, reason: 'Login should fail');
//     });

//     test('attempts increment on failed login', () {
//       // (2) Act
//       controller.login('salah_user', 'salah_pass');

//       // (3) Assert
//       // tidak bisa akses _attempts langsung → validasi via behavior
//       actual = controller.isLocked;
//       expected = false;

//       expect(actual, expected, reason: 'Should not be locked yet');
//     });

//     test('trigger lock after 3 failed attempts', () {
//       final expected = true;
//       // (2) Act
//       controller.login('salah', 'salah');
//       controller.login('salah', 'salah');
//       controller.login('salah', 'salah');
//       controller.login('salah', 'salah'); // ke-4 → lock

//       actual = controller.isLocked;

//       // (3) Assert
//       expect(actual, expected, reason: 'Account should be locked');
//     });

//     test('reject login when locked', () {
//       final expected = null;
//       // (1) Arrange → buat locked dulu
//       controller.login('salah', 'salah');
//       controller.login('salah', 'salah');
//       controller.login('salah', 'salah');
//       controller.login('salah', 'salah');

//       // (2) Act
//       actual = controller.login('admin', '123');

//       // (3) Assert
//       expect(actual, expected, reason: 'Login should be rejected when locked');
//     });    
//   });
// }