import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ClothingColor extends ChangeNotifier {
  /// Unique identifier
  final String id;
  
  /// Color name (e.g., 'Red', 'Navy Blue', 'Forest Green')
  final String name;
  
  /// Hex color code (e.g., '#FF0000', '#000080')
  final String hexCode;
  
  /// Flutter Color object for UI display
  Color get color => Color(int.parse(hexCode.substring(1), radix: 16) + 0xFF000000);
  
  /// Optional image URL for color swatch
  final String? imageUrl;
  
  /// Whether this color is active
  bool _isActive;
  
  /// Sort order for display
  final int sortOrder;
  
  /// Color family/group (e.g., 'Red', 'Blue', 'Neutral')
  final String? colorFamily;
  
  /// Season association (e.g., 'Spring', 'Fall', 'All Season')
  final String? season;
  
  /// Description or notes
  final String? description;

  ClothingColor({
    required this.id,
    required this.name,
    required this.hexCode,
    this.imageUrl,
    bool isActive = true,
    this.sortOrder = 0,
    this.colorFamily,
    this.season,
    this.description,
  }) : _isActive = isActive;

  /// Whether this color is active
  bool get isActive => _isActive;
  
  /// Set active status
  set isActive(bool value) {
    if (_isActive != value) {
      _isActive = value;
      notifyListeners();
    }
  }

  /// Get brightness of the color (for determining text color)
  bool get isDark {
    final luminance = color.computeLuminance();
    return luminance < 0.5;
  }

  /// Get contrasting text color (black or white)
  Color get contrastingTextColor => isDark ? Colors.white : Colors.black;

  /// Create a copy with updated fields
  ClothingColor copyWith({
    String? id,
    String? name,
    String? hexCode,
    String? imageUrl,
    bool? isActive,
    int? sortOrder,
    String? colorFamily,
    String? season,
    String? description,
  }) {
    return ClothingColor(
      id: id ?? this.id,
      name: name ?? this.name,
      hexCode: hexCode ?? this.hexCode,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      colorFamily: colorFamily ?? this.colorFamily,
      season: season ?? this.season,
      description: description ?? this.description,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hexCode': hexCode,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'colorFamily': colorFamily,
      'season': season,
      'description': description,
    };
  }

  /// Create from JSON
  factory ClothingColor.fromJson(Map<String, dynamic> json) {
    return ClothingColor(
      id: json['id'] as String,
      name: json['name'] as String,
      hexCode: json['hexCode'] as String,
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      sortOrder: json['sortOrder'] as int? ?? 0,
      colorFamily: json['colorFamily'] as String?,
      season: json['season'] as String?,
      description: json['description'] as String?,
    );
  }

  @override
  String toString() {
    return 'ClothingColor(id: $id, name: $name, hexCode: $hexCode)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClothingColor && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Predefined standard colors for clothing
class StandardColors {
  static const List<Map<String, dynamic>> _standardColors = [
    // Neutrals
    {'name': 'Black', 'hexCode': '#000000', 'family': 'Neutral', 'sortOrder': 1},
    {'name': 'White', 'hexCode': '#FFFFFF', 'family': 'Neutral', 'sortOrder': 2},
    {'name': 'Gray', 'hexCode': '#808080', 'family': 'Neutral', 'sortOrder': 3},
    {'name': 'Charcoal', 'hexCode': '#36454F', 'family': 'Neutral', 'sortOrder': 4},
    {'name': 'Cream', 'hexCode': '#F5F5DC', 'family': 'Neutral', 'sortOrder': 5},
    {'name': 'Beige', 'hexCode': '#F5F5DC', 'family': 'Neutral', 'sortOrder': 6},
    
    // Blues
    {'name': 'Navy Blue', 'hexCode': '#000080', 'family': 'Blue', 'sortOrder': 10},
    {'name': 'Royal Blue', 'hexCode': '#4169E1', 'family': 'Blue', 'sortOrder': 11},
    {'name': 'Sky Blue', 'hexCode': '#87CEEB', 'family': 'Blue', 'sortOrder': 12},
    {'name': 'Denim Blue', 'hexCode': '#1560BD', 'family': 'Blue', 'sortOrder': 13},
    
    // Reds
    {'name': 'Red', 'hexCode': '#FF0000', 'family': 'Red', 'sortOrder': 20},
    {'name': 'Burgundy', 'hexCode': '#800020', 'family': 'Red', 'sortOrder': 21},
    {'name': 'Maroon', 'hexCode': '#800000', 'family': 'Red', 'sortOrder': 22},
    {'name': 'Pink', 'hexCode': '#FFC0CB', 'family': 'Red', 'sortOrder': 23},
    
    // Greens
    {'name': 'Forest Green', 'hexCode': '#228B22', 'family': 'Green', 'sortOrder': 30},
    {'name': 'Olive Green', 'hexCode': '#808000', 'family': 'Green', 'sortOrder': 31},
    {'name': 'Mint Green', 'hexCode': '#98FB98', 'family': 'Green', 'sortOrder': 32},
    
    // Browns
    {'name': 'Brown', 'hexCode': '#A52A2A', 'family': 'Brown', 'sortOrder': 40},
    {'name': 'Tan', 'hexCode': '#D2B48C', 'family': 'Brown', 'sortOrder': 41},
    {'name': 'Khaki', 'hexCode': '#F0E68C', 'family': 'Brown', 'sortOrder': 42},
    
    // Others
    {'name': 'Purple', 'hexCode': '#800080', 'family': 'Purple', 'sortOrder': 50},
    {'name': 'Orange', 'hexCode': '#FFA500', 'family': 'Orange', 'sortOrder': 60},
    {'name': 'Yellow', 'hexCode': '#FFFF00', 'family': 'Yellow', 'sortOrder': 70},
  ];

  /// Get all standard colors
  static List<ClothingColor> getStandardColors() {
    return _standardColors.map((colorData) {
      return ClothingColor(
        id: colorData['name'].toString().toLowerCase().replaceAll(' ', '_'),
        name: colorData['name'] as String,
        hexCode: colorData['hexCode'] as String,
        colorFamily: colorData['family'] as String,
        sortOrder: colorData['sortOrder'] as int,
      );
    }).toList();
  }

  /// Get colors by family
  static List<ClothingColor> getColorsByFamily(String family) {
    return getStandardColors()
        .where((color) => color.colorFamily == family)
        .toList();
  }

  /// Get neutral colors
  static List<ClothingColor> getNeutralColors() {
    return getColorsByFamily('Neutral');
  }

  /// Get popular colors (most commonly used)
  static List<ClothingColor> getPopularColors() {
    final popularNames = ['Black', 'White', 'Navy Blue', 'Gray', 'Red'];
    return getStandardColors()
        .where((color) => popularNames.contains(color.name))
        .toList();
  }

  /// Get seasonal colors
  static List<ClothingColor> getSeasonalColors(String season) {
    // This could be expanded based on fashion trends
    switch (season.toLowerCase()) {
      case 'spring':
        return getStandardColors().where((color) => 
          ['Pink', 'Mint Green', 'Sky Blue', 'Yellow'].contains(color.name)
        ).toList();
      case 'summer':
        return getStandardColors().where((color) => 
          ['White', 'Sky Blue', 'Pink', 'Yellow', 'Mint Green'].contains(color.name)
        ).toList();
      case 'fall':
      case 'autumn':
        return getStandardColors().where((color) => 
          ['Brown', 'Orange', 'Burgundy', 'Olive Green', 'Tan'].contains(color.name)
        ).toList();
      case 'winter':
        return getStandardColors().where((color) => 
          ['Black', 'Navy Blue', 'Charcoal', 'Burgundy', 'Forest Green'].contains(color.name)
        ).toList();
      default:
        return getStandardColors();
    }
  }

  /// Create a custom color
  static ClothingColor createCustomColor({
    required String name,
    required String hexCode,
    String? colorFamily,
    int sortOrder = 999,
  }) {
    return ClothingColor(
      id: name.toLowerCase().replaceAll(' ', '_'),
      name: name,
      hexCode: hexCode,
      colorFamily: colorFamily,
      sortOrder: sortOrder,
    );
  }
}
