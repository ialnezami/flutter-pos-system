import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/enhanced_database_service.dart';
import '../services/web_storage_service.dart';
import '../services/auth_service.dart';
import '../helpers/csv_helper.dart';
import '../helpers/date_filter_helper.dart';

class WorkingHomePage extends StatefulWidget {
  const WorkingHomePage({super.key});

  @override
  State<WorkingHomePage> createState() => _WorkingHomePageState();
}

class ClothingProduct {
  final String name;
  final String category;
  final double price;
  final String size;
  final String color;
  
  ClothingProduct({
    required this.name,
    required this.category,
    required this.price,
    required this.size,
    required this.color,
  });
}

class CartItem {
  final ClothingProduct product;
  int quantity;
  double discount; // Discount amount for this item
  
  CartItem({
    required this.product,
    this.quantity = 1,
    this.discount = 0.0,
  });
  
  double get subtotal => product.price * quantity;
  double get total => subtotal - discount;
}

class _WorkingHomePageState extends State<WorkingHomePage> {
  int _selectedIndex = 0;
  final List<CartItem> _cartItems = [];
  double _cartDiscount = 0.0; // Cart-wide discount
  String _discountType = 'percentage'; // 'percentage' or 'fixed'
  
  // Products loaded from database
  List<ClothingProduct> _products = [];
  bool _isLoadingProducts = true;
  final EnhancedDatabaseService _dbService = EnhancedDatabaseService();
  
  // Date filtering for reports
  String _dateFilter = 'all'; // 'all', 'today', 'month', 'quarter'
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  
  @override
  void initState() {
    super.initState();
    _loadProducts();
    if (kIsWeb) {
      // Show web mode notification
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🌐 Web Mode: البيانات مؤقتة (in-memory)\nللحفظ الدائم، استخدم macOS/Windows'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 5),
            ),
          );
        }
      });
    }
  }
  
  // Helper: Get products based on platform
  Future<List<Map<String, dynamic>>> _getAllProducts() async {
    return kIsWeb 
        ? await WebStorageService.getAllProducts()
        : await _dbService.getAllProducts();
  }
  
  Future<Map<String, dynamic>?> _getProductById(int id) async {
    return kIsWeb
        ? await WebStorageService.getProductById(id)
        : await _dbService.getProductById(id);
  }
  
  Future<int> _insertProduct(Map<String, dynamic> product) async {
    return kIsWeb
        ? await WebStorageService.insertProduct(product)
        : await _dbService.insertProduct(product);
  }
  
  Future<void> _updateProduct(int id, Map<String, dynamic> product) async {
    return kIsWeb
        ? await WebStorageService.updateProduct(id, product)
        : await _dbService.updateProduct(id, product);
  }
  
  Future<void> _deleteProduct(int id) async {
    return kIsWeb
        ? await WebStorageService.deleteProduct(id)
        : await _dbService.deleteProduct(id);
  }
  
  Future<List<Map<String, dynamic>>> _getCategoriesWithCounts() async {
    return kIsWeb
        ? await WebStorageService.getCategoriesWithCounts()
        : await _dbService.getCategoriesWithCounts();
  }
  
  Future<void> _updateCategory(String oldName, String newName) async {
    return kIsWeb
        ? await WebStorageService.updateCategory(oldName, newName)
        : await _dbService.updateCategory(oldName, newName);
  }
  
  Future<void> _deleteCategoryService(String name) async {
    return kIsWeb
        ? await WebStorageService.deleteCategory(name)
        : await _dbService.deleteCategory(name);
  }
  
  // Sales helpers
  Future<int> _insertSale(Map<String, dynamic> sale, List<Map<String, dynamic>> items) async {
    return kIsWeb
        ? await WebStorageService.insertSale(sale, items)
        : await _dbService.insertSale(sale, items);
  }
  
  Future<List<Map<String, dynamic>>> _getAllSales() async {
    return kIsWeb
        ? await WebStorageService.getAllSales()
        : await _dbService.getAllSales();
  }
  
  Future<List<Map<String, dynamic>>> _getSaleItems(int saleId) async {
    return kIsWeb
        ? await WebStorageService.getSaleItems(saleId)
        : await _dbService.getSaleItems(saleId);
  }
  
  Future<String> _generateReceiptText(int saleId) async {
    return kIsWeb
        ? await WebStorageService.generateReceiptText(saleId)
        : await _dbService.generateReceiptText(saleId);
  }
  
  Future<void> _printReceipt(int saleId) async {
    return kIsWeb
        ? await WebStorageService.printReceipt(saleId)
        : await _dbService.printReceipt(saleId);
  }
  
  Future<dynamic> _saveReceiptToFile(int saleId) async {
    return kIsWeb
        ? await WebStorageService.saveReceiptToFile(saleId)
        : await _dbService.saveReceiptToFile(saleId);
  }
  
  Future<void> _loadProducts() async {
    setState(() => _isLoadingProducts = true);
    
    try {
      // Load products - use web storage on web, database on native
      final productsData = kIsWeb 
          ? await WebStorageService.getAllProducts()
          : await _dbService.getAllProducts();
      
      setState(() {
        _products = productsData.map((data) {
          return ClothingProduct(
            name: data['name'] as String,
            category: data['category'] as String,
            price: (data['sell_price'] as num).toDouble(),
            size: data['size'] as String,
            color: data['color'] as String,
          );
        }).toList();
        _isLoadingProducts = false;
      });
      } catch (e) {
      setState(() => _isLoadingProducts = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kIsWeb 
                ? 'تم تحميل ${_products.length} منتج (Web Mode - In Memory)'
                : 'خطأ في تحميل المنتجات: $e'),
            backgroundColor: kIsWeb ? Colors.blue : Colors.red,
          ),
        );
      }
    }
  }
  
  void _addToCart(ClothingProduct product) {
    setState(() {
      final existingIndex = _cartItems.indexWhere((item) => item.product.name == product.name);
      if (existingIndex >= 0) {
        _cartItems[existingIndex].quantity++;
      } else {
        _cartItems.add(CartItem(product: product));
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إضافة ${product.name} إلى السلة'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }
  
  double get _subtotal => _cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  double get _itemDiscounts => _cartItems.fold(0.0, (sum, item) => sum + item.discount);
  double get _totalDiscount => _itemDiscounts + _cartDiscount;
  double get _finalTotal => _subtotal - _totalDiscount;

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProducts) {
      return const Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('جاري تحميل المنتجات...', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      );
    }
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('نظام نقاط البيع - متجر الملابس'),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          actions: [
            IconButton(
              onPressed: () => setState(() => _selectedIndex = 4),
              icon: const Icon(Icons.settings),
              tooltip: 'الإعدادات',
            ),
          ],
        ),
        body: _buildCurrentPage(),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_cart),
              label: 'الكاشير',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory),
              label: 'إدارة المنتجات',
            ),
            NavigationDestination(
              icon: Icon(Icons.analytics),
              label: 'التقارير',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'الإعدادات',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return _buildCashierPage();
      case 2:
        return _buildProductManagementPage();
      case 3:
        return _buildReportsPage();
      case 4:
        return _buildSettingsPage();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مرحباً ${AuthService.currentUser}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Quick Action Cards
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'واجهة الكاشير',
                  'بدء عملية بيع جديدة',
                  Icons.point_of_sale,
                  Colors.green,
                  () => setState(() => _selectedIndex = 1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  'إدارة المنتجات',
                  'إضافة وتعديل المنتجات',
                  Icons.inventory,
                  Colors.blue,
                  () => setState(() => _selectedIndex = 2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'إضافة منتج جديد',
                  'إضافة منتج للمخزون',
                  Icons.add_circle,
                  Colors.orange,
                  _showAddProductDialog,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  'التقارير والإحصائيات',
                  'عرض تقارير المبيعات',
                  Icons.analytics,
                  Colors.purple,
                  () => setState(() => _selectedIndex = 3),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          Text(
            'إحصائيات سريعة',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard('المنتجات', '100+', Icons.inventory, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('الفئات', '8', Icons.category, Colors.green)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('المبيعات اليوم', '0 ر.س', Icons.trending_up, Colors.orange)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildCashierPage() {
    return Row(
      children: [
        // Products Panel (Left Side)
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'المنتجات المتاحة',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    labelText: 'البحث عن المنتجات',
                    hintText: 'ادخل اسم المنتج، الباركود، أو الفئة',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: _showBarcodeScanner,
                      tooltip: 'مسح الباركود',
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Products Grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _products.length,
                    itemBuilder: (context, index) => _buildProductCard(_products[index]),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Cart Panel (Right Side)
        Container(
          width: 400,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(
              left: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Column(
            children: [
              // Cart Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shopping_cart, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'سلة التسوق',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_cartItems.length} منتجات',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_cartItems.isNotEmpty)
                      IconButton(
                        onPressed: _clearCart,
                        icon: const Icon(Icons.delete_outline, color: Colors.white),
                        tooltip: 'مسح السلة',
                      ),
                  ],
                ),
              ),
              
              // Cart Items List
              Expanded(
                child: _cartItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'السلة فارغة',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'اضغط على المنتجات لإضافتها',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        final item = _cartItems[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.product.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${item.product.size} • ${item.product.color}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _cartItems.removeAt(index);
                                          if (_cartItems.isEmpty) _cartDiscount = 0.0;
                                        });
                                      },
                                      icon: const Icon(Icons.close, size: 20),
                                      color: Colors.red,
                                      tooltip: 'حذف',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Quantity Controls
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[300]!),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                if (item.quantity > 1) {
                                                  item.quantity--;
                                                }
                                              });
                                            },
                                            icon: const Icon(Icons.remove, size: 18),
                                            padding: const EdgeInsets.all(4),
                                            constraints: const BoxConstraints(),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            child: Text(
                                              '${item.quantity}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                item.quantity++;
                                              });
                                            },
                                            icon: const Icon(Icons.add, size: 18),
                                            padding: const EdgeInsets.all(4),
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Price
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${item.product.price.toStringAsFixed(2)} ر.س',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          '${item.subtotal.toStringAsFixed(2)} ر.س',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              ),
              
              // Cart Summary & Actions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Subtotal
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('المجموع الفرعي:', style: TextStyle(fontSize: 16)),
                        Text('${_subtotal.toStringAsFixed(2)} ر.س', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    
                    // Discount
                    if (_totalDiscount > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('الخصم:', style: TextStyle(fontSize: 16, color: Colors.green)),
                          Text(
                            '-${_totalDiscount.toStringAsFixed(2)} ر.س',
                            style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                    
                    const Divider(height: 24),
                    
                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'الإجمالي:',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_finalTotal.toStringAsFixed(2)} ر.س',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Action Buttons
                    if (_cartItems.isNotEmpty) ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _showDiscountDialog,
                              icon: const Icon(Icons.discount),
                              label: const Text('خصم'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _cartItems.isEmpty ? null : _showPaymentDialog,
                        icon: const Icon(Icons.payment, size: 24),
                        label: const Text('إتمام الدفع', style: TextStyle(fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(ClothingProduct product) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _addToCart(product),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.checkroom, size: 32, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                product.category,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${product.size} • ${product.color}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              Text(
                '${product.price.toStringAsFixed(2)} ر.س',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductManagementPage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Add Button
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.inventory, size: 48, color: Colors.blue[700]),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إدارة المنتجات',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        const Text('إضافة وتعديل وحذف المنتجات'),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddProductDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('منتج جديد'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // CRUD Operations
          Row(
            children: [
              Expanded(
                child: Card(
                  child: InkWell(
                    onTap: _showAddProductDialog,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(Icons.add_circle, size: 48, color: Colors.green[600]),
                          const SizedBox(height: 12),
                          const Text(
                            'إضافة منتج جديد',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Text('اسم، فئة، أسعار، خصائص'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: InkWell(
                    onTap: _showProductList,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(Icons.edit, size: 48, color: Colors.blue[600]),
                          const SizedBox(height: 12),
                          const Text(
                            'تعديل المنتجات',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Text('تحديث الأسعار والمخزون'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: InkWell(
                    onTap: _showCategoryManager,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(Icons.category, size: 48, color: Colors.orange[600]),
                          const SizedBox(height: 12),
                          const Text(
                            'إدارة الفئات',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Text('تنظيم المنتجات بالفئات'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Product List from Database
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          Text(
                'المنتجات الحالية',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
              ),
              TextButton.icon(
                onPressed: () => setState(() {}),
                icon: const Icon(Icons.refresh),
                label: const Text('تحديث'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _getAllProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
              children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('خطأ في تحميل المنتجات: ${snapshot.error}'),
                      ],
                    ),
                  );
                }
                
                final products = snapshot.data ?? [];
                
                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text('لا توجد منتجات بعد'),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _showAddProductDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('إضافة منتج'),
          ),
        ],
      ),
    );
  }

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildProductListItem(
                      product['name'] as String,
                      product['category'] as String? ?? 'غير محدد',
                      (product['buy_price'] as num).toDouble(),
                      (product['sell_price'] as num).toDouble(),
                      product['stock_quantity'] as int,
                      product['color'] as String? ?? 'غير محدد',
                      productId: product['id'] as int,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductListItem(String name, String category, double buyPrice, double sellPrice, int stock, String color, {int? productId}) {
    final profit = sellPrice - buyPrice;
    final margin = (profit / sellPrice * 100);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.checkroom),
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$category - $color'),
            Text('شراء: ${buyPrice.toStringAsFixed(2)} ر.س | بيع: ${sellPrice.toStringAsFixed(2)} ر.س'),
            Text(
              'ربح: ${profit.toStringAsFixed(2)} ر.س (${margin.toStringAsFixed(1)}%)',
              style: TextStyle(color: Colors.green[600], fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: productId != null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'مخزون: $stock',
              style: TextStyle(
                color: stock < 10 ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                        onPressed: () => _editProduct(productId),
                        icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  tooltip: 'تعديل',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () => _showDeleteProductDialog(productId),
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        tooltip: 'حذف',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
              ],
            ),
          ],
              )
            : Text(
                'مخزون: $stock',
                style: TextStyle(
                  color: stock < 10 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
        ),
      ),
    );
  }

  Widget _buildReportsPage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'التقارير والإحصائيات',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showExportDialog,
                icon: const Icon(Icons.file_download),
                label: const Text('تصدير CSV'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Statistics Cards
          Row(
            children: [
              Expanded(child: _buildStatCard('إجمالي المنتجات', '${_products.length}', Icons.inventory, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('المبيعات اليوم', _getSalesToday(), Icons.trending_up, Colors.green)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('إجمالي العمليات', _getTotalTransactions(), Icons.receipt, Colors.orange)),
            ],
          ),
          const SizedBox(height: 24),
          
          // Sales History Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'سجل المبيعات',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: _loadSalesHistory,
                icon: const Icon(Icons.refresh),
                label: const Text('تحديث'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Date Filter Buttons
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.blue, size: 20),
                  const SizedBox(width: 12),
                  const Text('تصفية حسب:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  _buildFilterChip('الكل', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('اليوم', 'today'),
                  const SizedBox(width: 8),
                  _buildFilterChip('هذا الشهر', 'month'),
                  const SizedBox(width: 8),
                  _buildFilterChip('3 أشهر', 'quarter'),
                  const Spacer(),
                  if (_dateFilter != 'all')
                    Text(
                      _getDateRangeText(),
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Sales History List
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _getFilteredSales(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Text('خطأ في تحميل السجل: ${snapshot.error}'),
                  );
                }
                
                final sales = snapshot.data ?? [];
                
                if (sales.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد عمليات بيع بعد',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: sales.length,
                  itemBuilder: (context, index) {
                    final sale = sales[index];
                    final saleDate = DateTime.parse(sale['sale_date'] as String);
                    final totalAmount = (sale['total_amount'] as num).toDouble();
                    final profitAmount = (sale['profit_amount'] as num).toDouble();
                    final paymentMethod = sale['payment_method'] as String;
                    final discountAmount = sale['discount_amount'] != null ? (sale['discount_amount'] as num).toDouble() : 0.0;
                    final subtotal = sale['subtotal'] != null ? (sale['subtotal'] as num).toDouble() : totalAmount;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green[100],
                          child: Icon(
                            paymentMethod == 'cash' ? Icons.money : Icons.credit_card,
                            color: Colors.green[700],
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              'فاتورة #${sale['id']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: paymentMethod == 'cash' ? Colors.blue[50] : Colors.purple[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                paymentMethod == 'cash' ? 'نقدي' : 'بطاقة',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: paymentMethod == 'cash' ? Colors.blue[700] : Colors.purple[700],
                                ),
                              ),
                            ),
                            if (discountAmount > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.discount, size: 12, color: Colors.orange[700]),
                                    const SizedBox(width: 4),
                                    Text(
                                      'خصم',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${saleDate.day}/${saleDate.month}/${saleDate.year} - ${saleDate.hour}:${saleDate.minute.toString().padLeft(2, '0')}',
                            ),
                            Text(
                              'الكاشير: ${sale['cashier_name']}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            if (discountAmount > 0)
                              Text(
                                'خصم: ${discountAmount.toStringAsFixed(2)} ر.س',
                                style: TextStyle(fontSize: 12, color: Colors.orange[700], fontWeight: FontWeight.bold),
                              ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (discountAmount > 0) ...[
                              Text(
                                '${subtotal.toStringAsFixed(2)} ر.س',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                            Text(
                              '${totalAmount.toStringAsFixed(2)} ر.س',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            Text(
                              'ربح: ${profitAmount.toStringAsFixed(2)} ر.س',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _showSaleDetails(sale),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  String _getSalesToday() {
    // This will be calculated from database in a real implementation
    return '0.00 ر.س';
  }
  
  String _getTotalTransactions() {
    // This will be calculated from database in a real implementation
    return '0';
  }
  
  void _loadSalesHistory() {
    setState(() {});
  }
  
  // Date filtering helpers
  Widget _buildFilterChip(String label, String value) {
    final isSelected = _dateFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _dateFilter = value;
        });
      },
      selectedColor: Colors.blue[300],
      backgroundColor: Colors.white,
      checkmarkColor: Colors.white,
    );
  }
  
  Future<List<Map<String, dynamic>>> _getFilteredSales() async {
    final allSales = await _getAllSales();
    
    if (_dateFilter == 'all') {
      return allSales;
    }
    
    final now = DateTime.now();
    DateTime startDate;
    
    switch (_dateFilter) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'quarter':
        startDate = DateTime(now.year, now.month - 3, now.day);
        break;
      default:
        return allSales;
    }
    
    return allSales.where((sale) {
      final saleDate = DateTime.parse(sale['sale_date'] as String);
      return saleDate.isAfter(startDate) || saleDate.isAtSameMomentAs(startDate);
    }).toList();
  }
  
  String _getDateRangeText() {
    final now = DateTime.now();
    
    switch (_dateFilter) {
      case 'today':
        return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      case 'month':
        return 'من ${now.year}-${now.month.toString().padLeft(2, '0')}-01';
      case 'quarter':
        final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
        return 'من ${threeMonthsAgo.year}-${threeMonthsAgo.month.toString().padLeft(2, '0')}-${threeMonthsAgo.day.toString().padLeft(2, '0')}';
      default:
        return '';
    }
  }
  
  String _convertSalesToCSV(List<Map<String, dynamic>> sales) {
    if (sales.isEmpty) {
      return 'رقم الفاتورة,التاريخ,الكاشير,الإجمالي,التكلفة,الربح,المبلغ المدفوع,الباقي,طريقة الدفع,الخصم,الإجمالي قبل الخصم\n';
    }
    
    final header = 'رقم الفاتورة,التاريخ,الكاشير,الإجمالي,التكلفة,الربح,المبلغ المدفوع,الباقي,طريقة الدفع,الخصم,الإجمالي قبل الخصم\n';
    final rows = sales.map((sale) {
      final id = sale['id'];
      final date = sale['sale_date'];
      final cashier = sale['cashier_name'] ?? 'admin';
      final total = sale['total_amount'];
      final cost = sale['total_cost'] ?? 0;
      final profit = sale['profit_amount'] ?? 0;
      final paid = sale['paid_amount'] ?? total;
      final change = sale['change_amount'] ?? 0;
      final paymentMethod = sale['payment_method'] == 'cash' ? 'نقدي' : 'بطاقة';
      final discount = sale['discount_amount'] ?? 0;
      final subtotal = sale['subtotal'] ?? total;
      
      return '$id,$date,$cashier,$total,$cost,$profit,$paid,$change,$paymentMethod,$discount,$subtotal';
    }).join('\n');
    
    return header + rows;
  }
  
  void _showSaleDetails(Map<String, dynamic> sale) async {
    // Load sale items
    final saleItems = await _getSaleItems(sale['id'] as int);
    final discountAmount = sale['discount_amount'] != null ? (sale['discount_amount'] as num).toDouble() : 0.0;
    final subtotal = sale['subtotal'] != null ? (sale['subtotal'] as num).toDouble() : (sale['total_amount'] as num).toDouble();
    final discountType = sale['discount_type'] as String?;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.receipt_long, color: Colors.blue),
            const SizedBox(width: 8),
            Text('تفاصيل فاتورة #${sale['id']}'),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sale Info
                _buildDetailRow('التاريخ', DateTime.parse(sale['sale_date'] as String).toString().substring(0, 16)),
                _buildDetailRow('الكاشير', sale['cashier_name'] as String),
                _buildDetailRow('طريقة الدفع', sale['payment_method'] == 'cash' ? 'نقدي' : 'بطاقة'),
                const Divider(),
                
                // Items
                const Text('المنتجات:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...saleItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item['quantity']}x منتج #${item['product_id']}'),
                      Text('${(item['total_price'] as num).toStringAsFixed(2)} ر.س'),
                    ],
                  ),
                )),
                const Divider(),
                
                // Totals
                _buildDetailRow('المجموع الفرعي', '${subtotal.toStringAsFixed(2)} ر.س'),
                if (discountAmount > 0) ...[
                  _buildDetailRow(
                    'الخصم ${discountType == 'percentage' ? '(نسبة %)' : '(مبلغ ثابت)'}',
                    '-${discountAmount.toStringAsFixed(2)} ر.س',
                    color: Colors.orange,
                    isBold: true,
                  ),
                  const Divider(),
                ],
                _buildDetailRow('الإجمالي', '${(sale['total_amount'] as num).toStringAsFixed(2)} ر.س', isBold: true),
                _buildDetailRow('المدفوع', '${(sale['paid_amount'] as num).toStringAsFixed(2)} ر.س'),
                if (sale['payment_method'] == 'cash')
                  _buildDetailRow('الباقي', '${(sale['change_amount'] as num).toStringAsFixed(2)} ر.س'),
                const Divider(),
                _buildDetailRow('الربح', '${(sale['profit_amount'] as num).toStringAsFixed(2)} ر.س', color: Colors.green, isBold: true),
              ],
            ),
          ),
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showPrintOptions(sale['id'] as int);
            },
            icon: const Icon(Icons.print),
            label: const Text('طباعة/حفظ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : null)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : null,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإعدادات',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  AuthService.logout();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تسجيل الخروج بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.logout),
                label: const Text('تسجيل الخروج'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildSettingCard('معلومات المتجر', 'اسم المتجر، العنوان، رقم الهاتف', Icons.store, () {}),
                _buildSettingCard('إعدادات الطباعة', 'إعداد الطابعات وتنسيق الفواتير', Icons.print, () {}),
                _buildSettingCard('إدارة المستخدمين', 'إضافة وإدارة المستخدمين والصلاحيات', Icons.people, () {}),
                _buildSettingCard('النسخ الاحتياطي', 'نسخ احتياطي واستعادة البيانات', Icons.backup, () {}),
                _buildSettingCard('تصدير البيانات', 'تصدير المنتجات والمبيعات', Icons.file_download, _showExportDialog),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_back_ios),
        onTap: onTap,
      ),
    );
  }

  // Dialog Methods
  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final tagsController = TextEditingController();
    final buyPriceController = TextEditingController();
    final sellPriceController = TextEditingController();
    final sizeController = TextEditingController();
    final colorController = TextEditingController();
    final materialController = TextEditingController();
    final stockController = TextEditingController(text: '10');
    final barcodeController = TextEditingController();
    final descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.add_box, color: Colors.green),
            SizedBox(width: 8),
            Text('إضافة منتج جديد'),
          ],
        ),
        content: SizedBox(
          width: 500,
          height: 600,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المنتج *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.inventory),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'الفئة *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                    hintText: 'مثال: قمصان، بناطيل، فساتين',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(
                    labelText: 'العلامات (مفصولة بفاصلة)',
                    hintText: 'صيفي, كاجوال, قطن',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: buyPriceController,
                        decoration: const InputDecoration(
                          labelText: 'سعر الشراء *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.shopping_cart),
                          suffixText: 'ر.س',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: sellPriceController,
                        decoration: const InputDecoration(
                          labelText: 'سعر البيع *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.sell),
                          suffixText: 'ر.س',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: sizeController,
                        decoration: const InputDecoration(
                          labelText: 'المقاس *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.straighten),
                          hintText: 'صغير، متوسط، كبير',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: colorController,
                        decoration: const InputDecoration(
                          labelText: 'اللون *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.palette),
                          hintText: 'أحمر، أزرق، أسود',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: materialController,
                        decoration: const InputDecoration(
                          labelText: 'المادة *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.texture),
                          hintText: 'قطن، جلد، حرير',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: stockController,
                        decoration: const InputDecoration(
                          labelText: 'الكمية *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.inventory_2),
                          suffixText: 'قطعة',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: barcodeController,
                  decoration: const InputDecoration(
                    labelText: 'الباركود',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.qr_code),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'الوصف',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                    hintText: 'وصف تفصيلي للمنتج',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Validate required fields
              if (nameController.text.trim().isEmpty ||
                  categoryController.text.trim().isEmpty ||
                  buyPriceController.text.trim().isEmpty ||
                  sellPriceController.text.trim().isEmpty ||
                  sizeController.text.trim().isEmpty ||
                  colorController.text.trim().isEmpty ||
                  materialController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('الرجاء ملء جميع الحقول المطلوبة (*)'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              final buyPrice = double.tryParse(buyPriceController.text);
              final sellPrice = double.tryParse(sellPriceController.text);
              final stock = int.tryParse(stockController.text) ?? 10;
              
              if (buyPrice == null || sellPrice == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('الأسعار يجب أن تكون أرقام صحيحة'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              if (sellPrice <= buyPrice) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('سعر البيع يجب أن يكون أكبر من سعر الشراء'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              
              Navigator.pop(context);
              
              try {
                final product = {
                  'name': nameController.text.trim(),
                  'category': categoryController.text.trim(),
                  'tags': tagsController.text.trim(),
                  'buy_price': buyPrice,
                  'sell_price': sellPrice,
                  'size': sizeController.text.trim(),
                  'color': colorController.text.trim(),
                  'material': materialController.text.trim(),
                  'stock_quantity': stock,
                  'barcode': barcodeController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'created_date': DateTime.now().toIso8601String(),
                  'updated_date': DateTime.now().toIso8601String(),
                };
                
                await _insertProduct(product);
                await _loadProducts(); // Reload products
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ تم إضافة "${nameController.text}" بنجاح${kIsWeb ? ' (Web - مؤقت)' : ''}'),
                  backgroundColor: Colors.green,
                ),
              );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطأ في الإضافة: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showProductList() async {
    final products = await _getAllProducts();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
            children: [
            Icon(Icons.inventory, color: Colors.blue),
            SizedBox(width: 8),
            Text('قائمة المنتجات'),
          ],
        ),
        content: SizedBox(
          width: 650,
          height: 500,
          child: products.isEmpty
              ? const Center(child: Text('لا توجد منتجات'))
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildEditableProductItem(
                      product['name'] as String,
                      product['category'] as String,
                      (product['buy_price'] as num).toDouble(),
                      (product['sell_price'] as num).toDouble(),
                      product['stock_quantity'] as int,
                      product['id'] as int,
                    );
                  },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableProductItem(String name, String category, double buyPrice, double sellPrice, int stock, int productId) {
    final profit = sellPrice - buyPrice;
    final margin = (profit / sellPrice * 100);
    
    return Card(
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$category - مخزون: $stock قطعة'),
            Text('شراء: ${buyPrice.toStringAsFixed(2)} | بيع: ${sellPrice.toStringAsFixed(2)} ر.س'),
            Text(
              'ربح: ${profit.toStringAsFixed(2)} ر.س (${margin.toStringAsFixed(1)}%)',
              style: TextStyle(color: Colors.green[600], fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
                _editProduct(productId);
              },
              icon: const Icon(Icons.edit, color: Colors.blue, size: 22),
              tooltip: 'تعديل',
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
                _showDeleteProductDialog(productId);
              },
              icon: const Icon(Icons.delete, color: Colors.red, size: 22),
              tooltip: 'حذف',
            ),
          ],
        ),
      ),
    );
  }

  void _showBarcodeScanner() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح الباركود'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_scanner, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text('امسح الباركود أو أدخله يدوياً'),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'رقم الباركود',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم العثور على المنتج')),
              );
            },
            child: const Text('بحث'),
          ),
        ],
      ),
    );
  }

  void _showQuickAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة سريعة'),
        content: const Text('اختر منتج من القائمة أو ابحث باستخدام الباركود'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
      _cartDiscount = 0.0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم مسح السلة'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showDiscountDialog() {
    final discountController = TextEditingController(text: _cartDiscount.toString());
    String tempDiscountType = _discountType;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('إضافة خصم'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Discount Type Selection
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'percentage', label: Text('نسبة %'), icon: Icon(Icons.percent)),
                    ButtonSegment(value: 'fixed', label: Text('مبلغ ثابت'), icon: Icon(Icons.money)),
                  ],
                  selected: {tempDiscountType},
                  onSelectionChanged: (Set<String> newSelection) {
                    setDialogState(() {
                      tempDiscountType = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Quick Discount Buttons
                const Text('خصومات سريعة:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildQuickDiscountButton(5, tempDiscountType, discountController, setDialogState),
                    _buildQuickDiscountButton(10, tempDiscountType, discountController, setDialogState),
                    _buildQuickDiscountButton(15, tempDiscountType, discountController, setDialogState),
                    _buildQuickDiscountButton(20, tempDiscountType, discountController, setDialogState),
                    _buildQuickDiscountButton(25, tempDiscountType, discountController, setDialogState),
                    if (tempDiscountType == 'fixed') _buildQuickDiscountButton(50, tempDiscountType, discountController, setDialogState),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Custom Discount Input
                TextField(
                  controller: discountController,
                  decoration: InputDecoration(
                    labelText: tempDiscountType == 'percentage' ? 'نسبة الخصم %' : 'مبلغ الخصم',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(tempDiscountType == 'percentage' ? Icons.percent : Icons.money),
                    suffixText: tempDiscountType == 'percentage' ? '%' : 'ر.س',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                
                // Preview
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('المجموع قبل الخصم:'),
                          Text('${_subtotal.toStringAsFixed(2)} ر.س'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('الخصم:'),
                          Text('-${_calculateDiscountPreview(discountController.text, tempDiscountType).toStringAsFixed(2)} ر.س', 
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('الإجمالي بعد الخصم:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${(_subtotal - _calculateDiscountPreview(discountController.text, tempDiscountType)).toStringAsFixed(2)} ر.س', 
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _discountType = tempDiscountType;
                  final discountValue = double.tryParse(discountController.text) ?? 0.0;
                  if (tempDiscountType == 'percentage') {
                    _cartDiscount = (_subtotal * discountValue / 100).clamp(0, _subtotal);
      } else {
                    _cartDiscount = discountValue.clamp(0, _subtotal);
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم تطبيق خصم بقيمة ${_cartDiscount.toStringAsFixed(2)} ر.س'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.check),
              label: const Text('تطبيق الخصم'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickDiscountButton(double value, String type, TextEditingController controller, StateSetter setDialogState) {
    return ElevatedButton(
      onPressed: () {
        setDialogState(() {
          controller.text = value.toString();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange[50],
        foregroundColor: Colors.orange[700],
      ),
      child: Text(type == 'percentage' ? '$value%' : '${value.toInt()} ر.س'),
    );
  }
  
  double _calculateDiscountPreview(String input, String type) {
    final value = double.tryParse(input) ?? 0.0;
    if (type == 'percentage') {
      return (_subtotal * value / 100).clamp(0, _subtotal);
    } else {
      return value.clamp(0, _subtotal);
    }
  }

  void _showPaymentDialog() {
    final paidController = TextEditingController(text: _finalTotal.toStringAsFixed(2));
    String paymentMethod = 'cash';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('إتمام عملية الدفع'),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Order Summary
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('عدد الأصناف:'),
                            Text('${_cartItems.length}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('إجمالي القطع:'),
                            Text('${_cartItems.fold(0, (sum, item) => sum + item.quantity)}'),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('المجموع الفرعي:'),
                            Text('${_subtotal.toStringAsFixed(2)} ر.س'),
                          ],
                        ),
                        if (_totalDiscount > 0) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('الخصم:', style: TextStyle(color: Colors.green)),
                              Text('-${_totalDiscount.toStringAsFixed(2)} ر.س', 
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'إجمالي المبلغ:',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_finalTotal.toStringAsFixed(2)} ر.س',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Payment Method
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text('طريقة الدفع:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('نقدي'),
                          value: 'cash',
                          groupValue: paymentMethod,
                          onChanged: (value) => setDialogState(() => paymentMethod = value!),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('بطاقة'),
                          value: 'card',
                          groupValue: paymentMethod,
                          onChanged: (value) => setDialogState(() => paymentMethod = value!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Payment Amount
                  TextField(
                    controller: paidController,
                    decoration: const InputDecoration(
                      labelText: 'المبلغ المدفوع',
                      border: OutlineInputBorder(),
                      suffixText: 'ر.س',
                      prefixIcon: Icon(Icons.payments),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  
                  // Quick Amount Buttons (for cash)
                  if (paymentMethod == 'cash') ...[
                    const Text('مبالغ سريعة:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildQuickAmountButton(_finalTotal, paidController, setDialogState),
                        _buildQuickAmountButton(_finalTotal + 10, paidController, setDialogState),
                        _buildQuickAmountButton(_finalTotal + 50, paidController, setDialogState),
                        _buildQuickAmountButton(((_finalTotal / 50).ceil() * 50).toDouble(), paidController, setDialogState),
                        _buildQuickAmountButton(((_finalTotal / 100).ceil() * 100).toDouble(), paidController, setDialogState),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final paidAmount = double.tryParse(paidController.text) ?? 0.0;
                if (paidAmount < _finalTotal) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('المبلغ المدفوع أقل من المطلوب'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                _showReceiptDialog(paidAmount, paymentMethod);
              },
              icon: const Icon(Icons.print),
              label: const Text('دفع وطباعة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickAmountButton(double amount, TextEditingController controller, StateSetter setDialogState) {
    return ElevatedButton(
      onPressed: () {
        setDialogState(() {
          controller.text = amount.toStringAsFixed(2);
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[50],
        foregroundColor: Colors.blue[700],
      ),
      child: Text('${amount.toStringAsFixed(0)} ر.س'),
    );
  }

  void _showReceiptDialog(double paidAmount, String paymentMethod) {
    final now = DateTime.now();
    final invoiceNumber = now.millisecondsSinceEpoch;
    final changeAmount = paidAmount - _finalTotal;
    
    // Generate receipt content
    String receipt = '''=======================================
        متجر الملابس والإكسسوارات
=======================================
التاريخ: ${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}
رقم الفاتورة: $invoiceNumber
الكاشير: ${AuthService.currentUser}
=======================================

''';

    // Add items
    for (final item in _cartItems) {
      receipt += '''${item.product.name}
${item.product.category} - ${item.product.size} • ${item.product.color}
${item.quantity} × ${item.product.price.toStringAsFixed(2)} = ${item.subtotal.toStringAsFixed(2)} ر.س
''';
      if (item.discount > 0) {
        receipt += '''  خصم: -${item.discount.toStringAsFixed(2)} ر.س
''';
      }
      receipt += '\n';
    }

    receipt += '''=======================================
عدد الأصناف: ${_cartItems.length}
إجمالي القطع: ${_cartItems.fold(0, (sum, item) => sum + item.quantity)}

المجموع الفرعي: ${_subtotal.toStringAsFixed(2)} ر.س
''';

    if (_totalDiscount > 0) {
      receipt += '''الخصم الإجمالي: -${_totalDiscount.toStringAsFixed(2)} ر.س
''';
    }

    receipt += '''الإجمالي: ${_finalTotal.toStringAsFixed(2)} ر.س

طريقة الدفع: ${paymentMethod == 'cash' ? 'نقدي' : 'بطاقة'}
''';

    if (paymentMethod == 'cash') {
      receipt += '''المبلغ المدفوع: ${paidAmount.toStringAsFixed(2)} ر.س
الباقي: ${changeAmount.toStringAsFixed(2)} ر.س
''';
    }

    receipt += '''
=======================================
        شكراً لتسوقكم معنا
    نتطلع لخدمتكم مرة أخرى
=======================================''';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.receipt_long, color: Colors.green),
            const SizedBox(width: 8),
            const Text('فاتورة البيع'),
          ],
        ),
        content: Container(
          width: 350,
          height: 500,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            child: Text(
              receipt,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.4),
            ),
          ),
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              // Print receipt to console (simulates printer)
              print('\n');
              print('=' * 50);
              print('PRINTING RECEIPT TO CONSOLE (SIMULATED PRINTER)');
              print('=' * 50);
              print(receipt);
              print('=' * 50);
              print('\n');
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✓ تم إرسال الفاتورة للطباعة (راجع Console)'),
                  backgroundColor: Colors.blue,
                  duration: Duration(seconds: 3),
                ),
              );
            },
            icon: const Icon(Icons.print),
            label: const Text('طباعة الآن'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              
              // Save sale to database
              try {
                // Calculate totals
                final totalCost = _cartItems.fold(0.0, (sum, item) => 
                  sum + (item.product.price * 0.6 * item.quantity)); // Assuming 40% markup
                final profitAmount = _finalTotal - totalCost;
                
                // Prepare sale data with discount information
                final saleData = {
                  'total_amount': _finalTotal,
                  'total_cost': totalCost,
                  'profit_amount': profitAmount,
                  'paid_amount': paidAmount,
                  'change_amount': changeAmount,
                  'payment_method': paymentMethod,
                  'cashier_name': AuthService.currentUser ?? 'admin',
                  'discount_amount': _totalDiscount,
                  'discount_type': _discountType,
                  'subtotal': _subtotal,
                };
                
                // Prepare sale items (Note: we need product IDs from database)
                final saleItems = _cartItems.map((item) => {
                  'product_id': 1, // This should be the actual product ID from database
                  'quantity': item.quantity,
                  'buy_price': item.product.price * 0.6, // Assuming 40% markup
                  'sell_price': item.product.price,
                  'total_cost': item.product.price * 0.6 * item.quantity,
                  'total_price': item.subtotal - item.discount,
                }).toList();
                
                // Save to database and get sale ID
                final saleId = await _insertSale(saleData, saleItems);
                
                // Clear cart
                setState(() {
                  _cartItems.clear();
                  _cartDiscount = 0.0;
                });
                
                // Show success message with print/save options
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم إتمام البيع وحفظه! 🎉\n'
                      '${paymentMethod == 'cash' ? 'الباقي: ${changeAmount.toStringAsFixed(2)} ر.س' : 'تم الدفع بالبطاقة'}',
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 5),
                    action: SnackBarAction(
                      label: 'طباعة/حفظ',
                      textColor: Colors.white,
                      onPressed: () => _showPrintOptions(saleId),
                    ),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم إتمام البيع ولكن حدث خطأ في الحفظ: $e'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('تم'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showPrintOptions(int saleId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.receipt_long, color: Colors.blue),
            SizedBox(width: 8),
            Text('خيارات الفاتورة'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // View Receipt
            ListTile(
              leading: const Icon(Icons.visibility, color: Colors.purple),
              title: const Text('عرض الفاتورة'),
              subtitle: const Text('معاينة الفاتورة المحفوظة'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final receiptText = await _generateReceiptText(saleId);
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Row(
                        children: [
                          const Icon(Icons.receipt_long, color: Colors.green),
                          const SizedBox(width: 8),
                          Text('فاتورة رقم #$saleId'),
                        ],
                      ),
                      content: Container(
                        width: 400,
                        height: 550,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SingleChildScrollView(
                          child: SelectableText(
                            receiptText,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('إغلاق'),
                        ),
                      ],
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('خطأ: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            const Divider(),
            // Print Receipt
            ListTile(
              leading: const Icon(Icons.print, color: Colors.blue),
              title: const Text('طباعة الفاتورة'),
              subtitle: const Text('إرسال إلى الطابعة (Console)'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await _printReceipt(saleId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✓ تم إرسال الفاتورة للطباعة\nتحقق من Console للمعاينة'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 4),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('خطأ في الطباعة: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            const Divider(),
            // Save to File
            ListTile(
              leading: const Icon(Icons.save, color: Colors.green),
              title: const Text('حفظ كملف نصي'),
              subtitle: const Text('حفظ الفاتورة في مجلد receipts/'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final file = await _saveReceiptToFile(saleId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✓ تم حفظ الفاتورة\n${file.path}'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 5),
                      action: SnackBarAction(
                        label: 'عرض المسار',
                        textColor: Colors.white,
                        onPressed: () => _showFileLocation(file.path),
                      ),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('خطأ في الحفظ: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            const Divider(),
            // Print AND Save
            ListTile(
              leading: const Icon(Icons.library_add_check, color: Colors.orange),
              title: const Text('طباعة وحفظ معاً'),
              subtitle: const Text('إرسال للطباعة + حفظ كملف'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  // Print first
                  await _printReceipt(saleId);
                  // Then save
                  final file = await _saveReceiptToFile(saleId);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '✓ تم طباعة وحفظ الفاتورة بنجاح!\n'
                        'الملف: ${file.path.split('/').last}',
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 5),
                      action: SnackBarAction(
                        label: 'عرض المسار',
                        textColor: Colors.white,
                        onPressed: () => _showFileLocation(file.path),
                      ),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('خطأ: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showCategoryManager() async {
    final categories = await _getCategoriesWithCounts();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.category, color: Colors.orange),
              SizedBox(width: 8),
              Text('إدارة الفئات'),
            ],
          ),
        content: SizedBox(
            width: 500,
            height: 400,
          child: Column(
            children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('الفئات المتاحة:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showAddCategoryDialog();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة فئة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Expanded(
                  child: categories.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                              Icon(Icons.category_outlined, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              const Text('لا توجد فئات بعد'),
                              const SizedBox(height: 8),
                              const Text('سيتم إنشاء الفئات تلقائياً عند إضافة منتجات'),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final name = category['category_name'] as String;
                            final count = category['product_count'] as int;
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(Icons.category, color: Colors.orange),
                                title: Text(
                                  name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('$count منتج'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _showEditCategoryDialog(name);
                                      },
                                      tooltip: 'تعديل',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _deleteCategory(name);
                                      },
                                      tooltip: 'حذف',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.add_box, color: Colors.green),
            SizedBox(width: 8),
            Text('إضافة فئة جديدة'),
          ],
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'اسم الفئة *',
            hintText: 'مثال: قمصان، أحذية، ساعات',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final categoryName = controller.text.trim();
              if (categoryName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('اسم الفئة مطلوب'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              Navigator.pop(context);
              try {
                await _dbService.addCategory(categoryName);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تمت إضافة الفئة "$categoryName" ✓\nقم بإضافة منتجات لهذه الفئة'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطأ: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(String oldName) {
    final controller = TextEditingController(text: oldName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit, color: Colors.blue),
            SizedBox(width: 8),
            Text('تعديل الفئة'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الفئة الحالية: $oldName', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'الاسم الجديد *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            Text(
              'تنبيه: سيتم تحديث جميع المنتجات في هذه الفئة',
              style: TextStyle(fontSize: 12, color: Colors.orange[700]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty || newName == oldName) {
                Navigator.pop(context);
                return;
              }
              
              Navigator.pop(context);
              try {
                await _updateCategory(oldName, newName);
                await _loadProducts(); // Reload to update cashier page
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم تحديث الفئة من "$oldName" إلى "$newName" ✓'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطأ: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('تحديث'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(String categoryName) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('حذف الفئة'),
          ],
        ),
        content: Text(
          'هل تريد حذف فئة "$categoryName"؟\n\n'
          'ملاحظة: لا يمكن حذف فئة تحتوي على منتجات.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _deleteCategoryService(categoryName);
                
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حذف الفئة "$categoryName" ✓'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$e'),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _editProduct(int productId) async {
    // Load product details
    final product = await _getProductById(productId);
    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('المنتج غير موجود'), backgroundColor: Colors.red),
      );
      return;
    }
    
    // Create controllers with existing values
    final nameController = TextEditingController(text: product['name'] as String);
    final categoryController = TextEditingController(text: product['category'] as String);
    final tagsController = TextEditingController(text: product['tags'] as String? ?? '');
    final buyPriceController = TextEditingController(text: product['buy_price'].toString());
    final sellPriceController = TextEditingController(text: product['sell_price'].toString());
    final sizeController = TextEditingController(text: product['size'] as String);
    final colorController = TextEditingController(text: product['color'] as String);
    final materialController = TextEditingController(text: product['material'] as String);
    final stockController = TextEditingController(text: product['stock_quantity'].toString());
    final barcodeController = TextEditingController(text: product['barcode'] as String? ?? '');
    final descriptionController = TextEditingController(text: product['description'] as String? ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.edit, color: Colors.blue),
            const SizedBox(width: 8),
            Text('تعديل ${product['name']}'),
          ],
        ),
        content: SizedBox(
          width: 500,
          height: 600,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المنتج *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.inventory),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'الفئة *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(
                    labelText: 'العلامات',
                    hintText: 'صيفي, كاجوال, قطن',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: buyPriceController,
                        decoration: const InputDecoration(
                          labelText: 'سعر الشراء *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.shopping_cart),
                          suffixText: 'ر.س',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: sellPriceController,
                        decoration: const InputDecoration(
                          labelText: 'سعر البيع *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.sell),
                          suffixText: 'ر.س',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: sizeController,
                        decoration: const InputDecoration(
                          labelText: 'المقاس *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.straighten),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: colorController,
                        decoration: const InputDecoration(
                          labelText: 'اللون *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.palette),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: materialController,
                        decoration: const InputDecoration(
                          labelText: 'المادة *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.texture),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: stockController,
                        decoration: const InputDecoration(
                          labelText: 'الكمية *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.inventory_2),
                          suffixText: 'قطعة',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: barcodeController,
                  decoration: const InputDecoration(
                    labelText: 'الباركود',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.qr_code),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'الوصف',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Validate
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('اسم المنتج مطلوب'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              final buyPrice = double.tryParse(buyPriceController.text);
              final sellPrice = double.tryParse(sellPriceController.text);
              final stock = int.tryParse(stockController.text) ?? 0;
              
              if (buyPrice == null || sellPrice == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('الأسعار يجب أن تكون أرقام صحيحة'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              Navigator.pop(context);
              
              try {
                final updatedProduct = {
                  'name': nameController.text.trim(),
                  'category': categoryController.text.trim(),
                  'tags': tagsController.text.trim(),
                  'buy_price': buyPrice,
                  'sell_price': sellPrice,
                  'size': sizeController.text.trim(),
                  'color': colorController.text.trim(),
                  'material': materialController.text.trim(),
                  'stock_quantity': stock,
                  'barcode': barcodeController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'updated_date': DateTime.now().toIso8601String(),
                };
                
                await _updateProduct(productId, updatedProduct);
                await _loadProducts(); // Reload products
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم تحديث "${nameController.text}" بنجاح ✓'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطأ في التحديث: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('تحديث'),
          ),
        ],
      ),
    );
  }

  void _showDeleteProductDialog(int productId) async {
    // Get product details first
    final product = await _getProductById(productId);
    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('المنتج غير موجود'), backgroundColor: Colors.red),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('حذف المنتج'),
          ],
        ),
        content: Text(
          'هل تريد حذف "${product['name']}"؟\n\n'
          'هذا الإجراء لا يمكن التراجع عنه.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _deleteProduct(productId);
                await _loadProducts(); // Reload products
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حذف "${product['name']}" بنجاح ✓'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطأ في الحذف: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    final filterLabel = _dateFilter == 'all' ? 'جميع' : 
                       _dateFilter == 'today' ? 'اليوم' :
                       _dateFilter == 'month' ? 'هذا الشهر' : '3 أشهر';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصدير البيانات'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('تصدير المنتجات'),
              subtitle: const Text('جميع المنتجات مع الأسعار والخصائص'),
              onTap: () => _exportData('products'),
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('تصدير جميع المبيعات'),
              subtitle: const Text('جميع المعاملات والأرباح'),
              onTap: () => _exportData('sales'),
            ),
            if (_dateFilter != 'all')
              ListTile(
                leading: const Icon(Icons.filter_alt, color: Colors.blue),
                title: Text('تصدير مبيعات ($filterLabel)'),
                subtitle: Text('المعاملات المصفاة: $_getDateRangeText()'),
                onTap: () => _exportData('filtered_sales'),
              ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('تصدير جميع البيانات'),
              subtitle: const Text('نسخة كاملة من قاعدة البيانات'),
              onTap: () => _exportData('all'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _exportData(String type) async {
    Navigator.pop(context);
    
    try {
      String csvContent = '';
      String fileName = '';
      
      switch (type) {
        case 'products':
          csvContent = await _dbService.exportTableToCSV('products');
          fileName = 'products_${DateTime.now().millisecondsSinceEpoch}.csv';
          break;
        case 'sales':
          csvContent = await _dbService.exportTableToCSV('sales');
          fileName = 'sales_${DateTime.now().millisecondsSinceEpoch}.csv';
          break;
        case 'filtered_sales':
          // Export only filtered sales
          final filteredSales = await _getFilteredSales();
          csvContent = _convertSalesToCSV(filteredSales);
          final filterName = _dateFilter == 'today' ? 'اليوم' :
                            _dateFilter == 'month' ? 'شهر' : '3أشهر';
          fileName = 'sales_${filterName}_${DateTime.now().millisecondsSinceEpoch}.csv';
          break;
        case 'all':
          csvContent = await _dbService.exportAllData();
          fileName = 'pos_backup_${DateTime.now().millisecondsSinceEpoch}.csv';
          break;
      }
      
      final file = await _dbService.saveExportToFile(csvContent, fileName);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تصدير البيانات بنجاح\nالملف: ${file.path}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'عرض الموقع',
            onPressed: () => _showFileLocation(file.path),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في التصدير: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _showFileLocation(String path) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('موقع الملف'),
        content: SelectableText(path),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }
}
