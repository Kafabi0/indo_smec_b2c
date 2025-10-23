class Store {
  final String id;
  final String name;
  final String category;
  final double distance;
  final String openHours;
  final double rating;
  final int reviewCount;
  final String? description;
  final bool isFlagship;

  Store({
    required this.id,
    required this.name,
    required this.category,
    required this.distance,
    required this.openHours,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.description,
    this.isFlagship = false,
  });

  String get distanceText => '${distance.toStringAsFixed(2)} km';
}
