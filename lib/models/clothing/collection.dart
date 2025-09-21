import 'package:flutter/foundation.dart';

enum CollectionStatus {
  upcoming('Upcoming'),
  active('Active'),
  ending('Ending Soon'),
  ended('Ended'),
  archived('Archived');

  const CollectionStatus(this.displayName);
  final String displayName;
}

enum Season {
  spring('Spring'),
  summer('Summer'),
  fall('Fall'),
  winter('Winter'),
  allSeason('All Season');

  const Season(this.displayName);
  final String displayName;
}

class ClothingCollection extends ChangeNotifier {
  /// Unique identifier
  final String id;
  
  /// Collection name (e.g., "Summer Essentials 2024", "Holiday Collection")
  final String name;
  
  /// Collection description
  final String? description;
  
  /// Season this collection belongs to
  final Season season;
  
  /// Year of the collection
  final int year;
  
  /// Collection start date (when it becomes available)
  DateTime _startDate;
  
  /// Collection end date (when it goes on sale/discontinued)
  DateTime _endDate;
  
  /// Current status of the collection
  CollectionStatus _status;
  
  /// Base discount percentage for the collection (0-100)
  double _discountPercentage;
  
  /// Whether the collection is currently active for sales
  bool _isActive;
  
  /// Collection image URL
  final String? imageUrl;
  
  /// Collection tags for search and filtering
  final List<String> tags;
  
  /// Target demographic
  final List<String> targetDemographic;
  
  /// Price range for this collection
  final Map<String, double>? priceRange; // {'min': 29.99, 'max': 199.99}
  
  /// Collection theme or style
  final String? theme;
  
  /// Marketing notes or special features
  final String? marketingNotes;
  
  /// When this collection was created
  final DateTime createdAt;
  
  /// When this collection was last updated
  DateTime updatedAt;

  ClothingCollection({
    required this.id,
    required this.name,
    this.description,
    required this.season,
    required this.year,
    required DateTime startDate,
    required DateTime endDate,
    CollectionStatus status = CollectionStatus.upcoming,
    double discountPercentage = 0.0,
    bool isActive = true,
    this.imageUrl,
    List<String>? tags,
    List<String>? targetDemographic,
    this.priceRange,
    this.theme,
    this.marketingNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    _startDate = startDate,
    _endDate = endDate,
    _status = status,
    _discountPercentage = discountPercentage,
    _isActive = isActive,
    tags = tags ?? [],
    targetDemographic = targetDemographic ?? [],
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  /// Collection start date
  DateTime get startDate => _startDate;
  
  /// Set start date and update status
  set startDate(DateTime value) {
    if (_startDate != value) {
      _startDate = value;
      _updateStatus();
      updatedAt = DateTime.now();
      notifyListeners();
    }
  }

  /// Collection end date
  DateTime get endDate => _endDate;
  
  /// Set end date and update status
  set endDate(DateTime value) {
    if (_endDate != value) {
      _endDate = value;
      _updateStatus();
      updatedAt = DateTime.now();
      notifyListeners();
    }
  }

  /// Current collection status
  CollectionStatus get status => _status;
  
  /// Set status manually
  set status(CollectionStatus value) {
    if (_status != value) {
      _status = value;
      updatedAt = DateTime.now();
      notifyListeners();
    }
  }

  /// Discount percentage (0-100)
  double get discountPercentage => _discountPercentage;
  
  /// Set discount percentage
  set discountPercentage(double value) {
    final clampedValue = value.clamp(0.0, 100.0);
    if (_discountPercentage != clampedValue) {
      _discountPercentage = clampedValue;
      updatedAt = DateTime.now();
      notifyListeners();
    }
  }

  /// Whether collection is active
  bool get isActive => _isActive;
  
  /// Set active status
  set isActive(bool value) {
    if (_isActive != value) {
      _isActive = value;
      updatedAt = DateTime.now();
      notifyListeners();
    }
  }

  /// Check if collection is currently available for sale
  bool get isAvailable {
    final now = DateTime.now();
    return _isActive && now.isAfter(_startDate) && now.isBefore(_endDate);
  }

  /// Check if collection is upcoming
  bool get isUpcoming {
    return DateTime.now().isBefore(_startDate);
  }

  /// Check if collection has ended
  bool get hasEnded {
    return DateTime.now().isAfter(_endDate);
  }

  /// Get days until collection starts
  int get daysUntilStart {
    if (!isUpcoming) return 0;
    return _startDate.difference(DateTime.now()).inDays;
  }

  /// Get days until collection ends
  int get daysUntilEnd {
    if (hasEnded) return 0;
    return _endDate.difference(DateTime.now()).inDays;
  }

  /// Get collection duration in days
  int get durationInDays {
    return _endDate.difference(_startDate).inDays;
  }

  /// Calculate discounted price
  double calculateDiscountedPrice(double originalPrice) {
    if (_discountPercentage <= 0) return originalPrice;
    return originalPrice * (1 - _discountPercentage / 100);
  }

  /// Get discount amount for a price
  double getDiscountAmount(double originalPrice) {
    return originalPrice - calculateDiscountedPrice(originalPrice);
  }

  /// Update status based on current date
  void _updateStatus() {
    final now = DateTime.now();
    
    if (now.isBefore(_startDate)) {
      _status = CollectionStatus.upcoming;
    } else if (now.isAfter(_endDate)) {
      _status = CollectionStatus.ended;
    } else {
      // Collection is active, check if it's ending soon (within 7 days)
      final daysLeft = _endDate.difference(now).inDays;
      if (daysLeft <= 7) {
        _status = CollectionStatus.ending;
      } else {
        _status = CollectionStatus.active;
      }
    }
  }

  /// Update status and notify listeners
  void updateStatus() {
    _updateStatus();
    notifyListeners();
  }

  /// Archive this collection
  void archive() {
    _status = CollectionStatus.archived;
    _isActive = false;
    updatedAt = DateTime.now();
    notifyListeners();
  }

  /// Activate this collection
  void activate() {
    _isActive = true;
    _updateStatus();
    updatedAt = DateTime.now();
    notifyListeners();
  }

  /// Deactivate this collection
  void deactivate() {
    _isActive = false;
    updatedAt = DateTime.now();
    notifyListeners();
  }

  /// Add a tag
  void addTag(String tag) {
    if (!tags.contains(tag)) {
      tags.add(tag);
      updatedAt = DateTime.now();
      notifyListeners();
    }
  }

  /// Remove a tag
  void removeTag(String tag) {
    if (tags.remove(tag)) {
      updatedAt = DateTime.now();
      notifyListeners();
    }
  }

  /// Check if collection matches search criteria
  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowerQuery) ||
           (description?.toLowerCase().contains(lowerQuery) ?? false) ||
           season.displayName.toLowerCase().contains(lowerQuery) ||
           tags.any((tag) => tag.toLowerCase().contains(lowerQuery)) ||
           (theme?.toLowerCase().contains(lowerQuery) ?? false);
  }

  /// Get display name with year
  String get displayNameWithYear => '$name ($year)';

  /// Get short status description
  String get statusDescription {
    switch (_status) {
      case CollectionStatus.upcoming:
        return 'Starts in $daysUntilStart days';
      case CollectionStatus.active:
        return 'Active - $daysUntilEnd days left';
      case CollectionStatus.ending:
        return 'Ending in $daysUntilEnd days';
      case CollectionStatus.ended:
        return 'Ended';
      case CollectionStatus.archived:
        return 'Archived';
    }
  }

  /// Create a copy with updated fields
  ClothingCollection copyWith({
    String? id,
    String? name,
    String? description,
    Season? season,
    int? year,
    DateTime? startDate,
    DateTime? endDate,
    CollectionStatus? status,
    double? discountPercentage,
    bool? isActive,
    String? imageUrl,
    List<String>? tags,
    List<String>? targetDemographic,
    Map<String, double>? priceRange,
    String? theme,
    String? marketingNotes,
  }) {
    return ClothingCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      season: season ?? this.season,
      year: year ?? this.year,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? List.from(this.tags),
      targetDemographic: targetDemographic ?? List.from(this.targetDemographic),
      priceRange: priceRange ?? this.priceRange,
      theme: theme ?? this.theme,
      marketingNotes: marketingNotes ?? this.marketingNotes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'season': season.name,
      'year': year,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.name,
      'discountPercentage': discountPercentage,
      'isActive': isActive,
      'imageUrl': imageUrl,
      'tags': tags,
      'targetDemographic': targetDemographic,
      'priceRange': priceRange,
      'theme': theme,
      'marketingNotes': marketingNotes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory ClothingCollection.fromJson(Map<String, dynamic> json) {
    return ClothingCollection(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      season: Season.values.firstWhere((e) => e.name == json['season']),
      year: json['year'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: CollectionStatus.values.firstWhere((e) => e.name == json['status']),
      discountPercentage: json['discountPercentage'] as double? ?? 0.0,
      isActive: json['isActive'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String?,
      tags: List<String>.from(json['tags'] as List? ?? []),
      targetDemographic: List<String>.from(json['targetDemographic'] as List? ?? []),
      priceRange: json['priceRange'] != null 
        ? Map<String, double>.from(json['priceRange'] as Map)
        : null,
      theme: json['theme'] as String?,
      marketingNotes: json['marketingNotes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'ClothingCollection(id: $id, name: $name, season: ${season.displayName}, year: $year, status: ${status.displayName})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClothingCollection && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
