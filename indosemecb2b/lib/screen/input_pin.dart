import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indosemecb2b/screen/setup_pin.dart';

class InputPinScreen extends StatefulWidget {
  final String title;
  final String subtitle;

  const InputPinScreen({
    Key? key,
    this.title = 'Masukkan PIN',
    this.subtitle = 'Masukkan PIN Saldo Klik Anda',
  }) : super(key: key);

  @override
  State<InputPinScreen> createState() => _InputPinScreenState();
}

class _InputPinScreenState extends State<InputPinScreen> {
  final List<TextEditingController> _pinControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isError = false;
  int _attemptCount = 0;

  @override
  void initState() {
    super.initState();
    // Auto focus on first field
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onPinComplete() {
    final pin = _pinControllers.map((c) => c.text).join();

    if (pin.length == 6) {
      // Return PIN to previous screen
      Navigator.pop(context, pin);
    }
  }

  void _onPinChanged(int index, String value) {
    setState(() {
      _isError = false;
    });

    if (value.isNotEmpty) {
      // Move to next field
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last field filled
        _focusNodes[index].unfocus();
        _onPinComplete();
      }
    }
  }

  void _clearPin() {
    setState(() {
      for (var controller in _pinControllers) {
        controller.clear();
      }
      _isError = false;
    });
    _focusNodes[0].requestFocus();
  }

  void _showError() {
    setState(() {
      _isError = true;
      _attemptCount++;
    });

    // Shake animation (visual feedback)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _clearPin();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _isError ? Colors.red[50] : Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isError ? Icons.error_outline : Icons.lock_outline,
                  size: 60,
                  color: _isError ? Colors.red[700] : Colors.blue[700],
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _isError ? Colors.red[700] : Colors.black,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                _isError ? 'PIN salah! Silakan coba lagi.' : widget.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: _isError ? Colors.red[600] : Colors.grey[600],
                ),
              ),

              if (_attemptCount > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Percobaan ke-$_attemptCount',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],

              const SizedBox(height: 48),

              // PIN Input Fields
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                transform:
                    _isError
                        ? (Matrix4.identity()..translate(
                          (_attemptCount % 2 == 0 ? 10.0 : -10.0),
                          0.0,
                        ))
                        : Matrix4.identity(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 50,
                      height: 60,
                      child: TextField(
                        controller: _pinControllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: 1,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _isError ? Colors.red[700] : Colors.black,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor:
                              _isError ? Colors.red[50] : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color:
                                  _isError
                                      ? Colors.red[300]!
                                      : Colors.grey[300]!,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color:
                                  _isError
                                      ? Colors.red[300]!
                                      : Colors.grey[300]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color:
                                  _isError
                                      ? Colors.red[700]!
                                      : Colors.blue[700]!,
                              width: 2,
                            ),
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(1),
                        ],
                        onChanged: (value) => _onPinChanged(index, value),
                        onTap: () {
                          if (_pinControllers[index].text.isNotEmpty) {
                            _pinControllers[index].clear();
                          }
                        },
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 32),

              // Forgot PIN Button
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text('Lupa PIN?'),
                          content: const Text(
                            'Silakan hubungi customer service untuk reset PIN Anda.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                  );
                },
                child: Text(
                  'Lupa PIN?',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const Spacer(),

              // Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber[100]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security, color: Colors.amber[900], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Jangan bagikan PIN Anda kepada siapapun termasuk pihak IndoSmec',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
