import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:csv/csv.dart';
import '../models/category.dart';

// Enums for product attributes
enum ProductSize {
  xs('صغير جداً'),
  s('صغير'),
  m('متوسط'),
  l('كبير'),
  xl('كبير جداً'),
  xxl('كبير جداً جداً'),
  freeSize('مقاس حر'),
  size36('36'),
  size37('37'),
  size38('38'),
  size39('39'),
  size40('40'),
  size41('41'),
  size42('42'),
  size43('43'),
  size44('44'),
  size45('45'),
  size46('46');

  const ProductSize(this.arabicName);
  final String arabicName;
}

enum ProductColor {
  white('أبيض'),
  black('أسود'),
  red('أحمر'),
  blue('أزرق'),
  green('أخضر'),
  yellow('أصفر'),
  pink('وردي'),
  purple('بنفسجي'),
  orange('برتقالي'),
  brown('بني'),
  gray('رمادي'),
  beige('بيج'),
  navy('كحلي'),
  gold('ذهبي'),
  silver('فضي'),
  multicolor('ملون'),
  transparent('شفاف'),
  natural('طبيعي');

  const ProductColor(this.arabicName);
  final String arabicName;
}

enum ProductMaterial {
  cotton('قطن'),
  silk('حرير'),
  wool('صوف'),
  leather('جلد'),
  denim('جينز'),
  polyester('بوليستر'),
  linen('كتان'),
  flannel('فلانيل'),
  cashmere('كشمير'),
  synthetic('صناعي'),
  metal('معدن'),
  plastic('بلاستيك'),
  glass('زجاج'),
  rubber('مطاط'),
  canvas('كانفاس'),
  nylon('نايلون'),
  velvet('مخمل'),
  satin('ساتان');

  const ProductMaterial(this.arabicName);
  final String arabicName;
}

enum ProductCategory {
  shirts('قمصان'),
  pants('بناطيل'),
  dresses('فساتين'),
  shoes('أحذية'),
  jackets('جاكيتات'),
  watches('ساعات'),
  bags('حقائب'),
  jewelry('مجوهرات'),
  sunglasses('نظارات'),
  belts('أحزمة'),
  hats('قبعات'),
  socks('جوارب'),
  underwear('ملابس داخلية'),
  sportswear('ملابس رياضية'),
  accessories('إكسسوارات عامة');

  const ProductCategory(this.arabicName);
  final String arabicName;
}

class EnhancedDatabaseService {
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }
  
  Future<String> _getDatabasePath() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "enhanced_pos_database.db");
    return path;
  }

  Future<Database> _initDB() async {
    String path = await _getDatabasePath();
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createTables,
      onUpgrade: _upgradeTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Enhanced products table
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        tags TEXT,
        buy_price REAL NOT NULL,
        sell_price REAL NOT NULL,
        size TEXT NOT NULL,
        color TEXT NOT NULL,
        material TEXT NOT NULL,
        stock_quantity INTEGER NOT NULL DEFAULT 0,
        min_stock_level INTEGER DEFAULT 5,
        barcode TEXT UNIQUE,
        description TEXT,
        image_paths TEXT,
        created_date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // Sales table
    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_amount REAL NOT NULL,
        total_cost REAL NOT NULL,
        profit_amount REAL NOT NULL,
        paid_amount REAL NOT NULL,
        change_amount REAL NOT NULL,
        payment_method TEXT NOT NULL,
        cashier_name TEXT NOT NULL,
        customer_name TEXT,
        sale_date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // Sale items table
    await db.execute('''
      CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        buy_price REAL NOT NULL,
        sell_price REAL NOT NULL,
        total_cost REAL NOT NULL,
        total_price REAL NOT NULL,
        FOREIGN KEY (sale_id) REFERENCES sales (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
      )
    ''');
    
    // Inventory movements table
    await db.execute('''
      CREATE TABLE inventory_movements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        type TEXT NOT NULL, -- 'in' or 'out'
        quantity INTEGER NOT NULL,
        cost_per_unit REAL,
        total_cost REAL,
        reason TEXT,
        movement_date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
      )
    ''');
    
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL -- 'admin', 'cashier'
      )
    ''');
    
    // Product tags table (for many-to-many relationship)
    await db.execute('''
      CREATE TABLE product_tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        tag_name TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
      )
    ''');
    
    // Insert default admin user
    await db.insert('users', {'username': 'admin', 'password': 'admin', 'role': 'admin'});
    
    // Insert comprehensive inventory
    await _insertInitialInventory(db);
  }

  Future<void> _upgradeTables(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns to existing products table
      await db.execute('ALTER TABLE products ADD COLUMN tags TEXT');
      await db.execute('ALTER TABLE products ADD COLUMN buy_price REAL DEFAULT 0');
      await db.execute('ALTER TABLE products ADD COLUMN sell_price REAL DEFAULT 0');
      await db.execute('ALTER TABLE products ADD COLUMN material TEXT DEFAULT "قطن"');
      await db.execute('ALTER TABLE products ADD COLUMN min_stock_level INTEGER DEFAULT 5');
      await db.execute('ALTER TABLE products ADD COLUMN description TEXT');
      
      // Update existing price column to sell_price
      await db.execute('UPDATE products SET sell_price = price WHERE sell_price = 0');
      await db.execute('UPDATE products SET buy_price = price * 0.6 WHERE buy_price = 0');
    }
  }

  Future<void> _insertInitialInventory(Database db) async {
    final products = [
      // قمصان (Shirts) - 15 items
      {'name': 'قميص قطني أبيض كلاسيكي', 'category': 'قمصان', 'tags': 'كاجوال,قطن,أساسي', 'buy_price': 80.0, 'sell_price': 120.0, 'size': 'صغير', 'color': 'أبيض', 'material': 'قطن', 'stock_quantity': 25, 'barcode': '1001001001', 'description': 'قميص قطني مريح للاستخدام اليومي'},
      {'name': 'قميص قطني أزرق عملي', 'category': 'قمصان', 'tags': 'عمل,قطن,كلاسيكي', 'buy_price': 85.0, 'sell_price': 130.0, 'size': 'متوسط', 'color': 'أزرق', 'material': 'قطن', 'stock_quantity': 30, 'barcode': '1001001002', 'description': 'قميص مثالي للعمل والمناسبات'},
      {'name': 'قميص قطني أسود أنيق', 'category': 'قمصان', 'tags': 'أنيق,قطن,مسائي', 'buy_price': 90.0, 'sell_price': 140.0, 'size': 'كبير', 'color': 'أسود', 'material': 'قطن', 'stock_quantity': 20, 'barcode': '1001001003', 'description': 'قميص أسود أنيق للمناسبات الخاصة'},
      {'name': 'قميص حرير فاخر أبيض', 'category': 'قمصان', 'tags': 'فاخر,حرير,رسمي', 'buy_price': 200.0, 'sell_price': 350.0, 'size': 'متوسط', 'color': 'أبيض', 'material': 'حرير', 'stock_quantity': 8, 'barcode': '1001001004', 'description': 'قميص حرير فاخر للمناسبات الرسمية'},
      {'name': 'قميص بولو رياضي أحمر', 'category': 'قمصان', 'tags': 'رياضي,بولو,كاجوال', 'buy_price': 100.0, 'sell_price': 160.0, 'size': 'صغير', 'color': 'أحمر', 'material': 'قطن', 'stock_quantity': 12, 'barcode': '1001001005', 'description': 'قميص بولو مريح للأنشطة الرياضية'},
      {'name': 'قميص جينز كاجوال', 'category': 'قمصان', 'tags': 'جينز,كاجوال,عصري', 'buy_price': 120.0, 'sell_price': 200.0, 'size': 'كبير', 'color': 'أزرق جينز', 'material': 'جينز', 'stock_quantity': 10, 'barcode': '1001001006', 'description': 'قميص جينز عصري للإطلالة الكاجوال'},
      {'name': 'قميص كتان صيفي بيج', 'category': 'قمصان', 'tags': 'صيفي,كتان,خفيف', 'buy_price': 130.0, 'sell_price': 220.0, 'size': 'متوسط', 'color': 'بيج', 'material': 'كتان', 'stock_quantity': 12, 'barcode': '1001001007', 'description': 'قميص كتان مثالي للطقس الحار'},
      {'name': 'قميص فلانيل شتوي', 'category': 'قمصان', 'tags': 'شتوي,فلانيل,دافئ', 'buy_price': 110.0, 'sell_price': 170.0, 'size': 'كبير', 'color': 'أحمر', 'material': 'فلانيل', 'stock_quantity': 15, 'barcode': '1001001008', 'description': 'قميص فلانيل دافئ للشتاء'},
      {'name': 'قميص رياضي تقني', 'category': 'قمصان', 'tags': 'رياضي,تقني,سريع_الجفاف', 'buy_price': 60.0, 'sell_price': 90.0, 'size': 'متوسط', 'color': 'رمادي', 'material': 'بوليستر', 'stock_quantity': 22, 'barcode': '1001001009', 'description': 'قميص رياضي بتقنية سريع الجفاف'},
      {'name': 'قميص مقلم عصري', 'category': 'قمصان', 'tags': 'مقلم,عصري,شبابي', 'buy_price': 95.0, 'sell_price': 140.0, 'size': 'صغير', 'color': 'مقلم', 'material': 'قطن', 'stock_quantity': 16, 'barcode': '1001001010', 'description': 'قميص بخطوط عصرية للشباب'},
      {'name': 'قميص هاواي ملون', 'category': 'قمصان', 'tags': 'هاواي,صيفي,ملون', 'buy_price': 85.0, 'sell_price': 130.0, 'size': 'كبير', 'color': 'ملون', 'material': 'قطن', 'stock_quantity': 9, 'barcode': '1001001011', 'description': 'قميص هاواي ملون للعطلات'},
      {'name': 'قميص تيشرت أساسي', 'category': 'قمصان', 'tags': 'تيشرت,أساسي,يومي', 'buy_price': 40.0, 'sell_price': 70.0, 'size': 'متوسط', 'color': 'أبيض', 'material': 'قطن', 'stock_quantity': 35, 'barcode': '1001001012', 'description': 'تيشرت أساسي للاستخدام اليومي'},
      {'name': 'قميص تيشرت أسود', 'category': 'قمصان', 'tags': 'تيشرت,أساسي,كلاسيكي', 'buy_price': 40.0, 'sell_price': 70.0, 'size': 'كبير', 'color': 'أسود', 'material': 'قطن', 'stock_quantity': 30, 'barcode': '1001001013', 'description': 'تيشرت أسود كلاسيكي'},
      {'name': 'قميص رسمي أبيض فاخر', 'category': 'قمصان', 'tags': 'رسمي,فاخر,عمل', 'buy_price': 150.0, 'sell_price': 250.0, 'size': 'متوسط', 'color': 'أبيض', 'material': 'قطن', 'stock_quantity': 11, 'barcode': '1001001014', 'description': 'قميص رسمي فاخر للعمل'},
      {'name': 'قميص تانك توب رياضي', 'category': 'قمصان', 'tags': 'رياضي,تانك_توب,صيفي', 'buy_price': 35.0, 'sell_price': 60.0, 'size': 'صغير', 'color': 'أزرق', 'material': 'بوليستر', 'stock_quantity': 28, 'barcode': '1001001015', 'description': 'تانك توب رياضي للتمارين'},

      // بناطيل (Pants) - 15 items
      {'name': 'بنطلون جينز كلاسيكي أزرق', 'category': 'بناطيل', 'tags': 'جينز,كلاسيكي,يومي', 'buy_price': 180.0, 'sell_price': 280.0, 'size': '32', 'color': 'أزرق', 'material': 'جينز', 'stock_quantity': 20, 'barcode': '1002002001', 'description': 'بنطلون جينز كلاسيكي عالي الجودة'},
      {'name': 'بنطلون جينز أسود ضيق', 'category': 'بناطيل', 'tags': 'جينز,ضيق,عصري', 'buy_price': 190.0, 'sell_price': 290.0, 'size': '34', 'color': 'أسود', 'material': 'جينز', 'stock_quantity': 18, 'barcode': '1002002002', 'description': 'بنطلون جينز أسود بقصة ضيقة عصرية'},
      {'name': 'بنطلون كلاسيكي رسمي', 'category': 'بناطيل', 'tags': 'رسمي,عمل,كلاسيكي', 'buy_price': 200.0, 'sell_price': 320.0, 'size': '36', 'color': 'رمادي', 'material': 'صوف', 'stock_quantity': 15, 'barcode': '1002002003', 'description': 'بنطلون رسمي للعمل والمناسبات'},
      {'name': 'بنطلون رياضي مرن', 'category': 'بناطيل', 'tags': 'رياضي,مرن,مريح', 'buy_price': 90.0, 'sell_price': 150.0, 'size': 'متوسط', 'color': 'أزرق', 'material': 'بوليستر', 'stock_quantity': 25, 'barcode': '1002002004', 'description': 'بنطلون رياضي مرن للتمارين'},
      {'name': 'بنطلون شورت صيفي', 'category': 'بناطيل', 'tags': 'شورت,صيفي,خفيف', 'buy_price': 80.0, 'sell_price': 120.0, 'size': '32', 'color': 'خاكي', 'material': 'قطن', 'stock_quantity': 20, 'barcode': '1002002005', 'description': 'شورت صيفي مريح'},
      {'name': 'بنطلون كارجو عملي', 'category': 'بناطيل', 'tags': 'كارجو,عملي,جيوب', 'buy_price': 160.0, 'sell_price': 250.0, 'size': '36', 'color': 'أخضر زيتوني', 'material': 'قطن', 'stock_quantity': 14, 'barcode': '1002002006', 'description': 'بنطلون كارجو بجيوب متعددة'},
      {'name': 'بنطلون كتان صيفي', 'category': 'بناطيل', 'tags': 'كتان,صيفي,مريح', 'buy_price': 140.0, 'sell_price': 220.0, 'size': '34', 'color': 'بيج', 'material': 'كتان', 'stock_quantity': 10, 'barcode': '1002002007', 'description': 'بنطلون كتان مثالي للصيف'},
      {'name': 'بنطلون جلد فاخر', 'category': 'بناطيل', 'tags': 'جلد,فاخر,أنيق', 'buy_price': 300.0, 'sell_price': 450.0, 'size': '32', 'color': 'أسود', 'material': 'جلد', 'stock_quantity': 6, 'barcode': '1002002008', 'description': 'بنطلون جلد فاخر للمناسبات الخاصة'},
      {'name': 'بنطلون تراك سوت', 'category': 'بناطيل', 'tags': 'تراك_سوت,رياضي,مريح', 'buy_price': 110.0, 'sell_price': 180.0, 'size': 'كبير', 'color': 'رمادي', 'material': 'قطن', 'stock_quantity': 18, 'barcode': '1002002009', 'description': 'بنطلون تراك سوت للراحة والرياضة'},
      {'name': 'بنطلون رسمي كحلي', 'category': 'بناطيل', 'tags': 'رسمي,أنيق,عمل', 'buy_price': 250.0, 'sell_price': 380.0, 'size': '36', 'color': 'كحلي', 'material': 'صوف', 'stock_quantity': 8, 'barcode': '1002002010', 'description': 'بنطلون رسمي كحلي للعمل'},
      {'name': 'بنطلون واسع عصري', 'category': 'بناطيل', 'tags': 'واسع,عصري,مريح', 'buy_price': 130.0, 'sell_price': 200.0, 'size': '34', 'color': 'أبيض', 'material': 'قطن', 'stock_quantity': 12, 'barcode': '1002002011', 'description': 'بنطلون واسع بقصة عصرية'},
      {'name': 'بنطلون ضيق أسود', 'category': 'بناطيل', 'tags': 'ضيق,عصري,شبابي', 'buy_price': 150.0, 'sell_price': 240.0, 'size': '32', 'color': 'أسود', 'material': 'قطن', 'stock_quantity': 14, 'barcode': '1002002012', 'description': 'بنطلون ضيق عصري للشباب'},
      {'name': 'بنطلون جوجر رياضي', 'category': 'بناطيل', 'tags': 'جوجر,رياضي,مرن', 'buy_price': 95.0, 'sell_price': 160.0, 'size': 'متوسط', 'color': 'أسود', 'material': 'قطن', 'stock_quantity': 22, 'barcode': '1002002013', 'description': 'بنطلون جوجر مرن ومريح'},
      {'name': 'بنطلون شينو أنيق', 'category': 'بناطيل', 'tags': 'شينو,أنيق,كاجوال_رسمي', 'buy_price': 140.0, 'sell_price': 220.0, 'size': '36', 'color': 'بيج', 'material': 'قطن', 'stock_quantity': 16, 'barcode': '1002002014', 'description': 'بنطلون شينو أنيق للمناسبات المختلطة'},
      {'name': 'بنطلون مخمل فاخر', 'category': 'بناطيل', 'tags': 'مخمل,فاخر,مسائي', 'buy_price': 180.0, 'sell_price': 280.0, 'size': '34', 'color': 'كحلي', 'material': 'مخمل', 'stock_quantity': 9, 'barcode': '1002002015', 'description': 'بنطلون مخمل فاخر للمساء'},

      // فساتين (Dresses) - 12 items
      {'name': 'فستان صيفي قطني', 'category': 'فساتين', 'tags': 'صيفي,قطن,كاجوال', 'buy_price': 180.0, 'sell_price': 280.0, 'size': 'صغير', 'color': 'أصفر', 'material': 'قطن', 'stock_quantity': 8, 'barcode': '1003003001', 'description': 'فستان صيفي مريح وأنيق'},
      {'name': 'فستان مسائي حرير', 'category': 'فساتين', 'tags': 'مسائي,حرير,فاخر', 'buy_price': 300.0, 'sell_price': 450.0, 'size': 'متوسط', 'color': 'أسود', 'material': 'حرير', 'stock_quantity': 5, 'barcode': '1003003002', 'description': 'فستان مسائي حرير فاخر'},
      {'name': 'فستان كاجوال يومي', 'category': 'فساتين', 'tags': 'كاجوال,يومي,مريح', 'buy_price': 200.0, 'sell_price': 320.0, 'size': 'كبير', 'color': 'أزرق', 'material': 'قطن', 'stock_quantity': 10, 'barcode': '1003003003', 'description': 'فستان كاجوال للاستخدام اليومي'},
      {'name': 'فستان ماكسي أنيق', 'category': 'فساتين', 'tags': 'ماكسي,أنيق,طويل', 'buy_price': 250.0, 'sell_price': 380.0, 'size': 'متوسط', 'color': 'أبيض', 'material': 'شيفون', 'stock_quantity': 7, 'barcode': '1003003004', 'description': 'فستان ماكسي أنيق وطويل'},
      {'name': 'فستان قصير وردي', 'category': 'فساتين', 'tags': 'قصير,شبابي,لطيف', 'buy_price': 160.0, 'sell_price': 250.0, 'size': 'صغير', 'color': 'وردي', 'material': 'قطن', 'stock_quantity': 12, 'barcode': '1003003005', 'description': 'فستان قصير وردي لطيف'},
      {'name': 'فستان عمل رسمي', 'category': 'فساتين', 'tags': 'رسمي,عمل,أنيق', 'buy_price': 280.0, 'sell_price': 420.0, 'size': 'متوسط', 'color': 'كحلي', 'material': 'بوليستر', 'stock_quantity': 6, 'barcode': '1003003006', 'description': 'فستان رسمي للعمل والاجتماعات'},
      {'name': 'فستان زهري ربيعي', 'category': 'فساتين', 'tags': 'زهري,ربيعي,ملون', 'buy_price': 190.0, 'sell_price': 300.0, 'size': 'كبير', 'color': 'أخضر', 'material': 'قطن', 'stock_quantity': 9, 'barcode': '1003003007', 'description': 'فستان بنقشة زهرية ربيعية'},
      {'name': 'فستان سهرة حرير أحمر', 'category': 'فساتين', 'tags': 'سهرة,حرير,فاخر', 'buy_price': 380.0, 'sell_price': 550.0, 'size': 'صغير', 'color': 'أحمر', 'material': 'حرير', 'stock_quantity': 4, 'barcode': '1003003008', 'description': 'فستان سهرة حرير أحمر فاخر'},
      {'name': 'فستان كتان بسيط', 'category': 'فساتين', 'tags': 'كتان,بسيط,صيفي', 'buy_price': 220.0, 'sell_price': 340.0, 'size': 'متوسط', 'color': 'بيج', 'material': 'كتان', 'stock_quantity': 8, 'barcode': '1003003009', 'description': 'فستان كتان بسيط للصيف'},
      {'name': 'فستان مخطط عصري', 'category': 'فساتين', 'tags': 'مخطط,عصري,شبابي', 'buy_price': 170.0, 'sell_price': 290.0, 'size': 'كبير', 'color': 'مخطط', 'material': 'قطن', 'stock_quantity': 11, 'barcode': '1003003010', 'description': 'فستان بخطوط عصرية'},
      {'name': 'فستان شتوي صوف', 'category': 'فساتين', 'tags': 'شتوي,صوف,دافئ', 'buy_price': 260.0, 'sell_price': 400.0, 'size': 'متوسط', 'color': 'بني', 'material': 'صوف', 'stock_quantity': 6, 'barcode': '1003003011', 'description': 'فستان صوف دافئ للشتاء'},
      {'name': 'فستان عملي مريح', 'category': 'فساتين', 'tags': 'عملي,مريح,يومي', 'buy_price': 210.0, 'sell_price': 350.0, 'size': 'صغير', 'color': 'رمادي', 'material': 'قطن', 'stock_quantity': 9, 'barcode': '1003003012', 'description': 'فستان عملي مريح للاستخدام اليومي'},

      // أحذية (Shoes) - 18 items
      {'name': 'حذاء رياضي جري أبيض', 'category': 'أحذية', 'tags': 'رياضي,جري,مريح', 'buy_price': 220.0, 'sell_price': 350.0, 'size': '40', 'color': 'أبيض', 'material': 'صناعي', 'stock_quantity': 15, 'barcode': '1004004001', 'description': 'حذاء رياضي مخصص للجري'},
      {'name': 'حذاء رياضي تدريب أسود', 'category': 'أحذية', 'tags': 'رياضي,تدريب,قوي', 'buy_price': 230.0, 'sell_price': 360.0, 'size': '42', 'color': 'أسود', 'material': 'صناعي', 'stock_quantity': 18, 'barcode': '1004004002', 'description': 'حذاء تدريب قوي ومتين'},
      {'name': 'حذاء كلاسيكي جلد بني', 'category': 'أحذية', 'tags': 'كلاسيكي,جلد,أنيق', 'buy_price': 280.0, 'sell_price': 450.0, 'size': '41', 'color': 'بني', 'material': 'جلد', 'stock_quantity': 10, 'barcode': '1004004003', 'description': 'حذاء جلد كلاسيكي أنيق'},
      {'name': 'حذاء رسمي أسود فاخر', 'category': 'أحذية', 'tags': 'رسمي,فاخر,عمل', 'buy_price': 350.0, 'sell_price': 550.0, 'size': '42', 'color': 'أسود', 'material': 'جلد', 'stock_quantity': 8, 'barcode': '1004004004', 'description': 'حذاء رسمي فاخر للعمل'},
      {'name': 'صندل صيفي مريح', 'category': 'أحذية', 'tags': 'صندل,صيفي,مريح', 'buy_price': 110.0, 'sell_price': 180.0, 'size': '40', 'color': 'بني', 'material': 'جلد', 'stock_quantity': 20, 'barcode': '1004004005', 'description': 'صندل صيفي مريح وأنيق'},
      {'name': 'حذاء كعب عالي أحمر', 'category': 'أحذية', 'tags': 'كعب_عالي,أنيق,مسائي', 'buy_price': 200.0, 'sell_price': 320.0, 'size': '37', 'color': 'أحمر', 'material': 'جلد', 'stock_quantity': 12, 'barcode': '1004004006', 'description': 'حذاء كعب عالي أحمر أنيق'},
      {'name': 'حذاء بوت شتوي', 'category': 'أحذية', 'tags': 'بوت,شتوي,دافئ', 'buy_price': 260.0, 'sell_price': 420.0, 'size': '42', 'color': 'أسود', 'material': 'جلد', 'stock_quantity': 9, 'barcode': '1004004007', 'description': 'حذاء بوت شتوي دافئ ومقاوم للماء'},
      {'name': 'حذاء كاجوال أبيض', 'category': 'أحذية', 'tags': 'كاجوال,يومي,مريح', 'buy_price': 170.0, 'sell_price': 280.0, 'size': '40', 'color': 'أبيض', 'material': 'قماش', 'stock_quantity': 17, 'barcode': '1004004008', 'description': 'حذاء كاجوال أبيض للاستخدام اليومي'},
      {'name': 'حذاء مطاطي مقاوم', 'category': 'أحذية', 'tags': 'مطاطي,مقاوم,عملي', 'buy_price': 70.0, 'sell_price': 120.0, 'size': '41', 'color': 'أسود', 'material': 'مطاط', 'stock_quantity': 25, 'barcode': '1004004009', 'description': 'حذاء مطاطي مقاوم للماء'},
      {'name': 'حذاء باليه نسائي', 'category': 'أحذية', 'tags': 'باليه,نسائي,مريح', 'buy_price': 120.0, 'sell_price': 200.0, 'size': '37', 'color': 'وردي', 'material': 'جلد', 'stock_quantity': 15, 'barcode': '1004004010', 'description': 'حذاء باليه نسائي مريح'},
      {'name': 'حذاء تسلق رياضي', 'category': 'أحذية', 'tags': 'تسلق,رياضي,قوي', 'buy_price': 300.0, 'sell_price': 480.0, 'size': '43', 'color': 'أزرق', 'material': 'صناعي', 'stock_quantity': 7, 'barcode': '1004004011', 'description': 'حذاء تسلق قوي ومتين'},
      {'name': 'حذاء تنس أبيض', 'category': 'أحذية', 'tags': 'تنس,رياضي,كلاسيكي', 'buy_price': 180.0, 'sell_price': 300.0, 'size': '41', 'color': 'أبيض', 'material': 'قماش', 'stock_quantity': 13, 'barcode': '1004004012', 'description': 'حذاء تنس كلاسيكي أبيض'},
      {'name': 'حذاء رقص أسود', 'category': 'أحذية', 'tags': 'رقص,أنيق,مرن', 'buy_price': 150.0, 'sell_price': 250.0, 'size': '38', 'color': 'أسود', 'material': 'جلد', 'stock_quantity': 11, 'barcode': '1004004013', 'description': 'حذاء رقص مرن وأنيق'},
      {'name': 'حذاء مشي رمادي', 'category': 'أحذية', 'tags': 'مشي,مريح,يومي', 'buy_price': 160.0, 'sell_price': 260.0, 'size': '42', 'color': 'رمادي', 'material': 'قماش', 'stock_quantity': 19, 'barcode': '1004004014', 'description': 'حذاء مشي مريح للاستخدام اليومي'},
      {'name': 'حذاء أوكسفورد بني', 'category': 'أحذية', 'tags': 'أوكسفورد,كلاسيكي,أنيق', 'buy_price': 320.0, 'sell_price': 520.0, 'size': '43', 'color': 'بني', 'material': 'جلد', 'stock_quantity': 6, 'barcode': '1004004015', 'description': 'حذاء أوكسفورد كلاسيكي بني'},
      {'name': 'حذاء لوفر أسود', 'category': 'أحذية', 'tags': 'لوفر,كاجوال_رسمي,مريح', 'buy_price': 200.0, 'sell_price': 340.0, 'size': '41', 'color': 'أسود', 'material': 'جلد', 'stock_quantity': 14, 'barcode': '1004004016', 'description': 'حذاء لوفر مريح للمناسبات المختلطة'},
      {'name': 'حذاء موكاسين بني', 'category': 'أحذية', 'tags': 'موكاسين,كاجوال,جلد', 'buy_price': 180.0, 'sell_price': 300.0, 'size': '40', 'color': 'بني', 'material': 'جلد', 'stock_quantity': 16, 'barcode': '1004004017', 'description': 'حذاء موكاسين جلد مريح'},
      {'name': 'حذاء إسبادريل صيفي', 'category': 'أحذية', 'tags': 'إسبادريل,صيفي,خفيف', 'buy_price': 90.0, 'sell_price': 150.0, 'size': '39', 'color': 'بيج', 'material': 'قماش', 'stock_quantity': 22, 'barcode': '1004004018', 'description': 'حذاء إسبادريل خفيف للصيف'}
    ];

    for (final product in products) {
      await db.insert('products', product);
    }
  }
  
  // Enhanced product insertion with all fields
  Future<int> insertProduct(Map<String, dynamic> product) async {
    final db = await database;
    product['created_date'] = DateTime.now().toIso8601String();
    product['updated_date'] = DateTime.now().toIso8601String();
    return await db.insert('products', product);
  }

  // Update existing product
  Future<void> updateProduct(int productId, Map<String, dynamic> product) async {
    final db = await database;
    product['updated_date'] = DateTime.now().toIso8601String();
    await db.update(
      'products',
      product,
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  // Get single product by ID
  Future<Map<String, dynamic>?> getProductById(int productId) async {
    final db = await database;
    final result = await db.query('products', where: 'id = ?', whereArgs: [productId]);
    return result.isNotEmpty ? result.first : null;
  }
  
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await database;
    return await db.query('products', orderBy: 'name ASC');
  }

  Future<List<Map<String, dynamic>>> getProductsByCategory(String category) async {
    final db = await database;
    return await db.query(
      'products',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'name ASC',
    );
  }

  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final db = await database;
    return await db.query(
      'products',
      where: 'name LIKE ? OR category LIKE ? OR tags LIKE ? OR barcode LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
  }

  Future<void> updateProductStock(int productId, int quantityChange, {String? reason}) async {
    final db = await database;
    
    // Get current product info for cost calculation
    final product = await db.query('products', where: 'id = ?', whereArgs: [productId]);
    if (product.isEmpty) return;
    
    final buyPrice = (product.first['buy_price'] as num).toDouble();
    
    await db.rawUpdate(
      'UPDATE products SET stock_quantity = stock_quantity + ?, updated_date = ? WHERE id = ?',
      [quantityChange, DateTime.now().toIso8601String(), productId],
    );
    
    await db.insert('inventory_movements', {
      'product_id': productId,
      'type': quantityChange > 0 ? 'in' : 'out',
      'quantity': quantityChange.abs(),
      'cost_per_unit': buyPrice,
      'total_cost': buyPrice * quantityChange.abs(),
      'reason': reason ?? (quantityChange > 0 ? 'إضافة مخزون' : 'بيع'),
    });
  }
  
  Future<int> insertSale(Map<String, dynamic> sale, List<Map<String, dynamic>> items) async {
    final db = await database;
    
    // Calculate total cost and profit
    double totalCost = 0.0;
    double totalPrice = sale['total_amount'];
    
    for (var item in items) {
      final product = await db.query('products', where: 'id = ?', whereArgs: [item['product_id']]);
      if (product.isNotEmpty) {
        final buyPrice = (product.first['buy_price'] as num).toDouble();
        totalCost += buyPrice * item['quantity'];
        item['buy_price'] = buyPrice;
        item['total_cost'] = buyPrice * item['quantity'];
      }
    }
    
    sale['total_cost'] = totalCost;
    sale['profit_amount'] = totalPrice - totalCost;
    
    final saleId = await db.insert('sales', sale);
    
    for (var item in items) {
      await db.insert('sale_items', {...item, 'sale_id': saleId});
      await updateProductStock(item['product_id'], -item['quantity'], reason: 'بيع');
    }
    return saleId;
  }
  
  Future<Map<String, dynamic>> getDailySummary() async {
    final db = await database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    
    final sales = await db.rawQuery('''
      SELECT 
        SUM(total_amount) as total_sales, 
        SUM(total_cost) as total_cost,
        SUM(profit_amount) as total_profit,
        COUNT(id) as transaction_count
      FROM sales
      WHERE sale_date LIKE '$today%'
    ''');
    
    return sales.first;
  }
  
  // Get all sales with optional date filter
  Future<List<Map<String, dynamic>>> getAllSales({String? dateFilter}) async {
    final db = await database;
    String query = 'SELECT * FROM sales ORDER BY sale_date DESC';
    
    if (dateFilter != null) {
      query = '''
        SELECT * FROM sales 
        WHERE sale_date LIKE '$dateFilter%' 
        ORDER BY sale_date DESC
      ''';
    }
    
    return await db.rawQuery(query);
  }
  
  // Get sale items for a specific sale
  Future<List<Map<String, dynamic>>> getSaleItems(int saleId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        si.*,
        p.name as product_name,
        p.category as product_category,
        p.size as product_size,
        p.color as product_color
      FROM sale_items si
      LEFT JOIN products p ON si.product_id = p.id
      WHERE si.sale_id = ?
    ''', [saleId]);
  }
  
  // Get sales statistics for a date range
  Future<Map<String, dynamic>> getSalesStats({String? startDate, String? endDate}) async {
    final db = await database;
    String whereClause = '';
    
    if (startDate != null && endDate != null) {
      whereClause = "WHERE sale_date BETWEEN '$startDate' AND '$endDate'";
    }
    
    final result = await db.rawQuery('''
      SELECT 
        COUNT(id) as total_sales,
        SUM(total_amount) as total_revenue,
        SUM(profit_amount) as total_profit,
        AVG(total_amount) as average_sale,
        MAX(total_amount) as largest_sale
      FROM sales
      $whereClause
    ''');
    
    return result.first;
  }

  Future<List<String>> getAllCategories() async {
    final db = await database;
    final result = await db.rawQuery('SELECT DISTINCT category FROM products ORDER BY category');
    return result.map((row) => row['category'] as String).toList();
  }

  Future<List<String>> getAllTags() async {
    final db = await database;
    final result = await db.rawQuery('SELECT DISTINCT tags FROM products WHERE tags IS NOT NULL');
    Set<String> allTags = {};
    
    for (var row in result) {
      final tags = (row['tags'] as String).split(',');
      allTags.addAll(tags.map((tag) => tag.trim()));
    }
    
    return allTags.toList()..sort();
  }

  Future<List<Map<String, dynamic>>> getLowStockProducts() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT * FROM products 
      WHERE stock_quantity <= min_stock_level 
      ORDER BY stock_quantity ASC
    ''');
  }

  Future<Map<String, dynamic>> getInventoryStats() async {
    final db = await database;
    
    final stats = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_products,
        SUM(stock_quantity) as total_stock,
        SUM(stock_quantity * buy_price) as total_inventory_value,
        SUM(stock_quantity * sell_price) as total_retail_value,
        COUNT(CASE WHEN stock_quantity <= min_stock_level THEN 1 END) as low_stock_count
      FROM products
    ''');
    
    return stats.first;
  }
  
  Future<String> exportTableToCSV(String tableName) async {
    final db = await database;
    final List<Map<String, dynamic>> data = await db.query(tableName);
    
    if (data.isEmpty) return '';
    
    List<List<dynamic>> rows = [];
    List<String> headers = data.first.keys.toList();
    rows.add(headers);
    
    for (var rowMap in data) {
      rows.add(rowMap.values.toList());
    }
    
    return const ListToCsvConverter().convert(rows);
  }
  
  Future<String> exportAllData() async {
    StringBuffer buffer = StringBuffer();
    
    // Export products with enhanced fields
    buffer.writeln('--- PRODUCTS ---');
    buffer.writeln(await exportTableToCSV('products'));
    buffer.writeln('\n');
    
    // Export sales with profit information
    buffer.writeln('--- SALES ---');
    buffer.writeln(await exportTableToCSV('sales'));
    buffer.writeln('\n');
    
    // Export sale_items with cost information
    buffer.writeln('--- SALE ITEMS ---');
    buffer.writeln(await exportTableToCSV('sale_items'));
    buffer.writeln('\n');
    
    // Export inventory_movements with cost tracking
    buffer.writeln('--- INVENTORY MOVEMENTS ---');
    buffer.writeln(await exportTableToCSV('inventory_movements'));
    buffer.writeln('\n');
    
    // Export users
    buffer.writeln('--- USERS ---');
    buffer.writeln(await exportTableToCSV('users'));
    buffer.writeln('\n');
    
    return buffer.toString();
  }
  
  Future<File> saveExportToFile(String content, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    return file.writeAsString(content);
  }

  // Photo management functions
  Future<List<String>> getProductImages(int productId) async {
    final db = await database;
    final result = await db.query('products', where: 'id = ?', whereArgs: [productId]);
    if (result.isEmpty) return [];
    
    final imagePaths = result.first['image_paths'] as String?;
    if (imagePaths == null || imagePaths.isEmpty) return [];
    
    return imagePaths.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  Future<void> updateProductImages(int productId, List<String> imagePaths) async {
    final db = await database;
    await db.update(
      'products',
      {
        'image_paths': imagePaths.join(','),
        'updated_date': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  Future<void> deleteProductWithImages(int productId) async {
    final db = await database;
    
    // Get product images before deletion
    final imagePaths = await getProductImages(productId);
    
    // Delete the product from database
    await db.delete('products', where: 'id = ?', whereArgs: [productId]);
    
    // Delete all associated image files
    await _deleteImageFiles(imagePaths);
  }

  Future<void> _deleteImageFiles(List<String> imagePaths) async {
    for (final imagePath in imagePaths) {
      try {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
          print('Deleted image file: $imagePath');
        }
      } catch (e) {
        print('Error deleting image file $imagePath: $e');
      }
    }
  }

  Future<String> saveProductImage(String imagePath, int productId) async {
    final directory = await getApplicationDocumentsDirectory();
    final productImagesDir = Directory('${directory.path}/product_images');
    
    // Create directory if it doesn't exist
    if (!await productImagesDir.exists()) {
      await productImagesDir.create(recursive: true);
    }
    
    // Generate unique filename
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = imagePath.split('.').last;
    final newFileName = 'product_${productId}_$timestamp.$extension';
    final newPath = '${productImagesDir.path}/$newFileName';
    
    // Copy image to app directory
    final sourceFile = File(imagePath);
    final targetFile = await sourceFile.copy(newPath);
    
    return targetFile.path;
  }

  Future<void> cleanupUnusedImages() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final productImagesDir = Directory('${directory.path}/product_images');
      
      if (!await productImagesDir.exists()) return;
      
      // Get all image paths from database
      final db = await database;
      final products = await db.query('products', columns: ['image_paths']);
      
      Set<String> usedImages = {};
      for (final product in products) {
        final imagePaths = product['image_paths'] as String?;
        if (imagePaths != null && imagePaths.isNotEmpty) {
          usedImages.addAll(imagePaths.split(',').map((e) => e.trim()));
        }
      }
      
      // Delete unused image files
      final imageFiles = await productImagesDir.list().toList();
      for (final file in imageFiles) {
        if (file is File && !usedImages.contains(file.path)) {
          await file.delete();
          print('Cleaned up unused image: ${file.path}');
        }
      }
    } catch (e) {
      print('Error during image cleanup: $e');
    }
  }

  // ============================================================
  // CATEGORY CRUD OPERATIONS
  // ============================================================

  Future<List<Map<String, dynamic>>> getCategoriesWithCounts() async {
    final db = await database;
    // Get unique categories from products with counts
    final result = await db.rawQuery('''
      SELECT DISTINCT category_name, COUNT(*) as product_count
      FROM products
      GROUP BY category_name
      ORDER BY category_name
    ''');
    return result;
  }

  Future<void> addCategory(String categoryName) async {
    // Categories are implicitly created when products use them
    // This method validates and ensures the category exists
    if (categoryName.trim().isEmpty) {
      throw Exception('اسم الفئة لا يمكن أن يكون فارغاً');
    }
  }

  Future<void> updateCategory(String oldName, String newName) async {
    if (newName.trim().isEmpty) {
      throw Exception('اسم الفئة الجديد لا يمكن أن يكون فارغاً');
    }
    
    final db = await database;
    await db.update(
      'products',
      {'category_name': newName},
      where: 'category_name = ?',
      whereArgs: [oldName],
    );
  }

  Future<void> deleteCategory(String categoryName) async {
    final db = await database;
    
    // Check if category has products
    final products = await db.query(
      'products',
      where: 'category_name = ?',
      whereArgs: [categoryName],
    );
    
    if (products.isNotEmpty) {
      throw Exception('لا يمكن حذف فئة تحتوي على منتجات (${products.length} منتج)');
    }
  }

  // ============================================================
  // ENHANCED PRODUCT OPERATIONS
  // ============================================================

  Future<void> deleteProduct(int productId) async {
    final db = await database;
    
    // Check if product exists in any sales
    final salesWithProduct = await db.query(
      'sale_items',
      where: 'product_id = ?',
      whereArgs: [productId],
      limit: 1,
    );
    
    if (salesWithProduct.isNotEmpty) {
      throw Exception('لا يمكن حذف منتج تم بيعه من قبل');
    }
    
    // Delete the product
    await deleteProductWithImages(productId);
  }

  // ============================================================
  // INVOICE/RECEIPT PRINTING
  // ============================================================

  Future<String> generateReceiptText(int saleId) async {
    final db = await database;
    
    // Get sale details
    final sales = await db.query('sales', where: 'id = ?', whereArgs: [saleId]);
    if (sales.isEmpty) throw Exception('الفاتورة غير موجودة');
    
    final sale = sales.first;
    final saleItems = await getSaleItems(saleId);
    
    // Build receipt text
    final buffer = StringBuffer();
    buffer.writeln('========================================');
    buffer.writeln('         محل الملابس والإكسسوارات        ');
    buffer.writeln('========================================');
    buffer.writeln();
    buffer.writeln('رقم الفاتورة: $saleId');
    buffer.writeln('التاريخ: ${sale['sale_date']}');
    buffer.writeln('الكاشير: ${sale['cashier_name']}');
    buffer.writeln('----------------------------------------');
    buffer.writeln();
    
    // Items
    buffer.writeln('المنتجات:');
    buffer.writeln();
    for (final item in saleItems) {
      final qty = item['quantity'];
      final price = item['sell_price'];
      final total = item['total_price'];
      buffer.writeln('  منتج #${item['product_id']}');
      buffer.writeln('  الكمية: $qty x ${_formatMoney(price)} = ${_formatMoney(total)}');
      buffer.writeln();
    }
    
    buffer.writeln('----------------------------------------');
    final subtotal = sale['subtotal'] ?? sale['total_amount'];
    buffer.writeln('المجموع الفرعي:           ${_formatMoney(subtotal)}');
    
    final discountAmount = sale['discount_amount'];
    final discount = discountAmount != null ? (discountAmount as num).toDouble() : 0.0;
    if (discount > 0) {
      final discountType = sale['discount_type'];
      final typeLabel = discountType == 'percentage' ? '(%)' : '(ثابت)';
      buffer.writeln('الخصم $typeLabel:            -${_formatMoney(discount)}');
    }
    
    buffer.writeln('========================================');
    buffer.writeln('الإجمالي:                 ${_formatMoney(sale['total_amount'])}');
    buffer.writeln('========================================');
    buffer.writeln();
    
    final paymentMethod = sale['payment_method'] == 'cash' ? 'نقدي' : 'بطاقة';
    buffer.writeln('طريقة الدفع: $paymentMethod');
    
    if (sale['payment_method'] == 'cash') {
      buffer.writeln('المدفوع:                  ${_formatMoney(sale['paid_amount'])}');
      buffer.writeln('الباقي:                   ${_formatMoney(sale['change_amount'])}');
    }
    
    buffer.writeln();
    buffer.writeln('========================================');
    buffer.writeln('        شكراً لزيارتكم         ');
    buffer.writeln('     نسعد بخدمتكم دائماً      ');
    buffer.writeln('========================================');
    
    return buffer.toString();
  }

  String _formatMoney(dynamic amount) {
    final value = amount is num ? amount.toDouble() : 0.0;
    return '${value.toStringAsFixed(2)} ر.س';
  }

  Future<void> printReceipt(int saleId) async {
    final receiptText = await generateReceiptText(saleId);
    print('\n$receiptText\n');
    // In a real app, this would send to a printer
    // For now, we just log it
  }

  Future<File> saveReceiptToFile(int saleId) async {
    final receiptText = await generateReceiptText(saleId);
    final directory = await getApplicationDocumentsDirectory();
    final receiptsDir = Directory('${directory.path}/receipts');
    
    if (!await receiptsDir.exists()) {
      await receiptsDir.create(recursive: true);
    }
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${receiptsDir.path}/receipt_${saleId}_$timestamp.txt';
    final file = File(filePath);
    
    await file.writeAsString(receiptText);
    return file;
  }
}
