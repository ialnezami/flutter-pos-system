// Web-compatible storage service (in-memory)
// For native platforms, use enhanced_database_service.dart

class WebStorageService {
  // In-memory product storage
  static final List<Map<String, dynamic>> _products = [];
  static final List<Map<String, dynamic>> _sales = [];
  static int _nextProductId = 1;
  static int _nextSaleId = 1;

  // Initialize with sample data
  static void initializeSampleData() {
    if (_products.isEmpty) {
      _products.addAll([
        {'id': _nextProductId++, 'name': 'قميص قطني أبيض', 'category': 'قمصان', 'tags': 'كاجوال,قطن', 'buy_price': 80.0, 'sell_price': 120.0, 'size': 'متوسط', 'color': 'أبيض', 'material': 'قطن', 'stock_quantity': 25, 'barcode': '1001', 'description': 'قميص قطني مريح'},
        {'id': _nextProductId++, 'name': 'بنطلون جينز أزرق', 'category': 'بناطيل', 'tags': 'جينز,كلاسيكي', 'buy_price': 180.0, 'sell_price': 280.0, 'size': '34', 'color': 'أزرق', 'material': 'جينز', 'stock_quantity': 20, 'barcode': '1002', 'description': 'بنطلون جينز عصري'},
        {'id': _nextProductId++, 'name': 'فستان صيفي أحمر', 'category': 'فساتين', 'tags': 'صيفي,أنيق', 'buy_price': 250.0, 'sell_price': 450.0, 'size': 'صغير', 'color': 'أحمر', 'material': 'قطن', 'stock_quantity': 12, 'barcode': '1003', 'description': 'فستان صيفي جميل'},
        {'id': _nextProductId++, 'name': 'حذاء رياضي أبيض', 'category': 'أحذية', 'tags': 'رياضي,مريح', 'buy_price': 220.0, 'sell_price': 350.0, 'size': '42', 'color': 'أبيض', 'material': 'جلد', 'stock_quantity': 15, 'barcode': '1004', 'description': 'حذاء رياضي عالي الجودة'},
        {'id': _nextProductId++, 'name': 'حقيبة يد جلد', 'category': 'حقائب', 'tags': 'فاخر,جلد', 'buy_price': 250.0, 'sell_price': 380.0, 'size': 'متوسط', 'color': 'أسود', 'material': 'جلد', 'stock_quantity': 12, 'barcode': '1005', 'description': 'حقيبة يد جلد طبيعي'},
        {'id': _nextProductId++, 'name': 'ساعة ذهبية', 'category': 'ساعات', 'tags': 'فاخر,ذهبي', 'buy_price': 500.0, 'sell_price': 850.0, 'size': 'قياس واحد', 'color': 'ذهبي', 'material': 'معدن', 'stock_quantity': 8, 'barcode': '1006', 'description': 'ساعة ذهبية فاخرة'},
        {'id': _nextProductId++, 'name': 'نظارة شمسية', 'category': 'نظارات', 'tags': 'صيفي,حماية', 'buy_price': 150.0, 'sell_price': 250.0, 'size': 'قياس واحد', 'color': 'أسود', 'material': 'بلاستيك', 'stock_quantity': 18, 'barcode': '1007', 'description': 'نظارة شمسية عصرية'},
        {'id': _nextProductId++, 'name': 'حزام جلد بني', 'category': 'أحزمة', 'tags': 'كلاسيكي,جلد', 'buy_price': 100.0, 'sell_price': 180.0, 'size': '85 سم', 'color': 'بني', 'material': 'جلد', 'stock_quantity': 16, 'barcode': '1008', 'description': 'حزام جلد طبيعي'},
      ]);
    }
  }

  // Product CRUD
  static Future<List<Map<String, dynamic>>> getAllProducts() async {
    initializeSampleData();
    return List.from(_products);
  }

  static Future<Map<String, dynamic>?> getProductById(int id) async {
    initializeSampleData();
    try {
      return _products.firstWhere((p) => p['id'] == id);
    } catch (e) {
      return null;
    }
  }

  static Future<int> insertProduct(Map<String, dynamic> product) async {
    initializeSampleData();
    product['id'] = _nextProductId++;
    product['created_date'] = DateTime.now().toIso8601String();
    product['updated_date'] = DateTime.now().toIso8601String();
    _products.add(product);
    print('✅ Product added (in-memory): ${product['name']}');
    return product['id'] as int;
  }

  static Future<void> updateProduct(int id, Map<String, dynamic> updates) async {
    initializeSampleData();
    final index = _products.indexWhere((p) => p['id'] == id);
    if (index != -1) {
      _products[index] = {..._products[index], ...updates, 'updated_date': DateTime.now().toIso8601String()};
      print('✅ Product updated (in-memory): ID $id');
    }
  }

  static Future<void> deleteProduct(int id) async {
    initializeSampleData();
    _products.removeWhere((p) => p['id'] == id);
    print('✅ Product deleted (in-memory): ID $id');
  }

  // Category operations
  static Future<List<Map<String, dynamic>>> getCategoriesWithCounts() async {
    initializeSampleData();
    final categoryMap = <String, int>{};
    for (var product in _products) {
      final category = product['category'] as String;
      categoryMap[category] = (categoryMap[category] ?? 0) + 1;
    }
    
    return categoryMap.entries
        .map((e) => {'category_name': e.key, 'product_count': e.value})
        .toList();
  }

  static Future<void> addCategory(String name) async {
    if (name.trim().isEmpty) {
      throw Exception('اسم الفئة لا يمكن أن يكون فارغاً');
    }
  }

  static Future<void> updateCategory(String oldName, String newName) async {
    initializeSampleData();
    if (newName.trim().isEmpty) {
      throw Exception('اسم الفئة الجديد لا يمكن أن يكون فارغاً');
    }
    
    for (var product in _products) {
      if (product['category'] == oldName) {
        product['category'] = newName;
      }
    }
    print('✅ Category updated (in-memory): $oldName → $newName');
  }

  static Future<void> deleteCategory(String name) async {
    initializeSampleData();
    final hasProducts = _products.any((p) => p['category'] == name);
    if (hasProducts) {
      final count = _products.where((p) => p['category'] == name).length;
      throw Exception('لا يمكن حذف فئة تحتوي على منتجات ($count منتج)');
    }
  }

  // Sales operations
  static Future<int> insertSale(Map<String, dynamic> sale, List<Map<String, dynamic>> items) async {
    final saleId = _nextSaleId++;
    sale['id'] = saleId;
    sale['sale_date'] = DateTime.now().toIso8601String();
    
    // Ensure all fields are present
    sale.putIfAbsent('discount_amount', () => 0.0);
    sale.putIfAbsent('discount_type', () => 'percentage');
    sale.putIfAbsent('subtotal', () => sale['total_amount']);
    
    _sales.add(sale);
    
    print('✅ Sale saved (in-memory):');
    print('   ID: $saleId');
    print('   Total: ${sale['total_amount']} ر.س');
    print('   Discount: ${sale['discount_amount']} ر.س');
    print('   Subtotal: ${sale['subtotal']} ر.س');
    print('   Payment: ${sale['payment_method']}');
    print('   Cashier: ${sale['cashier_name']}');
    
    return saleId;
  }

  static Future<List<Map<String, dynamic>>> getAllSales() async {
    return List.from(_sales.reversed);
  }

  static Future<List<Map<String, dynamic>>> getSaleItems(int saleId) async {
    // Mock sale items
    return [
      {'product_id': 1, 'quantity': 2, 'sell_price': 120.0, 'total_price': 240.0},
    ];
  }

  // Receipt operations
  static Future<String> generateReceiptText(int saleId) async {
    final sale = _sales.firstWhere((s) => s['id'] == saleId, orElse: () => {});
    if (sale.isEmpty) throw Exception('الفاتورة غير موجودة');
    
    final buffer = StringBuffer();
    buffer.writeln('========================================');
    buffer.writeln('         محل الملابس والإكسسوارات        ');
    buffer.writeln('========================================');
    buffer.writeln('رقم الفاتورة: $saleId');
    buffer.writeln('التاريخ: ${sale['sale_date']}');
    buffer.writeln('الكاشير: ${sale['cashier_name']}');
    buffer.writeln('========================================');
    buffer.writeln('الإجمالي: ${sale['total_amount']} ر.س');
    buffer.writeln('الخصم: ${sale['discount_amount'] ?? 0} ر.س');
    buffer.writeln('طريقة الدفع: ${sale['payment_method'] == 'cash' ? 'نقدي' : 'بطاقة'}');
    buffer.writeln('========================================');
    buffer.writeln('        شكراً لزيارتكم         ');
    buffer.writeln('========================================');
    
    return buffer.toString();
  }

  static Future<void> printReceipt(int saleId) async {
    final receiptText = await generateReceiptText(saleId);
    print('\n$receiptText\n');
  }

  // Export (web version - prints to console)
  static Future<String> exportTableToCSV(String table) async {
    if (table == 'products') {
      return 'ID,Name,Category,Buy,Sell,Stock\n' + 
             _products.map((p) => '${p['id']},${p['name']},${p['category']},${p['buy_price']},${p['sell_price']},${p['stock_quantity']}').join('\n');
    }
    return 'No data';
  }
  
  // Dummy methods for compatibility
  static Future<dynamic> saveExportToFile(String content, String fileName) async {
    print('📊 WEB EXPORT - Copy from console:');
    print('=' * 50);
    print(content);
    print('=' * 50);
    // Return object with path property for compatibility
    return _WebFile('Console output (Web mode) - Check browser console');
  }
  
  static Future<dynamic> saveReceiptToFile(int saleId) async {
    final receipt = await generateReceiptText(saleId);
    print('🖨️ WEB RECEIPT - Copy from console:');
    print(receipt);
    // Return object with path property for compatibility
    return _WebFile('Console output (Web mode) - Check browser console');
  }
}

// Mock File class for web compatibility
class _WebFile {
  final String path;
  _WebFile(this.path);
}

