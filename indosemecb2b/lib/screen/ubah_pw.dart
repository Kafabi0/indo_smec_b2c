import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool obscureOld = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  String? savedPassword;

  bool min6char = false;
  bool hasNumberLetter = false;
  bool matchConfirm = false;

  @override
  void initState() {
    super.initState();
    loadPassword();
  }

  Future<void> loadPassword() async {
    final prefs = await SharedPreferences.getInstance();
    savedPassword = prefs.getString('userPassword') ?? "";
  }

  void validateRules(String text) {
    setState(() {
      min6char = text.length >= 6;
      hasNumberLetter = RegExp(r'^(?=.*[A-Za-z])(?=.*[0-9])').hasMatch(text);
      matchConfirm = text == confirmPasswordController.text;
    });
  }

  Future<void> changePassword() async {
    if (oldPasswordController.text != savedPassword) {
      snack("Kata sandi lama salah");
      return;
    }

    if (!(min6char && hasNumberLetter && matchConfirm)) {
      snack("Aturan kata sandi belum terpenuhi");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userPassword', newPasswordController.text);

    snack("Kata sandi berhasil diubah");
    Navigator.pop(context);
  }

  void snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Widget ruleItem(bool status, String text) {
    return Row(
      children: [
        Icon(
          status ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 18,
          color: status ? Colors.blue : Colors.grey,
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget passwordField(
      String hint,
      TextEditingController controller,
      bool obscure,
      VoidCallback onToggle,
      ) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      onChanged: validateRules,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ubah Kata Sandi"),
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: changePassword,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            backgroundColor: Colors.blue,
          ),
          child: const Text(
            "Simpan",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            passwordField(
              "Masukkan Kata Sandi Lama *",
              oldPasswordController,
              obscureOld,
              () => setState(() => obscureOld = !obscureOld),
            ),
            const SizedBox(height: 15),

            passwordField(
              "Masukkan Kata Sandi Baru *",
              newPasswordController,
              obscureNew,
              () => setState(() => obscureNew = !obscureNew),
            ),
            const SizedBox(height: 15),

            passwordField(
              "Masukkan Konfirmasi Kata Sandi Baru *",
              confirmPasswordController,
              obscureConfirm,
              () => setState(() => obscureConfirm = !obscureConfirm),
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Kata sandi wajib mengandung",
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 10),

                  ruleItem(min6char, "Minimum 6 karakter"),
                  const SizedBox(height: 8),
                  ruleItem(hasNumberLetter, "Campuran angka dan huruf"),
                  const SizedBox(height: 8),
                  ruleItem(matchConfirm, "Konfirmasi sama dengan baru"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
