import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:indosemecb2b/screen/login.dart';
import 'package:indosemecb2b/utils/user_data_manager.dart'; // Import helper

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

  @override
  void initState() {
    super.initState();
    _loadLoginStatus();
  }

  Future<void> _loadLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('isLoggedIn') ?? false;
    final email = prefs.getString('userEmail');
    final name = prefs.getString('userName');
    final login = prefs.getString('userLogin'); // <- Tambahkan

    setState(() {
      isLoggedIn = loggedIn;
      userEmail = email;
      userName = name;
      userLogin = login;
    });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Logout'),
            content: const Text('Apakah Anda yakin ingin keluar?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    // Hapus status login saja (jangan hapus akun terdaftar)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userEmail');
    await prefs.remove('userName');

    // Hapus cache user lokal (jika kamu pakai UserDataManager)
    await UserDataManager.clearCurrentUser();

    // Update UI
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

      // Arahkan kembali ke halaman login
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

  // ==================== VIEW BELUM LOGIN ====================
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

  // ==================== VIEW SUDAH LOGIN ====================
  Widget _buildLoggedInView() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // ======= HEADER BIRU DENGAN AKUN + AKUN TERHUBUNG + KUPON =======
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
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 40, color: Colors.grey),
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
                            children: const [
                              _ConnectedItem(
                                icon: Icons.account_balance_wallet_outlined,
                                label: 'Saldo Klik',
                                buttonText: 'Aktifkan',
                              ),
                              SizedBox(width: 1),
                              _ConnectedItem(
                                icon: Icons.credit_card_outlined,
                                label: 'i.saku',
                                buttonText: 'Hubungkan',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
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
                                      'Kupon Saya',
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
                                        borderRadius: BorderRadius.circular(6),
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
                                  'Kumpulan kupon yang kamu punya',
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
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      value: 2 / 6,
                      color: Colors.blue[600],
                      backgroundColor: Colors.grey[200],
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '2/6',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tambahkan Email, Jenis Kelamin, Tanggal Lahir, Foto Profil kamu di pengaturan profil.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            // ======= KONTEN BAWAH =======
            const SizedBox(height: 16),
            _buildMenuSection(
              title: 'Pengaturan Akun',
              items: [
                _menuItem(
                  'Ubah Profil',
                  'Data diri, Email, dan Nomor handphone',
                ),
                _menuItem('Ubah Kata Sandi', 'Ubah kata sandi kamu'),
                _menuItem('Daftar Alamat', 'Pengaturan alamat tujuan'),
                _menuItem(
                  'Rekening Bank',
                  'Tarik Saldo Klik ke rekening tujuan',
                ),
                _menuItem(
                  'Bantuan',
                  'Informasi lebih lanjut terkait pertanyaanmu',
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
                  // Tombol logout di kiri
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

                  // Kode pengguna di kanan
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

  Widget _menuItem(String title, String subtitle) {
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
          onTap: () {},
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

  const _ConnectedItem({
    required this.icon,
    required this.label,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.blue[700]),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              buttonText,
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
