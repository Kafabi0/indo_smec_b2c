import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OTPVerificationPage extends StatefulWidget {
  final String userInput;
  final String name;
  final String password;

  const OTPVerificationPage({
    super.key,
    required this.userInput,
    required this.name,
    required this.password,
  });

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String _generatedOTP = '';
  int _countdown = 60;
  Timer? _timer;
  bool _isResendEnabled = false;

  @override
  void initState() {
    super.initState();
    _generateAndShowOTP();
    _startCountdown();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _generateAndShowOTP() {
    // Generate OTP 6 digit
    final random = Random();
    _generatedOTP = List.generate(6, (_) => random.nextInt(10)).join();

    // Simulasi pengiriman OTP (dalam production, kirim via SMS/Email)
    print('=== OTP DIKIRIM: $_generatedOTP ==='); // Untuk testing

    // Tampilkan snackbar dengan delay agar widget tree sudah siap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kode OTP telah dikirim ke ${widget.userInput}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    // Untuk testing, tampilkan OTP di dialog
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _showOTPDialog();
      }
    });
  }

  void _showOTPDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Kode OTP (Testing)'),
            content: Text(
              'Kode OTP Anda: $_generatedOTP\n\n'
              'Dalam production, kode ini akan dikirim via SMS/Email.',
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _startCountdown() {
    _isResendEnabled = false;
    _countdown = 60;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        setState(() => _isResendEnabled = true);
        timer.cancel();
      }
    });
  }

  void _resendOTP() {
    if (!_isResendEnabled) return;

    // Clear semua input
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();

    _generateAndShowOTP();
    _startCountdown();
  }

  void _verifyOTP() {
    final enteredOTP = _controllers.map((c) => c.text).join();

    if (enteredOTP.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan 6 digit kode OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (enteredOTP == _generatedOTP) {
      // OTP benar, return data untuk disimpan
      Navigator.pop(context, {
        'success': true,
        'emailOrPhone': widget.userInput,
        'name': widget.name,
        'password': widget.password,
      });
    } else {
      // OTP salah
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kode OTP salah. Silakan coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );

      // Clear semua input
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = RegExp(r'^[0-9]+$').hasMatch(widget.userInput);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Verifikasi OTP'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPhone ? Icons.smartphone : Icons.email_outlined,
                  size: 60,
                  color: Colors.blue[700],
                ),
              ),

              const SizedBox(height: 30),

              // Title
              const Text(
                'Masukkan Kode OTP',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Kode verifikasi telah dikirim ke\n${widget.userInput}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 40),

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    height: 55,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.blue[700]!,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }

                        // Auto verify jika sudah 6 digit
                        if (index == 5 && value.isNotEmpty) {
                          _verifyOTP();
                        }
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 30),

              // Countdown / Resend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isResendEnabled
                        ? 'Tidak menerima kode? '
                        : 'Kirim ulang dalam ',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  if (!_isResendEnabled)
                    Text(
                      '${_countdown}s',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _resendOTP,
                      child: Text(
                        'Kirim Ulang',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                ],
              ),

              const Spacer(),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Verifikasi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
