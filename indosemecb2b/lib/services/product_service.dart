import '../models/product_model.dart';
import '../models/store_model.dart';
import '../models/subcategory_model.dart';

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
    SubCategory(id: 'f2', name: 'Snack & Jajanan', parentCategory: 'Food', icon: '🍪'),
    SubCategory(id: 'f3', name: 'Minuman', parentCategory: 'Food', icon: '🥤'),
    SubCategory(id: 'f4', name: 'Lauk Pauk', parentCategory: 'Food', icon: '🍗'),
    SubCategory(id: 'f5', name: 'Dessert', parentCategory: 'Food', icon: '🍰'),
    
    // GROCERY SUB-CATEGORIES
    SubCategory(id: 'g1', name: 'Beras & Tepung', parentCategory: 'Grocery', icon: '🌾'),
    SubCategory(id: 'g2', name: 'Bumbu Dapur', parentCategory: 'Grocery', icon: '🧂'),
    SubCategory(id: 'g3', name: 'Minyak Goreng', parentCategory: 'Grocery', icon: '🛢️'),
    SubCategory(id: 'g4', name: 'Telur & Susu', parentCategory: 'Grocery', icon: '🥚'),
    SubCategory(id: 'g5', name: 'Mie Instan', parentCategory: 'Grocery', icon: '🍜'),
    
    // FASHION SUB-CATEGORIES
    SubCategory(id: 'fa1', name: 'Batik', parentCategory: 'Fashion', icon: '👔'),
    SubCategory(id: 'fa2', name: 'Hijab', parentCategory: 'Fashion', icon: '🧕'),
    SubCategory(id: 'fa3', name: 'Kaos & Kemeja', parentCategory: 'Fashion', icon: '👕'),
    SubCategory(id: 'fa4', name: 'Celana', parentCategory: 'Fashion', icon: '👖'),
    SubCategory(id: 'fa5', name: 'Dress', parentCategory: 'Fashion', icon: '👗'),
    
    // HERBAL SUB-CATEGORIES
    SubCategory(id: 'h1', name: 'Jamu Tradisional', parentCategory: 'Herbal', icon: '🍵'),
    SubCategory(id: 'h2', name: 'Madu', parentCategory: 'Herbal', icon: '🍯'),
    SubCategory(id: 'h3', name: 'Minuman Herbal', parentCategory: 'Herbal', icon: '☕'),
    SubCategory(id: 'h4', name: 'Rempah', parentCategory: 'Herbal', icon: '🌿'),
    
    // KERAJINAN SUB-CATEGORIES
    SubCategory(id: 'k1', name: 'Anyaman', parentCategory: 'Kerajinan', icon: '🧺'),
    SubCategory(id: 'k2', name: 'Ukiran Kayu', parentCategory: 'Kerajinan', icon: '🪵'),
    SubCategory(id: 'k3', name: 'Souvenir', parentCategory: 'Kerajinan', icon: '🎁'),
    SubCategory(id: 'k4', name: 'Dekorasi', parentCategory: 'Kerajinan', icon: '🖼️'),
    
    // PERTANIAN SUB-CATEGORIES
    SubCategory(id: 'p1', name: 'Pupuk', parentCategory: 'Pertanian', icon: '🌱'),
    SubCategory(id: 'p2', name: 'Bibit Tanaman', parentCategory: 'Pertanian', icon: '🌾'),
    SubCategory(id: 'p3', name: 'Sayuran Organik', parentCategory: 'Pertanian', icon: '🥬'),
    SubCategory(id: 'p4', name: 'Buah', parentCategory: 'Pertanian', icon: '🍎'),
    SubCategory(id: 'p5', name: 'Alat Tani', parentCategory: 'Pertanian', icon: '🚜'),
    
    // KREATIF SUB-CATEGORIES
    SubCategory(id: 'kr1', name: 'Alat Lukis', parentCategory: 'Kreatif', icon: '🎨'),
    SubCategory(id: 'kr2', name: 'Buku Sketsa', parentCategory: 'Kreatif', icon: '📓'),
    SubCategory(id: 'kr3', name: 'Clay & Polymer', parentCategory: 'Kreatif', icon: '🧱'),
    SubCategory(id: 'kr4', name: 'Craft Tools', parentCategory: 'Kreatif', icon: '✂️'),
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
    ),
    Product(
      id: '5',
      name: 'Y!Choice Dimsum Ayam Bawang 2\'S',
      description: '2 pcs Dimsum ayam dengan daun bawang segar',
      price: 10000,
      originalPrice: 12000,
      category: 'Food',
      rating: 4.8,
      reviewCount: 195,
      storeName: 'Dimsum House',
      storeDistance: '1.5 km',
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
    ),
    Product(
      id: '7',
      name: 'Y!Choice Mochi Matsu Saji',
      description: 'Mochi Jepang dengan isian pasta kacang merah',
      price: 23000,
      originalPrice: 28000,
      category: 'Food',
      rating: 4.9,
      reviewCount: 310,
      storeName: 'Japan Snack',
      storeDistance: '1.8 km',
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
    ),
    
    // ============ TAMBAHAN PRODUK SEGAR (MINUMAN, JELLY, PRODUK UMKM INDONESIA) ============
    Product(
      id: '33',
      name: 'Es Teh Manis Botolan 500ml',
      description: 'Es teh manis khas Indonesia dalam kemasan botol',
      price: 7000,
      originalPrice: 10000,
      category: 'Food',
      rating: 4.7,
      reviewCount: 425,
      storeName: 'Warung Pak Budi',
      storeDistance: '0.5 km',
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
    ),
    Product(
      id: '39',
      name: 'Es Kelapa Muda',
      description: 'Es kelapa muda segar dengan susu',
      price: 15000,
      originalPrice: 18000,
      category: 'Food',
      rating: 4.9,
      reviewCount: 345,
      storeName: 'Tropical Drink',
      storeDistance: '0.8 km',
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
    ),
    Product(
      id: '51',
      name: 'Semangka 1buah',
      description: 'Semangka merah segar dan manis',
      price: 20000,
      originalPrice: 25000,
      category: 'Pertanian',
      rating: 4.7,
      reviewCount: 267,
      storeName: 'Kebun Segar',
      storeDistance: '2.1 km',
    ),
    Product(
      id: '52',
      name: 'Melon 1buah',
      description: 'Melon hijau segar dan manis',
      price: 18000,
      originalPrice: 22000,
      category: 'Pertanian',
      rating: 4.8,
      reviewCount: 298,
      storeName: 'Kebun Segar',
      storeDistance: '2.1 km',
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
    ),
  ];

  // ============ METHOD UNTUK GET DATA ============

  // Get semua produk
  List<Product> getAllProducts() {
    return _allProducts;
  }

  // Get produk by kategori
  List<Product> getProductsByCategory(String category) {
    if (category == 'Semua') {
      return _allProducts;
    }
    return _allProducts.where((p) => p.category == category).toList();
  }

  // Get flash sale products (diskon >= 15%)
  List<Product> getFlashSaleProducts() {
    final flashSale = _allProducts.where((p) => 
        p.discountPercentage != null && p.discountPercentage! >= 15).toList();
    
    // Jika kurang dari 8 produk, tambahkan produk dengan diskon lebih rendah
    if (flashSale.length < 8) {
      final otherDiscounted = _allProducts.where((p) => 
          p.discountPercentage != null && p.discountPercentage! < 15).toList();
      flashSale.addAll(otherDiscounted);
    }
    
    // Urutkan berdasarkan persentase diskon tertinggi
    flashSale.sort((a, b) => 
        (b.discountPercentage ?? 0).compareTo(a.discountPercentage ?? 0));
    
    // Kembalikan maksimal 12 produk
    return flashSale.take(12).toList();
  }

  // Get produk dengan rating tinggi
  List<Product> getTopRatedProducts() {
    final sorted = List<Product>.from(_allProducts);
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(8).toList();
  }

  // Get produk terbaru (berdasarkan ID terbesar)
  List<Product> getNewestProducts() {
    final sorted = List<Product>.from(_allProducts);
    sorted.sort((a, b) => b.id.compareTo(a.id));
    return sorted.take(8).toList();
  }

  // Get produk segar (dari kategori Food, Grocery, Pertanian, Herbal)
  List<Product> getFreshProducts() {
    final freshCategories = ['Food', 'Grocery', 'Pertanian', 'Herbal'];
    
    // Filter produk segar berdasarkan kategori
    final freshProducts = _allProducts.where((p) => 
        freshCategories.contains(p.category)).toList();
    
    // Filter khusus untuk produk segar (minuman, jelly, dll)
    final specificFresh = freshProducts.where((p) {
      final name = p.name.toLowerCase();
      return name.contains('minuman') || 
             name.contains('es') || 
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
             name.contains('kacang ijo');
    }).toList();
    
    // Urutkan berdasarkan rating tertinggi
    specificFresh.sort((a, b) => b.rating.compareTo(a.rating));
    
    // Kembalikan maksimal 8 produk
    return specificFresh.take(8).toList();
  }

  // Get buah & sayur (dari kategori Pertanian & Grocery)
  List<Product> getFruitAndVeggies() {
    // Filter produk yang kemungkinan adalah buah & sayur berdasarkan nama
    final fruitVeggieProducts = _allProducts.where((p) {
      final name = p.name.toLowerCase();
      return name.contains('sayur') || 
             name.contains('buah') || 
             name.contains('pisang') ||
             name.contains('apel') ||
             name.contains('tomat') ||
             name.contains('cabai') ||
             name.contains('bayam') ||
             name.contains('brokoli') ||
             name.contains('wortel') ||
             name.contains('kentang') ||
             name.contains('semangka') ||
             name.contains('melon') ||
             name.contains('strawberry') ||
             name.contains('anggur') ||
             name.contains('mangga') ||
             name.contains('alpukat') ||
             name.contains('jeruk') ||
             name.contains('timun');
    }).toList();
    
    // Urutkan berdasarkan rating tertinggi
    fruitVeggieProducts.sort((a, b) => b.rating.compareTo(a.rating));
    
    // Kembalikan maksimal 8 produk
    return fruitVeggieProducts.take(8).toList();
  }

  // Get produk buah saja
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
             name.contains('rambutan');
    }).toList();
  }

  // Get produk sayuran saja
  List<Product> getVegetableProducts() {
    return _allProducts.where((p) {
      final name = p.name.toLowerCase();
      return name.contains('sayur') || 
             name.contains('tomat') ||
             name.contains('cabai') ||
             name.contains('bayam') ||
             name.contains('brokoli') ||
             name.contains('wortel') ||
             name.contains('kentang');
    }).toList();
  }

  // Get produk berdasarkan sub-kategori
  List<Product> getProductsBySubCategory(String subCategoryName) {
    // Filter produk berdasarkan nama sub-kategori
    return _allProducts.where((p) {
      final name = p.name.toLowerCase();
      
      // Untuk sub-kategori "Buah"
      if (subCategoryName.toLowerCase() == 'buah') {
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
               name.contains('rambutan');
      }
      
      // Untuk sub-kategori "Sayuran Organik"
      else if (subCategoryName.toLowerCase() == 'sayuran organik') {
        return name.contains('sayur') || 
               name.contains('tomat') ||
               name.contains('cabai') ||
               name.contains('bayam') ||
               name.contains('brokoli') ||
               name.contains('wortel') ||
               name.contains('kentang');
      }
      
      // Untuk sub-kategori lainnya
      else if (subCategoryName.toLowerCase() == 'pupuk') {
        return name.contains('pupuk');
      }
      else if (subCategoryName.toLowerCase() == 'bibit tanaman') {
        return name.contains('bibit');
      }
      else if (subCategoryName.toLowerCase() == 'alat tani') {
        return name.contains('alat');
      }
      
      return false;
    }).toList();
  }

  // ============ STORE METHODS ============

  // Get stores by category
  List<Store> getStoresByCategory(String category) {
    if (category == 'Semua') {
      return _allStores;
    }
    return _allStores.where((s) => s.category == category).toList();
  }

  // Get flagship store for category
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

  // ============ SUB-CATEGORY METHODS ============

  // Get sub-categories by parent category
  List<SubCategory> getSubCategories(String parentCategory) {
    if (parentCategory == 'Semua') {
      return [];
    }
    return _subCategories.where((sc) => sc.parentCategory == parentCategory).toList();
  }

  // Search produk
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _allProducts;
    
    return _allProducts
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}