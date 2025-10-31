import '../models/flash_sale_model.dart';

class FlashSaleService {
  // ⭐ DATA JADWAL FLASH SALE (disesuaikan dengan produk ID 100-120)
  static List<FlashSaleSchedule> getFlashSaleSchedules() {
  final today = DateTime.now();
  
  return [
    // FLASH SALE PAGI (09:00 - 11:00) - Diskon 35%
    // Fokus: Sembako & Breakfast
    FlashSaleSchedule(
      id: 'fs1',
      title: 'FLASH SALE PAGI',
      startTime: DateTime(today.year, today.month, today.day, 9, 0),
      endTime: DateTime(today.year, today.month, today.day, 10, 0),
      productIds: [
        '100', // Paket Sembako Hemat A
        '101', // Paket Sembako Lengkap E
        '104', // Paket Lauk Ayam Lengkap
        '107', // Paket Snack Keluarga
        '109', // Paket Buah Segar Mix
        '117', // Paket Nasi Box
      ], 
      discountPercentage: 35,
    ),
    
    // FLASH SALE SIANG (12:00 - 13:00) - Diskon 45%
    // Fokus: Lunch & Sayur
    FlashSaleSchedule(
      id: 'fs2',
      title: 'FLASH SALE SIANG',
      startTime: DateTime(today.year, today.month, today.day, 10, 40),
      endTime: DateTime(today.year, today.month, today.day, 13, 0),
      productIds: [
        '102', // Paket Sayur Asem
        '105', // Paket Lauk Seafood
        '106', // Paket Tumis Kangkung
        '108', // Paket Minuman Segar
        '110', // Paket Sayuran Organik
        '118', // Paket Tumpeng Mini
      ], 
      discountPercentage: 45,
    ),
    
    // FLASH SALE SORE (15:00 - 17:00) - Diskon 50% (GEDE!)
    // Fokus: Premium & Herbal
    FlashSaleSchedule(
      id: 'fs3',
      title: 'FLASH SALE SORE',
      startTime: DateTime(today.year, today.month, today.day, 16, 0),
      endTime: DateTime(today.year, today.month, today.day, 17, 0),
      productIds: [
        '103', // Paket Sembako Ramadhan
        '111', // Paket Buah Tropis Premium
        '112', // Paket Jamu Sehat Lengkap
        '113', // Paket Madu & Herbal
        '115', // Paket Rempah Nusantara
        '119', // Paket Hijab 5 Warna
      ], 
      discountPercentage: 50,
    ),
    
    // FLASH SALE MALAM (18:00 - 20:00) - Diskon 40%
    // Fokus: Fashion & Kebutuhan Rumah
    FlashSaleSchedule(
      id: 'fs4',
      title: 'FLASH SALE MALAM',
      startTime: DateTime(today.year, today.month, today.day, 19, 0),
      endTime: DateTime(today.year, today.month, today.day, 20, 0),
      productIds: [
        '114', // Paket Bumbu Dapur Lengkap
        '116', // Paket Hampers Bayi Newborn
        '120', // Paket Batik Couple
        '100', // Paket Sembako Hemat A (repeat strategis)
        '109', // Paket Buah Segar Mix (repeat untuk promo malam)
        '107', // Paket Snack Keluarga (cocok untuk ngemil malam)
      ], 
      discountPercentage: 40,
    ),
  ];
}

  // Ambil flash sale yang aktif sekarang
  static FlashSaleSchedule? getCurrentFlashSale() {
    final schedules = getFlashSaleSchedules();
    try {
      return schedules.firstWhere((schedule) => schedule.isActive);
    } catch (e) {
      return null;
    }
  }

  // Ambil flash sale berikutnya
  static FlashSaleSchedule? getNextFlashSale() {
    final schedules = getFlashSaleSchedules();
    final upcoming = schedules.where((s) => s.isUpcoming).toList();
    
    if (upcoming.isEmpty) {
      // Kalau tidak ada upcoming hari ini, ambil yang pertama besok
      final tomorrow = DateTime.now().add(Duration(days: 1));
      final tomorrowSchedules = [
        FlashSaleSchedule(
          id: 'fs1_tomorrow',
          title: 'FLASH SALE PAGI',
          startTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0),
          endTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 0),
          productIds: ['100', '101', '104', '107', '109'],
          discountPercentage: 40,
        ),
      ];
      return tomorrowSchedules.first;
    }
    
    upcoming.sort((a, b) => a.startTime.compareTo(b.startTime));
    return upcoming.first;
  }

  static bool isLocationBasedProduct(String productId) {
  // Produk ID 121-125 adalah produk buah/sayur lokasi
  // Atau cek dari KoperasiService
    final id = int.tryParse(productId);
    if (id != null && id >= 121) {
      return true; // Produk lokal tidak kena flash sale
    }
    return false;
}

  // ⭐ HITUNG HARGA FLASH SALE (OTOMATIS)
  static double calculateFlashPrice(String productId, double originalPrice) {
  // Skip flash sale untuk produk lokasi
    if (isLocationBasedProduct(productId)) {
      return originalPrice;
    }

    final currentSale = getCurrentFlashSale();
    
    if (currentSale != null && 
        currentSale.isActive && 
        currentSale.productIds.contains(productId)) {
      final discount = currentSale.discountPercentage / 100;
      final flashPrice = originalPrice * (1 - discount);
      
      print('💰 [FLASH] Product $productId:');
      print('   Original: ${originalPrice.toInt()}');
      print('   Diskon: ${currentSale.discountPercentage}%');
      print('   Flash Price: ${flashPrice.toInt()}');
      
      return flashPrice;
    }
    
    return originalPrice;
  }

  static bool isProductOnFlashSale(String productId) {
    if (isLocationBasedProduct(productId)) {
      return false; // Produk lokasi tidak kena flash sale
    }
    
    final currentSale = getCurrentFlashSale();
    return currentSale != null && 
          currentSale.isActive && 
          currentSale.productIds.contains(productId);
  }

  static int? getFlashDiscountPercentage(String productId) {
    final currentSale = getCurrentFlashSale();
    if (currentSale != null && 
        currentSale.isActive && 
        currentSale.productIds.contains(productId)) {
      return currentSale.discountPercentage.toInt();
    }
    return null;
  }
}