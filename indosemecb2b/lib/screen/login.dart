import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:indosemecb2b/screen/notification_provider.dart';
import 'package:indosemecb2b/screen/register.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:indosemecb2b/screen/main_navigasi.dart';
import 'package:indosemecb2b/utils/user_data_manager.dart'; // Import helper

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _stepTwo = false;
  bool _isFilled = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      setState(() {
        _isFilled = _emailController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isEmailOrPhone(String input) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final phoneRegex = RegExp(r'^[0-9]{9,15}$');
    return emailRegex.hasMatch(input) || phoneRegex.hasMatch(input);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Masuk atau Daftar Akun",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Masukkan Nomor Whatsapp",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Silakan masukkan nomor Whatsapp untuk masuk",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // STEP 1: Email / HP
            if (!_stepTwo) ...[
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Nomor Whatsapp",
                  hintText: "Masukkan nomor Whatsapp",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isFilled ? _checkAccountExists : null,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Lanjutkan",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],

            // STEP 2: Password
            if (_stepTwo) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _emailController.text,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _stepTwo = false;
                        _passwordController.clear();
                      });
                    },
                    child: const Text(
                      "Ubah",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: "Kata Sandi",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed:
                        () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Lupa Kata Sandi?",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Masuk",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _checkAccountExists() async {
    final input = _emailController.text.trim();

    if (!_isEmailOrPhone(input)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Masukkan email atau nomor telepon yang valid"),
        ),
      );
      return;
    }

    // 🔍 Simulasi pengecekan user di database / API
    // Nanti kamu bisa ganti dengan request ke backend
    bool exists = await _fakeCheckUser(input);

    if (exists) {
      setState(() => _stepTwo = true); // lanjut ke input password
    } else {
      // jika belum terdaftar → buka halaman Register
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RegisterPage(userInput: input)),
      );

      // Jika register sukses, isi kembali input field
      if (result != null && result is String) {
        setState(() {
          _emailController.text = result;
          _stepTwo = true; // langsung lanjut ke input password
        });
      }
    }
  }

  // simulasi pengecekan user
  Future<bool> _fakeCheckUser(String input) async {
    final prefs = await SharedPreferences.getInstance();
    final usersString = prefs.getString('registered_users');

    if (usersString == null) return false;

    final List<dynamic> users = jsonDecode(usersString);
    return users.any((u) => u['emailOrPhone'] == input);
  }

  Future<void> _handleLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final emailOrPhone = _emailController.text.trim();
    final password = _passwordController.text;

    final usersString = prefs.getString('registered_users');
    if (usersString == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Akun tidak ditemukan")));
      return;
    }

    final List<dynamic> users = jsonDecode(usersString);
    final user = users.firstWhere(
      (u) => u['emailOrPhone'] == emailOrPhone && u['password'] == password,
      orElse: () => {},
    );

    if (user.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email/Nomor HP atau kata sandi salah")),
      );
      return;
    }

    // ✅ Simpan status login dengan UserDataManager
    await UserDataManager.setCurrentUser(emailOrPhone);
    if (context.mounted) {
      final notifProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      await notifProvider.reloadForCurrentUser();

      print('✅ Login success, notifications reloaded for: $emailOrPhone');
    }
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userName', user['name']);
    await prefs.setString('userLogin', emailOrPhone); // <-- Tambahkan baris ini

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation()),
      (route) => false,
    );
  }
}
