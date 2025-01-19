class Category {
  final String id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromFirestore(Map<String, dynamic> data, String docId) {
    return Category(
      id: docId,
      name: data['name'] as String,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
    };
  }
}
