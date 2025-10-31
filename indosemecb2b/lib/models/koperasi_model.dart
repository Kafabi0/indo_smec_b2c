class Koperasi {
  final String id;
  final String name;
  final String kelurahan;
  final String kecamatan;
  final String kota;
  final String provinsi;
  final double latitude;
  final double longitude;
  final String? description;
  final String? imageUrl;
  final String? phoneNumber;
  final String? email;
  final List<String> productIds; // ID produk yang dijual koperasi ini
  final double rating;
  final int memberCount; // Jumlah anggota UMKM

  Koperasi({
    required this.id,
    required this.name,
    required this.kelurahan,
    required this.kecamatan,
    required this.kota,
    this.provinsi = 'Jawa Barat',
    required this.latitude,
    required this.longitude,
    this.description,
    this.imageUrl,
    this.phoneNumber,
    this.email,
    required this.productIds,
    this.rating = 4.5,
    this.memberCount = 0,
  });

  // ============ HELPER METHODS ============

  // Cek apakah koperasi sesuai dengan lokasi user
  bool matchLocation({
    String? kelurahan,
    String? kecamatan,
    String? kota,
  }) {
    // Priority 1: Kelurahan (paling spesifik)
    if (kelurahan != null && 
        this.kelurahan.toLowerCase().contains(kelurahan.toLowerCase())) {
      return true;
    }
    
    // Priority 2: Kecamatan
    if (kecamatan != null && 
        this.kecamatan.toLowerCase().contains(kecamatan.toLowerCase())) {
      return true;
    }
    
    // Priority 3: Kota
    if (kota != null && 
        this.kota.toLowerCase().contains(kota.toLowerCase())) {
      return true;
    }
    
    return false;
  }

  // Alamat lengkap untuk ditampilkan
  String get fullAddress => '$kelurahan, $kecamatan, $kota, $provinsi';

  // Alamat singkat (tanpa provinsi)
  String get shortAddress => '$kelurahan, $kecamatan, $kota';

  // Info singkat untuk card
  String get info => '$memberCount UMKM • ${productIds.length} produk';

  // Convert ke Map (untuk save ke database/shared preferences)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'kelurahan': kelurahan,
      'kecamatan': kecamatan,
      'kota': kota,
      'provinsi': provinsi,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'imageUrl': imageUrl,
      'phoneNumber': phoneNumber,
      'email': email,
      'productIds': productIds,
      'rating': rating,
      'memberCount': memberCount,
    };
  }

  // Create dari Map
  factory Koperasi.fromMap(Map<String, dynamic> map) {
    return Koperasi(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      kelurahan: map['kelurahan'] ?? '',
      kecamatan: map['kecamatan'] ?? '',
      kota: map['kota'] ?? '',
      provinsi: map['provinsi'] ?? 'Jawa Barat',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      description: map['description'],
      imageUrl: map['imageUrl'],
      phoneNumber: map['phoneNumber'],
      email: map['email'],
      productIds: List<String>.from(map['productIds'] ?? []),
      rating: map['rating']?.toDouble() ?? 4.5,
      memberCount: map['memberCount']?.toInt() ?? 0,
    );
  }

  // Copy with (untuk update data)
  Koperasi copyWith({
    String? id,
    String? name,
    String? kelurahan,
    String? kecamatan,
    String? kota,
    String? provinsi,
    double? latitude,
    double? longitude,
    String? description,
    String? imageUrl,
    String? phoneNumber,
    String? email,
    List<String>? productIds,
    double? rating,
    int? memberCount,
  }) {
    return Koperasi(
      id: id ?? this.id,
      name: name ?? this.name,
      kelurahan: kelurahan ?? this.kelurahan,
      kecamatan: kecamatan ?? this.kecamatan,
      kota: kota ?? this.kota,
      provinsi: provinsi ?? this.provinsi,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      productIds: productIds ?? this.productIds,
      rating: rating ?? this.rating,
      memberCount: memberCount ?? this.memberCount,
    );
  }

  @override
  String toString() {
    return 'Koperasi{id: $id, name: $name, location: $shortAddress}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Koperasi && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}