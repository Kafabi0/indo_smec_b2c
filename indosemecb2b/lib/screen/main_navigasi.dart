import 'package:flutter/material.dart';
import 'package:indosemecb2b/screen/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:indosemecb2b/screen/homescreen.dart';
import 'package:indosemecb2b/screen/keranjang.dart';
import 'package:indosemecb2b/screen/poinku.dart';
import 'package:indosemecb2b/screen/profile.dart';
import 'package:indosemecb2b/screen/transaksi.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  bool _isLoggedIn = false;

  // 🔑 Key untuk mengakses HomeScreen dan refresh-nya
  final GlobalKey<HomeScreenState> _homeScreenKey = GlobalKey<HomeScreenState>();

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();

    _screens = [
      HomeScreen(key: _homeScreenKey), // Pakai key
      const CartScreen(),
      const PoinkuScreen(),
      TransaksiScreen(),
      ProfileScreen(
        onLogout: _handleLogout, // ⭐ Ganti jadi callback khusus
      ),
    ];
  }

  @override
  void didUpdateWidget(MainNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkLoginStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (mounted && _isLoggedIn != loggedIn) {
      setState(() {
        _isLoggedIn = loggedIn;
      });
    }
  }

  // ⭐ Handler khusus untuk logout - refresh HomeScreen + pindah ke tab Beranda
  void _handleLogout() async {
    // Cek status login lagi
    await _checkLoginStatus();
    
    // Refresh HomeScreen agar tampilan berubah ke mode "belum login"
    _homeScreenKey.currentState?.refreshLoginStatus();
    
    // Pindah ke tab Beranda
    setState(() {
      _currentIndex = 0;
    });
  }

  void _onTabTapped(int index) {
    // Jika user belum login dan ingin akses selain Beranda (0) dan Akun (4)
    if (!_isLoggedIn && index != 0 && index != 4) {
      _showLoginBottomSheet();
      return;
    }

    // ⭐ Jika tab Beranda diklik berulang, refresh HomeScreen
    if (index == 0 && _currentIndex == 0) {
      _homeScreenKey.currentState?.refreshLoginStatus();
    }

    setState(() {
      _currentIndex = index;
    });
  }

  void _showLoginBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text(
                    "Login Untuk Berbelanja",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Image.asset(
                "assets/research.png",
                height: 160,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              const Text(
                "Belanja Mudah",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              const Text(
                "One stop online store yang menyediakan berbagai macam produk dalam satu aplikasi",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context); // tutup bottom sheet

                    // Navigasi ke login dan tunggu hasilnya
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );

                    // ⭐ Setelah kembali dari login, refresh status + HomeScreen
                    await _checkLoginStatus();
                    _homeScreenKey.currentState?.refreshLoginStatus();
                  },
                  child: const Text(
                    "Gabung Sekarang",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          selectedItemColor: Colors.blue[700],
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          backgroundColor: Colors.white,
          elevation: 0,
          onTap: _onTabTapped,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 26),
              activeIcon: Icon(Icons.home, size: 26),
              label: 'Beranda',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined, size: 26),
              activeIcon: Icon(Icons.shopping_cart, size: 26),
              label: 'Keranjang',
            ),
            BottomNavigationBarItem(
              icon: Transform.translate(
                offset: const Offset(0, -10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:
                        _currentIndex == 2 ? Colors.blue[100] : Colors.blue[50],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.qr_code_2,
                    size: 28,
                    color:
                        _currentIndex == 2
                            ? Colors.blue[700]
                            : Colors.blue[600],
                  ),
                ),
              ),
              label: 'Poinku',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined, size: 26),
              activeIcon: Icon(Icons.receipt_long, size: 26),
              label: 'Transaksi',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 26),
              activeIcon: Icon(Icons.person, size: 26),
              label: 'Akun',
            ),
          ],
        ),
      ),
    );
  }
}