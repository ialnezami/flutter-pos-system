import 'package:flutter/foundation.dart';
import 'package:possystem/models/clothing/clothing_product.dart';

enum LoyaltyTier {
  bronze('Bronze', 0, 499),
  silver('Silver', 500, 999),
  gold('Gold', 1000, 2499),
  platinum('Platinum', 2500, double.infinity);

  const LoyaltyTier(this.displayName, this.minPoints, this.maxPoints);
  final String displayName;
  final double minPoints;
  final double maxPoints;

  static LoyaltyTier fromPoints(int points) {
    for (final tier in LoyaltyTier.values.reversed) {
      if (points >= tier.minPoints) return tier;
    }
    return LoyaltyTier.bronze;
  }
}

enum CustomerType {
  regular('Regular Customer'),
  vip('VIP Customer'),
  wholesale('Wholesale Customer'),
  staff('Staff Member');

  const CustomerType(this.displayName);
  final String displayName;
}

class CustomerPreferences extends ChangeNotifier {
  /// Preferred brands
  final Set<String> preferredBrands;
  
  /// Preferred sizes by category
  final Map<ClothingCategory, String> preferredSizes;
  
  /// Preferred colors
  final Set<String> preferredColors;
  
  /// Preferred categories
  final Set<ClothingCategory> preferredCategories;
  
  /// Preferred price range
  final Map<String, double>? priceRange; // {'min': 50, 'max': 200}
  
  /// Style preferences
  final Set<String> stylePreferences;
  
  /// Preferred shopping seasons
  final Set<Season> preferredSeasons;
  
  /// Communication preferences
  final Map<String, bool> communicationPrefs; // email, sms, push notifications

  CustomerPreferences({
    Set<String>? preferredBrands,
    Map<ClothingCategory, String>? preferredSizes,
    Set<String>? preferredColors,
    Set<ClothingCategory>? preferredCategories,
    this.priceRange,
    Set<String>? stylePreferences,
    Set<Season>? preferredSeasons,
    Map<String, bool>? communicationPrefs,
  }) : 
    preferredBrands = preferredBrands ?? {},
    preferredSizes = preferredSizes ?? {},
    preferredColors = preferredColors ?? {},
    preferredCategories = preferredCategories ?? {},
    stylePreferences = stylePreferences ?? {},
    preferredSeasons = preferredSeasons ?? {},
    communicationPrefs = communicationPrefs ?? {
      'email': true,
      'sms': false,
      'push': true,
      'marketing': false,
    };

  /// Add preferred brand
  void addPreferredBrand(String brand) {
    if (preferredBrands.add(brand)) {
      notifyListeners();
    }
  }

  /// Remove preferred brand
  void removePreferredBrand(String brand) {
    if (preferredBrands.remove(brand)) {
      notifyListeners();
    }
  }

  /// Set preferred size for category
  void setPreferredSize(ClothingCategory category, String size) {
    preferredSizes[category] = size;
    notifyListeners();
  }

  /// Get preferred size for category
  String? getPreferredSize(ClothingCategory category) {
    return preferredSizes[category];
  }

  /// Add preferred color
  void addPreferredColor(String color) {
    if (preferredColors.add(color)) {
      notifyListeners();
    }
  }

  /// Check if product matches customer preferences
  bool matchesPreferences(ClothingProduct product) {
    // Check brand preference
    if (preferredBrands.isNotEmpty && !preferredBrands.contains(product.brand)) {
      return false;
    }

    // Check category preference
    if (preferredCategories.isNotEmpty && !preferredCategories.contains(product.category)) {
      return false;
    }

    // Check price range
    if (priceRange != null) {
      final minPrice = priceRange!['min'] ?? 0;
      final maxPrice = priceRange!['max'] ?? double.infinity;
      if (product.price < minPrice || product.price > maxPrice) {
        return false;
      }
    }

    return true;
  }

  /// Get preference score for a product (0-100)
  int getPreferenceScore(ClothingProduct product) {
    int score = 0;

    // Brand match (25 points)
    if (preferredBrands.contains(product.brand)) score += 25;

    // Category match (20 points)
    if (preferredCategories.contains(product.category)) score += 20;

    // Color match (15 points)
    if (product.availableColors.any((color) => preferredColors.contains(color))) {
      score += 15;
    }

    // Size availability (10 points)
    final preferredSize = preferredSizes[product.category];
    if (preferredSize != null && product.availableSizes.contains(preferredSize)) {
      score += 10;
    }

    // Price range match (10 points)
    if (priceRange != null) {
      final minPrice = priceRange!['min'] ?? 0;
      final maxPrice = priceRange!['max'] ?? double.infinity;
      if (product.price >= minPrice && product.price <= maxPrice) {
        score += 10;
      }
    }

    // Style match (10 points)
    if (stylePreferences.any((style) => product.tags.contains(style))) {
      score += 10;
    }

    // Season match (10 points)
    final productSeason = Season.values.firstWhere(
      (s) => s.name.toLowerCase() == product.season.toLowerCase(),
      orElse: () => Season.allSeason,
    );
    if (preferredSeasons.contains(productSeason)) {
      score += 10;
    }

    return score;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'preferredBrands': preferredBrands.toList(),
      'preferredSizes': preferredSizes.map((key, value) => MapEntry(key.name, value)),
      'preferredColors': preferredColors.toList(),
      'preferredCategories': preferredCategories.map((e) => e.name).toList(),
      'priceRange': priceRange,
      'stylePreferences': stylePreferences.toList(),
      'preferredSeasons': preferredSeasons.map((e) => e.name).toList(),
      'communicationPrefs': communicationPrefs,
    };
  }

  /// Create from JSON
  factory CustomerPreferences.fromJson(Map<String, dynamic> json) {
    Map<ClothingCategory, String>? preferredSizes;
    if (json['preferredSizes'] != null) {
      final sizesMap = json['preferredSizes'] as Map<String, dynamic>;
      preferredSizes = {};
      sizesMap.forEach((key, value) {
        final category = ClothingCategory.values.firstWhere((e) => e.name == key);
        preferredSizes![category] = value as String;
      });
    }

    return CustomerPreferences(
      preferredBrands: Set<String>.from(json['preferredBrands'] as List? ?? []),
      preferredSizes: preferredSizes,
      preferredColors: Set<String>.from(json['preferredColors'] as List? ?? []),
      preferredCategories: (json['preferredCategories'] as List? ?? [])
        .map((e) => ClothingCategory.values.firstWhere((cat) => cat.name == e))
        .toSet(),
      priceRange: json['priceRange'] != null 
        ? Map<String, double>.from(json['priceRange'] as Map)
        : null,
      stylePreferences: Set<String>.from(json['stylePreferences'] as List? ?? []),
      preferredSeasons: (json['preferredSeasons'] as List? ?? [])
        .map((e) => Season.values.firstWhere((season) => season.name == e))
        .toSet(),
      communicationPrefs: Map<String, bool>.from(json['communicationPrefs'] as Map? ?? {}),
    );
  }
}

class LoyaltyProgram extends ChangeNotifier {
  /// Current loyalty points
  int _points;
  
  /// Total lifetime points earned
  int _lifetimePoints;
  
  /// Points earned this year
  int _yearlyPoints;
  
  /// Current loyalty tier
  LoyaltyTier _tier;
  
  /// Date of last purchase
  DateTime? _lastPurchase;
  
  /// Total amount spent (for tier calculation)
  double _totalSpent;
  
  /// Available rewards/coupons
  final List<Reward> _availableRewards;

  LoyaltyProgram({
    int points = 0,
    int lifetimePoints = 0,
    int yearlyPoints = 0,
    DateTime? lastPurchase,
    double totalSpent = 0.0,
    List<Reward>? availableRewards,
  }) : 
    _points = points,
    _lifetimePoints = lifetimePoints,
    _yearlyPoints = yearlyPoints,
    _tier = LoyaltyTier.fromPoints(points),
    _lastPurchase = lastPurchase,
    _totalSpent = totalSpent,
    _availableRewards = availableRewards ?? [];

  /// Current points
  int get points => _points;
  
  /// Lifetime points
  int get lifetimePoints => _lifetimePoints;
  
  /// Yearly points
  int get yearlyPoints => _yearlyPoints;
  
  /// Current tier
  LoyaltyTier get tier => _tier;
  
  /// Last purchase date
  DateTime? get lastPurchase => _lastPurchase;
  
  /// Total spent
  double get totalSpent => _totalSpent;
  
  /// Available rewards
  List<Reward> get availableRewards => List.unmodifiable(_availableRewards);

  /// Add points from purchase
  void addPoints(int pointsToAdd, double purchaseAmount) {
    _points += pointsToAdd;
    _lifetimePoints += pointsToAdd;
    _yearlyPoints += pointsToAdd;
    _totalSpent += purchaseAmount;
    _lastPurchase = DateTime.now();
    
    // Update tier
    final newTier = LoyaltyTier.fromPoints(_points);
    if (newTier != _tier) {
      _tier = newTier;
      // Add tier upgrade reward
      _availableRewards.add(Reward.tierUpgrade(_tier));
    }
    
    notifyListeners();
  }

  /// Redeem points for reward
  bool redeemPoints(int pointsToRedeem) {
    if (_points >= pointsToRedeem) {
      _points -= pointsToRedeem;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Add reward
  void addReward(Reward reward) {
    _availableRewards.add(reward);
    notifyListeners();
  }

  /// Use reward
  bool useReward(String rewardId) {
    final rewardIndex = _availableRewards.indexWhere((r) => r.id == rewardId);
    if (rewardIndex >= 0) {
      _availableRewards.removeAt(rewardIndex);
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Points until next tier
  int get pointsUntilNextTier {
    final currentIndex = LoyaltyTier.values.indexOf(_tier);
    if (currentIndex >= LoyaltyTier.values.length - 1) return 0;
    
    final nextTier = LoyaltyTier.values[currentIndex + 1];
    return (nextTier.minPoints - _points).toInt();
  }

  /// Reset yearly points (called at year end)
  void resetYearlyPoints() {
    _yearlyPoints = 0;
    notifyListeners();
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'points': points,
      'lifetimePoints': lifetimePoints,
      'yearlyPoints': yearlyPoints,
      'tier': tier.name,
      'lastPurchase': lastPurchase?.toIso8601String(),
      'totalSpent': totalSpent,
      'availableRewards': availableRewards.map((r) => r.toJson()).toList(),
    };
  }

  /// Create from JSON
  factory LoyaltyProgram.fromJson(Map<String, dynamic> json) {
    return LoyaltyProgram(
      points: json['points'] as int? ?? 0,
      lifetimePoints: json['lifetimePoints'] as int? ?? 0,
      yearlyPoints: json['yearlyPoints'] as int? ?? 0,
      lastPurchase: json['lastPurchase'] != null 
        ? DateTime.parse(json['lastPurchase'] as String)
        : null,
      totalSpent: json['totalSpent'] as double? ?? 0.0,
      availableRewards: (json['availableRewards'] as List? ?? [])
        .map((r) => Reward.fromJson(r as Map<String, dynamic>))
        .toList(),
    );
  }
}

class Reward {
  final String id;
  final String name;
  final String description;
  final RewardType type;
  final double value; // discount amount or percentage
  final DateTime? expiryDate;
  final int? minimumPurchase;
  final bool isUsed;

  Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.value,
    this.expiryDate,
    this.minimumPurchase,
    this.isUsed = false,
  });

  factory Reward.tierUpgrade(LoyaltyTier tier) {
    return Reward(
      id: 'tier_upgrade_${tier.name}_${DateTime.now().millisecondsSinceEpoch}',
      name: '${tier.displayName} Tier Welcome',
      description: 'Welcome to ${tier.displayName} tier! Enjoy 15% off your next purchase.',
      type: RewardType.percentage,
      value: 15.0,
      expiryDate: DateTime.now().add(const Duration(days: 30)),
    );
  }

  bool get isExpired => expiryDate != null && DateTime.now().isAfter(expiryDate!);
  bool get isValid => !isUsed && !isExpired;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'value': value,
      'expiryDate': expiryDate?.toIso8601String(),
      'minimumPurchase': minimumPurchase,
      'isUsed': isUsed,
    };
  }

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: RewardType.values.firstWhere((e) => e.name == json['type']),
      value: json['value'] as double,
      expiryDate: json['expiryDate'] != null 
        ? DateTime.parse(json['expiryDate'] as String)
        : null,
      minimumPurchase: json['minimumPurchase'] as int?,
      isUsed: json['isUsed'] as bool? ?? false,
    );
  }
}

enum RewardType {
  percentage('Percentage Discount'),
  fixed('Fixed Amount Discount'),
  freeShipping('Free Shipping'),
  buyOneGetOne('Buy One Get One');

  const RewardType(this.displayName);
  final String displayName;
}

class ClothingCustomer extends ChangeNotifier {
  /// Unique customer ID
  final String id;
  
  /// Customer name
  String _name;
  
  /// Contact information
  String? _email;
  String? _phone;
  String? _address;
  
  /// Customer type
  CustomerType _type;
  
  /// Customer preferences
  final CustomerPreferences preferences;
  
  /// Loyalty program
  final LoyaltyProgram loyalty;
  
  /// Purchase history (simplified - just total counts and amounts)
  int _totalPurchases;
  double _totalSpent;
  DateTime? _lastPurchaseDate;
  
  /// Customer measurements (optional)
  final Map<String, String>? measurements;
  
  /// Birthday for special offers
  DateTime? _birthday;
  
  /// Notes about the customer
  String? _notes;
  
  /// Whether customer is active
  bool _isActive;
  
  /// When customer was created
  final DateTime createdAt;
  
  /// When customer was last updated
  DateTime updatedAt;

  ClothingCustomer({
    required this.id,
    required String name,
    String? email,
    String? phone,
    String? address,
    CustomerType type = CustomerType.regular,
    CustomerPreferences? preferences,
    LoyaltyProgram? loyalty,
    int totalPurchases = 0,
    double totalSpent = 0.0,
    DateTime? lastPurchaseDate,
    this.measurements,
    DateTime? birthday,
    String? notes,
    bool isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    _name = name,
    _email = email,
    _phone = phone,
    _address = address,
    _type = type,
    preferences = preferences ?? CustomerPreferences(),
    loyalty = loyalty ?? LoyaltyProgram(),
    _totalPurchases = totalPurchases,
    _totalSpent = totalSpent,
    _lastPurchaseDate = lastPurchaseDate,
    _birthday = birthday,
    _notes = notes,
    _isActive = isActive,
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  // Getters and setters
  String get name => _name;
  set name(String value) {
    if (_name != value) {
      _name = value;
      updatedAt = DateTime.now();
      notifyListeners();
    }
  }

  String? get email => _email;
  set email(String? value) {
    if (_email != value) {
      _email = value;
      updatedAt = DateTime.now();
      notifyListeners();
    }
  }

  String? get phone => _phone;
  set phone(String? value) {
    if (_phone != value) {
      _phone = value;
      updatedAt = DateTime.now();
      notifyListeners();
    }
  }

  CustomerType get type => _type;
  set type(CustomerType value) {
    if (_type != value) {
      _type = value;
      updatedAt = DateTime.now();
      notifyListeners();
    }
  }

  int get totalPurchases => _totalPurchases;
  double get totalSpent => _totalSpent;
  DateTime? get lastPurchaseDate => _lastPurchaseDate;
  DateTime? get birthday => _birthday;
  bool get isActive => _isActive;

  /// Record a purchase
  void recordPurchase(double amount, int loyaltyPoints) {
    _totalPurchases++;
    _totalSpent += amount;
    _lastPurchaseDate = DateTime.now();
    loyalty.addPoints(loyaltyPoints, amount);
    updatedAt = DateTime.now();
    notifyListeners();
  }

  /// Get customer lifetime value
  double get lifetimeValue => _totalSpent;

  /// Get average purchase amount
  double get averagePurchaseAmount {
    if (_totalPurchases == 0) return 0.0;
    return _totalSpent / _totalPurchases;
  }

  /// Check if it's customer's birthday month
  bool get isBirthdayMonth {
    if (_birthday == null) return false;
    final now = DateTime.now();
    return now.month == _birthday!.month;
  }

  /// Get days since last purchase
  int? get daysSinceLastPurchase {
    if (_lastPurchaseDate == null) return null;
    return DateTime.now().difference(_lastPurchaseDate!).inDays;
  }

  /// Check if customer is at risk of churning (no purchase in 90+ days)
  bool get isAtRiskOfChurning {
    final days = daysSinceLastPurchase;
    return days != null && days >= 90;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': _address,
      'type': type.name,
      'preferences': preferences.toJson(),
      'loyalty': loyalty.toJson(),
      'totalPurchases': totalPurchases,
      'totalSpent': totalSpent,
      'lastPurchaseDate': lastPurchaseDate?.toIso8601String(),
      'measurements': measurements,
      'birthday': birthday?.toIso8601String(),
      'notes': _notes,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory ClothingCustomer.fromJson(Map<String, dynamic> json) {
    return ClothingCustomer(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      type: CustomerType.values.firstWhere((e) => e.name == json['type']),
      preferences: CustomerPreferences.fromJson(json['preferences'] as Map<String, dynamic>),
      loyalty: LoyaltyProgram.fromJson(json['loyalty'] as Map<String, dynamic>),
      totalPurchases: json['totalPurchases'] as int? ?? 0,
      totalSpent: json['totalSpent'] as double? ?? 0.0,
      lastPurchaseDate: json['lastPurchaseDate'] != null 
        ? DateTime.parse(json['lastPurchaseDate'] as String)
        : null,
      measurements: json['measurements'] != null
        ? Map<String, String>.from(json['measurements'] as Map)
        : null,
      birthday: json['birthday'] != null 
        ? DateTime.parse(json['birthday'] as String)
        : null,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'ClothingCustomer(id: $id, name: $name, tier: ${loyalty.tier.displayName}, totalSpent: \$${totalSpent.toStringAsFixed(2)})';
  }
}
