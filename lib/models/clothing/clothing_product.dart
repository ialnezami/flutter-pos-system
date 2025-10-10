import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/clothing/product_variant.dart';
import 'package:possystem/models/clothing/collection.dart';

enum ClothingCategory {
  shirts('Shirts'),
  pants('Pants'),
  dresses('Dresses'),
  shoes('Shoes'),
  accessories('Accessories'),
  outerwear('Outerwear'),
  underwear('Underwear'),
  sportswear('Sportswear'),
  bags('Bags'),
  jewelry('Jewelry');

  const ClothingCategory(this.displayName);
  final String displayName;
}

enum ClothingGender {
  men('Men'),
  women('Women'),
  unisex('Unisex'),
  kids('Kids');

  const ClothingGender(this.displayName);
  final String displayName;
}

class ClothingProduct extends Product {
  /// Brand name (e.g., Nike, Adidas, Zara)
  final String brand;
  
  /// Season/Collection (e.g., Spring 2024, Fall 2023)
  final String season;
  
  /// Collection name (e.g., Summer Essentials, Holiday Collection)
  final String? collection;
  
  /// Clothing category
  final ClothingCategory category;
  
  /// Target gender
  final ClothingGender gender;
  
  /// Product variants (size/color combinations)
  final Map<String, ProductVariant> variants;
  
  /// Additional product attributes
  final Map<String, String> attributes;
  
  /// Material composition
  final String? material;
  
  /// Care instructions
  final String? careInstructions;
  
  /// Product tags for search and filtering
  final List<String> tags;

  ClothingProduct({
    super.id,
    super.status,
    super.name = 'clothing-product',
    super.cost = 0,
    super.price = 0,
    String? imagePath,
    DateTime? createdAt,
    this.brand = '',
    this.season = '',
    this.collection,
    this.category = ClothingCategory.shirts,
    this.gender = ClothingGender.unisex,
    Map<String, ProductVariant>? variants,
    Map<String, String>? attributes,
    this.material,
    this.careInstructions,
    List<String>? tags,
    int index = 1,
  }) : 
    variants = variants ?? {},
    attributes = attributes ?? {},
    tags = tags ?? [],
    super(
      index: index,
      imagePath: imagePath,
      createdAt: createdAt,
    );

  factory ClothingProduct.fromProduct(Product product, {
    required String brand,
    required String season,
    String? collection,
    required ClothingCategory category,
    required ClothingGender gender,
    Map<String, ProductVariant>? variants,
    Map<String, String>? attributes,
    String? material,
    String? careInstructions,
    List<String>? tags,
  }) {
    return ClothingProduct(
      id: product.id,
      status: product.status,
      name: product.name,
      cost: product.cost,
      price: product.price,
      imagePath: product.imagePath,
      createdAt: product.createdAt,
      index: product.index,
      brand: brand,
      season: season,
      collection: collection,
      category: category,
      gender: gender,
      variants: variants,
      attributes: attributes,
      material: material,
      careInstructions: careInstructions,
      tags: tags,
    );
  }

  /// Get all available sizes for this product
  Set<String> get availableSizes {
    return variants.values.where((v) => v.isActive && v.stockQuantity > 0)
        .map((v) => v.size).toSet();
  }

  /// Get all available colors for this product
  Set<String> get availableColors {
    return variants.values.where((v) => v.isActive && v.stockQuantity > 0)
        .map((v) => v.color).toSet();
  }

  /// Get variants for a specific size
  List<ProductVariant> getVariantsBySize(String size) {
    return variants.values.where((v) => v.size == size && v.isActive).toList();
  }

  /// Get variants for a specific color
  List<ProductVariant> getVariantsByColor(String color) {
    return variants.values.where((v) => v.color == color && v.isActive).toList();
  }

  /// Get variant by size and color combination
  ProductVariant? getVariant(String size, String color) {
    return variants.values.firstWhere(
      (v) => v.size == size && v.color == color && v.isActive,
      orElse: () => throw StateError('Variant not found'),
    );
  }

  /// Get total stock across all variants
  int get totalStock {
    return variants.values.fold(0, (sum, variant) => sum + variant.stockQuantity);
  }

  /// Check if product has any stock available
  bool get hasStock {
    return variants.values.any((v) => v.stockQuantity > 0 && v.isActive);
  }

  /// Get price for specific variant (base price + adjustment)
  num getVariantPrice(String variantId) {
    final variant = variants[variantId];
    if (variant == null) return price;
    return price + variant.priceAdjustment;
  }

  /// Get the lowest price among all variants
  num get minPrice {
    if (variants.isEmpty) return price;
    final minAdjustment = variants.values
        .where((v) => v.isActive)
        .map((v) => v.priceAdjustment)
        .reduce((a, b) => a < b ? a : b);
    return price + minAdjustment;
  }

  /// Get the highest price among all variants
  num get maxPrice {
    if (variants.isEmpty) return price;
    final maxAdjustment = variants.values
        .where((v) => v.isActive)
        .map((v) => v.priceAdjustment)
        .reduce((a, b) => a > b ? a : b);
    return price + maxAdjustment;
  }

  /// Add a new variant
  void addVariant(ProductVariant variant) {
    variants[variant.id] = variant;
    notifyListeners();
  }

  /// Remove a variant
  void removeVariant(String variantId) {
    variants.remove(variantId);
    notifyListeners();
  }

  /// Update variant stock
  void updateVariantStock(String variantId, int quantity) {
    final variant = variants[variantId];
    if (variant != null) {
      variant.stockQuantity = quantity;
      notifyListeners();
    }
  }

  /// Search variants by text
  List<ProductVariant> searchVariants(String query) {
    final lowerQuery = query.toLowerCase();
    return variants.values.where((variant) =>
      variant.size.toLowerCase().contains(lowerQuery) ||
      variant.color.toLowerCase().contains(lowerQuery) ||
      variant.style.toLowerCase().contains(lowerQuery) ||
      variant.sku.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  /// Get variants with low stock (below threshold)
  List<ProductVariant> getLowStockVariants([int threshold = 5]) {
    return variants.values.where((v) => 
      v.isActive && v.stockQuantity <= threshold && v.stockQuantity > 0
    ).toList();
  }

  /// Get out of stock variants
  List<ProductVariant> getOutOfStockVariants() {
    return variants.values.where((v) => v.isActive && v.stockQuantity <= 0).toList();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'season': season,
      'collection': collection,
      'category': category.name,
      'gender': gender.name,
      'material': material,
      'careInstructions': careInstructions,
      'tags': tags,
      'attributes': attributes,
      'variants': variants.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  @override
  String toString() {
    return 'ClothingProduct(id: $id, name: $name, brand: $brand, category: ${category.displayName}, variants: ${variants.length})';
  }
}
