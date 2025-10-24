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
      imageUrl:'https://img-global.cpcdn.com/recipes/2d6b62a61e9bb969/680x482cq70/nasi-goreng-hongkong-foto-resep-utama.jpg'
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
      'https://drivethru.klikindomaret.com/t69e/wp-content/uploads/sites/58/2020/09/nasi.jpg'
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
      imageUrl: 'https://drivethru.klikindomaret.com/t69e/wp-content/uploads/sites/58/2024/03/20096377_1-745x1024.jpg'
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
      imageUrl: 'https://assets.klikindomaret.com/products/20115652/20115652_1.jpg'
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
      imageUrl: 'https://assets.klikindomaret.com/products/20122942/20122942_thumb.jpg?Version.20.03.1.01'
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
      imageUrl: 'https://awsimages.detik.net.id/community/media/visual/2021/12/07/resep-sate-ayam-pedas_43.jpeg?w=480'
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
      imageUrl: 'https://drivethru.klikindomaret.com/t69e/wp-content/uploads/sites/58/2022/11/WhatsApp-Image-2022-11-04-at-16.47.13.jpeg'
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
      imageUrl: 'https://assets.klikindomaret.com/products/20103568/20103568_thumb.jpg?Version.20.03.1.01'
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
      imageUrl: 'https://cdn-klik.klikindomaret.com/klik-catalog/product/20002897_1.jpg'
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
      imageUrl: 'https://img.lazcdn.com/g/p/5a20b25510c6741f4b12a9607e3a2905.jpg_720x720q80.jpg'
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
      imageUrl: 'https://cdn-klik.klikindomaret.com/klik-catalog/product/20042991_1.jpg'
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
      imageUrl: 'https://cdn-klik.klikindomaret.com/klik-catalog/product/20024079_1.jpg'
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
      imageUrl: 'https://cdn-klik.klikindomaret.com/klik-catalog/product/20134320_1.jpg'
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
      imageUrl: 'https://down-id.img.susercontent.com/file/id-11134207-7r98x-lvic6q9m6095fc'
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
      imageUrl: 'https://i.pinimg.com/1200x/89/49/43/89494308b3d6d38cf728ec1b6e24e798.jpg'
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
      imageUrl: 'https://i.pinimg.com/1200x/7a/26/c9/7a26c999cfcd9a931c83237c22e8f96b.jpg'
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
      imageUrl: 'https://i.pinimg.com/736x/83/63/55/83635564a2b3880593033e875a7ee6cd.jpg'
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
      imageUrl: 'https://i.pinimg.com/736x/95/15/75/951575bf612a50d8a7632860215387ba.jpg'
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
      imageUrl: 'https://i.pinimg.com/736x/08/c8/9d/08c89d1c2f9b4bebbcfe079fd31d49a5.jpg'
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
      imageUrl: 'https://i.pinimg.com/736x/f9/bf/d6/f9bfd638c69ebdbeff6d236a6072b37b.jpg'
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
      imageUrl: 'https://i.pinimg.com/736x/aa/4c/e5/aa4ce5f447925e72362b0a6c9a6db65b.jpg'
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
      imageUrl: 'https://down-id.img.susercontent.com/file/40714140dc961d5ca9ca2444f1be0612'
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
      imageUrl: 'https://tse2.mm.bing.net/th/id/OIP.xuIGr5AFt6EeCaa_8mnX2gHaHa?rs=1&pid=ImgDetMain&o=7&rm=3'
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
      imageUrl: 'https://i.pinimg.com/736x/db/17/cc/db17ccbb78756c6f0cda1d11a40ef30e.jpg'
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
      imageUrl: 'https://i.pinimg.com/736x/5d/11/d0/5d11d0db5f0ea31b0e00077916e9e09f.jpg'
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
      imageUrl: 'https://i.pinimg.com/736x/2b/d6/72/2bd67264b0b81133eb7ff08895fb398b.jpg'
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
      imageUrl: 'https://i.pinimg.com/736x/23/c8/d4/23c8d4917eba6bd108d13dcadcab3ccc.jpg'
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
      imageUrl: 'https://i.pinimg.com/1200x/6a/e4/4f/6ae44f8829716b4bfbfddf3dcc5ca3ca.jpg'
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
      imageUrl: 'https://i.pinimg.com/1200x/e6/e1/19/e6e119960061eec773d9e0f573929d33.jpg'
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
      imageUrl: 'https://i.pinimg.com/736x/f2/ec/d7/f2ecd776d62afb556f7b8277f77d3ee0.jpg'
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
      imageUrl: 'https://i.pinimg.com/736x/6c/3f/5c/6c3f5c3efc8a11ad2ce76ad60e536069.jpg'

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
      imageUrl: 'https://i.pinimg.com/1200x/d2/73/8e/d2738eceae9feb07c53076a922bd1644.jpg'
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
      imageUrl: 'https://i.pinimg.com/736x/63/30/04/633004a76c6f03ab9665d8cce7dade47.jpg'
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
      imageUrl: 'https://i.pinimg.com/736x/85/58/a5/8558a5cc58e0e57707635793b32e9279.jpg'
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
      imageUrl: 'https://img.freepik.com/premium-photo/es-dawet-hitam-cendol-hitam-is-indonesia-traditional-iced-dessert-from-purworejo_581937-5126.jpg'
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
      imageUrl: 'https://tse2.mm.bing.net/th/id/OIP.JtMOAoE1KvaYFqqANYJeRwHaHa?rs=1&pid=ImgDetMain&o=7&rm=3'
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
      imageUrl: 'https://i.pinimg.com/736x/6a/5a/df/6a5adf9ad625176e415f49822ae7b924.jpg'
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
      imageUrl: 'https://i.pinimg.com/736x/61/47/0f/61470f214ef15ab5fc4008a0e7c1a749.jpg'
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
      imageUrl: 'https://i.pinimg.com/736x/43/3d/28/433d28c07a9b05f671d3710a90804934.jpg'
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
      imageUrl: 'https://i.pinimg.com/1200x/ae/78/f0/ae78f05040e740cc24887f84c3f5ed39.jpg'
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
      imageUrl: 'https://i.pinimg.com/1200x/bf/f5/02/bff502e79673602b6d93271c46583676.jpg'
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
      imageUrl: 'https://i.pinimg.com/1200x/69/72/c1/6972c17a5b9b8de373b26e1c61461c97.jpg'
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
      imageUrl: 'https://i.pinimg.com/736x/ab/0d/f7/ab0df7146af3fe5c29d1513cdaf9b97e.jpg'
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
      imageUrl: 'https://i.pinimg.com/736x/c1/8e/70/c18e709489f143a9b12152ab4ab2cc29.jpg'
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
      imageUrl: 'https://i.pinimg.com/1200x/89/94/cc/8994cc72eb45158a30c06d4774230ded.jpg'
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
      imageUrl: 'https://i.pinimg.com/1200x/16/ee/49/16ee497d374644223ccd26a1493c794b.jpg'
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
      imageUrl: 'https://i.pinimg.com/1200x/67/d7/fc/67d7fc8e8c788fd50b96cc650d24bfb9.jpg'
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
      imageUrl: 'https://i.pinimg.com/1200x/90/14/0a/90140a4f0056916e38b7c3020772416f.jpg'
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
      imageUrl: 'https://i.pinimg.com/1200x/e5/a0/95/e5a095d73452f84ee2dd563a9b56d2f7.jpg'
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
      imageUrl: 'https://i.pinimg.com/1200x/9c/68/6e/9c686ec6d33e9d264bf392c072371b89.jpg'
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
      imageUrl: 'https://i.pinimg.com/1200x/57/2e/44/572e446e7ecd1261d1973b7e11f1d622.jpg'
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
      imageUrl: 'https://i.pinimg.com/736x/05/1e/f7/051ef76a110dfd40de4aef4e601c3040.jpg'
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
      imageUrl: 'https://i.pinimg.com/736x/38/5a/1a/385a1a57260b175ffc75b32a4da62234.jpg'
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
      imageUrl: 'https://i.pinimg.com/1200x/02/ce/2f/02ce2feb0755beed215dac5f6187b7c0.jpg'
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
      imageUrl: 'https://i.pinimg.com/736x/fd/2f/75/fd2f7532157da5c6519aa76d938d17bc.jpg'
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
      imageUrl: 'https://i.pinimg.com/1200x/91/c2/d5/91c2d5cb35f8db6bd9ab3cadcb2e65a3.jpg'
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
      imageUrl: 'https://i.pinimg.com/1200x/82/b7/29/82b729fb22b9e2fd02a08d995c1ffbd7.jpg'
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
      imageUrl: 'https://i.pinimg.com/736x/8f/f4/f0/8ff4f0b8413c8e3ef42a200f43492a77.jpg'
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
      imageUrl: 'https://i.pinimg.com/1200x/70/f0/cc/70f0cc60b42372f96ff52242cf29710b.jpg'
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
      imageUrl: 'https://i.pinimg.com/736x/5a/3d/2f/5a3d2fb75acdd8aabe60ae134a357136.jpg'
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
      imageUrl: 'https://i.pinimg.com/1200x/64/2e/b8/642eb823cc55b56c8e0f611277d850a3.jpg'
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
      imageUrl: 'https://i.pinimg.com/1200x/5d/aa/71/5daa71ea3e755354e00cdacd26d60bbd.jpg'
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
      imageUrl: 'https://i.pinimg.com/736x/2c/91/5f/2c915f71906c55242fa4819403e888d0.jpg'
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
      imageUrl: 'https://i.pinimg.com/736x/1f/98/1a/1f981a87a0ecd3ef4d321e52400458af.jpg'
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
      imageUrl: 'https://i.pinimg.com/736x/2b/20/70/2b207008e715f68d55f9a913cda6799d.jpg'
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
      imageUrl: 'https://i.pinimg.com/736x/57/81/50/578150b5f0e41fea90ab992c2e971533.jpg'
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
      imageUrl: 'https://i.pinimg.com/1200x/96/e9/b6/96e9b6b277e3abc05ed03d92c7d41b1e.jpg'
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
      imageUrl: 'https://i.pinimg.com/736x/5c/79/5a/5c795af37a63ed75f733d5543dfd64c9.jpg'
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
    final flashSale =
        _allProducts
            .where(
              (p) =>
                  p.discountPercentage != null && p.discountPercentage! >= 15,
            )
            .toList();

    // Jika kurang dari 8 produk, tambahkan produk dengan diskon lebih rendah
    if (flashSale.length < 8) {
      final otherDiscounted =
          _allProducts
              .where(
                (p) =>
                    p.discountPercentage != null && p.discountPercentage! < 15,
              )
              .toList();
      flashSale.addAll(otherDiscounted);
    }

    // Urutkan berdasarkan persentase diskon tertinggi
    flashSale.sort(
      (a, b) =>
          (b.discountPercentage ?? 0).compareTo(a.discountPercentage ?? 0),
    );

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
    final freshProducts =
        _allProducts
            .where((p) => freshCategories.contains(p.category))
            .toList();

    // Filter khusus untuk produk segar (minuman, jelly, dll)
    final specificFresh =
        freshProducts.where((p) {
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
    final fruitVeggieProducts =
        _allProducts.where((p) {
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
      } else if (subCategoryName.toLowerCase() == 'bibit tanaman') {
        return name.contains('bibit');
      } else if (subCategoryName.toLowerCase() == 'alat tani') {
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
    return _subCategories
        .where((sc) => sc.parentCategory == parentCategory)
        .toList();
  }

  // Search produk
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _allProducts;

    return _allProducts
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
