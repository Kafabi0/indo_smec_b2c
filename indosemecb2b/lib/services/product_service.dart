import '../models/product_model.dart';
import '../models/store_model.dart';
import '../models/subcategory_model.dart';
import '../services/flash_sale_service.dart';

class ProductService {
  // ============ DATA STORES UMKM ============
  static final List<Store> _allStores = [
    // FOOD STORES
    Store(
      id: 's1',
      name: 'Warung Pak Budi',
      category: 'Food',
      distance: 0.5,
      openHours: '08:00 - 21:00',
      rating: 4.8,
      reviewCount: 340,
      description: 'Warung makan tradisional dengan menu nusantara',
      isFlagship: true,
    ),
    Store(
      id: 's2',
      name: 'Sushi Corner',
      category: 'Food',
      distance: 2.1,
      openHours: '10:00 - 22:00',
      rating: 4.7,
      reviewCount: 256,
      description: 'Makanan Jepang authentic',
    ),
    Store(
      id: 's3',
      name: 'Dimsum House',
      category: 'Food',
      distance: 1.5,
      openHours: '09:00 - 20:00',
      rating: 4.9,
      reviewCount: 412,
      description: 'Spesialis dimsum dan bakpao',
    ),
    Store(
      id: 's4',
      name: 'Rumah Makan Padang',
      category: 'Food',
      distance: 1.3,
      openHours: '07:00 - 21:00',
      rating: 4.8,
      reviewCount: 389,
      description: 'Masakan Padang asli',
    ),

    // GROCERY STORES
    Store(
      id: 's5',
      name: 'Toko Sumber Rezeki',
      category: 'Grocery',
      distance: 0.7,
      openHours: '07:00 - 20:00',
      rating: 4.6,
      reviewCount: 523,
      description: 'Toko kelontong lengkap',
      isFlagship: true,
    ),
    Store(
      id: 's6',
      name: 'Pasar Segar',
      category: 'Grocery',
      distance: 0.9,
      openHours: '06:00 - 18:00',
      rating: 4.7,
      reviewCount: 678,
      description: 'Pasar tradisional sayur & buah',
    ),
    Store(
      id: 's7',
      name: 'Supermarket Indo',
      category: 'Grocery',
      distance: 1.1,
      openHours: '08:00 - 22:00',
      rating: 4.5,
      reviewCount: 891,
      description: 'Minimarket kebutuhan sehari-hari',
    ),

    // FASHION STORES
    Store(
      id: 's8',
      name: 'Batik Nusantara',
      category: 'Fashion',
      distance: 2.3,
      openHours: '09:00 - 20:00',
      rating: 4.8,
      reviewCount: 234,
      description: 'Batik modern dan tradisional',
      isFlagship: true,
    ),
    Store(
      id: 's9',
      name: 'Hijab Store',
      category: 'Fashion',
      distance: 1.7,
      openHours: '10:00 - 21:00',
      rating: 4.9,
      reviewCount: 445,
      description: 'Koleksi hijab terlengkap',
    ),
    Store(
      id: 's10',
      name: 'Fashion Hub',
      category: 'Fashion',
      distance: 2.1,
      openHours: '10:00 - 22:00',
      rating: 4.6,
      reviewCount: 312,
      description: 'Fashion casual trendy',
    ),

    // HERBAL STORES
    Store(
      id: 's11',
      name: 'Jamu Bu Ningsih',
      category: 'Herbal',
      distance: 0.6,
      openHours: '07:00 - 17:00',
      rating: 4.9,
      reviewCount: 567,
      description: 'Jamu tradisional turun temurun',
      isFlagship: true,
    ),
    Store(
      id: 's12',
      name: 'Madu Alami',
      category: 'Herbal',
      distance: 1.4,
      openHours: '08:00 - 19:00',
      rating: 4.8,
      reviewCount: 423,
      description: 'Madu murni dari peternakan',
    ),

    // KERAJINAN STORES
    Store(
      id: 's13',
      name: 'Kerajinan Tangan',
      category: 'Kerajinan',
      distance: 2.5,
      openHours: '09:00 - 18:00',
      rating: 4.7,
      reviewCount: 189,
      description: 'Kerajinan rotan & bambu',
      isFlagship: true,
    ),
    Store(
      id: 's14',
      name: 'Seni Ukir Bali',
      category: 'Kerajinan',
      distance: 3.2,
      openHours: '10:00 - 19:00',
      rating: 4.9,
      reviewCount: 145,
      description: 'Ukiran kayu khas Bali',
    ),

    // PERTANIAN STORES
    Store(
      id: 's15',
      name: 'Toko Tani Jaya',
      category: 'Pertanian',
      distance: 2.8,
      openHours: '07:00 - 17:00',
      rating: 4.6,
      reviewCount: 234,
      description: 'Alat & pupuk pertanian',
      isFlagship: true,
    ),
    Store(
      id: 's16',
      name: 'Kebun Segar',
      category: 'Pertanian',
      distance: 2.1,
      openHours: '06:00 - 16:00',
      rating: 4.8,
      reviewCount: 378,
      description: 'Sayuran organik segar',
    ),

    // TAMBAHAN STORE KHUSUS BUAH
    Store(
      id: 's19',
      name: 'Buah Segar Pak Joko',
      category: 'Pertanian',
      distance: 1.2,
      openHours: '06:00 - 18:00',
      rating: 4.9,
      reviewCount: 412,
      description: 'Toko buah segar langsung dari petani',
      isFlagship: false,
    ),
    Store(
      id: 's20',
      name: 'Warung Buah Sari',
      category: 'Pertanian',
      distance: 0.8,
      openHours: '07:00 - 19:00',
      rating: 4.7,
      reviewCount: 356,
      description: 'Warung buah dengan harga terjangkau',
      isFlagship: false,
    ),
    Store(
      id: 's21',
      name: 'Gudang Buah Nusantara',
      category: 'Pertanian',
      distance: 2.3,
      openHours: '08:00 - 20:00',
      rating: 4.8,
      reviewCount: 289,
      description: 'Supplier buah-buahan segar',
      isFlagship: false,
    ),
    // JASA STORES (tambahkan di bagian bawah _allStores)
    Store(
      id: 's22',
      name: 'Jahit Bu Siti',
      category: 'Jasa',
      distance: 0.8,
      openHours: '08:00 - 17:00',
      rating: 4.9,
      reviewCount: 456,
      description: 'Jasa jahit dan reparasi pakaian',
      isFlagship: true,
    ),
    Store(
      id: 's23',
      name: 'Laundry Express',
      category: 'Jasa',
      distance: 1.2,
      openHours: '07:00 - 20:00',
      rating: 4.7,
      reviewCount: 678,
      description: 'Laundry kilat dan dry cleaning',
    ),
    Store(
      id: 's24',
      name: 'Salon Cantik',
      category: 'Jasa',
      distance: 1.5,
      openHours: '09:00 - 19:00',
      rating: 4.8,
      reviewCount: 534,
      description: 'Salon kecantikan lengkap',
    ),
    Store(
      id: 's25',
      name: 'Bengkel Motor Jaya',
      category: 'Jasa',
      distance: 2.0,
      openHours: '08:00 - 18:00',
      rating: 4.6,
      reviewCount: 389,
      description: 'Service motor dan spare part',
    ),
    Store(
      id: 's26',
      name: 'Tukang Kayu Pak Agus',
      category: 'Jasa',
      distance: 2.5,
      openHours: '07:00 - 17:00',
      rating: 4.8,
      reviewCount: 267,
      description: 'Pembuatan furniture custom',
    ),
    Store(
      id: 's27',
      name: 'Cuci AC Profesional',
      category: 'Jasa',
      distance: 1.8,
      openHours: '08:00 - 18:00',
      rating: 4.7,
      reviewCount: 423,
      description: 'Service AC dan elektronik',
    ),

    // KREATIF STORES
    Store(
      id: 's17',
      name: 'Art Supply Store',
      category: 'Kreatif',
      distance: 2.4,
      openHours: '09:00 - 20:00',
      rating: 4.7,
      reviewCount: 267,
      description: 'Alat lukis & kerajinan',
      isFlagship: true,
    ),
    Store(
      id: 's18',
      name: 'Creative Corner',
      category: 'Kreatif',
      distance: 1.8,
      openHours: '10:00 - 21:00',
      rating: 4.6,
      reviewCount: 198,
      description: 'Bahan craft & DIY',
    ),
  ];

  // ============ DATA SUB-CATEGORIES ============
  static final List<SubCategory> _subCategories = [
    // FOOD SUB-CATEGORIES
    SubCategory(id: 'f1', name: 'Nasi Box', parentCategory: 'Food', icon: '🍱'),
    SubCategory(
      id: 'f2',
      name: 'Snack & Jajanan',
      parentCategory: 'Food',
      icon: '🍪',
    ),
    SubCategory(id: 'f3', name: 'Minuman', parentCategory: 'Food', icon: '🥤'),
    SubCategory(
      id: 'f4',
      name: 'Lauk Pauk',
      parentCategory: 'Food',
      icon: '🍗',
    ),
    SubCategory(id: 'f5', name: 'Dessert', parentCategory: 'Food', icon: '🍰'),

    // GROCERY SUB-CATEGORIES
    SubCategory(
      id: 'g1',
      name: 'Beras & Tepung',
      parentCategory: 'Grocery',
      icon: '🌾',
    ),
    SubCategory(
      id: 'g2',
      name: 'Bumbu Dapur',
      parentCategory: 'Grocery',
      icon: '🧂',
    ),
    SubCategory(
      id: 'g3',
      name: 'Minyak Goreng',
      parentCategory: 'Grocery',
      icon: '🛢️',
    ),
    SubCategory(
      id: 'g4',
      name: 'Telur & Susu',
      parentCategory: 'Grocery',
      icon: '🥚',
    ),
    SubCategory(
      id: 'g5',
      name: 'Mie Instan',
      parentCategory: 'Grocery',
      icon: '🍜',
    ),

    // FASHION SUB-CATEGORIES
    SubCategory(
      id: 'fa1',
      name: 'Batik',
      parentCategory: 'Fashion',
      icon: '👔',
    ),
    SubCategory(
      id: 'fa2',
      name: 'Hijab',
      parentCategory: 'Fashion',
      icon: '🧕',
    ),
    SubCategory(
      id: 'fa3',
      name: 'Kaos & Kemeja',
      parentCategory: 'Fashion',
      icon: '👕',
    ),
    SubCategory(
      id: 'fa4',
      name: 'Celana',
      parentCategory: 'Fashion',
      icon: '👖',
    ),
    SubCategory(
      id: 'fa5',
      name: 'Dress',
      parentCategory: 'Fashion',
      icon: '👗',
    ),

    // JASA SUB-CATEGORIES (tambahkan di bagian bawah _subCategories)
    SubCategory(
      id: 'j1',
      name: 'Jahit & Bordir',
      parentCategory: 'Jasa',
      icon: '🧵',
    ),
    SubCategory(id: 'j2', name: 'Laundry', parentCategory: 'Jasa', icon: '👔'),
    SubCategory(
      id: 'j3',
      name: 'Salon & Spa',
      parentCategory: 'Jasa',
      icon: '💇',
    ),
    SubCategory(id: 'j4', name: 'Bengkel', parentCategory: 'Jasa', icon: '🔧'),
    SubCategory(id: 'j5', name: 'Tukang', parentCategory: 'Jasa', icon: '🛠️'),
    SubCategory(
      id: 'j6',
      name: 'Service Elektronik',
      parentCategory: 'Jasa',
      icon: '📱',
    ),
    SubCategory(
      id: 'j7',
      name: 'Cleaning Service',
      parentCategory: 'Jasa',
      icon: '🧹',
    ),
    SubCategory(
      id: 'j8',
      name: 'Catering',
      parentCategory: 'Jasa',
      icon: '🍽️',
    ),

    // HERBAL SUB-CATEGORIES
    SubCategory(
      id: 'h1',
      name: 'Jamu Tradisional',
      parentCategory: 'Herbal',
      icon: '🍵',
    ),
    SubCategory(id: 'h2', name: 'Madu', parentCategory: 'Herbal', icon: '🍯'),
    SubCategory(
      id: 'h3',
      name: 'Minuman Herbal',
      parentCategory: 'Herbal',
      icon: '☕',
    ),
    SubCategory(id: 'h4', name: 'Rempah', parentCategory: 'Herbal', icon: '🌿'),

    // KERAJINAN SUB-CATEGORIES
    SubCategory(
      id: 'k1',
      name: 'Anyaman',
      parentCategory: 'Kerajinan',
      icon: '🧺',
    ),
    SubCategory(
      id: 'k2',
      name: 'Ukiran Kayu',
      parentCategory: 'Kerajinan',
      icon: '🪵',
    ),
    SubCategory(
      id: 'k3',
      name: 'Souvenir',
      parentCategory: 'Kerajinan',
      icon: '🎁',
    ),
    SubCategory(
      id: 'k4',
      name: 'Dekorasi',
      parentCategory: 'Kerajinan',
      icon: '🖼️',
    ),

    // PERTANIAN SUB-CATEGORIES
    SubCategory(
      id: 'p1',
      name: 'Pupuk',
      parentCategory: 'Pertanian',
      icon: '🌱',
    ),
    SubCategory(
      id: 'p2',
      name: 'Bibit Tanaman',
      parentCategory: 'Pertanian',
      icon: '🌾',
    ),
    SubCategory(
      id: 'p3',
      name: 'Sayuran Organik',
      parentCategory: 'Pertanian',
      icon: '🥬',
    ),
    SubCategory(
      id: 'p4',
      name: 'Buah',
      parentCategory: 'Pertanian',
      icon: '🍎',
    ),
    SubCategory(
      id: 'p5',
      name: 'Alat Tani',
      parentCategory: 'Pertanian',
      icon: '🚜',
    ),

    // KREATIF SUB-CATEGORIES
    SubCategory(
      id: 'kr1',
      name: 'Alat Lukis',
      parentCategory: 'Kreatif',
      icon: '🎨',
    ),
    SubCategory(
      id: 'kr2',
      name: 'Buku Sketsa',
      parentCategory: 'Kreatif',
      icon: '📓',
    ),
    SubCategory(
      id: 'kr3',
      name: 'Clay & Polymer',
      parentCategory: 'Kreatif',
      icon: '🧱',
    ),
    SubCategory(
      id: 'kr4',
      name: 'Craft Tools',
      parentCategory: 'Kreatif',
      icon: '✂️',
    ),
  ];

  // ============ SEMUA DATA DUMMY PRODUK ============
  static final List<Product> _allProducts = [
    // ============ FOOD CATEGORY ============
    Product(
      id: '1',
      name: 'Nasi Goreng Ayam Hongkong',
      description: 'Nasi Goreng dengan bumbu khas dan daging ayam pilihan',
      price: 25000,
      originalPrice: 30000,
      category: 'Food',
      rating: 4.8,
      reviewCount: 150,
      storeName: 'Warung Pak Budi',
      storeDistance: '0.5 km',
      imageUrl:
          'https://img-global.cpcdn.com/recipes/2d6b62a61e9bb969/680x482cq70/nasi-goreng-hongkong-foto-resep-utama.jpg',
    ),
    Product(
      id: '2',
      name: 'Y!Choice Nasi Putih',
      description: 'Nasi putih segar pilihan dengan tekstur pulen dan lembut',
      price: 5000,
      originalPrice: 7000,
      category: 'Food',
      rating: 4.5,
      reviewCount: 89,
      storeName: 'Toko Berkah',
      storeDistance: '1.2 km',
      imageUrl:
          'https://drivethru.klikindomaret.com/t69e/wp-content/uploads/sites/58/2020/09/nasi.jpg',
    ),
    Product(
      id: '3',
      name: 'Y!Choice Onigiri Chicken Teriyaki',
      description: 'Nasi kepal dengan isian ayam teriyaki yang gurih',
      price: 13000,
      originalPrice: 15000,
      category: 'Food',
      rating: 4.7,
      reviewCount: 220,
      storeName: 'Sushi Corner',
      storeDistance: '2.1 km',
      imageUrl:
          'https://drivethru.klikindomaret.com/t69e/wp-content/uploads/sites/58/2024/03/20096377_1-745x1024.jpg',
    ),
    Product(
      id: '4',
      name: 'Yummy Choice French Fries',
      description: 'Kentang goreng krispi dengan bumbu pilihan',
      price: 10000,
      originalPrice: 12000,
      category: 'Food',
      rating: 4.6,
      reviewCount: 180,
      storeName: 'Fast Food Center',
      storeDistance: '0.8 km',
      imageUrl:
          'https://assets.klikindomaret.com/products/20115652/20115652_1.jpg',
    ),
    Product(
      id: '5',
      name: 'Y!Choice Dimsum Siomay Ayam Pedas 2\'S',
      description: '2 pcs Dimsum ayam dengan daun bawang segar',
      price: 10000,
      originalPrice: 12000,
      category: 'Food',
      rating: 4.8,
      reviewCount: 195,
      storeName: 'Dimsum House',
      storeDistance: '1.5 km',
      imageUrl:
          'https://assets.klikindomaret.com/products/20122942/20122942_thumb.jpg?Version.20.03.1.01',
    ),
    Product(
      id: '6',
      name: 'Sate Ayam Double Cheese Bread',
      description: 'Sate ayam dengan roti double keju yang lezat',
      price: 10000,
      originalPrice: 15000,
      category: 'Food',
      rating: 4.7,
      reviewCount: 167,
      storeName: 'Bakery Mama',
      storeDistance: '0.9 km',
      imageUrl:
          'https://awsimages.detik.net.id/community/media/visual/2021/12/07/resep-sate-ayam-pedas_43.jpeg?w=480',
    ),
    Product(
      id: '7',
      name: 'Y!Choice Steam Pao Besar Ayam Panggang',
      description: 'Mochi Jepang dengan isian pasta kacang merah',
      price: 23000,
      originalPrice: 28000,
      category: 'Food',
      rating: 4.9,
      reviewCount: 310,
      storeName: 'Japan Snack',
      storeDistance: '1.8 km',
      imageUrl:
          'https://drivethru.klikindomaret.com/t69e/wp-content/uploads/sites/58/2022/11/WhatsApp-Image-2022-11-04-at-16.47.13.jpeg',
    ),
    Product(
      id: '8',
      name: 'Yummy Choice Nasi Rendang Sapi',
      description: 'Nasi dengan rendang sapi empuk bumbu Padang',
      price: 34000,
      originalPrice: 40000,
      category: 'Food',
      rating: 4.8,
      reviewCount: 278,
      storeName: 'Rumah Makan Padang',
      storeDistance: '1.3 km',
      imageUrl:
          'https://assets.klikindomaret.com/products/20103568/20103568_thumb.jpg?Version.20.03.1.01',
    ),

    // ============ GROCERY CATEGORY ============
    Product(
      id: '9',
      name: 'Beras Premium Pandan Wangi 5kg',
      description: 'Beras berkualitas premium dengan aroma pandan',
      price: 75000,
      originalPrice: 90000,
      category: 'Grocery',
      rating: 4.8,
      reviewCount: 320,
      storeName: 'Toko Sumber Rezeki',
      storeDistance: '0.7 km',
      imageUrl:
          'https://cdn-klik.klikindomaret.com/klik-catalog/product/20002897_1.jpg',
    ),
    Product(
      id: '10',
      name: 'Minyak Goreng Tropical 2L',
      description: 'Minyak goreng untuk keperluan memasak sehari-hari',
      price: 35000,
      originalPrice: 40000,
      category: 'Grocery',
      rating: 4.5,
      reviewCount: 250,
      storeName: 'Grocery Mart',
      storeDistance: '0.5 km',
      imageUrl:
          'https://img.lazcdn.com/g/p/5a20b25510c6741f4b12a9607e3a2905.jpg_720x720q80.jpg',
    ),
    Product(
      id: '11',
      name: 'Gula Pasir Premium 1kg',
      description: 'Gula pasir putih bersih untuk kebutuhan masak',
      price: 15000,
      originalPrice: 18000,
      category: 'Grocery',
      rating: 4.6,
      reviewCount: 189,
      storeName: 'Toko Berkah',
      storeDistance: '1.2 km',
      imageUrl:
          'https://cdn-klik.klikindomaret.com/klik-catalog/product/20042991_1.jpg',
    ),
    Product(
      id: '12',
      name: 'Telur Ayam Negeri Fresh 10pcs',
      description: 'Telur ayam segar pilihan untuk konsumsi',
      price: 25000,
      originalPrice: 28000,
      category: 'Grocery',
      rating: 4.7,
      reviewCount: 412,
      storeName: 'Pasar Segar',
      storeDistance: '0.9 km',
      imageUrl:
          'https://cdn-klik.klikindomaret.com/klik-catalog/product/20024079_1.jpg',
    ),
    Product(
      id: '13',
      name: 'Susu UHT Full Cream 1L',
      description: 'Susu segar UHT full cream untuk keluarga',
      price: 18000,
      originalPrice: 22000,
      category: 'Grocery',
      rating: 4.8,
      reviewCount: 356,
      storeName: 'Supermarket Indo',
      storeDistance: '1.1 km',
      imageUrl:
          'https://cdn-klik.klikindomaret.com/klik-catalog/product/20134320_1.jpg',
    ),
    Product(
      id: '14',
      name: 'Mie Instan Goreng Pedas 10pcs',
      description: 'Paket mie instan goreng rasa pedas isi 10',
      price: 28000,
      originalPrice: 35000,
      category: 'Grocery',
      rating: 4.7,
      reviewCount: 289,
      storeName: 'Warung Serba Ada',
      storeDistance: '0.6 km',
      imageUrl:
          'https://down-id.img.susercontent.com/file/id-11134207-7r98x-lvic6q9m6095fc',
    ),

    // ============ FASHION CATEGORY ============
    Product(
      id: '15',
      name: 'Kaos Batik Modern Pria',
      description: 'Kaos dengan motif batik kontemporer untuk pria',
      price: 89000,
      originalPrice: 120000,
      category: 'Fashion',
      rating: 4.7,
      reviewCount: 95,
      storeName: 'Batik Nusantara',
      storeDistance: '2.3 km',
      imageUrl:
          'https://i.pinimg.com/1200x/89/49/43/89494308b3d6d38cf728ec1b6e24e798.jpg',
    ),
    Product(
      id: '16',
      name: 'Hijab Instan Premium Voal',
      description: 'Hijab instan dengan bahan voal premium adem',
      price: 55000,
      originalPrice: 75000,
      category: 'Fashion',
      rating: 4.9,
      reviewCount: 310,
      storeName: 'Hijab Store',
      storeDistance: '1.7 km',
      imageUrl:
          'https://i.pinimg.com/1200x/7a/26/c9/7a26c999cfcd9a931c83237c22e8f96b.jpg',
    ),
    Product(
      id: '17',
      name: 'Kemeja Flanel Kotak-Kotak',
      description: 'Kemeja flanel motif kotak casual untuk santai',
      price: 95000,
      originalPrice: 125000,
      category: 'Fashion',
      rating: 4.6,
      reviewCount: 147,
      storeName: 'Fashion Hub',
      storeDistance: '2.1 km',
      imageUrl:
          'https://i.pinimg.com/736x/83/63/55/83635564a2b3880593033e875a7ee6cd.jpg',
    ),
    Product(
      id: '18',
      name: 'Dress Batik Wanita Modern',
      description: 'Dress batik kombinasi modern untuk wanita',
      price: 135000,
      originalPrice: 180000,
      category: 'Fashion',
      rating: 4.8,
      reviewCount: 203,
      storeName: 'Batik Cantik',
      storeDistance: '1.9 km',
      imageUrl:
          'https://i.pinimg.com/736x/95/15/75/951575bf612a50d8a7632860215387ba.jpg',
    ),
    Product(
      id: '19',
      name: 'Celana Jeans Slim Fit',
      description: 'Celana jeans pria model slim fit trendy',
      price: 175000,
      originalPrice: 220000,
      category: 'Fashion',
      rating: 4.7,
      reviewCount: 178,
      storeName: 'Denim Store',
      storeDistance: '2.5 km',
      imageUrl:
          'https://i.pinimg.com/736x/08/c8/9d/08c89d1c2f9b4bebbcfe079fd31d49a5.jpg',
    ),

    // ============ HERBAL CATEGORY ============
    Product(
      id: '20',
      name: 'Jamu Kunyit Asam Segar',
      description: 'Jamu tradisional kunyit asam untuk kesehatan',
      price: 15000,
      originalPrice: 20000,
      category: 'Herbal',
      rating: 4.8,
      reviewCount: 180,
      storeName: 'Jamu Bu Ningsih',
      storeDistance: '0.6 km',
      imageUrl:
          'https://i.pinimg.com/736x/f9/bf/d6/f9bfd638c69ebdbeff6d236a6072b37b.jpg',
    ),
    Product(
      id: '21',
      name: 'Madu Murni Hutan 500ml',
      description: 'Madu asli dari hutan peternakan lokal',
      price: 65000,
      originalPrice: 80000,
      category: 'Herbal',
      rating: 4.9,
      reviewCount: 275,
      storeName: 'Madu Alami',
      storeDistance: '1.4 km',
      imageUrl:
          'https://i.pinimg.com/736x/aa/4c/e5/aa4ce5f447925e72362b0a6c9a6db65b.jpg',
    ),
    Product(
      id: '22',
      name: 'Temulawak Instan Box 10 sachet',
      description: 'Minuman temulawak instan untuk stamina',
      price: 35000,
      originalPrice: 45000,
      category: 'Herbal',
      rating: 4.7,
      reviewCount: 198,
      storeName: 'Herbal Nusantara',
      storeDistance: '1.8 km',
      imageUrl:
          'https://down-id.img.susercontent.com/file/40714140dc961d5ca9ca2444f1be0612',
    ),
    Product(
      id: '23',
      name: 'Jahe Merah Instan Sachet',
      description: 'Minuman jahe merah instant untuk menghangatkan',
      price: 25000,
      originalPrice: 32000,
      category: 'Herbal',
      rating: 4.6,
      reviewCount: 156,
      storeName: 'Toko Herbal Sehat',
      storeDistance: '1.1 km',
      imageUrl:
          'https://tse2.mm.bing.net/th/id/OIP.xuIGr5AFt6EeCaa_8mnX2gHaHa?rs=1&pid=ImgDetMain&o=7&rm=3',
    ),

    // ============ KERAJINAN CATEGORY ============
    Product(
      id: '24',
      name: 'Tas Anyaman Rotan Natural',
      description: 'Tas anyaman rotan handmade dari pengrajin lokal',
      price: 125000,
      originalPrice: 160000,
      category: 'Kerajinan',
      rating: 4.8,
      reviewCount: 87,
      storeName: 'Kerajinan Tangan',
      storeDistance: '2.5 km',
      imageUrl:
          'https://i.pinimg.com/736x/db/17/cc/db17ccbb78756c6f0cda1d11a40ef30e.jpg',
    ),
    Product(
      id: '25',
      name: 'Topeng Kayu Ukir Bali',
      description: 'Topeng kayu ukiran khas Bali untuk dekorasi',
      price: 175000,
      originalPrice: 220000,
      category: 'Kerajinan',
      rating: 4.9,
      reviewCount: 56,
      storeName: 'Seni Ukir Bali',
      storeDistance: '3.2 km',
      imageUrl:
          'https://i.pinimg.com/736x/5d/11/d0/5d11d0db5f0ea31b0e00077916e9e09f.jpg',
    ),
    Product(
      id: '26',
      name: 'Gantungan Kunci Batik',
      description: 'Gantungan kunci dengan motif batik handmade',
      price: 15000,
      originalPrice: 20000,
      category: 'Kerajinan',
      rating: 4.5,
      reviewCount: 234,
      storeName: 'Souvenir Nusantara',
      storeDistance: '1.9 km',
      imageUrl:
          'https://i.pinimg.com/736x/2b/d6/72/2bd67264b0b81133eb7ff08895fb398b.jpg',
    ),

    // ============ PERTANIAN CATEGORY ============
    Product(
      id: '27',
      name: 'Pupuk Organik Kompos 5kg',
      description: 'Pupuk organik dari bahan alami untuk tanaman',
      price: 25000,
      originalPrice: 32000,
      category: 'Pertanian',
      rating: 4.7,
      reviewCount: 145,
      storeName: 'Toko Tani Jaya',
      storeDistance: '2.8 km',
      imageUrl:
          'https://i.pinimg.com/736x/10/f8/fc/10f8fcf1ecd91bd59d9eaa59f1e3f4f4.jpg',
    ),
    Product(
      id: '28',
      name: 'Bibit Cabe Rawit Unggul',
      description: 'Bibit cabe rawit berkualitas tinggi untuk budidaya',
      price: 15000,
      originalPrice: 20000,
      category: 'Pertanian',
      rating: 4.6,
      reviewCount: 98,
      storeName: 'Tani Makmur',
      storeDistance: '3.5 km',
      imageUrl:
          'https://i.pinimg.com/1200x/6a/e4/4f/6ae44f8829716b4bfbfddf3dcc5ca3ca.jpg',
    ),
    Product(
      id: '29',
      name: 'Sayuran Organik Mix 1kg',
      description: 'Paket sayuran organik segar dari petani lokal',
      price: 35000,
      originalPrice: 45000,
      category: 'Pertanian',
      rating: 4.8,
      reviewCount: 267,
      storeName: 'Kebun Segar',
      storeDistance: '2.1 km',
      imageUrl:
          'https://i.pinimg.com/1200x/e6/e1/19/e6e119960061eec773d9e0f573929d33.jpg',
    ),

    // ============ KREATIF CATEGORY ============
    Product(
      id: '30',
      name: 'Set Alat Lukis Kanvas',
      description: 'Set lengkap alat lukis untuk pemula dan profesional',
      price: 85000,
      originalPrice: 110000,
      category: 'Kreatif',
      rating: 4.7,
      reviewCount: 89,
      storeName: 'Art Supply Store',
      storeDistance: '2.4 km',
      imageUrl:
          'https://i.pinimg.com/736x/f2/ec/d7/f2ecd776d62afb556f7b8277f77d3ee0.jpg',
    ),
    Product(
      id: '31',
      name: 'Buku Sketsa A4 Premium',
      description: 'Buku sketsa kertas premium untuk menggambar',
      price: 35000,
      originalPrice: 45000,
      category: 'Kreatif',
      rating: 4.6,
      reviewCount: 156,
      storeName: 'Creative Corner',
      storeDistance: '1.8 km',
      imageUrl:
          'https://i.pinimg.com/736x/6c/3f/5c/6c3f5c3efc8a11ad2ce76ad60e536069.jpg',
    ),
    Product(
      id: '32',
      name: 'Clay Polymer Warna Warni',
      description: 'Clay polymer set untuk membuat kerajinan tangan',
      price: 45000,
      originalPrice: 60000,
      category: 'Kreatif',
      rating: 4.8,
      reviewCount: 123,
      storeName: 'DIY Craft Shop',
      storeDistance: '2.2 km',
      imageUrl:
          'https://i.pinimg.com/1200x/d2/73/8e/d2738eceae9feb07c53076a922bd1644.jpg',
    ),

    // ============ TAMBAHAN PRODUK SEGAR (MINUMAN, JELLY, PRODUK UMKM INDONESIA) ============
    Product(
      id: '33',
      name: 'Es Teh Manis Cup',
      description: 'Es teh manis khas Indonesia dalam kemasan botol',
      price: 7000,
      originalPrice: 10000,
      category: 'Food',
      rating: 4.7,
      reviewCount: 425,
      storeName: 'Warung Pak Budi',
      storeDistance: '0.5 km',
      imageUrl:
          'https://i.pinimg.com/736x/63/30/04/633004a76c6f03ab9665d8cce7dade47.jpg',
    ),
    Product(
      id: '34',
      name: 'Jelly Lychee 1kg',
      description: 'Jelly rasa leci segar dan kenyal',
      price: 25000,
      originalPrice: 30000,
      category: 'Food',
      rating: 4.8,
      reviewCount: 312,
      storeName: 'Snack House',
      storeDistance: '1.1 km',
      imageUrl:
          'https://i.pinimg.com/736x/85/58/a5/8558a5cc58e0e57707635793b32e9279.jpg',
    ),
    Product(
      id: '35',
      name: 'Dawet Hitam Asli',
      description: 'Minuman tradisional dawet hitam dengan gula merah',
      price: 12000,
      originalPrice: 15000,
      category: 'Food',
      rating: 4.9,
      reviewCount: 278,
      storeName: 'Jamu Bu Ningsih',
      storeDistance: '0.6 km',
      imageUrl:
          'https://img.freepik.com/premium-photo/es-dawet-hitam-cendol-hitam-is-indonesia-traditional-iced-dessert-from-purworejo_581937-5126.jpg',
    ),
    Product(
      id: '36',
      name: 'Sirsak Madu Botol',
      description: 'Minuman sirsak dengan madu murni',
      price: 15000,
      originalPrice: 20000,
      category: 'Food',
      rating: 4.6,
      reviewCount: 234,
      storeName: 'Madu Alami',
      storeDistance: '1.4 km',
      imageUrl:
          'https://tse2.mm.bing.net/th/id/OIP.JtMOAoE1KvaYFqqANYJeRwHaHa?rs=1&pid=ImgDetMain&o=7&rm=3',
    ),
    Product(
      id: '37',
      name: 'Jelly Kopyor 500gr',
      description: 'Jelly kopyor segar dengan gula merah',
      price: 18000,
      originalPrice: 22000,
      category: 'Food',
      rating: 4.7,
      reviewCount: 198,
      storeName: 'Pasar Segar',
      storeDistance: '0.9 km',
      imageUrl:
          'https://i.pinimg.com/736x/6a/5a/df/6a5adf9ad625176e415f49822ae7b924.jpg',
    ),
    Product(
      id: '38',
      name: 'Wedang Uwuh Instan',
      description: 'Minuman herbal tradisional Yogyakarta',
      price: 10000,
      originalPrice: 13000,
      category: 'Herbal',
      rating: 4.8,
      reviewCount: 267,
      storeName: 'Herbal Nusantara',
      storeDistance: '1.8 km',
      imageUrl:
          'https://i.pinimg.com/736x/61/47/0f/61470f214ef15ab5fc4008a0e7c1a749.jpg',
    ),
    Product(
      id: '39',
      name: 'Es Kelapa Muda',
      description: 'Es kelapa muda segar dengan susu',
      price: 15000,
      originalPrice: 18000,
      category: 'Food',
      rating: 4.7,
      reviewCount: 345,
      storeName: 'Tropical Drink',
      storeDistance: '0.8 km',
      imageUrl:
          'https://i.pinimg.com/736x/43/3d/28/433d28c07a9b05f671d3710a90804934.jpg',
    ),
    Product(
      id: '40',
      name: 'Jelly Mangga 1kg',
      description: 'Jelly rasa mangga segar dan manis',
      price: 22000,
      originalPrice: 27000,
      category: 'Food',
      rating: 4.7,
      reviewCount: 289,
      storeName: 'Snack House',
      storeDistance: '1.1 km',
      imageUrl:
          'https://i.pinimg.com/1200x/ae/78/f0/ae78f05040e740cc24887f84c3f5ed39.jpg',
    ),
    Product(
      id: '41',
      name: 'Sari Kacang Ijo',
      description: 'Minuman sari kacang hijau asli',
      price: 12000,
      originalPrice: 15000,
      category: 'Food',
      rating: 4.8,
      reviewCount: 312,
      storeName: 'Warung Pak Budi',
      storeDistance: '0.5 km',
      imageUrl:
          'https://i.pinimg.com/1200x/bf/f5/02/bff502e79673602b6d93271c46583676.jpg',
    ),
    Product(
      id: '42',
      name: 'Jelly Jeruk 500gr',
      description: 'Jelly rasa jeruk segar dan asam manis',
      price: 18000,
      originalPrice: 22000,
      category: 'Food',
      rating: 4.6,
      reviewCount: 234,
      storeName: 'Snack House',
      storeDistance: '1.1 km',
      imageUrl:
          'https://i.pinimg.com/1200x/69/72/c1/6972c17a5b9b8de373b26e1c61461c97.jpg',
    ),
    Product(
      id: '43',
      name: 'Bandrek Susu',
      description: 'Minuman hangat bandrek dengan susu',
      price: 10000,
      originalPrice: 13000,
      category: 'Herbal',
      rating: 4.7,
      reviewCount: 267,
      storeName: 'Herbal Nusantara',
      storeDistance: '1.8 km',
      imageUrl:
          'https://i.pinimg.com/736x/ab/0d/f7/ab0df7146af3fe5c29d1513cdaf9b97e.jpg',
    ),
    Product(
      id: '44',
      name: 'Jelly Strawberry 1kg',
      description: 'Jelly rasa stroberi segar dan manis',
      price: 23000,
      originalPrice: 28000,
      category: 'Food',
      rating: 4.8,
      reviewCount: 298,
      storeName: 'Snack House',
      storeDistance: '1.1 km',
      imageUrl:
          'https://i.pinimg.com/736x/c1/8e/70/c18e709489f143a9b12152ab4ab2cc29.jpg',
    ),

    // ============ TAMBAHAN PRODUK BUAH & SAYUR ============
    Product(
      id: '45',
      name: 'Pisang Cavendish 1kg',
      description: 'Pisang cavendish segar dan manis',
      price: 25000,
      originalPrice: 30000,
      category: 'Pertanian',
      rating: 4.7,
      reviewCount: 312,
      storeName: 'Kebun Segar',
      storeDistance: '2.1 km',
      imageUrl:
          'https://i.pinimg.com/1200x/89/94/cc/8994cc72eb45158a30c06d4774230ded.jpg',
    ),
    Product(
      id: '46',
      name: 'Apel Fuji 1kg',
      description: 'Apel fuji segar dan renyah',
      price: 35000,
      originalPrice: 40000,
      category: 'Pertanian',
      rating: 4.8,
      reviewCount: 278,
      storeName: 'Kebun Segar',
      storeDistance: '2.1 km',
      imageUrl:
          'https://i.pinimg.com/1200x/16/ee/49/16ee497d374644223ccd26a1493c794b.jpg',
    ),
    Product(
      id: '47',
      name: 'Tomat Segar 1kg',
      description: 'Tomat segar merah dan berkualitas',
      price: 15000,
      originalPrice: 20000,
      category: 'Pertanian',
      rating: 4.6,
      reviewCount: 234,
      storeName: 'Kebun Segar',
      storeDistance: '2.1 km',
      imageUrl:
          'https://i.pinimg.com/1200x/67/d7/fc/67d7fc8e8c788fd50b96cc650d24bfb9.jpg',
    ),
    Product(
      id: '48',
      name: 'Wortel Segar 1kg',
      description: 'Wortel segar oranye dan berkualitas',
      price: 12000,
      originalPrice: 15000,
      category: 'Pertanian',
      rating: 4.7,
      reviewCount: 267,
      storeName: 'Kebun Segar',
      storeDistance: '2.1 km',
      imageUrl:
          'https://i.pinimg.com/1200x/90/14/0a/90140a4f0056916e38b7c3020772416f.jpg',
    ),
    Product(
      id: '49',
      name: 'Bayam Segar 1ikat',
      description: 'Bayam hijau segar dan nutrisi tinggi',
      price: 8000,
      originalPrice: 10000,
      category: 'Pertanian',
      rating: 4.8,
      reviewCount: 289,
      storeName: 'Kebun Segar',
      storeDistance: '2.1 km',
      imageUrl:
          'https://i.pinimg.com/1200x/e5/a0/95/e5a095d73452f84ee2dd563a9b56d2f7.jpg',
    ),
    Product(
      id: '50',
      name: 'Kentang 1kg',
      description: 'Kentang segar dan berkualitas',
      price: 15000,
      originalPrice: 18000,
      category: 'Pertanian',
      rating: 4.6,
      reviewCount: 234,
      storeName: 'Kebun Segar',
      storeDistance: '2.1 km',
      imageUrl:
          'https://i.pinimg.com/1200x/9c/68/6e/9c686ec6d33e9d264bf392c072371b89.jpg',
    ),
    Product(
      id: '51',
      name: 'Buah Semangka',
      description: 'Semangka merah segar dan manis',
      price: 20000,
      originalPrice: 25000,
      category: 'Pertanian',
      rating: 4.9,
      reviewCount: 267,
      storeName: 'Kebun Segar',
      storeDistance: '2.1 km',
      imageUrl:
          'https://i.pinimg.com/1200x/57/2e/44/572e446e7ecd1261d1973b7e11f1d622.jpg',
    ),
    Product(
      id: '52',
      name: 'Buah Melon',
      description: 'Melon hijau segar dan manis',
      price: 18000,
      originalPrice: 22000,
      category: 'Pertanian',
      rating: 4.9,
      reviewCount: 298,
      storeName: 'Kebun Segar',
      storeDistance: '2.1 km',
      imageUrl:
          'https://i.pinimg.com/736x/05/1e/f7/051ef76a110dfd40de4aef4e601c3040.jpg',
    ),
    Product(
      id: '53',
      name: 'Mangga Harum Manis 1kg',
      description: 'Mangga harum manis segar',
      price: 30000,
      originalPrice: 35000,
      category: 'Pertanian',
      rating: 4.9,
      reviewCount: 345,
      storeName: 'Kebun Segar',
      storeDistance: '2.1 km',
      imageUrl:
          'https://i.pinimg.com/736x/38/5a/1a/385a1a57260b175ffc75b32a4da62234.jpg',
    ),
    Product(
      id: '54',
      name: 'Alpukat 1kg',
      description: 'Alpukat segar dan berkualitas',
      price: 25000,
      originalPrice: 30000,
      category: 'Pertanian',
      rating: 4.7,
      reviewCount: 312,
      storeName: 'Kebun Segar',
      storeDistance: '2.1 km',
      imageUrl:
          'https://i.pinimg.com/1200x/02/ce/2f/02ce2feb0755beed215dac5f6187b7c0.jpg',
    ),
    Product(
      id: '55',
      name: 'Jeruk Manis 1kg',
      description: 'Jeruk manis segar dan berkualitas',
      price: 20000,
      originalPrice: 25000,
      category: 'Pertanian',
      rating: 4.8,
      reviewCount: 278,
      storeName: 'Kebun Segar',
      storeDistance: '2.1 km',
      imageUrl:
          'https://i.pinimg.com/736x/fd/2f/75/fd2f7532157da5c6519aa76d938d17bc.jpg',
    ),
    Product(
      id: '56',
      name: 'Brokoli 1ikat',
      description: 'Brokoli hijau segar dan berkualitas',
      price: 18000,
      originalPrice: 22000,
      category: 'Pertanian',
      rating: 4.6,
      reviewCount: 234,
      storeName: 'Kebun Segar',
      storeDistance: '2.1 km',
      imageUrl:
          'https://i.pinimg.com/1200x/91/c2/d5/91c2d5cb35f8db6bd9ab3cadcb2e65a3.jpg',
    ),
    Product(
      id: '57',
      name: 'Cabai Merah 100gr',
      description: 'Cabai merah segar dan pedas',
      price: 5000,
      originalPrice: 7000,
      category: 'Pertanian',
      rating: 4.7,
      reviewCount: 267,
      storeName: 'Kebun Segar',
      storeDistance: '2.1 km',
      imageUrl:
          'https://i.pinimg.com/1200x/82/b7/29/82b729fb22b9e2fd02a08d995c1ffbd7.jpg',
    ),
    Product(
      id: '58',
      name: 'Strawberry 250gr',
      description: 'Strawberry merah segar dan manis',
      price: 15000,
      originalPrice: 18000,
      category: 'Pertanian',
      rating: 4.8,
      reviewCount: 289,
      storeName: 'Kebun Segar',
      storeDistance: '2.1 km',
      imageUrl:
          'https://i.pinimg.com/736x/8f/f4/f0/8ff4f0b8413c8e3ef42a200f43492a77.jpg',
    ),
    Product(
      id: '59',
      name: 'Anggur 500gr',
      description: 'Anggur ungu segar dan manis',
      price: 25000,
      originalPrice: 30000,
      category: 'Pertanian',
      rating: 4.9,
      reviewCount: 345,
      storeName: 'Kebun Segar',
      storeDistance: '2.1 km',
      imageUrl:
          'https://i.pinimg.com/1200x/70/f0/cc/70f0cc60b42372f96ff52242cf29710b.jpg',
    ),
    Product(
      id: '60',
      name: 'Timun 1kg',
      description: 'Timun hijau segar dan renyah',
      price: 10000,
      originalPrice: 13000,
      category: 'Pertanian',
      rating: 4.7,
      reviewCount: 312,
      storeName: 'Kebun Segar',
      storeDistance: '2.1 km',
      imageUrl:
          'https://i.pinimg.com/736x/5a/3d/2f/5a3d2fb75acdd8aabe60ae134a357136.jpg',
    ),

    // ============ TAMBAHAN PRODUK BUAH YANG LEBIH BANYAK ============
    Product(
      id: '61',
      name: 'Pisang Raja 1 sisir',
      description: 'Pisang raja manis dan segar langsung dari pohon',
      price: 20000,
      originalPrice: 25000,
      category: 'Pertanian',
      rating: 4.9,
      reviewCount: 312,
      storeName: 'Buah Segar Pak Joko',
      storeDistance: '1.2 km',
      imageUrl:
          'https://i.pinimg.com/1200x/64/2e/b8/642eb823cc55b56c8e0f611277d850a3.jpg',
    ),
    Product(
      id: '62',
      name: 'Salak Pondoh 1kg',
      description: 'Salak pondoh manis segar dari Sleman',
      price: 22000,
      originalPrice: 28000,
      category: 'Pertanian',
      rating: 4.8,
      reviewCount: 278,
      storeName: 'Warung Buah Sari',
      storeDistance: '0.8 km',
      imageUrl:
          'https://i.pinimg.com/1200x/5d/aa/71/5daa71ea3e755354e00cdacd26d60bbd.jpg',
    ),
    Product(
      id: '63',
      name: 'Nanas Madu 1buah',
      description: 'Nanas madu manis dan segar',
      price: 25000,
      originalPrice: 30000,
      category: 'Pertanian',
      rating: 4.7,
      reviewCount: 234,
      storeName: 'Gudang Buah Nusantara',
      storeDistance: '2.3 km',
      imageUrl:
          'https://i.pinimg.com/736x/2c/91/5f/2c915f71906c55242fa4819403e888d0.jpg',
    ),
    Product(
      id: '64',
      name: 'Jambu Air Merah 1kg',
      description: 'Jambu air merah segar dan renyah',
      price: 18000,
      originalPrice: 22000,
      category: 'Pertanian',
      rating: 4.8,
      reviewCount: 267,
      storeName: 'Buah Segar Pak Joko',
      storeDistance: '1.2 km',
      imageUrl:
          'https://i.pinimg.com/736x/1f/98/1a/1f981a87a0ecd3ef4d321e52400458af.jpg',
    ),
    Product(
      id: '65',
      name: 'Duku Langsat 1kg',
      description: 'Duku langsat manis segar',
      price: 30000,
      originalPrice: 35000,
      category: 'Pertanian',
      rating: 4.9,
      reviewCount: 289,
      storeName: 'Warung Buah Sari',
      storeDistance: '0.8 km',
      imageUrl:
          'https://i.pinimg.com/736x/2b/20/70/2b207008e715f68d55f9a913cda6799d.jpg',
    ),
    Product(
      id: '66',
      name: 'Srikaya 1kg',
      description: 'Srikaya manis dan gurih',
      price: 35000,
      originalPrice: 40000,
      category: 'Pertanian',
      rating: 4.7,
      reviewCount: 234,
      storeName: 'Gudang Buah Nusantara',
      storeDistance: '2.3 km',
      imageUrl:
          'https://i.pinimg.com/736x/57/81/50/578150b5f0e41fea90ab992c2e971533.jpg',
    ),
    Product(
      id: '67',
      name: 'Manggis 1kg',
      description: 'Manggis segar dengan kulit mengkilat',
      price: 28000,
      originalPrice: 33000,
      category: 'Pertanian',
      rating: 4.8,
      reviewCount: 267,
      storeName: 'Buah Segar Pak Joko',
      storeDistance: '1.2 km',
      imageUrl:
          'https://i.pinimg.com/1200x/96/e9/b6/96e9b6b277e3abc05ed03d92c7d41b1e.jpg',
    ),
    Product(
      id: '68',
      name: 'Rambutan 1kg',
      description: 'Rambutan manis segar',
      price: 22000,
      originalPrice: 27000,
      category: 'Pertanian',
      rating: 4.9,
      reviewCount: 289,
      storeName: 'Warung Buah Sari',
      storeDistance: '0.8 km',
      imageUrl:
          'https://i.pinimg.com/736x/5c/79/5a/5c795af37a63ed75f733d5543dfd64c9.jpg',
    ),
    Product(
      id: '69',
      name: 'Buah Naga Segar',
      description: 'Buah Naga Segar',
      price: 18000,
      originalPrice: 22000,
      category: 'Pertanian',
      rating: 4.7,
      reviewCount: 298,
      storeName: 'Kebun Segar',
      storeDistance: '1.1 km',
      imageUrl:
          'https://i.pinimg.com/1200x/96/d8/9f/96d89ffa06df1f3892d23f84eba165b5.jpg',
    ),
    Product(
      id: '70',
      name: 'Cabai Rawit Merah',
      description: 'Cabai Rawit Merah Segar ',
      price: 15000,
      originalPrice: 20000,
      category: 'Pertanian',
      rating: 4.7,
      reviewCount: 298,
      storeName: 'Kebun Segar',
      storeDistance: '1.1 km',
      imageUrl:
          'https://i.pinimg.com/736x/b1/89/6f/b1896ff335654b5a929a86aa0de16e8b.jpg',
    ),
    Product(
      id: '71',
      name: 'Jus Jambu Biji Merah 350ml',
      description: 'Jus jambu biji merah segar kaya vitamin C',
      price: 15000,
      originalPrice: 20000,
      category: 'Food',
      rating: 4.7,
      reviewCount: 345,
      storeName: 'Tropical Drink',
      storeDistance: '0.8 km',
      imageUrl:
          'https://i.pinimg.com/1200x/e3/73/db/e373dbc89364aea76c28358495654b39.jpg',
    ),
    Product(
      id: '72',
      name: 'Jelly Cocopandan',
      description: 'Jelly kelapa pandan segar dengan tekstur kenyal',
      price: 20000,
      originalPrice: 25000,
      category: 'Food',
      rating: 4.7,
      reviewCount: 234,
      storeName: 'Snack House',
      storeDistance: '1.1 km',
      imageUrl:
          'https://i.pinimg.com/736x/0b/ce/2e/0bce2ecb6117309961a0e4ede944c9c3.jpg',
    ),
    Product(
      id: '73',
      name: 'Es Cendol Durian',
      description: 'Minuman cendol dengan topping durian segar',
      price: 15000,
      originalPrice: 20000,
      category: 'Food',
      rating: 4.9,
      reviewCount: 412,
      storeName: 'Bu Ningsih',
      storeDistance: '0.6 km',
      imageUrl:
          'https://i.pinimg.com/736x/00/51/5e/00515eaa273b7e0390200dbd8d9ca8ea.jpg',
    ),
    Product(
      id: '74',
      name: 'Smoothie Mangga Segar',
      description: 'Smoothie mangga manis dengan topping mangga segar dan saus karamel',
      price: 18000,
      originalPrice: 22000,
      category: 'Food',
      rating: 4.8,
      reviewCount: 267,
      storeName: 'Tropical Drink',
      storeDistance: '0.8 km',
      imageUrl: 'https://i.pinimg.com/736x/47/46/0a/47460a579a239e5db9df9027685a5490.jpg', 
    ),

    Product(
      id: '75',
      name: 'Smoothie Buah Naga Pink',
      description: 'Smoothie buah naga merah dengan topping buah naga segar dan chia seed',
      price: 20000,
      originalPrice: 25000,
      category: 'Food',
      rating: 4.9,
      reviewCount: 312,
      storeName: 'Tropical Drink',
      storeDistance: '0.8 km',
      imageUrl: 'https://i.pinimg.com/1200x/46/95/c9/4695c9ffed3530771bc6f7d1b6582b42.jpg', 
    ),

    Product(
      id: '76',
      name: 'Smoothie Alpukat Keju',
      description: 'Smoothie alpukat creamy dengan topping keju parut dan saus coklat',
      price: 22000,
      originalPrice: 27000,
      category: 'Food',
      rating: 4.9,
      reviewCount: 345,
      storeName: 'Tropical Drink',
      storeDistance: '0.8 km',
      imageUrl: 'https://i.pinimg.com/736x/14/a1/70/14a170916103962748d5b107e21e6e6e.jpg', 
    ),
    // PAKET SEMBAKO
    Product(
      id: '100',
      name: 'Paket Sembako Hemat A',
      description: 'Beras 5kg + Minyak Goreng 2L + Gula 1kg + Telur 10pcs',
      price: 100000,
      originalPrice: 150000,
      category: 'Grocery',
      rating: 4.9,
      reviewCount: 567,
      storeName: 'Toko Sumber Rezeki',
      storeDistance: '0.7 km',
      imageUrl:
          'https://i.pinimg.com/1200x/09/b9/72/09b972688cd8b79b4ee15502fd652456.jpg',
    ),
    Product(
      id: '101',
      name: 'Paket Sembako Lengkap E',
      description:
          'Beras 5kg + Minyak 2L + Gula 1kg + Telur 10pcs + Mie Instan 10pcs + Susu 1L',
      price: 165000,
      originalPrice: 225000,
      category: 'Grocery',
      rating: 4.8,
      reviewCount: 489,
      storeName: 'Toko Sumber Rezeki',
      storeDistance: '0.7 km',
      imageUrl:
          'https://i.pinimg.com/1200x/04/28/ae/0428ae2dd8d05913fda40d33b39e8c4c.jpg',
    ),
    Product(
      id: '102',
      name: 'Paket Sayur Asem',
      description:
          'Tomat, Toge kedelai, Kacang Panjang, Manisa, Asem dan Labu air',
      price: 15000,
      originalPrice: 20000,
      category: 'Grocery',
      rating: 4.9,
      reviewCount: 623,
      storeName: 'Toko Sumber Rezeki',
      storeDistance: '0.7 km',
      imageUrl:
          'https://i.pinimg.com/1200x/5e/88/cf/5e88cfe4ffb4b767823cff39731c2ed2.jpg',
    ),
    Product(
      id: '103',
      name: 'Paket Sembako Komplit',
      description:
          'Beras 5kg + Minyak 2L + Tepung 1kg + Gula 2kg + Susu 2L',
      price: 195000,
      originalPrice: 220000,
      category: 'Grocery',
      rating: 4.8,
      reviewCount: 512,
      storeName: 'Toko Sumber Rezeki',
      storeDistance: '0.7 km',
      imageUrl:
          'https://down-id.img.susercontent.com/file/id-11134207-7qul6-lf059vr2tv9jc8@resize_w900_nl.webp',
    ),

    // PAKET LAUK PAUK
    Product(
      id: '104',
      name: 'Paket Lauk Ayam Lengkap',
      description:
          'Nasi, Ayam Goreng / Bakar, Tahu / Tempe, Sambal / Lalapan, Perkedel / Tempe Kering',
      price: 27000,
      originalPrice: 30000,
      category: 'Food',
      rating: 4.7,
      reviewCount: 345,
      storeName: 'Warung Pak Budi',
      storeDistance: '0.5 km',
      imageUrl:
          'https://i.pinimg.com/1200x/a9/4f/ec/a94fec80cee33091150472f62e139ada.jpg',
    ),
    Product(
      id: '105',
      name: 'Paket Lauk Seafood',
      description:
          'Kepiting ukuran sedang, Kerang campur ±150–200gr, Jagung + bumbu',
      price: 52000,
      originalPrice: 55000,
      category: 'Food',
      rating: 4.8,
      reviewCount: 298,
      storeName: 'Pasar Segar',
      storeDistance: '0.9 km',
      imageUrl:
          'https://i.pinimg.com/736x/6e/56/4f/6e564f2f06eb7fdc75660d8f561b1a5c.jpg',
    ),
    Product(
      id: '106',
      name: 'Paket Tumis Kangkung',
      description: 'Sayur Kangkung, Cabe Rawit, Bawang Putih, Bawang Merah',
      price: 11160,
      originalPrice: 12000,
      category: 'Food',
      rating: 4.9,
      reviewCount: 412,
      storeName: 'Rumah Makan Padang',
      storeDistance: '1.3 km',
      imageUrl:
          'https://i.pinimg.com/1200x/7c/6e/02/7c6e02d9bdde795470cce9bd364f433a.jpg',
    ),

    // PAKET SNACK & MINUMAN
    Product(
      id: '107',
      name: 'Paket Snack Keluarga',
      description:
          '10 Macam Snack (Keripik, Biskuit, Coklat, Permen) + 6 Minuman Ringan',
      price: 125000,
      originalPrice: 175000,
      category: 'Food',
      rating: 4.6,
      reviewCount: 456,
      storeName: 'Warung Pak Budi',
      storeDistance: '0.5 km',
      imageUrl:
          'https://i.pinimg.com/736x/c2/22/27/c22227da9452f0e24cdea4511498db68.jpg',
    ),
    Product(
      id: '108',
      name: 'Paket Minuman Segar',
      description: '4 Botol Jus Mangga',
      price: 85000,
      originalPrice: 120000,
      category: 'Food',
      rating: 4.7,
      reviewCount: 389,
      storeName: 'Tropical Drink',
      storeDistance: '0.8 km',
      imageUrl:
          'https://i.pinimg.com/1200x/27/51/ad/2751ad58f8a34da9eb93a4fd72ebf2c2.jpg',
    ),

    // PAKET BUAH & SAYUR
    Product(
      id: '109',
      name: 'Paket Buah Segar Mix',
      description: 'Apel, Jeruk, Pisang, Anggur, Semangka - Total 5kg',
      price: 95000,
      originalPrice: 135000,
      category: 'Pertanian',
      rating: 4.8,
      reviewCount: 523,
      storeName: 'Buah Segar Pak Joko',
      storeDistance: '1.2 km',
      imageUrl:
          'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=400&h=400&fit=crop',
    ),
    Product(
      id: '110',
      name: 'Paket Sayuran Organik',
      description: 'Bayam, Kangkung, Wortel, Brokoli, Tomat, Cabai - Total 5kg',
      price: 75000,
      originalPrice: 105000,
      category: 'Pertanian',
      rating: 4.9,
      reviewCount: 467,
      storeName: 'Kebun Segar',
      storeDistance: '2.1 km',
      imageUrl:
          'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&h=400&fit=crop',
    ),
    Product(
      id: '111',
      name: 'Parcel Buah',
      description: 'Pir, Apel, Anggur Hijau, Jeruk, Buavita Guava',
      price: 125000,
      originalPrice: 175000,
      category: 'Pertanian',
      rating: 4.9,
      reviewCount: 389,
      storeName: 'Gudang Buah Nusantara',
      storeDistance: '2.3 km',
      imageUrl:
          'https://i.pinimg.com/736x/30/06/a2/3006a25d6bbf14a71aa86f8035372b2e.jpg',
    ),

    // PAKET HERBAL & KESEHATAN
    Product(
      id: '112',
      name: 'Paket Jamu Sehat Lengkap',
      description: '3 Botol Jamu (Kunyit Asam, Beras Kencur, Temulawak, Jahe)',
      price: 85000,
      originalPrice: 125000,
      category: 'Herbal',
      rating: 4.8,
      reviewCount: 412,
      storeName: 'Jamu Bu Ningsih',
      storeDistance: '0.6 km',
      imageUrl:
          'https://i.pinimg.com/1200x/f2/6b/70/f26b70aa1ea1dd46110ce43ade9cdefb.jpg',
    ),
    Product(
      id: '113',
      name: 'Paket Madu & Herbal',
      description: 'Madu 1L + Propolis + Royal Jelly + Bee Pollen',
      price: 165000,
      originalPrice: 230000,
      category: 'Herbal',
      rating: 4.9,
      reviewCount: 345,
      storeName: 'Madu Alami',
      storeDistance: '1.4 km',
      imageUrl:
          'https://i.pinimg.com/1200x/7f/ee/4d/7fee4d25744b070bfe355911e457bd6e.jpg',
    ),

    // PAKET BUMBU DAPUR
    Product(
      id: '114',
      name: 'Paket Bumbu Dapur Lengkap',
      description:
          '15 Jenis Bumbu (Bawang, Cabai, Jahe, Kunyit, Lengkuas, dll)',
      price: 65000,
      originalPrice: 95000,
      category: 'Grocery',
      rating: 4.7,
      reviewCount: 489,
      storeName: 'Toko Sumber Rezeki',
      storeDistance: '0.7 km',
      imageUrl:
          'https://i.pinimg.com/1200x/14/50/da/1450daea02bdf6e5741831c87483d28b.jpg',
    ),
    Product(
      id: '115',
      name: 'Paket Rempah Nusantara',
      description:
          'Rempah Pilihan: Kayu Manis, Cengkeh, Pala, Kapulaga, Merica',
      price: 55000,
      originalPrice: 80000,
      category: 'Herbal',
      rating: 4.8,
      reviewCount: 367,
      storeName: 'Herbal Nusantara',
      storeDistance: '1.8 km',
      imageUrl:
          'https://i.pinimg.com/1200x/ed/b9/7c/edb97cd71eb4adfab250590dfcb2cfa7.jpg',
    ),

    // PAKET KEBUTUHAN BAYI & ANAK
    Product(
      id: '116',
      name: 'Paket Hampers Bayi Newborn',
      description:
          'UKURAN 20 × 20 × 5 cm) Dilapisi Paper Tissue + stiker thank you Gift Card',
      price: 145000,
      originalPrice: 200000,
      category: 'Grocery',
      rating: 4.9,
      reviewCount: 523,
      storeName: 'Supermarket Indo',
      storeDistance: '1.1 km',
      imageUrl:
          'https://i.pinimg.com/1200x/5e/9d/58/5e9d58710b089870133d2064e409685f.jpg',
    ),

    // PAKET NASI BOX & CATERING
    Product(
      id: '117',
      name: 'Paket Nasi Box',
      description: 'Box Nasi + Lauk Ayam/Ikan + Sayur + Sambal + Kerupuk',
      price: 111000,
      originalPrice: 150000,
      category: 'Food',
      rating: 4.8,
      reviewCount: 678,
      storeName: 'Warung Pak Budi',
      storeDistance: '0.5 km',
      imageUrl:
          'https://i.pinimg.com/736x/c2/3d/c6/c23dc672030d696e4167bfa8f4c978d2.jpg',
    ),
    Product(
      id: '118',
      name: 'Paket Tumpeng Mini',
      description: 'Tumpeng + Lauk Lengkap untuk 20 orang',
      price: 60000,
      originalPrice: 85000,
      category: 'Food',
      rating: 4.9,
      reviewCount: 445,
      storeName: 'Rumah Makan Padang',
      storeDistance: '1.3 km',
      imageUrl:
          'https://i.pinimg.com/1200x/2d/0d/3e/2d0d3eb53498670c275cf452916e3316.jpg',
    ),

    // PAKET FASHION
    Product(
      id: '119',
      name: 'Paket Hijab 5 Warna',
      description: '5 Hijab Premium Voal Berbeda Warna',
      price: 195000,
      originalPrice: 275000,
      category: 'Fashion',
      rating: 4.9,
      reviewCount: 567,
      storeName: 'Hijab Store',
      storeDistance: '1.7 km',
      imageUrl:
          'https://i.pinimg.com/736x/ae/4b/d3/ae4bd32a32125a561647a661080dd73f.jpg',
    ),
    Product(
      id: '120',
      name: 'Paket Batik Couple',
      description: 'Kemeja Batik Pria + Dress Batik Wanita Matching',
      price: 285000,
      originalPrice: 400000,
      category: 'Fashion',
      rating: 4.8,
      reviewCount: 389,
      storeName: 'Batik Nusantara',
      storeDistance: '2.3 km',
      imageUrl:
          'https://i.pinimg.com/1200x/82/b3/ee/82b3ee7ca7de98c0912f14000495873b.jpg',
    ),

    // ============ TAMBAHAN PRODUK BUAH & SAYUR ANTAPANI KIDUL ============
    Product(
      id: '121',
      name: 'Paket Buah Segar Harian',
      description: 'Pisang, Apel, Jeruk - Total 2kg',
      price: 45000,
      originalPrice: 60000,
      category: 'Pertanian',
      rating: 4.8,
      reviewCount: 234,
      storeName: 'Buah Segar Pak Joko',
      storeDistance: '1.2 km',
      imageUrl:
          'https://i.pinimg.com/1200x/9b/34/d6/9b34d6c11454df471aaf4a4016a0e643.jpg',
    ),
    Product(
      id: '122',
      name: 'Paket Sayur Segar Harian',
      description: 'Bayam, Kangkung, Wortel, Tomat - Total 2kg',
      price: 30000,
      originalPrice: 40000,
      category: 'Pertanian',
      rating: 4.7,
      reviewCount: 189,
      storeName: 'Kebun Segar',
      storeDistance: '2.1 km',
      imageUrl:
          'https://i.pinimg.com/736x/fc/20/c3/fc20c344d55b0d934bc96c329fdeeede.jpg',
    ),
    Product(
      id: '123',
      name: 'Paket Buah Tropis Mini',
      description: 'Mangga, Pepaya, Pisang - Total 2kg',
      price: 50000,
      originalPrice: 65000,
      category: 'Pertanian',
      rating: 4.9,
      reviewCount: 267,
      storeName: 'Buah Segar Pak Joko',
      storeDistance: '1.2 km',
      imageUrl:
          'https://i.pinimg.com/1200x/24/fd/4b/24fd4b6fbe068137f447498948902328.jpg',
    ),
    Product(
      id: '124',
      name: 'Sayur Organik Mix 2kg',
      description: 'Brokoli, Wortel, Kentang, Cabai',
      price: 35000,
      originalPrice: 45000,
      category: 'Pertanian',
      rating: 4.8,
      reviewCount: 198,
      storeName: 'Kebun Segar',
      storeDistance: '2.1 km',
      imageUrl:
          'https://i.pinimg.com/1200x/50/37/8a/50378a38123d6fbfee9c293f7901d9a2.jpg',
    ),
    Product(
      id: '125',
      name: 'Jeruk Manis Premium 2kg',
      description: 'Jeruk manis segar pilihan',
      price: 40000,
      originalPrice: 50000,
      category: 'Pertanian',
      rating: 4.9,
      reviewCount: 312,
      storeName: 'Buah Segar Pak Joko',
      storeDistance: '1.2 km',
      imageUrl:
          'https://i.pinimg.com/736x/30/cf/92/30cf924f97b8a30adc4e9c4382e95b64.jpg',
    ),
    // ============ JASA CATEGORY ============ (tambahkan di bagian bawah _allProducts)

    // JASA JAHIT & BORDIR
    Product(
      id: '126',
      name: 'Jahit Baju Baru',
      description: 'Jasa jahit baju baru sesuai model yang diinginkan',
      price: 150000,
      originalPrice: 200000,
      category: 'Jasa',
      rating: 4.9,
      reviewCount: 234,
      storeName: 'Jahit Bu Siti',
      storeDistance: '0.8 km',
      imageUrl:
          'https://i.pinimg.com/1200x/6d/7a/25/6d7a2546fec0b43d75e7db699ce7a4da.jpg',
    ),
    Product(
      id: '127',
      name: 'Obras Baju',
      description: 'Jasa obras/reparasi baju yang sobek atau rusak',
      price: 25000,
      originalPrice: 35000,
      category: 'Jasa',
      rating: 4.8,
      reviewCount: 456,
      storeName: 'Jahit Bu Siti',
      storeDistance: '0.8 km',
      imageUrl:
          'https://i.pinimg.com/1200x/ec/3e/fd/ec3efd5dd70f04f0046f5b7c64286fcd.jpg',
    ),
    Product(
      id: '128',
      name: 'Bordir Nama',
      description: 'Jasa bordir nama di baju, tas, atau topi',
      price: 15000,
      originalPrice: 20000,
      category: 'Jasa',
      rating: 4.7,
      reviewCount: 189,
      storeName: 'Jahit Bu Siti',
      storeDistance: '0.8 km',
      imageUrl:
          'https://i.pinimg.com/736x/da/74/3b/da743b01900c5d7b0bbc1188aa9b88d4.jpg',
    ),
    Product(
      id: '129',
      name: 'Jahit Celana Pendek',
      description: 'Jasa mempendekkan celana sesuai ukuran',
      price: 20000,
      originalPrice: 30000,
      category: 'Jasa',
      rating: 4.8,
      reviewCount: 312,
      storeName: 'Jahit Bu Siti',
      storeDistance: '0.8 km',
      imageUrl:
          'https://i.pinimg.com/736x/e1/a4/9a/e1a49abac463fc9bd0e5c1f23dda80f3.jpg',
    ),

    // JASA LAUNDRY
    Product(
      id: '130',
      name: 'Laundry Kiloan Regular',
      description: 'Laundry per kilogram untuk pakaian sehari-hari',
      price: 7000,
      originalPrice: 10000,
      category: 'Jasa',
      rating: 4.7,
      reviewCount: 678,
      storeName: 'Laundry Express',
      storeDistance: '1.2 km',
      imageUrl:
          'https://i.pinimg.com/1200x/67/63/cc/6763cc2eb799ffb9ac0760ace0cc41ff.jpg',
    ),
    Product(
      id: '131',
      name: 'Laundry Express (1 Hari)',
      description: 'Laundry kilat selesai dalam 1 hari',
      price: 12000,
      originalPrice: 15000,
      category: 'Jasa',
      rating: 4.8,
      reviewCount: 523,
      storeName: 'Laundry Express',
      storeDistance: '1.2 km',
      imageUrl:
          'https://i.pinimg.com/1200x/bd/ff/80/bdff807bdf5db5d2ff2933fbfbdd067c.jpg',
    ),
    Product(
      id: '132',
      name: 'Dry Cleaning Jas/Jaket',
      description: 'Dry cleaning khusus jas, jaket, atau mantel',
      price: 35000,
      originalPrice: 45000,
      category: 'Jasa',
      rating: 4.9,
      reviewCount: 289,
      storeName: 'Laundry Express',
      storeDistance: '1.2 km',
      imageUrl:
          'https://i.pinimg.com/736x/30/5d/9f/305d9f8ac37a921e538db712c685ded8.jpg',
    ),
    Product(
      id: '133',
      name: 'Cuci Sepatu',
      description: 'Jasa cuci sepatu hingga bersih seperti baru',
      price: 25000,
      originalPrice: 35000,
      category: 'Jasa',
      rating: 4.6,
      reviewCount: 412,
      storeName: 'Laundry Express',
      storeDistance: '1.2 km',
      imageUrl:
          'https://i.pinimg.com/1200x/f5/39/0b/f5390b634743638c0e4d567ff02cfa6c.jpg',
    ),

    // JASA SALON & SPA
    Product(
      id: '134',
      name: 'Potong Rambut Pria',
      description: 'Potong rambut gaya modern untuk pria',
      price: 30000,
      originalPrice: 40000,
      category: 'Jasa',
      rating: 4.8,
      reviewCount: 534,
      storeName: 'Salon Cantik',
      storeDistance: '1.5 km',
      imageUrl:
          'https://i.pinimg.com/736x/74/e3/18/74e318156d57c26f1218249912988fc1.jpg',
    ),
    Product(
      id: '135',
      name: 'Potong Rambut Wanita',
      description: 'Potong rambut dengan styling untuk wanita',
      price: 45000,
      originalPrice: 60000,
      category: 'Jasa',
      rating: 4.9,
      reviewCount: 623,
      storeName: 'Salon Cantik',
      storeDistance: '1.5 km',
      imageUrl:
          'https://i.pinimg.com/736x/57/0d/49/570d49d8dfc2fe9dff5a151cef34a9d9.jpg',
    ),
    Product(
      id: '136',
      name: 'Creambath + Masker',
      description: 'Perawatan rambut creambath dengan masker',
      price: 55000,
      originalPrice: 75000,
      category: 'Jasa',
      rating: 4.8,
      reviewCount: 445,
      storeName: 'Salon Cantik',
      storeDistance: '1.5 km',
      imageUrl:
          'https://i.pinimg.com/736x/e0/1f/65/e01f65a161957f6e75dd5f830c9d71ad.jpg',
    ),
    Product(
      id: '137',
      name: 'Facial Treatment',
      description: 'Perawatan wajah lengkap dengan facial',
      price: 85000,
      originalPrice: 110000,
      category: 'Jasa',
      rating: 4.9,
      reviewCount: 389,
      storeName: 'Salon Cantik',
      storeDistance: '1.5 km',
      imageUrl:
          'https://i.pinimg.com/736x/f5/3d/c2/f53dc2f3b6bdca19959f2628d03d912f.jpg',
    ),

    // JASA BENGKEL
    Product(
      id: '138',
      name: 'Service Motor Rutin',
      description: 'Service rutin motor ganti oli dan tune up',
      price: 75000,
      originalPrice: 100000,
      category: 'Jasa',
      rating: 4.6,
      reviewCount: 389,
      storeName: 'Bengkel Motor Jaya',
      storeDistance: '2.0 km',
      imageUrl:
          'https://i.pinimg.com/1200x/11/af/c6/11afc699df33049810ef1e8de0cc5ef3.jpg',
    ),
    Product(
      id: '139',
      name: 'Ganti Ban Motor',
      description: 'Jasa ganti ban motor sudah termasuk ban baru',
      price: 185000,
      originalPrice: 220000,
      category: 'Jasa',
      rating: 4.7,
      reviewCount: 312,
      storeName: 'Bengkel Motor Jaya',
      storeDistance: '2.0 km',
      imageUrl:
          'https://i.pinimg.com/736x/64/71/e8/6471e8b575b53daca54bc13e5bd7bf95.jpg',
    ),
    Product(
      id: '140',
      name: 'Tambal Ban Motor',
      description: 'Tambal ban motor bocor atau kempes',
      price: 15000,
      originalPrice: 20000,
      category: 'Jasa',
      rating: 4.5,
      reviewCount: 567,
      storeName: 'Bengkel Motor Jaya',
      storeDistance: '2.0 km',
      imageUrl:
          'https://i.pinimg.com/1200x/0e/4c/90/0e4c9081b2a9abe5bfa8c44bb7771c37.jpg',
    ),

    // JASA TUKANG
    Product(
      id: '141',
      name: 'Pembuatan Meja Kayu Custom',
      description: 'Jasa pembuatan meja kayu sesuai ukuran dan desain',
      price: 850000,
      originalPrice: 1200000,
      category: 'Jasa',
      rating: 4.8,
      reviewCount: 145,
      storeName: 'Tukang Kayu Pak Agus',
      storeDistance: '2.5 km',
      imageUrl:
          'https://down-id.img.susercontent.com/file/sg-11134201-22120-s1jp6kei5kkv31@resize_w900_nl.webp',
    ),
    Product(
      id: '142',
      name: 'Pembuatan Lemari Pakaian',
      description: 'Jasa pembuatan lemari pakaian kayu jati',
      price: 1500000,
      originalPrice: 2000000,
      category: 'Jasa',
      rating: 4.9,
      reviewCount: 98,
      storeName: 'Tukang Kayu Pak Agus',
      storeDistance: '2.5 km',
      imageUrl:
          'https://i.pinimg.com/1200x/e2/14/a9/e214a911556ecc4e1c90b8f7fb9be94a.jpg',
    ),
    Product(
      id: '143',
      name: 'Reparasi Furniture',
      description: 'Jasa perbaikan furniture yang rusak atau patah',
      price: 125000,
      originalPrice: 175000,
      category: 'Jasa',
      rating: 4.7,
      reviewCount: 234,
      storeName: 'Tukang Kayu Pak Agus',
      storeDistance: '2.5 km',
      imageUrl:
          'https://i.pinimg.com/736x/f3/0d/b2/f30db2618cde3344119613d4ad3d2924.jpg',
    ),

    // JASA SERVICE ELEKTRONIK
    Product(
      id: '144',
      name: 'Cuci AC 1 PK',
      description: 'Jasa cuci AC 1 PK hingga bersih dan dingin',
      price: 85000,
      originalPrice: 110000,
      category: 'Jasa',
      rating: 4.7,
      reviewCount: 423,
      storeName: 'Cuci AC Profesional',
      storeDistance: '1.8 km',
      imageUrl:
          'https://i.pinimg.com/736x/c7/3b/bc/c73bbc2413230e6ba236d6a96ec48c81.jpg',
    ),
    Product(
      id: '145',
      name: 'Service AC (Isi Freon)',
      description: 'Jasa service AC dengan isi freon R410A',
      price: 165000,
      originalPrice: 210000,
      category: 'Jasa',
      rating: 4.8,
      reviewCount: 356,
      storeName: 'Cuci AC Profesional',
      storeDistance: '1.8 km',
      imageUrl:
          'https://i.pinimg.com/1200x/0d/e7/db/0de7db6330259357c6f26c96b101413b.jpg',
    ),
    Product(
      id: '146',
      name: 'Service Kulkas',
      description: 'Jasa service kulkas tidak dingin atau rusak',
      price: 135000,
      originalPrice: 175000,
      category: 'Jasa',
      rating: 4.6,
      reviewCount: 289,
      storeName: 'Cuci AC Profesional',
      storeDistance: '1.8 km',
      imageUrl:
          'https://i.pinimg.com/736x/ae/b5/1c/aeb51c02e751e76eb30efbf67f91f810.jpg',
    ),
    Product(
      id: '147',
      name: 'Service TV LED',
      description: 'Jasa service TV LED mati atau bergaris',
      price: 125000,
      originalPrice: 165000,
      category: 'Jasa',
      rating: 4.7,
      reviewCount: 312,
      storeName: 'Cuci AC Profesional',
      storeDistance: '1.8 km',
      imageUrl:
          'https://i.pinimg.com/1200x/c6/d1/fe/c6d1fecb340b20a324c4c471ddf255ca.jpg',
    ),

    // JASA CLEANING SERVICE
    Product(
      id: '148',
      name: 'General Cleaning Rumah',
      description: 'Jasa bersih-bersih rumah menyeluruh',
      price: 275000,
      originalPrice: 350000,
      category: 'Jasa',
      rating: 4.8,
      reviewCount: 445,
      storeName: 'Cleaning Pro',
      storeDistance: '1.4 km',
      imageUrl:
          'https://i.pinimg.com/736x/91/23/d1/9123d1fd0162848f5993cf577a97e056.jpg',
    ),
    Product(
      id: '149',
      name: 'Cuci Sofa',
      description: 'Jasa cuci sofa dengan teknologi modern',
      price: 185000,
      originalPrice: 240000,
      category: 'Jasa',
      rating: 4.9,
      reviewCount: 378,
      storeName: 'Cleaning Pro',
      storeDistance: '1.4 km',
      imageUrl:
          'https://i.pinimg.com/736x/c3/8c/b7/c38cb71d80afa9fa1edbe55c03bd4173.jpg',
    ),
    Product(
      id: '150',
      name: 'Cuci Karpet',
      description: 'Jasa cuci karpet bersih dan wangi',
      price: 35000,
      originalPrice: 50000,
      category: 'Jasa',
      rating: 4.7,
      reviewCount: 512,
      storeName: 'Cleaning Pro',
      storeDistance: '1.4 km',
      imageUrl:
          'https://i.pinimg.com/1200x/0b/4c/d6/0b4cd6fcfde48e5a1845789064f25650.jpg',
    ),
  ];

 // ============================================================
// SECTION 1: BASIC PRODUCT METHODS
// ============================================================

/// Get semua produk
List<Product> getAllProducts() {
  return _allProducts;
}

/// Get produk berdasarkan kategori
List<Product> getProductsByCategory(String category) {
  if (category == 'Semua') {
    return _allProducts;
  }
  return _allProducts.where((p) => p.category == category).toList();
}

/// Search produk berdasarkan query
List<Product> searchProducts(String query) {
  if (query.isEmpty) return _allProducts;
  return _allProducts
      .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
      .toList();
}

// ============================================================
// SECTION 2: FLASH SALE METHODS
// ============================================================

/// Get flash sale products (diskon >= 15%)
List<Product> getFlashSaleProducts() {
  final flashSale = _allProducts
      .where((p) => p.discountPercentage != null && p.discountPercentage! >= 15)
      .toList();

  // Jika kurang dari 8 produk, tambahkan produk dengan diskon lebih rendah
  if (flashSale.length < 8) {
    final otherDiscounted = _allProducts
        .where((p) => p.discountPercentage != null && p.discountPercentage! < 15)
        .toList();
    flashSale.addAll(otherDiscounted);
  }

  // Urutkan berdasarkan persentase diskon tertinggi
  flashSale.sort((a, b) => (b.discountPercentage ?? 0).compareTo(a.discountPercentage ?? 0));

  // Kembalikan maksimal 12 produk
  return flashSale.take(12).toList();
}

/// Get flash sale paketan (KHUSUS PAKET id >= 100)
List<Product> getFlashSalePaketan() {
  final paketan = _allProducts.where((p) {
    try {
      return int.parse(p.id) >= 100;
    } catch (e) {
      return false;
    }
  }).toList();

  // Urutkan berdasarkan persentase diskon tertinggi
  paketan.sort((a, b) => (b.discountPercentage ?? 0).compareTo(a.discountPercentage ?? 0));

  return paketan;
}

/// Get produk flash sale yang sedang aktif
List<Product> getActiveFlashSaleProducts() {
  final currentSale = FlashSaleService.getCurrentFlashSale();

  if (currentSale != null && currentSale.isActive) {
    return _allProducts
        .where((p) => currentSale.productIds.contains(p.id))
        .toList();
  }

  // Jika tidak ada flash sale aktif, tampilkan semua paket
  return getFlashSalePaketan();
}

/// Get harga produk (otomatis cek flash sale)
double getProductPrice(String productId) {
  final product = _allProducts.firstWhere(
    (p) => p.id == productId,
    orElse: () => _allProducts.first,
  );

  // Cek apakah sedang flash sale
  if (FlashSaleService.isProductOnFlashSale(productId)) {
    return FlashSaleService.calculateFlashPrice(
      productId,
      product.originalPrice ?? product.price,
    );
  }

  return product.price;
}

/// Get persentase diskon produk
double getProductDiscountPercentage(String productId) {
  final product = _allProducts.firstWhere(
    (p) => p.id == productId,
    orElse: () => _allProducts.first,
  );

  // Cek flash sale dulu
  final flashDiscount = FlashSaleService.getFlashDiscountPercentage(productId);
  if (flashDiscount != null) {
    return flashDiscount.toDouble();
  }

  return product.discountPercentage?.toDouble() ?? 0.0;
}

/// Get flash sale products yang tersedia di koperasi tertentu
List<Product> getFlashSaleProductsByKoperasi(List<String> allowedProductIds) {
  print('\n📦 [PRODUCT_SERVICE] ========== getFlashSaleProductsByKoperasi ==========');
  print('📥 [PRODUCT_SERVICE] Allowed product IDs: ${allowedProductIds.length}');
  
  final flashSaleProductIds = FlashSaleService.getFlashSaleProductsByKoperasi(
    allowedProductIds,
  );
  
  print('🔙 [PRODUCT_SERVICE] Got ${flashSaleProductIds.length} flash sale product IDs from service');
  
  if (flashSaleProductIds.isEmpty) {
    print('❌ [PRODUCT_SERVICE] No flash sale products in koperasi');
    print('========================================================\n');
    return [];
  }
  
  print('🔍 [PRODUCT_SERVICE] Looking up products in database...');
  final products = _allProducts
      .where((p) => flashSaleProductIds.contains(p.id))
      .toList();
  
  print('✅ [PRODUCT_SERVICE] Found ${products.length} products');
  
  if (products.isNotEmpty) {
    print('\n📋 [PRODUCT_SERVICE] Flash sale products details:');
    for (var p in products) {
      print('   - ID: ${p.id} | Name: ${p.name} | Price: ${p.price}');
    }
  } else {
    print('⚠️ [PRODUCT_SERVICE] Products not found in database!');
    print('   Flash sale IDs: ${flashSaleProductIds.join(", ")}');
  }
  
  print('========================================================\n');
  return products;
}


// ============================================================
// SECTION 3: PAKET/BUNDLE METHODS
// ============================================================

/// Get paketan berdasarkan kategori
List<Product> getPaketanByCategory(String category) {
  final paketan = _allProducts.where((p) {
    try {
      return int.parse(p.id) >= 100;
    } catch (e) {
      return false;
    }
  }).toList();

  if (category == 'Semua') {
    return paketan;
  }

  return paketan.where((p) => p.category == category).toList();
}

/// Get paket sembako
List<Product> getPaketSembako() {
  return _allProducts.where((p) {
    try {
      return int.parse(p.id) >= 100 &&
          p.name.toLowerCase().contains('paket sembako');
    } catch (e) {
      return false;
    }
  }).toList();
}

/// Get paket makanan
List<Product> getPaketMakanan() {
  return _allProducts.where((p) {
    try {
      return int.parse(p.id) >= 100 &&
          (p.name.toLowerCase().contains('paket lauk') ||
              p.name.toLowerCase().contains('paket snack') ||
              p.name.toLowerCase().contains('paket nasi') ||
              p.name.toLowerCase().contains('paket tumpeng'));
    } catch (e) {
      return false;
    }
  }).toList();
}

// ============================================================
// SECTION 4: FILTERED PRODUCT LISTS (FOR HOME SCREEN)
// ============================================================

List<Product> getTopRatedProducts({int? limit}) {
  final sorted = List<Product>.from(_allProducts);
  sorted.sort((a, b) => b.rating.compareTo(a.rating));
  return limit != null ? sorted.take(limit).toList() : sorted;
}

List<Product> getNewestProducts({int? limit}) {
  final sorted = List<Product>.from(_allProducts);
  sorted.sort((a, b) {
    try {
      return int.parse(b.id).compareTo(int.parse(a.id));
    } catch (e) {
      return b.id.compareTo(a.id);
    }
  });
  return limit != null ? sorted.take(limit).toList() : sorted;
}

/// Get produk segar (minuman, jelly, jamu, dll - BUKAN buah fisik)
/// ✅ FIXED: Semua rating bisa masuk, urut berdasarkan ID
List<Product> getFreshProducts() {
  print('\n🍹 [ProductService] ========== getFreshProducts START ==========');
  
  final freshCategories = ['Food', 'Grocery', 'Pertanian', 'Herbal'];

  final freshProducts = _allProducts
      .where((p) => freshCategories.contains(p.category))
      .toList();

  print('📦 [ProductService] Total produk di kategori segar: ${freshProducts.length}');

  final specificFresh = freshProducts.where((p) {
    final name = p.name.toLowerCase();
    
    // HANYA KEYWORD MATCHING (TIDAK PERLU MANUAL LIST!)
    final isMatch = name.contains('minuman') ||
        name.contains('es ') ||
        name.contains('teh') ||
        name.contains('madu') ||
        name.contains('sari') ||
        name.contains('jamu') ||
        name.contains('dawet') ||
        name.contains('wedang') ||
        name.contains('bandrek') ||
        name.contains('sirsak') ||
        name.contains('kelapa') ||
        name.contains('jelly') ||
        name.contains('kopyor') ||
        name.contains('uwuh') ||
        name.contains('jus') ||
        name.contains('cendol') ||
        name.contains('durian') ||
        name.contains('kacang ijo') ||
        name.contains('susu') || 
        name.contains('kopi') || 
        name.contains('smoothie');  
    
    if (isMatch) {
      print('   ✅ [KEYWORD MATCH] ID: ${p.id} | Name: ${p.name}');
    }
    
    return isMatch;
  }).toList();

  print('🎯 [ProductService] Produk segar terfilter: ${specificFresh.length}');

  // ⭐ SORTING: ID 71, 72, 73 di depan (MANUAL HIGH PRIORITY)
  specificFresh.sort((a, b) {
    final highPriorityIds = ['74', '75', '76'];
    
    if (highPriorityIds.contains(a.id) && !highPriorityIds.contains(b.id)) {
      return -1;
    }
    if (!highPriorityIds.contains(a.id) && highPriorityIds.contains(b.id)) {
      return 1;
    }
    
    try {
      return int.parse(a.id).compareTo(int.parse(b.id));
    } catch (e) {
      return a.id.compareTo(b.id);
    }
  });

  final result = specificFresh.toList();
  
  print('📋 [ProductService] Final result (8 produk):');
  for (var p in result) {
    print('   - ID: ${p.id} | ${p.name}');
  }
  print('========================================================\n');
  
  return result;
}

/// ✅ FIXED: Priority IDs (51-53) di depan, sisanya urut ID
/// Get buah & sayur (buah fisik + sayuran)
List<Product> getFruitAndVeggies() {
  print('\n🍎 [ProductService] ========== getFruitAndVeggies START ==========');
  
  // Filter produk buah & sayur berdasarkan nama
  final fruitVeggieProducts = _allProducts.where((p) {
    final name = p.name.toLowerCase();
    final id = p.id;
    
    // ⚠️ EXCLUDE produk minuman/jus/jelly meskipun ada nama buah
    final excludeKeywords = ['jus', 'minuman', 'jelly', 'es ', 'smoothie'];
    for (var keyword in excludeKeywords) {
      if (name.contains(keyword)) {
        print('   ❌ [EXCLUDED] ID: $id | Name: ${p.name} | Keyword: $keyword');
        return false;
      }
    }
    
    // List buah & sayur yang valid
    final fruitVeggieKeywords = [
      'sayur', 'buah', 'pisang', 'apel', 'tomat', 'cabai', 'bayam', 
      'brokoli', 'wortel', 'kentang', 'semangka', 'melon', 'strawberry', 
      'anggur', 'mangga', 'alpukat', 'jeruk', 'jambu', 'timun', 'salak', 
      'nanas', 'duku', 'srikaya', 'manggis', 'rambutan', 'pepaya', 
      'durian', 'lengkeng', 'belimbing', 'kangkung', 'kol', 'sawi', 
      'terong', 'naga', 'labu'
    ];
    
    final isMatch = fruitVeggieKeywords.any((keyword) => name.contains(keyword));
    
    if (isMatch) {
      print('   ✅ [INCLUDED] ID: $id | Name: ${p.name}');
    }
    
    return isMatch;
  }).toList();

  print('📦 [ProductService] Total produk Buah & Sayur: ${fruitVeggieProducts.length}');
  print('   ╔═════════╦═════════════════════════════════════╦═════════════╗');
  print('   ║   ID    ║             NAMA PRODUK              ║  KATEGORI   ║');
  print('   ╠═════════╬═════════════════════════════════════╬═════════════╣');
  for (var product in fruitVeggieProducts) {
    final idStr = product.id.padRight(7);
    final nameStr = product.name.length > 35 
        ? product.name.substring(0, 32) + '...' 
        : product.name.padRight(35);
    final categoryStr = product.category.padRight(11);
    print('   ║ $idStr ║ $nameStr ║ $categoryStr ║');
  }
  print('   ╚═════════╩═════════════════════════════════════╩═════════════╝');
  print('========================================================\n');

  // Kembalikan SEMUA produk tanpa sorting dan limit
  return fruitVeggieProducts;
}

// ============================================================
// SECTION 5: SPECIFIC CATEGORY FILTERS
// ============================================================

/// Get produk buah saja (tanpa sayuran)
/// ✅ Semua rating bisa masuk
List<Product> getFruitProducts() {
  return _allProducts.where((p) {
    final name = p.name.toLowerCase();
    return name.contains('pisang') ||
        name.contains('apel') ||
        name.contains('semangka') ||
        name.contains('melon') ||
        name.contains('mangga') ||
        name.contains('alpukat') ||
        name.contains('jeruk') ||
        name.contains('strawberry') ||
        name.contains('anggur') ||
        name.contains('timun') ||
        name.contains('salak') ||
        name.contains('nanas') ||
        name.contains('jambu') ||
        name.contains('duku') ||
        name.contains('srikaya') ||
        name.contains('manggis') ||
        name.contains('rambutan') ||
        name.contains('pepaya') ||
        name.contains('durian') ||
        name.contains('lengkeng') ||
        name.contains('belimbing');
  }).toList();
}

/// Get produk sayuran saja (tanpa buah)
/// ✅ Semua rating bisa masuk
List<Product> getVegetableProducts() {
  return _allProducts.where((p) {
    final name = p.name.toLowerCase();
    return name.contains('sayur') ||
        name.contains('tomat') ||
        name.contains('cabai') ||
        name.contains('bayam') ||
        name.contains('brokoli') ||
        name.contains('wortel') ||
        name.contains('kentang') ||
        name.contains('kangkung') ||
        name.contains('kol') ||
        name.contains('sawi') ||
        name.contains('terong') ||
        name.contains('labu');
  }).toList();
}

/// Get produk berdasarkan sub-kategori
/// ✅ Semua rating bisa masuk
List<Product> getProductsBySubCategory(String subCategoryName) {
  return _allProducts.where((p) {
    final name = p.name.toLowerCase();
    final subCatLower = subCategoryName.toLowerCase();

    // Sub-kategori "Buah"
    if (subCatLower == 'buah') {
      return name.contains('pisang') ||
          name.contains('apel') ||
          name.contains('tomat') ||
          name.contains('semangka') ||
          name.contains('melon') ||
          name.contains('mangga') ||
          name.contains('alpukat') ||
          name.contains('jeruk') ||
          name.contains('strawberry') ||
          name.contains('anggur') ||
          name.contains('timun') ||
          name.contains('salak') ||
          name.contains('nanas') ||
          name.contains('jambu') ||
          name.contains('duku') ||
          name.contains('srikaya') ||
          name.contains('manggis') ||
          name.contains('rambutan') ||
          name.contains('pepaya') ||
          name.contains('durian') ||
          name.contains('lengkeng') ||
          name.contains('belimbing');
    }
    
    // Sub-kategori "Sayuran Organik"
    else if (subCatLower == 'sayuran organik') {
      return name.contains('sayur') ||
          name.contains('tomat') ||
          name.contains('cabai') ||
          name.contains('bayam') ||
          name.contains('brokoli') ||
          name.contains('wortel') ||
          name.contains('kentang') ||
          name.contains('kangkung') ||
          name.contains('kol') ||
          name.contains('sawi') ||
          name.contains('terong') ||
          name.contains('labu');
    }
    
    // Sub-kategori lainnya
    else if (subCatLower == 'pupuk') {
      return name.contains('pupuk');
    } else if (subCatLower == 'bibit tanaman') {
      return name.contains('bibit');
    } else if (subCatLower == 'alat tani') {
      return name.contains('alat');
    }

    return false;
  }).toList();
}

// ============================================================
// SECTION 6: STORE METHODS
// ============================================================

/// Get stores berdasarkan kategori
List<Store> getStoresByCategory(String category) {
  if (category == 'Semua') {
    return _allStores;
  }
  return _allStores.where((s) => s.category == category).toList();
}

/// Get flagship store untuk kategori tertentu
Store? getFlagshipStore(String category) {
  if (category == 'Semua') return null;

  try {
    return _allStores.firstWhere(
      (s) => s.category == category && s.isFlagship,
    );
  } catch (e) {
    // Jika tidak ada flagship, ambil store pertama dari kategori
    final stores = getStoresByCategory(category);
    return stores.isNotEmpty ? stores.first : null;
  }
}

// ============================================================
// SECTION 7: SUB-CATEGORY METHODS
// ============================================================

/// Get sub-categories berdasarkan parent category
  List<SubCategory> getSubCategories(String parentCategory) {
    if (parentCategory == 'Semua') {
      return [];
    }
    return _subCategories
        .where((sc) => sc.parentCategory == parentCategory)
        .toList();
  }
}