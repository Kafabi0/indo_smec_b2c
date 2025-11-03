import 'dart:io';

import 'package:flutter/material.dart';
import 'package:indosemecb2b/screen/bantuan.dart';
import 'package:indosemecb2b/screen/daftar_alamat.dart';
import 'package:indosemecb2b/screen/edit_profile_screen.dart';
import 'package:indosemecb2b/screen/notification_provider.dart';
import 'package:indosemecb2b/screen/poinku.dart';
import 'package:indosemecb2b/screen/saldo.dart';
import 'package:indosemecb2b/screen/ubah_pw.dart';
import 'package:indosemecb2b/screen/setup_pin.dart'; // ✅ ADD
import 'package:indosemecb2b/utils/saldo_klik_manager.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:indosemecb2b/screen/login.dart';
import 'package:indosemecb2b/utils/user_data_manager.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onLogout;
  const ProfileScreen({Key? key, this.onLogout}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoggedIn = false;
  String? userEmail;
  String? userName;
  String? userLogin;
  String? imagePath; // ✅ Tambahkan ini

  // ✅ TAMBAHKAN STATE UNTUK SALDO KLIK
  bool _isSaldoKlikActive = false;
  double _saldoKlik = 0.0;

  // ✅ TAMBAHKAN FORMAT RUPIAH
  static final _formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );
  double profileProgress = 0.0;
  int completedSteps = 0;

  @override
  void initState() {
    super.initState();
    _loadLoginStatus();
    _loadProfileProgress();
  }

  Future<void> _loadProfileProgress() async {
    final loginValue = await UserDataManager.getCurrentUserLogin();
    final profile = await UserDataManager.getUserProfile(loginValue!);
    if (profile == null) return;

    int filled = 0;
    if ((profile['name'] ?? '').toString().trim().isNotEmpty) filled++;
    if ((profile['email'] ?? '').toString().trim().isNotEmpty) filled++;
    if (loginValue.isNotEmpty) filled++;
    if (profile['gender'] != null && profile['gender'].toString().isNotEmpty)
      filled++;
    if ((profile['birthdate'] ?? '').toString().trim().isNotEmpty) filled++;
    if (profile['imagePath'] != null && File(profile['imagePath']).existsSync())
      filled++;

    setState(() {
      profileProgress = filled / 6;
      completedSteps = filled;
    });
  }

  String _getProfileHintText() {
    if (profileProgress == 1) {
      return 'Profil kamu sudah lengkap! 🎉';
    } else {
      return 'Lengkapi data seperti Email, Jenis Kelamin, Tanggal Lahir, dan Foto Profil kamu.';
    }
  }

  Future<void> _loadLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('isLoggedIn') ?? false;
    final email = prefs.getString('userEmail');
    final name = prefs.getString('userName');
    final login = prefs.getString('userLogin');

    // ✅ LOAD STATUS DAN SALDO KLIK
    final isSaldoActive = await SaldoKlikManager.isActive();
    final saldo = await SaldoKlikManager.getSaldo();

    // ✅ MUAT PROFIL USER DARI UserDataManager
    // ✅ MUAT PROFIL USER DARI UserDataManager
    String? imgPath;
    String? updatedName;
    if (login != null) {
      final profile = await UserDataManager.getUserProfile(login);
      imgPath = profile?['imagePath'];
      updatedName = profile?['name'];
    }

    setState(() {
      isLoggedIn = loggedIn;
      userEmail = email;
      userName = updatedName ?? name; // ✅ gunakan nama profil jika tersedia
      userLogin = login;
      _isSaldoKlikActive = isSaldoActive;
      _saldoKlik = saldo;
      imagePath = imgPath;
    });
  }

  Future<double> _getProfileCompletion() async {
    final loginValue = await UserDataManager.getCurrentUserLogin();
    if (loginValue == null) return 0;

    final profile = await UserDataManager.getUserProfile(loginValue);
    if (profile == null) return 0;

    int filled = 0;
    int total = 6;

    // ✅ Nama
    if ((profile['name'] ?? '').toString().trim().isNotEmpty) filled++;

    // ✅ Email
    if ((profile['email'] ?? '').toString().trim().isNotEmpty) filled++;

    // ✅ Nomor HP
    if (loginValue.isNotEmpty) filled++;

    // ✅ Jenis Kelamin
    if (profile['gender'] != null && profile['gender'].toString().isNotEmpty) {
      filled++;
    }

    // ✅ Tanggal Lahir
    if ((profile['birthdate'] ?? '').toString().trim().isNotEmpty) filled++;

    // ✅ Foto Profil
    if (profile['imagePath'] != null &&
        File(profile['imagePath']).existsSync()) {
      filled++;
    }

    return filled / total; // contoh hasil 0.5 berarti 50%
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                const Text(
                  "Keluar dari Indosmec",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Apakah kamu ingin keluar dari Indosmec?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Keluar",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF1976D2)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Batalkan",
                      style: TextStyle(
                        color: Color(0xFF1976D2),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    if (context.mounted) {
      final notifProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      await notifProvider.clearForLogout();

      print('🚪 Logout success, notifications cleared');
    }
    await prefs.remove('userEmail');
    await prefs.remove('userName');
    await UserDataManager.clearCurrentUser();

    setState(() {
      isLoggedIn = false;
      userEmail = null;
    });

    widget.onLogout?.call();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil logout'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: isLoggedIn ? _buildLoggedInView() : _buildLoginView(),
    );
  }

  Widget _buildLoginView() {
    return SafeArea(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.blue[700],
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Akun',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Masuk atau daftar ke Klik Indomaret',
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                      const SizedBox(height: 13),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                            _loadLoginStatus();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Masuk / Daftar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedInView() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.blue[700]),
              padding: const EdgeInsets.only(top: 24, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Akun Saya',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            (imagePath != null && File(imagePath!).existsSync())
                                ? FileImage(File(imagePath!))
                                : null,
                        child:
                            (imagePath == null ||
                                    !File(imagePath!).existsSync())
                                ? const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.grey,
                                )
                                : null,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName ?? 'Pengguna Baru',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            userLogin ?? 'kafabi',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: const [
                              Text(
                                'Lengkapi profil kamu',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.white70,
                                size: 18,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ========== AKUN TERHUBUNG ==========
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.link, color: Colors.blue),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Akun Terhubung',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // ✅ UPDATE _ConnectedItem UNTUK SALDO KLIK
                              _ConnectedItem(
                                icon: Icons.account_balance_wallet_outlined,
                                label: 'Saldo Klik',
                                buttonText:
                                    _isSaldoKlikActive
                                        ? _formatRupiah.format(_saldoKlik)
                                        : 'Aktifkan',
                                isActive: _isSaldoKlikActive,
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const SaldoKlikScreen(),
                                    ),
                                  );
                                  // ✅ REFRESH SETELAH KEMBALI
                                  _loadLoginStatus();
                                },
                              ),
                              const SizedBox(width: 1),
                              const _ConnectedItem(
                                icon: Icons.credit_card_outlined,
                                label: 'i.saku',
                                buttonText: 'Hubungkan',
                                isActive: false,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => PoinkuMainScreen(),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.card_giftcard,
                              color: Colors.orange,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Voucher Saya',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red[600],
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Text(
                                          'Baru',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Kumpulan Voucher yang kamu punya',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () async {
                  // Buka halaman edit profil
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );

                  // Setelah user kembali dari halaman edit, update progress
                  _loadProfileProgress();
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lengkapi profil kamu',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: profileProgress, // ✅ nilai dinamis dari state
                        color: Colors.blue[600],
                        backgroundColor: Colors.grey[200],
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$completedSteps/6',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getProfileHintText(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            _buildMenuSection(
              title: 'Pengaturan Akun',
              items: [
                _menuItem(
                  'Ubah Profil',
                  'Data diri, Email, dan Nomor handphone',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    ).then((_) => _loadLoginStatus());
                  },
                ),
                _menuItem(
                  'Ubah Kata Sandi',
                  'Ubah kata sandi kamu',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen(),
                      ),
                    ).then((_) => _loadLoginStatus());
                  },
                ),
                _menuItem(
                  'Daftar Alamat',
                  'Pengaturan alamat tujuan',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DaftarAlamatScreen(),
                      ),
                    ).then((_) => _loadLoginStatus());
                  },
                ),
                _menuItem(
                  'Rekening Bank',
                  'Tarik Saldo Klik ke rekening tujuan',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SaldoKlikScreen(),
                      ),
                    ).then((_) => _loadLoginStatus());
                  },
                ),
                _menuItem(
                  'Bantuan',
                  'Informasi lebih lanjut terkait pertanyaanmu',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BantuanScreen()),
                    );
                  },
                ),

                _menuItem('Resolusi Komplain', 'Daftar Komplain'),
                _menuItem(
                  'Review Aplikasi',
                  'Berikan Penilaianmu untuk IndoSmec B2C',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.red, size: 18),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    'V2510102',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<Widget> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _menuItem(String title, String subtitle, {VoidCallback? onTap}) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }
}

class _ConnectedItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String buttonText;
  final bool isActive; // ✅ TAMBAHKAN PARAMETER
  final VoidCallback? onTap;

  const _ConnectedItem({
    required this.icon,
    required this.label,
    required this.buttonText,
    this.isActive = false, // ✅ DEFAULT FALSE
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue[700]),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                // ✅ UBAH WARNA BERDASARKAN STATUS
                color: isActive ? Colors.green[50] : Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                buttonText,
                style: TextStyle(
                  // ✅ UBAH WARNA TEXT BERDASARKAN STATUS
                  color: isActive ? Colors.green[700] : Colors.blue[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
