// screen/main_navigation.dart
import 'package:flutter/material.dart';
import 'package:indosemecb2b/screen/favorit.dart';
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

  // List screen yang akan ditampilkan
  final List<Widget> _screens = [
    const HomeScreen(),
    const CartScreen(),
    const PoinkuScreen(),
     TransaksiScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
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

            /// 🔹 POINKU (tombol melayang tengah)
            BottomNavigationBarItem(
              icon: Transform.translate(
                offset: const Offset(
                  0,
                  -10,
                ), // ikon naik 10px, tapi background bar tetap diam
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:
                        _currentIndex == 2
                            ? Colors.blue[100] // aktif → biru muda
                            : Colors.blue[50], // nonaktif → putih
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
