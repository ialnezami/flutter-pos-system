import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/database_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const ArabicPOSApp());
}

class AuthService {
  static bool _isLoggedIn = false;
  static String? _currentUser;
  
  static bool get isLoggedIn => _isLoggedIn;
  static String? get currentUser => _currentUser;
  
  static bool login(String username, String password) {
    if (username == 'admin' && password == 'admin') {
      _isLoggedIn = true;
      _currentUser = username;
      return true;
    }
    return false;
  }
  
  static void logout() {
    _isLoggedIn = false;
    _currentUser = null;
  }
}

class ArabicPOSApp extends StatelessWidget {
  const ArabicPOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام نقاط البيع',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF448AFF),
        textTheme: const TextTheme().apply(
          fontFamily: 'NotoSansArabic',
        ),
      ),
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: AuthService.isLoggedIn ? const POSHomePage() : const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController(text: 'admin');
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    
    await Future.delayed(const Duration(seconds: 1)); // Simulate loading
    
    if (AuthService.login(_usernameController.text, _passwordController.text)) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const POSHomePage()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('اسم المستخدم أو كلمة المرور غير صحيحة'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFB0CDFF), Color(0xFFD8E5FB), Color(0xFFC3F9FE)],
            ),
          ),
          child: Center(
            child: Card(
              margin: const EdgeInsets.all(32),
              elevation: 8,
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.store,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'نظام نقاط البيع',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      'متجر الملابس والإكسسوارات',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم المستخدم',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'كلمة المرور',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _login(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _login,
                        icon: _isLoading 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.login),
                        label: Text(_isLoading ? 'جاري تسجيل الدخول...' : 'تسجيل الدخول'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'المستخدم الافتراضي: admin\nكلمة المرور: admin',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class POSHomePage extends StatefulWidget {
  const POSHomePage({super.key});

  @override
  State<POSHomePage> createState() => _POSHomePageState();
}

class _POSHomePageState extends State<POSHomePage> {
  int _selectedIndex = 0;
  final List<CartItem> _cartItems = [];
  double _totalAmount = 0.0;
  double _dailySales = 0.0;
  int _dailyTransactions = 0;
  double _dailyProfit = 0.0;
  
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load products from database
      final productsData = await _dbService.getAllProducts();
      _products = productsData.map((data) => Product.fromMap(data)).toList();
      _filteredProducts = _products;
      
      // Load daily summary
      final summary = await _dbService.getDailySummary();
      _dailySales = (summary['total_sales'] ?? 0.0).toDouble();
      _dailyTransactions = summary['transaction_count'] ?? 0;
      _dailyProfit = _dailySales * 0.35; // Assume 35% profit margin
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل البيانات: $e')),
        );
      }
    }
    
    setState(() => _isLoading = false);
  }

  void _addToCart(Product product) {
    setState(() {
      _cartItems.add(CartItem(product: product, quantity: 1));
      _calculateTotal();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إضافة ${product.name} إلى السلة'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _calculateTotal() {
    _totalAmount = _cartItems.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products.where((product) {
          return product.name.toLowerCase().contains(query.toLowerCase()) ||
                 product.category.toLowerCase().contains(query.toLowerCase()) ||
                 product.size.toLowerCase().contains(query.toLowerCase()) ||
                 product.color.toLowerCase().contains(query.toLowerCase()) ||
                 (product.barcode != null && product.barcode!.contains(query));
        }).toList();
      }
    });
  }

  void _clearCart() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح السلة'),
        content: const Text('هل تريد مسح جميع المنتجات من السلة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _cartItems.clear();
                _calculateTotal();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم مسح السلة'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
      _calculateTotal();
    });
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
            TextField(
              decoration: const InputDecoration(
                labelText: 'رقم الباركود',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (barcode) {
                _searchByBarcode(barcode);
                Navigator.pop(context);
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

  void _searchByBarcode(String barcode) {
    final product = _products.firstWhere(
      (p) => p.barcode == barcode,
      orElse: () => Product(
        name: 'غير موجود',
        category: '',
        price: 0,
        size: '',
        color: '',
      ),
    );
    
    if (product.name != 'غير موجود') {
      _addToCart(product);
      _searchController.text = barcode;
      _filterProducts(barcode);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('المنتج غير موجود'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showQuickAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة سريعة'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('اختر منتج من القائمة أو ابحث باستخدام الباركود'),
            SizedBox(height: 16),
            Text('هذه الميزة ستتيح إضافة المنتجات بسرعة للكاشير'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog() {
    if (_cartItems.isEmpty) return;
    
    final paidController = TextEditingController(text: _totalAmount.toStringAsFixed(2));
    String paymentMethod = 'cash';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('إتمام عملية الدفع'),
          content: SizedBox(
            width: 400,
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
                          Text(
                            'إجمالي المبلغ:',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_totalAmount.toStringAsFixed(2)} ر.س',
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
                      _buildQuickAmountButton(_totalAmount, paidController, setDialogState),
                      _buildQuickAmountButton(_totalAmount + 10, paidController, setDialogState),
                      _buildQuickAmountButton(_totalAmount + 50, paidController, setDialogState),
                      _buildQuickAmountButton(((_totalAmount / 50).ceil() * 50).toDouble(), paidController, setDialogState),
                      _buildQuickAmountButton(((_totalAmount / 100).ceil() * 100).toDouble(), paidController, setDialogState),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final paidAmount = double.tryParse(paidController.text) ?? 0.0;
                if (paidAmount < _totalAmount) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('المبلغ المدفوع أقل من المطلوب'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                Navigator.pop(context);
                await _processSale(paidAmount, paymentMethod);
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
        controller.text = amount.toStringAsFixed(2);
        setDialogState(() {});
      },
      child: Text('${amount.toStringAsFixed(0)} ر.س'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[50],
        foregroundColor: Colors.blue[700],
      ),
    );
  }

  Future<void> _processSale(double paidAmount, String paymentMethod) async {
    try {
      final changeAmount = paidAmount - _totalAmount;
      final saleId = DateTime.now().millisecondsSinceEpoch;
      
      // Prepare sale data
      final saleData = {
        'total_amount': _totalAmount,
        'paid_amount': paidAmount,
        'change_amount': changeAmount,
        'payment_method': paymentMethod,
        'cashier_name': AuthService.currentUser,
      };
      
      // Prepare sale items
      final saleItems = _cartItems.map((item) => {
        'product_id': item.product.id,
        'quantity': item.quantity,
        'unit_price': item.product.price,
        'total_price': item.product.price * item.quantity,
      }).toList();
      
      // Save to database
      await _dbService.insertSale(saleData, saleItems);
      
      // Show receipt and print
      await _showReceiptDialog(saleId, changeAmount, paymentMethod);
      
      // Clear cart and reload data
      setState(() {
        _cartItems.clear();
        _calculateTotal();
      });
      
      await _loadData(); // Refresh data
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في حفظ البيع: $e')),
      );
    }
  }

  Future<void> _showReceiptDialog(int saleId, double changeAmount, String paymentMethod) async {
    final receiptContent = _generateReceiptContent(saleId, changeAmount, paymentMethod);
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.receipt_long, color: Colors.green),
            const SizedBox(width: 8),
            const Text('فاتورة البيع'),
          ],
        ),
        content: SizedBox(
          width: 350,
          height: 500,
          child: Column(
            children: [
              // Receipt Preview
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      receiptContent,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Print Options
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _printReceipt(receiptContent),
                      icon: const Icon(Icons.print),
                      label: const Text('طباعة'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تم إتمام البيع بنجاح! 🎉\n'
                              '${paymentMethod == 'cash' ? 'الباقي: ${changeAmount.toStringAsFixed(2)} ر.س' : 'تم الدفع بالبطاقة'}',
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('تم'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _generateReceiptContent(int saleId, double changeAmount, String paymentMethod) {
    final now = DateTime.now();
    final dateTime = '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    
    String receipt = '''
=======================================
        متجر الملابس والإكسسوارات
=======================================
التاريخ: $dateTime
رقم الفاتورة: $saleId
الكاشير: ${AuthService.currentUser}
=======================================

''';

    for (final item in _cartItems) {
      receipt += '''${item.product.name}
${item.product.size} • ${item.product.color}
${item.quantity} × ${item.product.price.toStringAsFixed(2)} = ${(item.product.price * item.quantity).toStringAsFixed(2)} ر.س

''';
    }

    receipt += '''=======================================
عدد الأصناف: ${_cartItems.length}
إجمالي القطع: ${_cartItems.fold(0, (sum, item) => sum + item.quantity)}

المجموع الفرعي: ${_totalAmount.toStringAsFixed(2)} ر.س
الإجمالي: ${_totalAmount.toStringAsFixed(2)} ر.س

طريقة الدفع: ${paymentMethod == 'cash' ? 'نقدي' : 'بطاقة'}
''';

    if (paymentMethod == 'cash') {
      receipt += '''المبلغ المدفوع: ${(_totalAmount + changeAmount).toStringAsFixed(2)} ر.س
الباقي: ${changeAmount.toStringAsFixed(2)} ر.س
''';
    }

    receipt += '''
=======================================
        شكراً لتسوقكم معنا
    نتطلع لخدمتكم مرة أخرى
=======================================
''';

    return receipt;
  }

  void _printReceipt(String content) {
    // In a real app, this would connect to a thermal printer
    // For now, we'll show a print preview
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('طباعة الفاتورة'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.print, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text('تم إرسال الفاتورة للطابعة'),
            Text('سيتم طباعة الفاتورة على الطابعة الحرارية'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return _buildSalesPage();
      case 2:
        return _buildInventoryPage();
      case 3:
        return _buildStatisticsPage();
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'المبيعات اليومية',
                  '${_dailySales.toStringAsFixed(2)} ر.س',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'عدد المعاملات',
                  '$_dailyTransactions',
                  Icons.receipt,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'صافي الربح',
                  '${_dailyProfit.toStringAsFixed(2)} ر.س',
                  Icons.account_balance_wallet,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'الإجراءات السريعة',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  'بيع جديد',
                  Icons.add_shopping_cart,
                  () => setState(() => _selectedIndex = 1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickAction(
                  'إدارة المخزون',
                  Icons.inventory,
                  () => setState(() => _selectedIndex = 2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickAction(
                  'التقارير',
                  Icons.analytics,
                  () => setState(() => _selectedIndex = 3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalesPage() {
    return Row(
      children: [
            // Products Panel
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المنتجات المتاحة',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return Card(
                            elevation: 4,
                            child: InkWell(
                              onTap: () => _addToCart(product),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 80,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.checkroom,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      product.name,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      product.category,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Text(
                                      '${product.size} / ${product.color}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${product.price.toStringAsFixed(2)} ر.س',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Cart Panel
            Container(
              width: 350,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                border: Border(
                  right: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'سلة التسوق',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _cartItems.isEmpty
                        ? const Center(
                            child: Text(
                              'السلة فارغة\nاضغط على المنتجات لإضافتها',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _cartItems.length,
                            itemBuilder: (context, index) {
                              final item = _cartItems[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(item.product.name),
                                  subtitle: Text('${item.product.size} / ${item.product.color}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('${item.quantity}x'),
                                      const SizedBox(width: 8),
                                      Text('${(item.product.price * item.quantity).toStringAsFixed(2)} ر.س'),
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline),
                                        onPressed: () {
                                          setState(() {
                                            _cartItems.removeAt(index);
                                            _calculateTotal();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الإجمالي:',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_totalAmount.toStringAsFixed(2)} ر.س',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _cartItems.isEmpty ? null : _showPaymentDialog,
                      icon: const Icon(Icons.payment),
                      label: const Text('دفع'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
  }

  Widget _buildInventoryPage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إدارة المخزون',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddProductDialog(),
                icon: const Icon(Icons.add),
                label: const Text('منتج جديد'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                final stock = (index + 1) * 5;
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
                    title: Text(product.name),
                    subtitle: Text('${product.category} - ${product.size} / ${product.color}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${product.price.toStringAsFixed(2)} ر.س',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'متوفر: ${product.stockQuantity}',
                          style: TextStyle(
                            color: product.stockQuantity < 10 ? Colors.red : Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _showProductDetailsDialog(product),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsPage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإحصائيات والتقارير',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showExportDialog(),
                icon: const Icon(Icons.file_download),
                label: const Text('تصدير'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'إجمالي المنتجات',
                  '${_products.length}',
                  Icons.inventory,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'إجمالي المخزون',
                  '${_products.fold(0, (sum, p) => sum + p.stockQuantity)}',
                  Icons.warehouse,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'المبيعات اليومية',
                  '${_dailySales.toStringAsFixed(2)} ر.س',
                  Icons.trending_up,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'عدد المعاملات',
                  '$_dailyTransactions',
                  Icons.receipt,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'المبيعات الأسبوعية',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildWeeklyBar('السبت', 0.8),
                    _buildWeeklyBar('الأحد', 0.6),
                    _buildWeeklyBar('الاثنين', 0.9),
                    _buildWeeklyBar('الثلاثاء', 0.7),
                    _buildWeeklyBar('الأربعاء', 0.85),
                    _buildWeeklyBar('الخميس', 0.95),
                    _buildWeeklyBar('الجمعة', 1.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyBar(String day, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(day, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage > 0.8 ? Colors.green : 
                percentage > 0.6 ? Colors.orange : Colors.red,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('${(percentage * 100).toInt()}%'),
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
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
                _buildSettingCard(
                  'معلومات المتجر',
                  'اسم المتجر، العنوان، رقم الهاتف',
                  Icons.store,
                  () => _showStoreInfoDialog(),
                ),
                _buildSettingCard(
                  'إعدادات الطباعة',
                  'إعداد الطابعات وتنسيق الفواتير',
                  Icons.print,
                  () => _showPrinterSettingsDialog(),
                ),
                _buildSettingCard(
                  'إعدادات العملة',
                  'الريال السعودي، تنسيق الأسعار',
                  Icons.attach_money,
                  () => _showCurrencySettingsDialog(),
                ),
                _buildSettingCard(
                  'النسخ الاحتياطي',
                  'نسخ احتياطي واستعادة البيانات',
                  Icons.backup,
                  () => _showBackupDialog(),
                ),
                _buildSettingCard(
                  'تصدير البيانات',
                  'تصدير المنتجات والمبيعات والمخزون',
                  Icons.file_download,
                  () => _showExportDialog(),
                ),
                _buildSettingCard(
                  'حول التطبيق',
                  'الإصدار 1.0.0 - نظام نقاط البيع العربي',
                  Icons.info,
                  () => _showAboutDialog(),
                ),
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

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة منتج جديد'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'اسم المنتج',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'السعر (ر.س)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إضافة المنتج بنجاح')),
              );
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showProductDetailsDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الفئة: ${product.category}'),
            Text('المقاس: ${product.size}'),
            Text('اللون: ${product.color}'),
            Text('السعر: ${product.price.toStringAsFixed(2)} ر.س'),
            Text('المخزون: ${product.stockQuantity} قطعة'),
            if (product.barcode != null) Text('الباركود: ${product.barcode}'),
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
              _addToCart(product);
            },
            child: const Text('إضافة للسلة'),
          ),
        ],
      ),
    );
  }

  void _showStoreInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('معلومات المتجر'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'اسم المتجر',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'العنوان',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'رقم الهاتف',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showPrinterSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعدادات الطباعة'),
        content: const Text('سيتم إضافة إعدادات الطابعة قريباً'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showCurrencySettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعدادات العملة'),
        content: const Text('العملة الحالية: الريال السعودي (ر.س)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('النسخ الاحتياطي'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.upload),
              title: Text('إنشاء نسخة احتياطية'),
            ),
            ListTile(
              leading: Icon(Icons.download),
              title: Text('استعادة من نسخة احتياطية'),
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

  void _showExportDialog() {
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
              subtitle: const Text('جميع المنتجات والمخزون'),
              onTap: () => _exportData('products'),
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('تصدير المبيعات'),
              subtitle: const Text('جميع المعاملات والفواتير'),
              onTap: () => _exportData('sales'),
            ),
            ListTile(
              leading: const Icon(Icons.move_down),
              title: const Text('تصدير حركات المخزون'),
              subtitle: const Text('سجل حركات الإدخال والإخراج'),
              onTap: () => _exportData('inventory_movements'),
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

  Future<void> _exportData(String type) async {
    Navigator.pop(context); // Close dialog
    
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
        case 'inventory_movements':
          csvContent = await _dbService.exportTableToCSV('inventory_movements');
          fileName = 'inventory_${DateTime.now().millisecondsSinceEpoch}.csv';
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
            label: 'عرض',
            onPressed: () => _showFileLocation(file.path),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تصدير البيانات: $e')),
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

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حول التطبيق'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('نظام نقاط البيع العربي'),
            Text('الإصدار: 1.0.0'),
            Text('متخصص في متاجر الملابس والإكسسوارات'),
            SizedBox(height: 16),
            Text('الميزات:'),
            Text('• واجهة عربية كاملة'),
            Text('• قاعدة بيانات محلية'),
            Text('• تصدير البيانات'),
            Text('• إدارة المخزون'),
            Text('• التقارير والإحصائيات'),
            Text('• نظام المستخدمين'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
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
              label: 'المبيعات',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory),
              label: 'المخزون',
            ),
            NavigationDestination(
              icon: Icon(Icons.analytics),
              label: 'الإحصائيات',
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
}

class Product {
  final int? id;
  final String name;
  final String category;
  final double price;
  final String size;
  final String color;
  final int stockQuantity;
  final String? barcode;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.size,
    required this.color,
    this.stockQuantity = 0,
    this.barcode,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      price: (map['price'] as num).toDouble(),
      size: map['size'],
      color: map['color'],
      stockQuantity: map['stock_quantity'] ?? 0,
      barcode: map['barcode'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'size': size,
      'color': color,
      'stock_quantity': stockQuantity,
      'barcode': barcode,
    };
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}
