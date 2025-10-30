import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SetupPinScreen extends StatefulWidget {
  const SetupPinScreen({Key? key}) : super(key: key);

  @override
  State<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<SetupPinScreen> {
  final List<TextEditingController> _pinControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  final List<TextEditingController> _confirmPinControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _confirmFocusNodes =
      List.generate(6, (_) => FocusNode());

  bool _isConfirmStep = false;
  String _firstPin = '';

  @override
  void dispose() {
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _confirmPinControllers) {
      controller.dispose();
    }
    for (var node in _confirmFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onPinComplete() {
    final pin = _pinControllers.map((c) => c.text).join();

    if (pin.length == 6) {
      setState(() {
        _firstPin = pin;
        _isConfirmStep = true;
      });

      // Focus on first confirm pin field
      Future.delayed(const Duration(milliseconds: 100), () {
        _confirmFocusNodes[0].requestFocus();
      });
    }
  }

  void _onConfirmPinComplete() {
    final confirmPin = _confirmPinControllers.map((c) => c.text).join();

    if (confirmPin.length == 6) {
      if (_firstPin == confirmPin) {
        // PIN cocok, return ke screen sebelumnya
        Navigator.pop(context, _firstPin);
      } else {
        // PIN tidak cocok
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ PIN tidak cocok! Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );

        // Reset confirm PIN
        for (var controller in _confirmPinControllers) {
          controller.clear();
        }
        _confirmFocusNodes[0].requestFocus();
      }
    }
  }

  void _onPinChanged(int index, String value, bool isConfirm) {
    final controllers = isConfirm ? _confirmPinControllers : _pinControllers;
    final focusNodes = isConfirm ? _confirmFocusNodes : _focusNodes;

    if (value.isNotEmpty) {
      // Move to next field
      if (index < 5) {
        focusNodes[index + 1].requestFocus();
      } else {
        // Last field filled
        focusNodes[index].unfocus();
        if (isConfirm) {
          _onConfirmPinComplete();
        } else {
          _onPinComplete();
        }
      }
    }
  }

  void _onPinBackspace(int index, bool isConfirm) {
    final controllers = isConfirm ? _confirmPinControllers : _pinControllers;
    final focusNodes = isConfirm ? _confirmFocusNodes : _focusNodes;

    if (controllers[index].text.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (_isConfirmStep) {
              // Kembali ke step pertama
              setState(() {
                _isConfirmStep = false;
                _firstPin = '';
                for (var controller in _confirmPinControllers) {
                  controller.clear();
                }
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  size: 60,
                  color: Colors.blue[700],
                ),
              ),

              const SizedBox(height: 32),

              // Title & Description
              Text(
                _isConfirmStep ? 'Konfirmasi PIN' : 'Buat PIN Saldo Klik',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                _isConfirmStep
                    ? 'Masukkan kembali PIN untuk konfirmasi'
                    : 'PIN 6 digit untuk mengamankan transaksi Anda',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 48),

              // PIN Input Fields
              _buildPinFields(
                controllers:
                    _isConfirmStep ? _confirmPinControllers : _pinControllers,
                focusNodes: _isConfirmStep ? _confirmFocusNodes : _focusNodes,
                isConfirm: _isConfirmStep,
              ),

              const SizedBox(height: 32),

              // Progress Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepIndicator(isActive: !_isConfirmStep),
                  const SizedBox(width: 8),
                  _buildStepIndicator(isActive: _isConfirmStep),
                ],
              ),

              const Spacer(),

              // Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'PIN ini akan digunakan untuk setiap transaksi dengan Saldo Klik',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[900],
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

  Widget _buildPinFields({
    required List<TextEditingController> controllers,
    required List<FocusNode> focusNodes,
    required bool isConfirm,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 50,
          height: 60,
          child: TextField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 1,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            onChanged: (value) => _onPinChanged(index, value, isConfirm),
            onTap: () {
              // Clear on tap if already filled
              if (controllers[index].text.isNotEmpty) {
                controllers[index].clear();
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildStepIndicator({required bool isActive}) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: isActive ? Colors.blue[700] : Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}