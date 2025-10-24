import 'package:flutter/material.dart';
import 'package:indosemecb2b/utils/cart_manager.dart';
import 'package:indosemecb2b/models/cart_item.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic>? alamat;
  final String deliveryOption;

  CheckoutScreen({required this.alamat, required this.deliveryOption});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  List<CartItem> _cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final cartItems = await CartManager.getCartItems();
    setState(() {
      _cartItems = cartItems;
      _isLoading = false;
    });
  }

  double getTotal() =>
      _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Alamat Pengiriman",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on,
                              color: Colors.blue[700], size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.alamat?['alamat_lengkap'] ??
                                  'Alamat belum lengkap',
                              style: const TextStyle(fontSize: 14),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Daftar Produk",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    ..._cartItems.map((item) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.imageUrl ?? "",
                                width: 65,
                                height: 65,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text("Rp${item.totalPrice.toStringAsFixed(0)}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Pembayaran",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  Text(
                    "Rp${getTotal().toStringAsFixed(0)}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 35),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Lanjut ke Pembayaran",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
