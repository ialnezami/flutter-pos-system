import 'package:flutter/material.dart';
import 'package:possystem/models/clothing/clothing_product.dart';
import 'package:possystem/models/clothing/collection.dart';
import 'package:possystem/models/clothing/clothing_customer.dart';

class ClothingLocalizations {
  final Locale locale;

  ClothingLocalizations(this.locale);

  static ClothingLocalizations of(BuildContext context) {
    return Localizations.of<ClothingLocalizations>(context, ClothingLocalizations) ??
        ClothingLocalizations(const Locale('ar'));
  }

  // Clothing Categories
  String getClothingCategoryName(ClothingCategory category) {
    switch (locale.languageCode) {
      case 'ar':
        switch (category) {
          case ClothingCategory.shirts:
            return 'قمصان';
          case ClothingCategory.pants:
            return 'بناطيل';
          case ClothingCategory.dresses:
            return 'فساتين';
          case ClothingCategory.shoes:
            return 'أحذية';
          case ClothingCategory.accessories:
            return 'إكسسوارات';
          case ClothingCategory.outerwear:
            return 'ملابس خارجية';
          case ClothingCategory.underwear:
            return 'ملابس داخلية';
          case ClothingCategory.sportswear:
            return 'ملابس رياضية';
          case ClothingCategory.bags:
            return 'حقائب';
          case ClothingCategory.jewelry:
            return 'مجوهرات';
        }
      case 'en':
        return category.displayName;
      case 'zh':
        switch (category) {
          case ClothingCategory.shirts:
            return '襯衫';
          case ClothingCategory.pants:
            return '褲子';
          case ClothingCategory.dresses:
            return '連衣裙';
          case ClothingCategory.shoes:
            return '鞋子';
          case ClothingCategory.accessories:
            return '配飾';
          case ClothingCategory.outerwear:
            return '外套';
          case ClothingCategory.underwear:
            return '內衣';
          case ClothingCategory.sportswear:
            return '運動服';
          case ClothingCategory.bags:
            return '包包';
          case ClothingCategory.jewelry:
            return '珠寶';
        }
      default:
        return category.displayName;
    }
  }

  // Gender Options
  String getGenderName(ClothingGender gender) {
    switch (locale.languageCode) {
      case 'ar':
        switch (gender) {
          case ClothingGender.men:
            return 'رجال';
          case ClothingGender.women:
            return 'نساء';
          case ClothingGender.unisex:
            return 'للجنسين';
          case ClothingGender.kids:
            return 'أطفال';
        }
      case 'en':
        return gender.displayName;
      case 'zh':
        switch (gender) {
          case ClothingGender.men:
            return '男士';
          case ClothingGender.women:
            return '女士';
          case ClothingGender.unisex:
            return '中性';
          case ClothingGender.kids:
            return '兒童';
        }
      default:
        return gender.displayName;
    }
  }

  // Season Names
  String getSeasonName(Season season) {
    switch (locale.languageCode) {
      case 'ar':
        switch (season) {
          case Season.spring:
            return 'ربيع';
          case Season.summer:
            return 'صيف';
          case Season.fall:
            return 'خريف';
          case Season.winter:
            return 'شتاء';
          case Season.allSeason:
            return 'جميع المواسم';
        }
      case 'en':
        return season.displayName;
      case 'zh':
        switch (season) {
          case Season.spring:
            return '春季';
          case Season.summer:
            return '夏季';
          case Season.fall:
            return '秋季';
          case Season.winter:
            return '冬季';
          case Season.allSeason:
            return '四季';
        }
      default:
        return season.displayName;
    }
  }

  // Collection Status
  String getCollectionStatusName(CollectionStatus status) {
    switch (locale.languageCode) {
      case 'ar':
        switch (status) {
          case CollectionStatus.upcoming:
            return 'قادمة';
          case CollectionStatus.active:
            return 'نشطة';
          case CollectionStatus.ending:
            return 'تنتهي قريباً';
          case CollectionStatus.ended:
            return 'انتهت';
          case CollectionStatus.archived:
            return 'مؤرشفة';
        }
      case 'en':
        return status.displayName;
      case 'zh':
        switch (status) {
          case CollectionStatus.upcoming:
            return '即將推出';
          case CollectionStatus.active:
            return '活躍';
          case CollectionStatus.ending:
            return '即將結束';
          case CollectionStatus.ended:
            return '已結束';
          case CollectionStatus.archived:
            return '已歸檔';
        }
      default:
        return status.displayName;
    }
  }

  // Loyalty Tiers
  String getLoyaltyTierName(LoyaltyTier tier) {
    switch (locale.languageCode) {
      case 'ar':
        switch (tier) {
          case LoyaltyTier.bronze:
            return 'برونزي';
          case LoyaltyTier.silver:
            return 'فضي';
          case LoyaltyTier.gold:
            return 'ذهبي';
          case LoyaltyTier.platinum:
            return 'بلاتيني';
        }
      case 'en':
        return tier.displayName;
      case 'zh':
        switch (tier) {
          case LoyaltyTier.bronze:
            return '青銅';
          case LoyaltyTier.silver:
            return '白銀';
          case LoyaltyTier.gold:
            return '黃金';
          case LoyaltyTier.platinum:
            return '白金';
        }
      default:
        return tier.displayName;
    }
  }

  // Customer Types
  String getCustomerTypeName(CustomerType type) {
    switch (locale.languageCode) {
      case 'ar':
        switch (type) {
          case CustomerType.regular:
            return 'عميل عادي';
          case CustomerType.vip:
            return 'عميل مميز';
          case CustomerType.wholesale:
            return 'عميل جملة';
          case CustomerType.staff:
            return 'موظف';
        }
      case 'en':
        return type.displayName;
      case 'zh':
        switch (type) {
          case CustomerType.regular:
            return '普通客戶';
          case CustomerType.vip:
            return 'VIP客戶';
          case CustomerType.wholesale:
            return '批發客戶';
          case CustomerType.staff:
            return '員工';
        }
      default:
        return type.displayName;
    }
  }

  // Common UI Text
  String get selectSize => locale.languageCode == 'ar' ? 'اختر المقاس' : 
                          locale.languageCode == 'zh' ? '選擇尺寸' : 'Select Size';
  
  String get selectColor => locale.languageCode == 'ar' ? 'اختر اللون' : 
                           locale.languageCode == 'zh' ? '選擇顏色' : 'Select Color';
  
  String get addToCart => locale.languageCode == 'ar' ? 'أضف للسلة' : 
                         locale.languageCode == 'zh' ? '加入購物車' : 'Add to Cart';
  
  String get viewDetails => locale.languageCode == 'ar' ? 'عرض التفاصيل' : 
                           locale.languageCode == 'zh' ? '查看詳情' : 'View Details';
  
  String get inStock => locale.languageCode == 'ar' ? 'متوفر' : 
                       locale.languageCode == 'zh' ? '有庫存' : 'In Stock';
  
  String get outOfStock => locale.languageCode == 'ar' ? 'نفد المخزون' : 
                          locale.languageCode == 'zh' ? '缺貨' : 'Out of Stock';
  
  String get lowStock => locale.languageCode == 'ar' ? 'مخزون قليل' : 
                        locale.languageCode == 'zh' ? '庫存不足' : 'Low Stock';

  String stockLeft(int count) {
    switch (locale.languageCode) {
      case 'ar':
        return '$count متبقي';
      case 'zh':
        return '剩餘 $count';
      default:
        return '$count left';
    }
  }

  String priceRange(num min, num max) {
    switch (locale.languageCode) {
      case 'ar':
        return '${min.toStringAsFixed(2)} - ${max.toStringAsFixed(2)} ر.س';
      case 'zh':
        return '\$${min.toStringAsFixed(2)} - \$${max.toStringAsFixed(2)}';
      default:
        return '\$${min.toStringAsFixed(2)} - \$${max.toStringAsFixed(2)}';
    }
  }

  String price(num amount) {
    switch (locale.languageCode) {
      case 'ar':
        return '${amount.toStringAsFixed(2)} ر.س';
      case 'zh':
        return '\$${amount.toStringAsFixed(2)}';
      default:
        return '\$${amount.toStringAsFixed(2)}';
    }
  }

  String get loyaltyPoints => locale.languageCode == 'ar' ? 'نقاط الولاء' : 
                             locale.languageCode == 'zh' ? '忠誠度積分' : 'Loyalty Points';

  String pointsEarned(int points) {
    switch (locale.languageCode) {
      case 'ar':
        return 'نقاط مكتسبة: $points';
      case 'zh':
        return '獲得積分：$points';
      default:
        return 'Points Earned: $points';
    }
  }

  String get customerPreferences => locale.languageCode == 'ar' ? 'تفضيلات العميل' : 
                                   locale.languageCode == 'zh' ? '客戶偏好' : 'Customer Preferences';

  String get preferredBrands => locale.languageCode == 'ar' ? 'الماركات المفضلة' : 
                               locale.languageCode == 'zh' ? '偏好品牌' : 'Preferred Brands';

  String get preferredSizes => locale.languageCode == 'ar' ? 'المقاسات المفضلة' : 
                              locale.languageCode == 'zh' ? '偏好尺寸' : 'Preferred Sizes';

  String get preferredColors => locale.languageCode == 'ar' ? 'الألوان المفضلة' : 
                               locale.languageCode == 'zh' ? '偏好顏色' : 'Preferred Colors';

  // Form Labels
  String get formName => locale.languageCode == 'ar' ? 'الاسم' : 
                        locale.languageCode == 'zh' ? '名稱' : 'Name';

  String get formDescription => locale.languageCode == 'ar' ? 'الوصف' : 
                               locale.languageCode == 'zh' ? '描述' : 'Description';

  String get formPrice => locale.languageCode == 'ar' ? 'السعر' : 
                         locale.languageCode == 'zh' ? '價格' : 'Price';

  String get formStock => locale.languageCode == 'ar' ? 'المخزون' : 
                         locale.languageCode == 'zh' ? '庫存' : 'Stock';

  String get formBrand => locale.languageCode == 'ar' ? 'الماركة' : 
                         locale.languageCode == 'zh' ? '品牌' : 'Brand';

  String get formMaterial => locale.languageCode == 'ar' ? 'المادة' : 
                            locale.languageCode == 'zh' ? '材質' : 'Material';

  String get formCareInstructions => locale.languageCode == 'ar' ? 'تعليمات العناية' : 
                                    locale.languageCode == 'zh' ? '保養說明' : 'Care Instructions';

  // Size Names (Arabic specific)
  Map<String, String> get sizeNames {
    switch (locale.languageCode) {
      case 'ar':
        return {
          'XS': 'صغير جداً',
          'S': 'صغير',
          'M': 'متوسط',
          'L': 'كبير',
          'XL': 'كبير جداً',
          'XXL': 'كبير جداً جداً',
          'OS': 'مقاس واحد',
        };
      case 'zh':
        return {
          'XS': '特小',
          'S': '小',
          'M': '中',
          'L': '大',
          'XL': '特大',
          'XXL': '加大',
          'OS': '均碼',
        };
      default:
        return {
          'XS': 'Extra Small',
          'S': 'Small',
          'M': 'Medium',
          'L': 'Large',
          'XL': 'Extra Large',
          'XXL': 'Double Extra Large',
          'OS': 'One Size',
        };
    }
  }

  // Color Names (Arabic specific)
  Map<String, String> get colorNames {
    switch (locale.languageCode) {
      case 'ar':
        return {
          'Black': 'أسود',
          'White': 'أبيض',
          'Red': 'أحمر',
          'Blue': 'أزرق',
          'Green': 'أخضر',
          'Yellow': 'أصفر',
          'Purple': 'بنفسجي',
          'Orange': 'برتقالي',
          'Pink': 'وردي',
          'Brown': 'بني',
          'Gray': 'رمادي',
          'Navy Blue': 'أزرق بحري',
          'Burgundy': 'عنابي',
          'Forest Green': 'أخضر غابات',
          'Olive Green': 'أخضر زيتوني',
          'Tan': 'بني فاتح',
          'Khaki': 'كاكي',
        };
      case 'zh':
        return {
          'Black': '黑色',
          'White': '白色',
          'Red': '紅色',
          'Blue': '藍色',
          'Green': '綠色',
          'Yellow': '黃色',
          'Purple': '紫色',
          'Orange': '橙色',
          'Pink': '粉色',
          'Brown': '棕色',
          'Gray': '灰色',
          'Navy Blue': '海軍藍',
          'Burgundy': '酒紅色',
          'Forest Green': '森林綠',
          'Olive Green': '橄欖綠',
          'Tan': '棕褐色',
          'Khaki': '卡其色',
        };
      default:
        return {
          'Black': 'Black',
          'White': 'White',
          'Red': 'Red',
          'Blue': 'Blue',
          'Green': 'Green',
          'Yellow': 'Yellow',
          'Purple': 'Purple',
          'Orange': 'Orange',
          'Pink': 'Pink',
          'Brown': 'Brown',
          'Gray': 'Gray',
          'Navy Blue': 'Navy Blue',
          'Burgundy': 'Burgundy',
          'Forest Green': 'Forest Green',
          'Olive Green': 'Olive Green',
          'Tan': 'Tan',
          'Khaki': 'Khaki',
        };
    }
  }

  // Common Phrases
  String get selectSizeFirst => locale.languageCode == 'ar' ? 'يرجى اختيار المقاس أولاً' : 
                               locale.languageCode == 'zh' ? '請先選擇尺寸' : 'Please select a size first';

  String get noVariantsAvailable => locale.languageCode == 'ar' ? 'لا توجد متغيرات متاحة' : 
                                   locale.languageCode == 'zh' ? '沒有可用的變體' : 'No variants available';

  String get variantOutOfStock => locale.languageCode == 'ar' ? 'هذا المتغير غير متوفر' : 
                                 locale.languageCode == 'zh' ? '此變體缺貨' : 'This variant is out of stock';

  String variantPrice(num basePrice, num adjustment) {
    final totalPrice = basePrice + adjustment;
    switch (locale.languageCode) {
      case 'ar':
        if (adjustment == 0) return '${totalPrice.toStringAsFixed(2)} ر.س';
        final adjustmentText = adjustment > 0 ? '+${adjustment.toStringAsFixed(2)}' : '${adjustment.toStringAsFixed(2)}';
        return '${totalPrice.toStringAsFixed(2)} ر.س ($adjustmentText)';
      case 'zh':
        if (adjustment == 0) return '\$${totalPrice.toStringAsFixed(2)}';
        final adjustmentText = adjustment > 0 ? '+\$${adjustment.toStringAsFixed(2)}' : '-\$${(-adjustment).toStringAsFixed(2)}';
        return '\$${totalPrice.toStringAsFixed(2)} ($adjustmentText)';
      default:
        if (adjustment == 0) return '\$${totalPrice.toStringAsFixed(2)}';
        final adjustmentText = adjustment > 0 ? '+\$${adjustment.toStringAsFixed(2)}' : '-\$${(-adjustment).toStringAsFixed(2)}';
        return '\$${totalPrice.toStringAsFixed(2)} ($adjustmentText)';
    }
  }

  // Helper method to get localized size name
  String getLocalizedSizeName(String sizeName) {
    return sizeNames[sizeName] ?? sizeName;
  }

  // Helper method to get localized color name
  String getLocalizedColorName(String colorName) {
    return colorNames[colorName] ?? colorName;
  }
}

// Extension to make it easier to use
extension ClothingLocalizationsExtension on BuildContext {
  ClothingLocalizations get clothingL10n => ClothingLocalizations.of(this);
}
