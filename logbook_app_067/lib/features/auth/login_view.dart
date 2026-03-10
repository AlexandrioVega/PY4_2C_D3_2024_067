import 'package:flutter/material.dart';
import 'package:logbook_app_067/features/auth/login_controller.dart';
import 'package:logbook_app_067/features/logbook/log_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController _controller = LoginController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isObscure = true;

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final user = _userController.text.trim();
    final pass = _passController.text;

    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Nama dan password tidak boleh kosong!"),
          backgroundColor: Colors.red.shade400,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final currentUser = _controller.login(user, pass);

    if (currentUser != null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => LogView(currentUser: currentUser),
        ),
        (route) => false,
      );
    } else {
      final msg = _controller.isLocked
          ? "Terlalu banyak percobaan. Tunggu 10 detik."
          : "Login Gagal! Gunakan admin/123 (Ketua) atau alex/456 (Anggota)";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red.shade400,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Gatekeeper")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passController,
              obscureText: _isObscure,
              decoration: InputDecoration(
                labelText: "Password",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => _isObscure = !_isObscure);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleLogin,
                child: const Text("Masuk"),
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}