import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'pos_arabic.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Products table
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        size TEXT NOT NULL,
        color TEXT NOT NULL,
        stock_quantity INTEGER DEFAULT 0,
        barcode TEXT UNIQUE,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Sales table
    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_amount REAL NOT NULL,
        paid_amount REAL NOT NULL,
        change_amount REAL NOT NULL,
        payment_method TEXT DEFAULT 'cash',
        customer_name TEXT,
        cashier_name TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Sale items table
    await db.execute('''
      CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        total_price REAL NOT NULL,
        FOREIGN KEY (sale_id) REFERENCES sales (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Inventory movements table
    await db.execute('''
      CREATE TABLE inventory_movements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        movement_type TEXT NOT NULL, -- 'in', 'out', 'adjustment'
        quantity INTEGER NOT NULL,
        reason TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT DEFAULT 'cashier',
        full_name TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Insert default admin user
    await db.insert('users', {
      'username': 'admin',
      'password': 'admin',
      'role': 'admin',
      'full_name': 'مدير النظام',
    });

    // Insert sample products
    final sampleProducts = [
      {'name': 'قميص أزرق', 'category': 'قمصان', 'price': 150.0, 'size': 'كبير', 'color': 'أزرق', 'stock_quantity': 25, 'barcode': '1234567890123'},
      {'name': 'بنطلون أسود', 'category': 'بناطيل', 'price': 200.0, 'size': 'متوسط', 'color': 'أسود', 'stock_quantity': 15, 'barcode': '1234567890124'},
      {'name': 'فستان أحمر', 'category': 'فساتين', 'price': 300.0, 'size': 'صغير', 'color': 'أحمر', 'stock_quantity': 10, 'barcode': '1234567890125'},
      {'name': 'حذاء بني', 'category': 'أحذية', 'price': 250.0, 'size': '42', 'color': 'بني', 'stock_quantity': 20, 'barcode': '1234567890126'},
      {'name': 'حقيبة يد', 'category': 'إكسسوارات', 'price': 180.0, 'size': 'متوسط', 'color': 'أسود', 'stock_quantity': 30, 'barcode': '1234567890127'},
    ];

    for (final product in sampleProducts) {
      await db.insert('products', product);
    }
  }

  // Products CRUD operations
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await database;
    return await db.query('products', orderBy: 'name ASC');
  }

  Future<Map<String, dynamic>?> getProductById(int id) async {
    final db = await database;
    final results = await db.query('products', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    final db = await database;
    final results = await db.query('products', where: 'barcode = ?', whereArgs: [barcode]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> insertProduct(Map<String, dynamic> product) async {
    final db = await database;
    product['created_at'] = DateTime.now().toIso8601String();
    product['updated_at'] = DateTime.now().toIso8601String();
    return await db.insert('products', product);
  }

  Future<int> updateProduct(int id, Map<String, dynamic> product) async {
    final db = await database;
    product['updated_at'] = DateTime.now().toIso8601String();
    return await db.update('products', product, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // Sales operations
  Future<int> insertSale(Map<String, dynamic> sale, List<Map<String, dynamic>> items) async {
    final db = await database;
    
    return await db.transaction((txn) async {
      // Insert sale
      sale['created_at'] = DateTime.now().toIso8601String();
      final saleId = await txn.insert('sales', sale);
      
      // Insert sale items
      for (final item in items) {
        item['sale_id'] = saleId;
        await txn.insert('sale_items', item);
        
        // Update product stock
        await txn.rawUpdate(
          'UPDATE products SET stock_quantity = stock_quantity - ? WHERE id = ?',
          [item['quantity'], item['product_id']]
        );
        
        // Record inventory movement
        await txn.insert('inventory_movements', {
          'product_id': item['product_id'],
          'movement_type': 'out',
          'quantity': -item['quantity'],
          'reason': 'بيع - فاتورة #$saleId',
          'created_at': DateTime.now().toIso8601String(),
        });
      }
      
      return saleId;
    });
  }

  Future<List<Map<String, dynamic>>> getSalesReport({DateTime? startDate, DateTime? endDate}) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (startDate != null && endDate != null) {
      whereClause = 'WHERE created_at BETWEEN ? AND ?';
      whereArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
    }
    
    return await db.rawQuery('''
      SELECT 
        s.*,
        COUNT(si.id) as item_count,
        GROUP_CONCAT(p.name, ', ') as products
      FROM sales s
      LEFT JOIN sale_items si ON s.id = si.sale_id
      LEFT JOIN products p ON si.product_id = p.id
      $whereClause
      GROUP BY s.id
      ORDER BY s.created_at DESC
    ''', whereArgs);
  }

  Future<Map<String, dynamic>> getDailySummary() async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();
    
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as transaction_count,
        COALESCE(SUM(total_amount), 0) as total_sales,
        COALESCE(SUM(paid_amount - total_amount), 0) as total_change
      FROM sales 
      WHERE created_at BETWEEN ? AND ?
    ''', [startOfDay, endOfDay]);
    
    return result.first;
  }

  // Inventory operations
  Future<List<Map<String, dynamic>>> getLowStockProducts({int threshold = 10}) async {
    final db = await database;
    return await db.query(
      'products', 
      where: 'stock_quantity <= ?', 
      whereArgs: [threshold],
      orderBy: 'stock_quantity ASC'
    );
  }

  Future<int> updateStock(int productId, int newQuantity, String reason) async {
    final db = await database;
    
    return await db.transaction((txn) async {
      // Get current stock
      final product = await txn.query('products', where: 'id = ?', whereArgs: [productId]);
      if (product.isEmpty) return 0;
      
      final currentStock = product.first['stock_quantity'] as int;
      final difference = newQuantity - currentStock;
      
      // Update product stock
      await txn.update(
        'products', 
        {'stock_quantity': newQuantity, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?', 
        whereArgs: [productId]
      );
      
      // Record inventory movement
      await txn.insert('inventory_movements', {
        'product_id': productId,
        'movement_type': difference > 0 ? 'in' : difference < 0 ? 'out' : 'adjustment',
        'quantity': difference,
        'reason': reason,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      return 1;
    });
  }

  // Export functionality
  Future<String> exportTableToCSV(String tableName) async {
    final db = await database;
    final data = await db.query(tableName);
    
    if (data.isEmpty) return '';
    
    // Get column names
    final columns = data.first.keys.toList();
    
    // Create CSV content
    List<List<dynamic>> csvData = [columns];
    for (final row in data) {
      csvData.add(columns.map((col) => row[col] ?? '').toList());
    }
    
    return const ListToCsvConverter().convert(csvData);
  }

  Future<String> exportAllData() async {
    final db = await database;
    final tables = ['products', 'sales', 'sale_items', 'inventory_movements', 'users'];
    
    String allData = '';
    for (final table in tables) {
      allData += '=== $table ===\n';
      allData += await exportTableToCSV(table);
      allData += '\n\n';
    }
    
    return allData;
  }

  Future<File> saveExportToFile(String csvContent, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(csvContent);
    return file;
  }

  Future<List<Map<String, dynamic>>> getInventoryMovements({int? productId}) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (productId != null) {
      whereClause = 'WHERE im.product_id = ?';
      whereArgs = [productId];
    }
    
    return await db.rawQuery('''
      SELECT 
        im.*,
        p.name as product_name,
        p.category as product_category
      FROM inventory_movements im
      LEFT JOIN products p ON im.product_id = p.id
      $whereClause
      ORDER BY im.created_at DESC
    ''', whereArgs);
  }

  Future<Map<String, dynamic>> getInventorySummary() async {
    final db = await database;
    
    final totalProducts = await db.rawQuery('SELECT COUNT(*) as count FROM products');
    final totalStock = await db.rawQuery('SELECT SUM(stock_quantity) as total FROM products');
    final lowStock = await db.rawQuery('SELECT COUNT(*) as count FROM products WHERE stock_quantity <= 10');
    final totalValue = await db.rawQuery('SELECT SUM(price * stock_quantity) as value FROM products');
    
    return {
      'total_products': totalProducts.first['count'] ?? 0,
      'total_stock': totalStock.first['total'] ?? 0,
      'low_stock_items': lowStock.first['count'] ?? 0,
      'total_inventory_value': totalValue.first['value'] ?? 0.0,
    };
  }

  // Analytics queries
  Future<List<Map<String, dynamic>>> getTopSellingProducts({int limit = 10}) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        p.name,
        p.category,
        p.price,
        SUM(si.quantity) as total_sold,
        SUM(si.total_price) as total_revenue
      FROM products p
      JOIN sale_items si ON p.id = si.product_id
      GROUP BY p.id
      ORDER BY total_sold DESC
      LIMIT ?
    ''', [limit]);
  }

  Future<List<Map<String, dynamic>>> getSalesByPeriod(String period) async {
    final db = await database;
    String dateFormat = '';
    
    switch (period) {
      case 'daily':
        dateFormat = '%Y-%m-%d';
        break;
      case 'weekly':
        dateFormat = '%Y-%W';
        break;
      case 'monthly':
        dateFormat = '%Y-%m';
        break;
      default:
        dateFormat = '%Y-%m-%d';
    }
    
    return await db.rawQuery('''
      SELECT 
        strftime('$dateFormat', created_at) as period,
        COUNT(*) as transaction_count,
        SUM(total_amount) as total_sales,
        SUM(paid_amount - total_amount) as total_change
      FROM sales
      GROUP BY strftime('$dateFormat', created_at)
      ORDER BY period DESC
      LIMIT 30
    ''');
  }

  // Database maintenance
  Future<void> cleanOldData({int daysToKeep = 365}) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep)).toIso8601String();
    
    await db.transaction((txn) async {
      // Delete old sales and related items
      final oldSales = await txn.query('sales', where: 'created_at < ?', whereArgs: [cutoffDate]);
      for (final sale in oldSales) {
        await txn.delete('sale_items', where: 'sale_id = ?', whereArgs: [sale['id']]);
      }
      await txn.delete('sales', where: 'created_at < ?', whereArgs: [cutoffDate]);
      
      // Delete old inventory movements
      await txn.delete('inventory_movements', where: 'created_at < ?', whereArgs: [cutoffDate]);
    });
  }

  Future<Map<String, int>> getDatabaseStats() async {
    final db = await database;
    
    final products = await db.rawQuery('SELECT COUNT(*) as count FROM products');
    final sales = await db.rawQuery('SELECT COUNT(*) as count FROM sales');
    final movements = await db.rawQuery('SELECT COUNT(*) as count FROM inventory_movements');
    final users = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    
    return {
      'products': products.first['count'] as int,
      'sales': sales.first['count'] as int,
      'inventory_movements': movements.first['count'] as int,
      'users': users.first['count'] as int,
    };
  }

  // Search functionality
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final db = await database;
    return await db.query(
      'products',
      where: 'name LIKE ? OR category LIKE ? OR barcode LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'name ASC'
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
