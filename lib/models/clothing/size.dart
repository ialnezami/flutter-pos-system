import 'package:flutter/foundation.dart';

enum SizeCategory {
  clothing('Clothing'),
  shoes('Shoes'),
  accessories('Accessories'),
  kids('Kids');

  const SizeCategory(this.displayName);
  final String displayName;
}

enum SizeType {
  letter('Letter'), // XS, S, M, L, XL, XXL
  numeric('Numeric'), // 32, 34, 36, 38
  european('European'), // 36, 38, 40, 42
  uk('UK'), // 8, 10, 12, 14
  us('US'), // 6, 8, 10, 12
  oneSize('One Size'); // One size fits all

  const SizeType(this.displayName);
  final String displayName;
}

class Size extends ChangeNotifier {
  /// Unique identifier
  final String id;
  
  /// Size name/value (e.g., 'M', '32', '38')
  final String name;
  
  /// Display name (e.g., 'Medium', 'Size 32')
  final String displayName;
  
  /// Category this size belongs to
  final SizeCategory category;
  
  /// Type of sizing system
  final SizeType type;
  
  /// Sort order for display (smaller numbers first)
  final int sortOrder;
  
  /// Whether this size is active
  bool _isActive;
  
  /// Size measurements in centimeters
  final Map<String, double>? measurements;
  
  /// Equivalent sizes in other systems
  final Map<SizeType, String>? equivalents;
  
  /// Description or notes about this size
  final String? description;

  Size({
    required this.id,
    required this.name,
    String? displayName,
    required this.category,
    required this.type,
    required this.sortOrder,
    bool isActive = true,
    this.measurements,
    this.equivalents,
    this.description,
  }) : 
    displayName = displayName ?? name,
    _isActive = isActive;

  /// Whether this size is active
  bool get isActive => _isActive;
  
  /// Set active status
  set isActive(bool value) {
    if (_isActive != value) {
      _isActive = value;
      notifyListeners();
    }
  }

  /// Get measurement for a specific dimension
  double? getMeasurement(String dimension) {
    return measurements?[dimension];
  }

  /// Get equivalent size in another system
  String? getEquivalent(SizeType sizeType) {
    return equivalents?[sizeType];
  }

  /// Check if this size has measurements defined
  bool get hasMeasurements => measurements != null && measurements!.isNotEmpty;

  /// Get formatted measurement string
  String get measurementString {
    if (!hasMeasurements) return '';
    
    final parts = <String>[];
    measurements!.forEach((key, value) {
      parts.add('$key: ${value}cm');
    });
    return parts.join(', ');
  }

  /// Create a copy with updated fields
  Size copyWith({
    String? id,
    String? name,
    String? displayName,
    SizeCategory? category,
    SizeType? type,
    int? sortOrder,
    bool? isActive,
    Map<String, double>? measurements,
    Map<SizeType, String>? equivalents,
    String? description,
  }) {
    return Size(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      category: category ?? this.category,
      type: type ?? this.type,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      measurements: measurements ?? this.measurements,
      equivalents: equivalents ?? this.equivalents,
      description: description ?? this.description,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'category': category.name,
      'type': type.name,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'measurements': measurements,
      'equivalents': equivalents?.map((key, value) => MapEntry(key.name, value)),
      'description': description,
    };
  }

  /// Create from JSON
  factory Size.fromJson(Map<String, dynamic> json) {
    Map<SizeType, String>? equivalents;
    if (json['equivalents'] != null) {
      final equivMap = json['equivalents'] as Map<String, dynamic>;
      equivalents = {};
      equivMap.forEach((key, value) {
        final sizeType = SizeType.values.firstWhere((e) => e.name == key);
        equivalents![sizeType] = value as String;
      });
    }

    return Size(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      category: SizeCategory.values.firstWhere((e) => e.name == json['category']),
      type: SizeType.values.firstWhere((e) => e.name == json['type']),
      sortOrder: json['sortOrder'] as int,
      isActive: json['isActive'] as bool? ?? true,
      measurements: json['measurements'] != null
        ? Map<String, double>.from(json['measurements'] as Map)
        : null,
      equivalents: equivalents,
      description: json['description'] as String?,
    );
  }

  @override
  String toString() {
    return 'Size(id: $id, name: $name, category: ${category.displayName}, type: ${type.displayName})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Size && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Predefined standard sizes for different categories
class StandardSizes {
  static const Map<SizeCategory, List<Map<String, dynamic>>> _standardSizes = {
    SizeCategory.clothing: [
      {'name': 'XS', 'displayName': 'Extra Small', 'type': 'letter', 'sortOrder': 1},
      {'name': 'S', 'displayName': 'Small', 'type': 'letter', 'sortOrder': 2},
      {'name': 'M', 'displayName': 'Medium', 'type': 'letter', 'sortOrder': 3},
      {'name': 'L', 'displayName': 'Large', 'type': 'letter', 'sortOrder': 4},
      {'name': 'XL', 'displayName': 'Extra Large', 'type': 'letter', 'sortOrder': 5},
      {'name': 'XXL', 'displayName': 'Double Extra Large', 'type': 'letter', 'sortOrder': 6},
    ],
    SizeCategory.shoes: [
      {'name': '35', 'displayName': 'Size 35', 'type': 'european', 'sortOrder': 35},
      {'name': '36', 'displayName': 'Size 36', 'type': 'european', 'sortOrder': 36},
      {'name': '37', 'displayName': 'Size 37', 'type': 'european', 'sortOrder': 37},
      {'name': '38', 'displayName': 'Size 38', 'type': 'european', 'sortOrder': 38},
      {'name': '39', 'displayName': 'Size 39', 'type': 'european', 'sortOrder': 39},
      {'name': '40', 'displayName': 'Size 40', 'type': 'european', 'sortOrder': 40},
      {'name': '41', 'displayName': 'Size 41', 'type': 'european', 'sortOrder': 41},
      {'name': '42', 'displayName': 'Size 42', 'type': 'european', 'sortOrder': 42},
      {'name': '43', 'displayName': 'Size 43', 'type': 'european', 'sortOrder': 43},
      {'name': '44', 'displayName': 'Size 44', 'type': 'european', 'sortOrder': 44},
      {'name': '45', 'displayName': 'Size 45', 'type': 'european', 'sortOrder': 45},
    ],
    SizeCategory.accessories: [
      {'name': 'OS', 'displayName': 'One Size', 'type': 'oneSize', 'sortOrder': 1},
    ],
  };

  /// Get standard sizes for a category
  static List<Size> getStandardSizes(SizeCategory category) {
    final sizes = _standardSizes[category] ?? [];
    return sizes.map((sizeData) {
      final typeString = sizeData['type'] as String;
      final type = SizeType.values.firstWhere((e) => e.name == typeString);
      
      return Size(
        id: '${category.name}_${sizeData['name']}',
        name: sizeData['name'] as String,
        displayName: sizeData['displayName'] as String,
        category: category,
        type: type,
        sortOrder: sizeData['sortOrder'] as int,
      );
    }).toList();
  }

  /// Get all standard sizes
  static List<Size> getAllStandardSizes() {
    final allSizes = <Size>[];
    for (final category in SizeCategory.values) {
      allSizes.addAll(getStandardSizes(category));
    }
    return allSizes;
  }
}
