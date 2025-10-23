class SubCategory {
  final String id;
  final String name;
  final String parentCategory;
  final String icon; // emoji or icon name

  SubCategory({
    required this.id,
    required this.name,
    required this.parentCategory,
    required this.icon,
  });
}