import '../services/enhanced_database_service.dart';

class EnhancedProduct {
  final int? id;
  final String name;
  final String category;
  final List<String> tags;
  final double buyPrice;
  final double sellPrice;
  final String size;
  final String color;
  final String material;
  final int stockQuantity;
  final int minStockLevel;
  final String? barcode;
  final String? description;
  final List<String> imagePaths;
  final DateTime? createdDate;
  final DateTime? updatedDate;

  EnhancedProduct({
    this.id,
    required this.name,
    required this.category,
    this.tags = const [],
    required this.buyPrice,
    required this.sellPrice,
    required this.size,
    required this.color,
    required this.material,
    this.stockQuantity = 0,
    this.minStockLevel = 5,
    this.barcode,
    this.description,
    this.imagePaths = const [],
    this.createdDate,
    this.updatedDate,
  });

  // Calculate profit margin
  double get profitMargin => sellPrice > 0 ? ((sellPrice - buyPrice) / sellPrice) * 100 : 0;
  
  // Calculate profit amount
  double get profitAmount => sellPrice - buyPrice;
  
  // Check if stock is low
  bool get isLowStock => stockQuantity <= minStockLevel;
  
  // Check if product is profitable
  bool get isProfitable => sellPrice > buyPrice;

  factory EnhancedProduct.fromMap(Map<String, dynamic> map) {
    return EnhancedProduct(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      tags: map['tags'] != null ? (map['tags'] as String).split(',').map((e) => e.trim()).toList() : [],
      buyPrice: (map['buy_price'] as num).toDouble(),
      sellPrice: (map['sell_price'] as num).toDouble(),
      size: map['size'],
      color: map['color'],
      material: map['material'],
      stockQuantity: map['stock_quantity'] ?? 0,
      minStockLevel: map['min_stock_level'] ?? 5,
      barcode: map['barcode'],
      description: map['description'],
      imagePaths: map['image_paths'] != null ? (map['image_paths'] as String).split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() : [],
      createdDate: map['created_date'] != null ? DateTime.tryParse(map['created_date']) : null,
      updatedDate: map['updated_date'] != null ? DateTime.tryParse(map['updated_date']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'tags': tags.join(','),
      'buy_price': buyPrice,
      'sell_price': sellPrice,
      'size': size,
      'color': color,
      'material': material,
      'stock_quantity': stockQuantity,
      'min_stock_level': minStockLevel,
      'barcode': barcode,
      'description': description,
      'image_paths': imagePaths.join(','),
      'created_date': createdDate?.toIso8601String(),
      'updated_date': updatedDate?.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  EnhancedProduct copyWith({
    int? id,
    String? name,
    String? category,
    List<String>? tags,
    double? buyPrice,
    double? sellPrice,
    String? size,
    String? color,
    String? material,
    int? stockQuantity,
    int? minStockLevel,
    String? barcode,
    String? description,
    List<String>? imagePaths,
    DateTime? createdDate,
    DateTime? updatedDate,
  }) {
    return EnhancedProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      size: size ?? this.size,
      color: color ?? this.color,
      material: material ?? this.material,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      barcode: barcode ?? this.barcode,
      description: description ?? this.description,
      imagePaths: imagePaths ?? this.imagePaths,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }

  @override
  String toString() {
    return 'EnhancedProduct{id: $id, name: $name, category: $category, sellPrice: $sellPrice}';
  }
}

// Product form data class for the add product dialog
class ProductFormData {
  String name = '';
  String category = '';
  List<String> tags = [];
  double buyPrice = 0.0;
  double sellPrice = 0.0;
  String size = '';
  String color = '';
  String material = '';
  int stockQuantity = 0;
  int minStockLevel = 5;
  String barcode = '';
  String description = '';
  List<String> imagePaths = [];

  bool get isValid {
    return name.isNotEmpty &&
           category.isNotEmpty &&
           buyPrice > 0 &&
           sellPrice > 0 &&
           sellPrice > buyPrice &&
           size.isNotEmpty &&
           color.isNotEmpty &&
           material.isNotEmpty;
  }

  String get validationError {
    if (name.isEmpty) return 'اسم المنتج مطلوب';
    if (category.isEmpty) return 'فئة المنتج مطلوبة';
    if (buyPrice <= 0) return 'سعر الشراء يجب أن يكون أكبر من صفر';
    if (sellPrice <= 0) return 'سعر البيع يجب أن يكون أكبر من صفر';
    if (sellPrice <= buyPrice) return 'سعر البيع يجب أن يكون أكبر من سعر الشراء';
    if (size.isEmpty) return 'المقاس مطلوب';
    if (color.isEmpty) return 'اللون مطلوب';
    if (material.isEmpty) return 'المادة مطلوبة';
    return '';
  }

  EnhancedProduct toProduct() {
    return EnhancedProduct(
      name: name,
      category: category,
      tags: tags,
      buyPrice: buyPrice,
      sellPrice: sellPrice,
      size: size,
      color: color,
      material: material,
      stockQuantity: stockQuantity,
      minStockLevel: minStockLevel,
      barcode: barcode.isEmpty ? null : barcode,
      description: description.isEmpty ? null : description,
      imagePaths: imagePaths,
      createdDate: DateTime.now(),
      updatedDate: DateTime.now(),
    );
  }
}
