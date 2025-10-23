import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  final String userInput;
  const RegisterPage({super.key, required this.userInput});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _emailController = TextEditingController();
  bool _showPassword = false;
  bool _showConfirm = false;
  bool _agree = false;

  bool get _isPasswordValid =>
      _passwordController.text.length >= 6 &&
      RegExp(r'[0-9]').hasMatch(_passwordController.text) &&
      RegExp(r'[A-Za-z]').hasMatch(_passwordController.text) &&
      _passwordController.text == _confirmController.text;

  @override
  Widget build(BuildContext context) {
    final isPhone = RegExp(r'^[0-9]+$').hasMatch(widget.userInput);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pendaftaran Akun"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: Colors.white,

      // 👉 form tetap bisa discroll
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Atur Kata Sandi",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                children: [
                  TextSpan(text: isPhone ? "Nomor " : "Email "),
                  TextSpan(
                    text: widget.userInput, // hanya bagian input user
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(
                    text:
                        " akan digunakan untuk membuat akun. Silakan lengkapi data di bawah ini untuk melanjutkan pendaftaran.",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Nama Lengkap
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Nama Lengkap *",
                hintText: "Masukkan Nama Lengkap *",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Kata Sandi
            TextField(
              controller: _passwordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: "Kata Sandi *",
                hintText: "Masukkan Kata Sandi *",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
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
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Konfirmasi
            TextField(
              controller: _confirmController,
              obscureText: !_showConfirm,
              decoration: InputDecoration(
                labelText: "Konfirmasi Kata Sandi *",
                hintText: "Masukkan Konfirmasi Kata Sandi *",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () => setState(() => _showConfirm = !_showConfirm),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 10),
            const Text(
              "Kata Sandi wajib mengandung",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            _buildPasswordRule(
              "Minimum 6 Karakter",
              _passwordController.text.length >= 6,
            ),
            _buildPasswordRule(
              "Terdapat campuran angka dan huruf",
              RegExp(
                r'^(?=.*[A-Za-z])(?=.*\d)',
              ).hasMatch(_passwordController.text),
            ),
            _buildPasswordRule(
              "Kata Sandi baru dan konfirmasi sama",
              _passwordController.text == _confirmController.text,
            ),

            const SizedBox(height: 20),

            // Email opsional
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email (Opsional)",
                hintText: "Masukkan Alamat Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Melalui email, kamu bisa melakukan masuk akun dan menerima informasi promo.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 100), // supaya bagian bawah tak tertutup
          ],
        ),
      ),

      // ✅ bagian bawah fix
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // checkbox persetujuan
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agree,
                    onChanged: (val) => setState(() => _agree = val ?? false),
                  ),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: "Dengan mendaftar, saya menyetujui ",
                        style: TextStyle(fontSize: 13),
                        children: [
                          TextSpan(
                            text: "syarat & ketentuan ",
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(text: "dari aplikasi ini"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // tombol daftar
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed:
                      _isPasswordValid &&
                              _agree &&
                              _nameController.text.isNotEmpty
                          ? _handleRegister
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Simpan dan Daftar",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRule(String text, bool condition) {
    return Row(
      children: [
        Icon(
          condition ? Icons.check_circle : Icons.radio_button_unchecked,
          color: condition ? Colors.green : Colors.grey,
          size: 18,
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  void _handleRegister() async {
    final prefs = await SharedPreferences.getInstance();

    // Simpan data user yang baru
    await prefs.setString('userEmail', widget.userInput);
    await prefs.setString('userName', _nameController.text);
    await prefs.setBool('isLoggedIn', false); // belum login, baru daftar

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Akun berhasil dibuat!")));

    // Kirimkan data kembali ke halaman login
    Navigator.pop(context, widget.userInput);
  }
}
