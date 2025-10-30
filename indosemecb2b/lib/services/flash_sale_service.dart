import '../models/flash_sale_model.dart';

class FlashSaleService {
  // ⭐ DATA JADWAL FLASH SALE (disesuaikan dengan produk ID 100-120)
  static List<FlashSaleSchedule> getFlashSaleSchedules() {
    final today = DateTime.now();
    
    return [
      // FLASH SALE PAGI (09:00 - 11:00)
      FlashSaleSchedule(
        id: 'fs1',
        title: 'FLASH SALE PAGI',
        startTime: DateTime(today.year, today.month, today.day, 9, 0),
        endTime: DateTime(today.year, today.month, today.day, 11, 0),
        productIds: ['100', '101', '104', '107', '109'], // Paket Sembako & Lauk
        discountPercentage: 40,
      ),
      
      // FLASH SALE SIANG (11:00 - 13:00)
      FlashSaleSchedule(
        id: 'fs2',
        title: 'FLASH SALE SIANG',
        startTime: DateTime(today.year, today.month, today.day, 11, 0),
        endTime: DateTime(today.year, today.month, today.day, 13, 0),
        productIds: ['102', '105', '108', '110', '112'], // Sayur Asem, Seafood, dll
        discountPercentage: 35,
      ),
      
      // FLASH SALE SORE (15:00 - 17:00)
      FlashSaleSchedule(
        id: 'fs3',
        title: 'FLASH SALE SORE',
        startTime: DateTime(today.year, today.month, today.day, 15, 0),
        endTime: DateTime(today.year, today.month, today.day, 17, 0),
        productIds: ['103', '106', '111', '113', '115'], // Paket Ramadhan, Buah, Herbal
        discountPercentage: 45,
      ),
      
      // FLASH SALE MALAM (18:00 - 20:00)
      FlashSaleSchedule(
        id: 'fs4',
        title: 'FLASH SALE MALAM',
        startTime: DateTime(today.year, today.month, today.day, 18, 0),
        endTime: DateTime(today.year, today.month, today.day, 20, 0),
        productIds: ['114', '116', '117', '119', '120'], // Bumbu, Hampers, Fashion
        discountPercentage: 50,
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
          endTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 11, 0),
          productIds: ['100', '101', '104', '107', '109'],
          discountPercentage: 40,
        ),
      ];
      return tomorrowSchedules.first;
    }
    
    upcoming.sort((a, b) => a.startTime.compareTo(b.startTime));
    return upcoming.first;
  }

  // ⭐ HITUNG HARGA FLASH SALE (OTOMATIS)
  static double calculateFlashPrice(String productId, double originalPrice) {
    final currentSale = getCurrentFlashSale();
    
    // Jika ada flash sale aktif dan produk termasuk di dalamnya
    if (currentSale != null && currentSale.productIds.contains(productId)) {
      final discount = currentSale.discountPercentage / 100;
      return originalPrice * (1 - discount);
    }
    
    // Jika tidak flash sale, kembalikan harga normal
    return originalPrice;
  }
}