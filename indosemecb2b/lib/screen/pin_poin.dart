// lib/screen/pin_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indosemecb2b/utils/pin_manager.dart';
import 'package:indosemecb2b/utils/user_data_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinSettingsScreen extends StatefulWidget {
  const PinSettingsScreen({super.key});

  @override
  State<PinSettingsScreen> createState() => _PinSettingsScreenState();
}

class _PinSettingsScreenState extends State<PinSettingsScreen> {
  bool _isPinSet = false;
  bool _isLoading = true;
  String _userName = '';
  String _userLogin = '';

  @override
  void initState() {
    super.initState();
    _checkPinStatus();
  }

  Future<void> _checkPinStatus() async {
    final userLogin = await UserDataManager.getCurrentUserLogin();
    if (userLogin == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda harus login terlebih dahulu'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    final isPinSet = await PinManager.isPinSet(userLogin);
    final userName = await _getUserName();

    if (mounted) {
      setState(() {
        _isPinSet = isPinSet;
        _userName = userName;
        _userLogin = userLogin;
        _isLoading = false;
      });
    }
  }

  Future<String> _getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('userName') ?? 'User';
    } catch (e) {
      print('❌ Error getting user name: $e');
      return 'User';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pengaturan PIN',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Info
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[600]!, Colors.blue[800]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.security,
                              color: Colors.blue[700],
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hai, $_userName!',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _isPinSet
                                      ? 'PIN Anda sudah aktif'
                                      : 'Lindungi akun dengan PIN',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isPinSet
                                  ? Icons.check_circle
                                  : Icons.lock_outline,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Status PIN
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isPinSet ? Colors.green[50] : Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              _isPinSet
                                  ? Colors.green[200]!
                                  : Colors.orange[200]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isPinSet ? Icons.check_circle : Icons.info_outline,
                            color:
                                _isPinSet
                                    ? Colors.green[700]
                                    : Colors.orange[700],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _isPinSet
                                  ? 'PIN sudah diatur dan aktif'
                                  : 'PIN belum diatur. Atur PIN untuk keamanan akun Anda.',
                              style: TextStyle(
                                color:
                                    _isPinSet
                                        ? Colors.green[900]
                                        : Colors.orange[900],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Menu Opsi
                    if (!_isPinSet) ...[
                      _buildMenuCard(
                        icon: Icons.add_circle_outline,
                        title: 'Buat PIN Baru',
                        subtitle: 'Atur PIN 6 digit untuk keamanan',
                        color: Colors.blue[700]!,
                        onTap: () => _navigateToCreatePin(),
                      ),
                    ] else ...[
                      _buildMenuCard(
                        icon: Icons.edit_outlined,
                        title: 'Ubah PIN',
                        subtitle: 'Ganti PIN lama dengan yang baru',
                        color: Colors.orange[700]!,
                        onTap: () => _navigateToChangePin(),
                      ),
                      const SizedBox(height: 12),
                      _buildMenuCard(
                        icon: Icons.refresh_outlined,
                        title: 'Reset PIN',
                        subtitle: 'Hapus PIN dan buat yang baru',
                        color: Colors.red[700]!,
                        onTap: () => _showResetConfirmation(),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Info Keamanan
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                color: Colors.blue[700],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tips Keamanan PIN',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildTip(
                            'Gunakan kombinasi angka yang sulit ditebak',
                          ),
                          _buildTip(
                            'Jangan gunakan tanggal lahir atau nomor berurutan',
                          ),
                          _buildTip('Jangan bagikan PIN kepada siapapun'),
                          _buildTip('Ubah PIN secara berkala untuk keamanan'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.blue[700],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCreatePin() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreatePinScreen()),
    );

    if (result == true && mounted) {
      _checkPinStatus();
    }
  }

  void _navigateToChangePin() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChangePinScreen()),
    );

    if (result == true && mounted) {
      _checkPinStatus();
    }
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red[700]),
                const SizedBox(width: 12),
                const Text('Reset PIN'),
              ],
            ),
            content: const Text(
              'Apakah Anda yakin ingin reset PIN? Anda perlu membuat PIN baru setelah reset.',
              style: TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _resetPin();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Reset',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _resetPin() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final userLogin = await UserDataManager.getCurrentUserLogin();
    if (userLogin == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    final success = await PinManager.resetPin(userLogin);
    if (mounted) Navigator.pop(context);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ PIN berhasil direset'),
          backgroundColor: Colors.green,
        ),
      );
      _checkPinStatus();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Gagal reset PIN'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// ===== CREATE PIN SCREEN =====
class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({super.key});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _isPinVisible = false;
  bool _isConfirmPinVisible = false;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Buat PIN Baru',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline,
                size: 64,
                color: Colors.blue[700],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Buat PIN Keamanan',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'PIN akan digunakan untuk mengamankan\ntransaksi Poin Cash dan Saldo Klik',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),

            const SizedBox(height: 32),

            // Input PIN
            _buildPinField(
              controller: _pinController,
              label: 'Masukkan PIN (6 digit)',
              isVisible: _isPinVisible,
              onVisibilityToggle: () {
                setState(() => _isPinVisible = !_isPinVisible);
              },
            ),

            const SizedBox(height: 16),

            // Konfirmasi PIN
            _buildPinField(
              controller: _confirmPinController,
              label: 'Konfirmasi PIN',
              isVisible: _isConfirmPinVisible,
              onVisibilityToggle: () {
                setState(() => _isConfirmPinVisible = !_isConfirmPinVisible);
              },
            ),

            const SizedBox(height: 32),

            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createPin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Buat PIN',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 6,
      obscureText: !isVisible,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: onVisibilityToggle,
        ),
        counterText: '',
      ),
    );
  }

  Future<void> _createPin() async {
    final pin = _pinController.text;
    final confirmPin = _confirmPinController.text;

    if (pin.length != 6) {
      _showError('PIN harus 6 digit');
      return;
    }

    if (pin != confirmPin) {
      _showError('PIN tidak cocok');
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final userLogin = await UserDataManager.getCurrentUserLogin();
    if (userLogin == null) {
      if (mounted) {
        Navigator.pop(context);
        _showError('User tidak ditemukan');
      }
      return;
    }

    final success = await PinManager.setPin(userLogin, pin);
    if (mounted) Navigator.pop(context);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ PIN berhasil dibuat'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      _showError('Gagal membuat PIN');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}

// ===== CHANGE PIN SCREEN =====
class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final _oldPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _isOldPinVisible = false;
  bool _isNewPinVisible = false;
  bool _isConfirmPinVisible = false;

  @override
  void dispose() {
    _oldPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ubah PIN',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit_outlined,
                size: 64,
                color: Colors.orange[700],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Ubah PIN Keamanan',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Masukkan PIN lama dan PIN baru Anda',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),

            const SizedBox(height: 32),

            _buildPinField(
              controller: _oldPinController,
              label: 'PIN Lama',
              isVisible: _isOldPinVisible,
              onVisibilityToggle: () {
                setState(() => _isOldPinVisible = !_isOldPinVisible);
              },
            ),

            const SizedBox(height: 16),

            _buildPinField(
              controller: _newPinController,
              label: 'PIN Baru (6 digit)',
              isVisible: _isNewPinVisible,
              onVisibilityToggle: () {
                setState(() => _isNewPinVisible = !_isNewPinVisible);
              },
            ),

            const SizedBox(height: 16),

            _buildPinField(
              controller: _confirmPinController,
              label: 'Konfirmasi PIN Baru',
              isVisible: _isConfirmPinVisible,
              onVisibilityToggle: () {
                setState(() => _isConfirmPinVisible = !_isConfirmPinVisible);
              },
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _changePin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Ubah PIN',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 6,
      obscureText: !isVisible,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: onVisibilityToggle,
        ),
        counterText: '',
      ),
    );
  }

  Future<void> _changePin() async {
    final oldPin = _oldPinController.text;
    final newPin = _newPinController.text;
    final confirmPin = _confirmPinController.text;

    if (oldPin.length != 6 || newPin.length != 6) {
      _showError('PIN harus 6 digit');
      return;
    }

    if (newPin != confirmPin) {
      _showError('PIN baru tidak cocok');
      return;
    }

    if (oldPin == newPin) {
      _showError('PIN baru harus berbeda dengan PIN lama');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final userLogin = await UserDataManager.getCurrentUserLogin();
    if (userLogin == null) {
      if (mounted) {
        Navigator.pop(context);
        _showError('User tidak ditemukan');
      }
      return;
    }

    final success = await PinManager.changePin(userLogin, oldPin, newPin);
    if (mounted) Navigator.pop(context);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ PIN berhasil diubah'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      _showError('PIN lama salah atau gagal mengubah PIN');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}
