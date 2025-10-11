import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/enhanced_database_service.dart';
import '../services/web_storage_service.dart';
import '../services/auth_service.dart';
import '../models/clothing_product.dart';
import 'cashier/cashier_page.dart';
import 'product_management/product_management_page.dart';
import 'reports/reports_page.dart';
import 'settings/settings_page.dart';
import 'dashboard/dashboard_page.dart';

/// Refactored Home Page - Main coordinator for the POS system
/// 
/// This page manages:
/// - Navigation between different sections (Dashboard, Cashier, Products, Reports, Settings)
/// - Shared state (cart, products, filters)
/// - Database operations
/// - Dialog presentations
class WorkingHomePage extends StatefulWidget {
  const WorkingHomePage({super.key});

  @override
  State<WorkingHomePage> createState() => _WorkingHomePageState();
}

class _WorkingHomePageState extends State<WorkingHomePage> {
  // Navigation
  int _selectedIndex = 0;
  
  // Cart State
  final List<CartItem> _cartItems = [];
  double _cartDiscount = 0.0;
  String _discountType = 'percentage';
  
  // Products State
  List<ClothingProduct> _products = [];
  bool _isLoadingProducts = true;
  final TextEditingController _searchController = TextEditingController();
  List<ClothingProduct> _filteredProducts = [];
  
  // Reports State
  String _dateFilter = 'all';
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  
  // Services
  final EnhancedDatabaseService _dbService = EnhancedDatabaseService();
  
  // Computed values
  double get _subtotal => _cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  double get _itemDiscounts => _cartItems.fold(0.0, (sum, item) => sum + item.discount);
  double get _totalDiscount => _itemDiscounts + _cartDiscount;
  double get _finalTotal => _subtotal - _totalDiscount;
  
  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_onSearchChanged);
    _showWebModeNotification();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  // ==================== LIFECYCLE METHODS ====================
  
  void _showWebModeNotification() {
    if (kIsWeb) {
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
  
  // ==================== DATA OPERATIONS ====================
  
  Future<void> _loadProducts() async {
    setState(() => _isLoadingProducts = true);
    
    try {
      final productsData = await _getAllProducts();
      
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
        _filteredProducts = _products;
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
  
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products.where((product) {
          return product.name.toLowerCase().contains(query) ||
                 product.category.toLowerCase().contains(query) ||
                 product.color.toLowerCase().contains(query);
        }).toList();
      }
    });
  }
  
  // Platform-agnostic database operations
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
  
  Future<List<Map<String, dynamic>>> _getAllSales() async {
    return kIsWeb
        ? await WebStorageService.getAllSales()
        : await _dbService.getAllSales();
  }
  
  Future<List<Map<String, dynamic>>> _getFilteredSales() async {
    final allSales = await _getAllSales();
    
    if (_dateFilter == 'all') return allSales;
    
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
  
  Future<int> _insertSale(Map<String, dynamic> sale, List<Map<String, dynamic>> items) async {
    return kIsWeb
        ? await WebStorageService.insertSale(sale, items)
        : await _dbService.insertSale(sale, items);
  }
  
  // ==================== CART OPERATIONS ====================
  
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
  
  void _removeCartItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
      if (_cartItems.isEmpty) _cartDiscount = 0.0;
    });
  }
  
  void _updateCartItemQuantity(int index, int newQuantity) {
    if (newQuantity > 0) {
      setState(() {
        _cartItems[index].quantity = newQuantity;
      });
    }
  }
  
  Future<void> _searchAndAddByBarcode(String barcode) async {
    if (barcode.trim().isEmpty) return;
    
    try {
      final allProducts = await _getAllProducts();
      final found = allProducts.where((p) => 
        (p['barcode'] as String?) == barcode.trim()
      ).toList();
      
      if (found.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('لم يتم العثور على منتج بالباركود: $barcode'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      final productData = found.first;
      final product = ClothingProduct(
        name: productData['name'] as String,
        category: productData['category'] as String,
        price: (productData['sell_price'] as num).toDouble(),
        size: productData['size'] as String,
        color: productData['color'] as String,
      );
      
      _addToCart(product);
      _searchController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ تمت إضافة ${product.name} عبر الباركود'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في البحث: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // ==================== NAVIGATION ====================
  
  void _navigateTo(int index) {
    setState(() => _selectedIndex = index);
  }
  
  // ==================== UI BUILD METHODS ====================
  
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
              onPressed: () => _navigateTo(4),
              icon: const Icon(Icons.settings),
              tooltip: 'الإعدادات',
            ),
          ],
        ),
        body: _buildCurrentPage(),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _navigateTo,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'الرئيسية'),
            NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'الكاشير'),
            NavigationDestination(icon: Icon(Icons.inventory), label: 'إدارة المنتجات'),
            NavigationDestination(icon: Icon(Icons.analytics), label: 'التقارير'),
            NavigationDestination(icon: Icon(Icons.settings), label: 'الإعدادات'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return DashboardPage(
          currentUser: AuthService.currentUser ?? 'مستخدم',
          productsCount: _products.length,
          onNavigateToCashier: () => _navigateTo(1),
          onNavigateToProductManagement: () => _navigateTo(2),
          onNavigateToReports: () => _navigateTo(3),
          onShowAddProductDialog: _showAddProductDialog,
        );
      case 1:
        return CashierPage(
          products: _products,
          filteredProducts: _filteredProducts,
          cartItems: _cartItems,
          searchController: _searchController,
          subtotal: _subtotal,
          totalDiscount: _totalDiscount,
          finalTotal: _finalTotal,
          onClearCart: _clearCart,
          onShowDiscountDialog: _showDiscountDialog,
          onShowPaymentDialog: _showPaymentDialog,
          onShowBarcodeScanner: _showBarcodeScanner,
          onAddToCart: _addToCart,
          onRemoveCartItem: _removeCartItem,
          onUpdateQuantity: _updateCartItemQuantity,
          onSearchAndAddByBarcode: _searchAndAddByBarcode,
        );
      case 2:
        return ProductManagementPage(
          onShowAddProductDialog: _showAddProductDialog,
          onShowProductList: _showProductList,
          onShowCategoryManager: _showCategoryManager,
          getAllProducts: _getAllProducts,
          onEditProduct: _editProduct,
          onDeleteProduct: _showDeleteProductDialog,
        );
      case 3:
        return ReportsPage(
          productsCount: _products.length,
          salesToday: '0.00 ر.س',
          totalTransactions: '0',
          dateFilter: _dateFilter,
          getFilteredSales: _getFilteredSales,
          onDateFilterChanged: (filter) => setState(() => _dateFilter = filter),
          onRefresh: () => setState(() {}),
          onShowExportDialog: _showExportDialog,
          onShowSaleDetails: _showSaleDetails,
        );
      case 4:
        return SettingsPage(
          onLogout: _handleLogout,
          onShowExportDialog: _showExportDialog,
        );
      default:
        return const Center(child: Text('صفحة غير موجودة'));
    }
  }
  
  void _handleLogout() {
    AuthService.logout();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تسجيل الخروج بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }
  
  // ==================== DIALOG METHODS ====================
  // Note: These dialog methods remain in this file for now
  // They can be further refactored into separate dialog helper files if needed
  
  void _showAddProductDialog() {
    // TODO: Implementation - keeping from original file
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('إضافة منتج جديد - قيد التطوير')),
    );
  }
  
  void _showProductList() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('قائمة المنتجات - قيد التطوير')),
    );
  }
  
  void _showCategoryManager() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('إدارة الفئات - قيد التطوير')),
    );
  }
  
  void _editProduct(int productId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تعديل منتج #$productId - قيد التطوير')),
    );
  }
  
  void _showDeleteProductDialog(int productId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('حذف منتج #$productId - قيد التطوير')),
    );
  }
  
  void _showDiscountDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('إضافة خصم - قيد التطوير')),
    );
  }
  
  void _showPaymentDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('إتمام الدفع - قيد التطوير')),
    );
  }
  
  void _showBarcodeScanner() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('مسح الباركود - قيد التطوير')),
    );
  }
  
  void _showExportDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تصدير البيانات - قيد التطوير')),
    );
  }
  
  void _showSaleDetails(Map<String, dynamic> sale) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('عرض تفاصيل فاتورة #${sale['id']} - قيد التطوير')),
    );
  }
}

