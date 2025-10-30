import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:indosemecb2b/utils/saldo_klik_manager.dart';

class TopUpSaldoScreen extends StatefulWidget {
  const TopUpSaldoScreen({Key? key}) : super(key: key);

  @override
  State<TopUpSaldoScreen> createState() => _TopUpSaldoScreenState();
}

class _TopUpSaldoScreenState extends State<TopUpSaldoScreen> {
  final _nominalController = TextEditingController();
  String? _selectedPayment;
  bool _isProcessing = false;

  final List<int> _quickAmounts = [50000, 100000, 200000, 500000, 1000000];

  static final _formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'name': 'GoPay',
      'image':
          'https://i.pinimg.com/736x/c7/40/65/c74065540ccade0683a869b622cdc4a6.jpg',
      'badge': 'Gratis Admin',
    },
    {
      'name': 'OVO',
      'image':
          'https://i.pinimg.com/736x/c1/0a/d6/c10ad6ece8ee01e5d2eacc07bc2c1490.jpg',
    },
    {
      'name': 'DANA',
      'image':
          'https://i.pinimg.com/1200x/2b/1f/11/2b1f11dec29fe28b5137b46fffa0b25f.jpg',
    },
    {
      'name': 'ShopeePay',
      'image':
          'https://i.pinimg.com/736x/d4/9f/70/d49f702b94f54a479ff6a44525650537.jpg',
    },
    {
      'name': 'BCA Virtual Account',
      'image':
          'https://i.pinimg.com/736x/0b/ed/5c/0bed5c44c43dc1efd1cbf6acf3aa1d89.jpg',
    },
    {
      'name': 'Mandiri Virtual Account',
      'image':
          'https://i.pinimg.com/1200x/41/5f/61/415f6193712cbf8e90613921937aa86b.jpg',
    },
    {
      'name': 'Transfer Bank Manual',
      'image':
          'https://i.pinimg.com/1200x/a2/9d/29/a29d290535c8a5fd55f67631c7e454f1.jpg',
    },
  ];

  @override
  void dispose() {
    _nominalController.dispose();
    super.dispose();
  }

  Future<void> _processTopUp() async {
    final nominal = double.tryParse(
      _nominalController.text.replaceAll('.', ''),
    );

    if (nominal == null || nominal < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal top up Rp 10.000'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedPayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih metode pembayaran terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Simulasi proses pembayaran
    await Future.delayed(const Duration(seconds: 2));

    final success = await SaldoKlikManager.topUp(nominal, _selectedPayment!);

    setState(() => _isProcessing = false);

    if (success && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green[600],
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Top Up Berhasil!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Saldo ${_formatRupiah.format(nominal)} berhasil ditambahkan',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Back to saldo screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Isi Saldo'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Input Nominal
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Masukkan Nominal',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nominalController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _ThousandsSeparatorInputFormatter(),
                        ],
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          prefixText: 'Rp ',
                          prefixStyle: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          border: InputBorder.none,
                          hintText: '0',
                          hintStyle: TextStyle(color: Colors.grey[300]),
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 12),
                      Text(
                        'Minimal top up Rp 10.000',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Quick Amount Buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _quickAmounts.map((amount) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _nominalController.text = NumberFormat(
                                '#,###',
                                'id_ID',
                              ).format(amount).replaceAll(',', '.');
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Text(
                              _formatRupiah.format(amount),
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),

                const SizedBox(height: 24),

                // Payment Methods
                const Text(
                  'Pilih Metode Pembayaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                ..._paymentMethods.map((method) {
                  final isSelected = _selectedPayment == method['name'];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected ? Colors.blue[700]! : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                              : [],
                    ),
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          _selectedPayment = method['name'];
                        });
                      },
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            method['image'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.payment,
                                color: Colors.grey[400],
                              );
                            },
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            method['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          if (method['badge'] != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                method['badge'],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing:
                          isSelected
                              ? Icon(
                                Icons.check_circle,
                                color: Colors.blue[700],
                              )
                              : Icon(
                                Icons.circle_outlined,
                                color: Colors.grey[400],
                              ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 100),
              ],
            ),
          ),

          if (_isProcessing)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _processTopUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: Colors.grey[400],
            ),
            child:
                _isProcessing
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Text(
                      'Lanjutkan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final number = int.tryParse(newValue.text.replaceAll('.', ''));
    if (number == null) {
      return oldValue;
    }

    final formattedText = NumberFormat(
      '#,###',
      'id_ID',
    ).format(number).replaceAll(',', '.');

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
