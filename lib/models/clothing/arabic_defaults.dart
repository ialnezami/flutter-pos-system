import 'package:possystem/models/clothing/clothing_product.dart';
import 'package:possystem/models/clothing/size.dart';
import 'package:possystem/models/clothing/color.dart';
import 'package:possystem/models/clothing/collection.dart';

/// Arabic-specific default data for clothing store
class ArabicClothingDefaults {
  
  /// Arabic size names mapping
  static const Map<String, String> arabicSizeNames = {
    'XS': 'صغير جداً',
    'S': 'صغير',
    'M': 'متوسط',
    'L': 'كبير',
    'XL': 'كبير جداً',
    'XXL': 'كبير جداً جداً',
    'OS': 'مقاس واحد',
    // Numeric sizes
    '32': 'مقاس ٣٢',
    '34': 'مقاس ٣٤',
    '36': 'مقاس ٣٦',
    '38': 'مقاس ٣٨',
    '40': 'مقاس ٤٠',
    '42': 'مقاس ٤٢',
    '44': 'مقاس ٤٤',
    '46': 'مقاس ٤٦',
    // Shoe sizes
    '35': 'مقاس ٣٥',
    '36': 'مقاس ٣٦',
    '37': 'مقاس ٣٧',
    '38': 'مقاس ٣٨',
    '39': 'مقاس ٣٩',
    '40': 'مقاس ٤٠',
    '41': 'مقاس ٤١',
    '42': 'مقاس ٤٢',
    '43': 'مقاس ٤٣',
    '44': 'مقاس ٤٤',
    '45': 'مقاس ٤٥',
  };

  /// Arabic color names mapping
  static const Map<String, String> arabicColorNames = {
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
    'Royal Blue': 'أزرق ملكي',
    'Sky Blue': 'أزرق سماوي',
    'Denim Blue': 'أزرق جينز',
    'Burgundy': 'عنابي',
    'Maroon': 'كستنائي',
    'Forest Green': 'أخضر غابات',
    'Olive Green': 'أخضر زيتوني',
    'Mint Green': 'أخضر نعناعي',
    'Tan': 'بني فاتح',
    'Khaki': 'كاكي',
    'Cream': 'كريمي',
    'Beige': 'بيج',
    'Charcoal': 'فحمي',
  };

  /// Arabic category names mapping
  static const Map<ClothingCategory, String> arabicCategoryNames = {
    ClothingCategory.shirts: 'قمصان',
    ClothingCategory.pants: 'بناطيل',
    ClothingCategory.dresses: 'فساتين',
    ClothingCategory.shoes: 'أحذية',
    ClothingCategory.accessories: 'إكسسوارات',
    ClothingCategory.outerwear: 'ملابس خارجية',
    ClothingCategory.underwear: 'ملابس داخلية',
    ClothingCategory.sportswear: 'ملابس رياضية',
    ClothingCategory.bags: 'حقائب',
    ClothingCategory.jewelry: 'مجوهرات',
  };

  /// Arabic gender names mapping
  static const Map<ClothingGender, String> arabicGenderNames = {
    ClothingGender.men: 'رجال',
    ClothingGender.women: 'نساء',
    ClothingGender.unisex: 'للجنسين',
    ClothingGender.kids: 'أطفال',
  };

  /// Arabic season names mapping
  static const Map<Season, String> arabicSeasonNames = {
    Season.spring: 'ربيع',
    Season.summer: 'صيف',
    Season.fall: 'خريف',
    Season.winter: 'شتاء',
    Season.allSeason: 'جميع المواسم',
  };

  /// Get Arabic-localized sizes for clothing
  static List<Size> getArabicClothingSizes() {
    return [
      Size(
        id: 'clothing_xs',
        name: 'XS',
        displayName: 'صغير جداً',
        category: SizeCategory.clothing,
        type: SizeType.letter,
        sortOrder: 1,
      ),
      Size(
        id: 'clothing_s',
        name: 'S',
        displayName: 'صغير',
        category: SizeCategory.clothing,
        type: SizeType.letter,
        sortOrder: 2,
      ),
      Size(
        id: 'clothing_m',
        name: 'M',
        displayName: 'متوسط',
        category: SizeCategory.clothing,
        type: SizeType.letter,
        sortOrder: 3,
      ),
      Size(
        id: 'clothing_l',
        name: 'L',
        displayName: 'كبير',
        category: SizeCategory.clothing,
        type: SizeType.letter,
        sortOrder: 4,
      ),
      Size(
        id: 'clothing_xl',
        name: 'XL',
        displayName: 'كبير جداً',
        category: SizeCategory.clothing,
        type: SizeType.letter,
        sortOrder: 5,
      ),
      Size(
        id: 'clothing_xxl',
        name: 'XXL',
        displayName: 'كبير جداً جداً',
        category: SizeCategory.clothing,
        type: SizeType.letter,
        sortOrder: 6,
      ),
    ];
  }

  /// Get Arabic-localized colors
  static List<ClothingColor> getArabicColors() {
    return [
      ClothingColor(
        id: 'black',
        name: 'Black',
        hexCode: '#000000',
        colorFamily: 'محايد',
        sortOrder: 1,
      ),
      ClothingColor(
        id: 'white',
        name: 'White',
        hexCode: '#FFFFFF',
        colorFamily: 'محايد',
        sortOrder: 2,
      ),
      ClothingColor(
        id: 'gray',
        name: 'Gray',
        hexCode: '#808080',
        colorFamily: 'محايد',
        sortOrder: 3,
      ),
      ClothingColor(
        id: 'navy_blue',
        name: 'Navy Blue',
        hexCode: '#000080',
        colorFamily: 'أزرق',
        sortOrder: 10,
      ),
      ClothingColor(
        id: 'royal_blue',
        name: 'Royal Blue',
        hexCode: '#4169E1',
        colorFamily: 'أزرق',
        sortOrder: 11,
      ),
      ClothingColor(
        id: 'red',
        name: 'Red',
        hexCode: '#FF0000',
        colorFamily: 'أحمر',
        sortOrder: 20,
      ),
      ClothingColor(
        id: 'burgundy',
        name: 'Burgundy',
        hexCode: '#800020',
        colorFamily: 'أحمر',
        sortOrder: 21,
      ),
      ClothingColor(
        id: 'forest_green',
        name: 'Forest Green',
        hexCode: '#228B22',
        colorFamily: 'أخضر',
        sortOrder: 30,
      ),
      ClothingColor(
        id: 'olive_green',
        name: 'Olive Green',
        hexCode: '#808000',
        colorFamily: 'أخضر',
        sortOrder: 31,
      ),
      ClothingColor(
        id: 'brown',
        name: 'Brown',
        hexCode: '#A52A2A',
        colorFamily: 'بني',
        sortOrder: 40,
      ),
      ClothingColor(
        id: 'tan',
        name: 'Tan',
        hexCode: '#D2B48C',
        colorFamily: 'بني',
        sortOrder: 41,
      ),
    ];
  }

  /// Popular Arabic/Middle Eastern brands
  static const List<String> popularArabicBrands = [
    'أناقة', // Anaqah (Elegance)
    'روعة', // Rawaa (Magnificence)
    'زهرة', // Zahra (Flower)
    'نجمة', // Najma (Star)
    'لؤلؤة', // Lulua (Pearl)
    'ريم', // Reem
    'نور', // Noor (Light)
    'جمال', // Jamal (Beauty)
    'فخامة', // Fakhamah (Luxury)
    'أصالة', // Asalah (Authenticity)
  ];

  /// Arabic collection names for different seasons
  static List<ClothingCollection> getArabicSeasonalCollections(int year) {
    return [
      ClothingCollection(
        id: 'spring_$year',
        name: 'مجموعة الربيع $year',
        description: 'ملابس ربيعية أنيقة وعملية',
        season: Season.spring,
        year: year,
        startDate: DateTime(year, 3, 1),
        endDate: DateTime(year, 5, 31),
        theme: 'ألوان زاهية ومريحة',
        targetDemographic: ['شباب', 'عائلات', 'مهنيون'],
      ),
      ClothingCollection(
        id: 'summer_$year',
        name: 'مجموعة الصيف $year',
        description: 'ملابس صيفية خفيفة ومنعشة',
        season: Season.summer,
        year: year,
        startDate: DateTime(year, 6, 1),
        endDate: DateTime(year, 8, 31),
        theme: 'ملابس خفيفة وألوان فاتحة',
        targetDemographic: ['شباب', 'رياضيون', 'عائلات'],
      ),
      ClothingCollection(
        id: 'fall_$year',
        name: 'مجموعة الخريف $year',
        description: 'ملابس خريفية دافئة وأنيقة',
        season: Season.fall,
        year: year,
        startDate: DateTime(year, 9, 1),
        endDate: DateTime(year, 11, 30),
        theme: 'ألوان ترابية ودافئة',
        targetDemographic: ['مهنيون', 'طلاب', 'عائلات'],
      ),
      ClothingCollection(
        id: 'winter_$year',
        name: 'مجموعة الشتاء $year',
        description: 'ملابس شتوية دافئة ومقاومة للبرد',
        season: Season.winter,
        year: year,
        startDate: DateTime(year, 12, 1),
        endDate: DateTime(year + 1, 2, 28),
        theme: 'ملابس دافئة وعملية',
        targetDemographic: ['جميع الأعمار'],
      ),
    ];
  }

  /// Arabic material names
  static const Map<String, String> arabicMaterialNames = {
    'Cotton': 'قطن',
    '100% Cotton': '١٠٠٪ قطن',
    'Polyester': 'بوليستر',
    'Wool': 'صوف',
    'Silk': 'حرير',
    'Linen': 'كتان',
    'Denim': 'جينز',
    'Leather': 'جلد',
    'Synthetic': 'صناعي',
    'Blend': 'مخلوط',
    'Cashmere': 'كشمير',
    'Viscose': 'فيسكوز',
    'Spandex': 'سباندكس',
    'Nylon': 'نايلون',
  };

  /// Arabic care instruction names
  static const Map<String, String> arabicCareInstructions = {
    'Machine Wash Cold': 'غسيل آلة بالماء البارد',
    'Hand Wash Only': 'غسيل يدوي فقط',
    'Dry Clean Only': 'تنظيف جاف فقط',
    'Do Not Bleach': 'لا تستخدم المبيض',
    'Tumble Dry Low': 'تجفيف على حرارة منخفضة',
    'Air Dry': 'تجفيف بالهواء',
    'Iron Low Heat': 'كي على حرارة منخفضة',
    'Do Not Iron': 'لا تكوي',
    'Professional Clean': 'تنظيف مهني',
  };

  /// Arabic style names
  static const Map<String, String> arabicStyleNames = {
    'Casual': 'كاجوال',
    'Formal': 'رسمي',
    'Business': 'أعمال',
    'Sport': 'رياضي',
    'Evening': 'سهرة',
    'Traditional': 'تقليدي',
    'Modern': 'عصري',
    'Classic': 'كلاسيكي',
    'Trendy': 'عصري',
    'Vintage': 'قديم',
    'Bohemian': 'بوهيمي',
    'Minimalist': 'بسيط',
  };

  /// Arabic product names for common clothing items
  static const Map<String, String> arabicProductNames = {
    // Shirts
    'T-Shirt': 'تيشيرت',
    'Polo Shirt': 'بولو شيرت',
    'Dress Shirt': 'قميص رسمي',
    'Casual Shirt': 'قميص كاجوال',
    'Blouse': 'بلوزة',
    'Tank Top': 'تانك توب',
    
    // Pants
    'Jeans': 'جينز',
    'Trousers': 'بنطلون',
    'Chinos': 'تشينوز',
    'Shorts': 'شورت',
    'Leggings': 'ليجنز',
    'Sweatpants': 'بنطلون رياضي',
    
    // Dresses
    'Casual Dress': 'فستان كاجوال',
    'Evening Dress': 'فستان سهرة',
    'Summer Dress': 'فستان صيفي',
    'Maxi Dress': 'فستان طويل',
    'Mini Dress': 'فستان قصير',
    
    // Shoes
    'Sneakers': 'حذاء رياضي',
    'Dress Shoes': 'حذاء رسمي',
    'Sandals': 'صندل',
    'Boots': 'بوت',
    'Heels': 'كعب عالي',
    'Flats': 'حذاء مسطح',
    
    // Accessories
    'Belt': 'حزام',
    'Watch': 'ساعة',
    'Sunglasses': 'نظارة شمسية',
    'Hat': 'قبعة',
    'Scarf': 'وشاح',
    'Tie': 'ربطة عنق',
    'Wallet': 'محفظة',
    'Handbag': 'حقيبة يد',
    'Backpack': 'حقيبة ظهر',
    'Jewelry': 'مجوهرات',
  };

  /// Get Arabic size with display name
  static Size getArabicSize(String sizeName, SizeCategory category, SizeType type, int sortOrder) {
    return Size(
      id: '${category.name}_$sizeName',
      name: sizeName,
      displayName: arabicSizeNames[sizeName] ?? sizeName,
      category: category,
      type: type,
      sortOrder: sortOrder,
    );
  }

  /// Get Arabic color with display name
  static ClothingColor getArabicColor(String colorName, String hexCode, String? family, int sortOrder) {
    return ClothingColor(
      id: colorName.toLowerCase().replaceAll(' ', '_'),
      name: colorName,
      hexCode: hexCode,
      colorFamily: family,
      sortOrder: sortOrder,
    );
  }

  /// Create a sample Arabic clothing product
  static ClothingProduct createSampleArabicProduct() {
    return ClothingProduct(
      id: 'sample_arabic_shirt',
      name: 'قميص قطني كلاسيكي',
      brand: 'أناقة',
      category: ClothingCategory.shirts,
      gender: ClothingGender.men,
      season: 'ربيع ٢٠٢٤',
      collection: 'مجموعة الأساسيات',
      material: '١٠٠٪ قطن',
      careInstructions: 'غسيل آلة بالماء البارد',
      price: 89.99,
      cost: 35.00,
      tags: ['كاجوال', 'مريح', 'قطني'],
      attributes: {
        'النمط': 'كلاسيكي',
        'الموسم': 'ربيع/صيف',
        'المناسبة': 'يومي',
      },
    );
  }

  /// Get Arabic day names
  static const Map<int, String> arabicDayNames = {
    1: 'الاثنين',
    2: 'الثلاثاء',
    3: 'الأربعاء',
    4: 'الخميس',
    5: 'الجمعة',
    6: 'السبت',
    7: 'الأحد',
  };

  /// Get Arabic month names
  static const Map<int, String> arabicMonthNames = {
    1: 'يناير',
    2: 'فبراير',
    3: 'مارس',
    4: 'أبريل',
    5: 'مايو',
    6: 'يونيو',
    7: 'يوليو',
    8: 'أغسطس',
    9: 'سبتمبر',
    10: 'أكتوبر',
    11: 'نوفمبر',
    12: 'ديسمبر',
  };

  /// Format Arabic currency (Saudi Riyal)
  static String formatCurrency(num amount) {
    return '${amount.toStringAsFixed(2)} ر.س';
  }

  /// Format Arabic date
  static String formatArabicDate(DateTime date) {
    final day = date.day;
    final month = arabicMonthNames[date.month] ?? date.month.toString();
    final year = date.year;
    return '$day $month $year';
  }

  /// Convert English numbers to Arabic numerals
  static String toArabicNumerals(String text) {
    const englishToArabic = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    };

    String result = text;
    englishToArabic.forEach((english, arabic) {
      result = result.replaceAll(english, arabic);
    });
    return result;
  }

  /// Get RTL-friendly text direction
  static TextDirection getTextDirection() {
    return TextDirection.rtl;
  }

  /// Get Arabic-specific text alignment
  static TextAlign getTextAlign() {
    return TextAlign.right;
  }

  /// Get Arabic-specific cross axis alignment
  static CrossAxisAlignment getCrossAxisAlignment() {
    return CrossAxisAlignment.end;
  }

  /// Get Arabic-specific main axis alignment
  static MainAxisAlignment getMainAxisAlignment() {
    return MainAxisAlignment.end;
  }
}
