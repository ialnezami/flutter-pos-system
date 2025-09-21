import 'package:flutter/foundation.dart';

class ProductVariant extends ChangeNotifier {
  /// Unique identifier for the variant
  final String id;
  
  /// Parent product ID
  final String productId;
  
  /// Size (e.g., XS, S, M, L, XL, 32, 34, 36)
  final String size;
  
  /// Color name (e.g., Red, Blue, Black, White)
  final String color;
  
  /// Color hex code for display
  final String? colorHex;
  
  /// Style variation (e.g., Slim Fit, Regular, Loose)
  final String style;
  
  /// Stock Keeping Unit - unique identifier for inventory
  final String sku;
  
  /// Barcode for scanning
  final String? barcode;
  
  /// Current stock quantity
  int _stockQuantity;
  
  /// Price adjustment from base product price (can be negative)
  final num priceAdjustment;
  
  /// Image URL specific to this variant
  final String? imageUrl;
  
  /// Whether this variant is active/available for sale
  bool _isActive;
  
  /// Minimum stock level for reorder alerts
  final int reorderLevel;
  
  /// Maximum stock level
  final int? maxStockLevel;
  
  /// Weight in grams (for shipping calculations)
  final double? weight;
  
  /// Dimensions for shipping
  final Map<String, double>? dimensions;
  
  /// When this variant was created
  final DateTime createdAt;
  
  /// When this variant was last updated
  DateTime updatedAt;

  ProductVariant({
    required this.id,
    required this.productId,
    required this.size,
    required this.color,
    this.colorHex,
    this.style = '',
    required this.sku,
    this.barcode,
    int stockQuantity = 0,
    this.priceAdjustment = 0,
    this.imageUrl,
    bool isActive = true,
    this.reorderLevel = 5,
    this.maxStockLevel,
    this.weight,
    this.dimensions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    _stockQuantity = stockQuantity,
    _isActive = isActive,
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  /// Current stock quantity
  int get stockQuantity => _stockQuantity;
  
  /// Set stock quantity and notify listeners
  set stockQuantity(int value) {
    if (_stockQuantity != value) {
      _stockQuantity = value;
      updatedAt = DateTime.now();
      notifyListeners();
    }
  }

  /// Whether variant is active
  bool get isActive => _isActive;
  
  /// Set active status and notify listeners
  set isActive(bool value) {
    if (_isActive != value) {
      _isActive = value;
      updatedAt = DateTime.now();
      notifyListeners();
    }
  }

  /// Check if variant is available (active and in stock)
  bool get isAvailable => _isActive && _stockQuantity > 0;

  /// Check if variant is out of stock
  bool get isOutOfStock => _stockQuantity <= 0;

  /// Check if variant needs reordering
  bool get needsReorder => _stockQuantity <= reorderLevel;

  /// Check if variant is overstocked
  bool get isOverstocked => maxStockLevel != null && _stockQuantity > maxStockLevel!;

  /// Get stock status as string
  String get stockStatus {
    if (!_isActive) return 'Inactive';
    if (_stockQuantity <= 0) return 'Out of Stock';
    if (_stockQuantity <= reorderLevel) return 'Low Stock';
    if (maxStockLevel != null && _stockQuantity > maxStockLevel!) return 'Overstocked';
    return 'In Stock';
  }

  /// Get display name for this variant
  String get displayName => '$size - $color${style.isNotEmpty ? ' ($style)' : ''}';

  /// Get short display name
  String get shortName => '$size/$color';

  /// Adjust stock quantity by a delta amount
  void adjustStock(int delta, {String? reason}) {
    stockQuantity = (_stockQuantity + delta).clamp(0, maxStockLevel ?? double.infinity).toInt();
  }

  /// Add stock
  void addStock(int quantity, {String? reason}) {
    adjustStock(quantity, reason: reason);
  }

  /// Remove stock
  void removeStock(int quantity, {String? reason}) {
    adjustStock(-quantity, reason: reason);
  }

  /// Set stock to specific amount
  void setStock(int quantity, {String? reason}) {
    stockQuantity = quantity.clamp(0, maxStockLevel ?? double.infinity).toInt();
  }

  /// Check if enough stock is available for a sale
  bool canSell(int quantity) {
    return _isActive && _stockQuantity >= quantity;
  }

  /// Reserve stock for a pending sale
  bool reserveStock(int quantity) {
    if (canSell(quantity)) {
      removeStock(quantity, reason: 'Reserved for sale');
      return true;
    }
    return false;
  }

  /// Release reserved stock (if sale is cancelled)
  void releaseStock(int quantity) {
    addStock(quantity, reason: 'Released from reservation');
  }

  /// Get estimated shipping weight
  double get shippingWeight => weight ?? 0.0;

  /// Get estimated shipping volume (length × width × height)
  double get shippingVolume {
    if (dimensions == null) return 0.0;
    return (dimensions!['length'] ?? 0.0) * 
           (dimensions!['width'] ?? 0.0) * 
           (dimensions!['height'] ?? 0.0);
  }

  /// Create a copy of this variant with updated fields
  ProductVariant copyWith({
    String? id,
    String? productId,
    String? size,
    String? color,
    String? colorHex,
    String? style,
    String? sku,
    String? barcode,
    int? stockQuantity,
    num? priceAdjustment,
    String? imageUrl,
    bool? isActive,
    int? reorderLevel,
    int? maxStockLevel,
    double? weight,
    Map<String, double>? dimensions,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      size: size ?? this.size,
      color: color ?? this.color,
      colorHex: colorHex ?? this.colorHex,
      style: style ?? this.style,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      priceAdjustment: priceAdjustment ?? this.priceAdjustment,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      maxStockLevel: maxStockLevel ?? this.maxStockLevel,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Convert to JSON for storage/API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'size': size,
      'color': color,
      'colorHex': colorHex,
      'style': style,
      'sku': sku,
      'barcode': barcode,
      'stockQuantity': stockQuantity,
      'priceAdjustment': priceAdjustment,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'reorderLevel': reorderLevel,
      'maxStockLevel': maxStockLevel,
      'weight': weight,
      'dimensions': dimensions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] as String,
      productId: json['productId'] as String,
      size: json['size'] as String,
      color: json['color'] as String,
      colorHex: json['colorHex'] as String?,
      style: json['style'] as String? ?? '',
      sku: json['sku'] as String,
      barcode: json['barcode'] as String?,
      stockQuantity: json['stockQuantity'] as int? ?? 0,
      priceAdjustment: json['priceAdjustment'] as num? ?? 0,
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      reorderLevel: json['reorderLevel'] as int? ?? 5,
      maxStockLevel: json['maxStockLevel'] as int?,
      weight: json['weight'] as double?,
      dimensions: json['dimensions'] != null 
        ? Map<String, double>.from(json['dimensions'] as Map)
        : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'ProductVariant(id: $id, sku: $sku, size: $size, color: $color, stock: $stockQuantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductVariant && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
