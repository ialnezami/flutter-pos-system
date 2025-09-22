class Category {
  final int? id;
  final String name;
  final String? description;
  final String? icon;
  final String? color;
  final DateTime? createdDate;
  final DateTime? updatedDate;

  Category({
    this.id,
    required this.name,
    this.description,
    this.icon,
    this.color,
    this.createdDate,
    this.updatedDate,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      icon: map['icon'],
      color: map['color'],
      createdDate: map['created_date'] != null ? DateTime.tryParse(map['created_date']) : null,
      updatedDate: map['updated_date'] != null ? DateTime.tryParse(map['updated_date']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'created_date': createdDate?.toIso8601String(),
      'updated_date': updatedDate?.toIso8601String(),
    };
  }

  Category copyWith({
    int? id,
    String? name,
    String? description,
    String? icon,
    String? color,
    DateTime? createdDate,
    DateTime? updatedDate,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }

  @override
  String toString() {
    return 'Category{id: $id, name: $name}';
  }
}
