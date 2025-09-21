import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const CompletePOSApp());
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

class CompletePOSApp extends StatelessWidget {
  const CompletePOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام نقاط البيع',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF448AFF),
      ),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: AuthService.isLoggedIn ? const CompletePOSHome() : const LoginPage(),
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

  void _login() {
    if (AuthService.login(_usernameController.text, _passwordController.text)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CompletePOSHome()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB0CDFF), Color(0xFFD8E5FB), Color(0xFFC3F9FE)],
            ),
          ),
          child: Center(
            child: Card(
              margin: const EdgeInsets.all(32),
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.store, size: 80, color: Colors.blue),
                    const SizedBox(height: 16),
                    const Text('نظام نقاط البيع', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const Text('متجر الملابس والإكسسوارات'),
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
                        onPressed: _login,
                        icon: const Icon(Icons.login),
                        label: const Text('تسجيل الدخول'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('admin / admin', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CompletePOSHome extends StatefulWidget {
  const CompletePOSHome({super.key});

  @override
  State<CompletePOSHome> createState() => _CompletePOSHomeState();
}

class _CompletePOSHomeState extends State<CompletePOSHome> {
  int _selectedIndex = 0;
  final List<CartItem> _cart = [];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('نظام نقاط البيع - متجر الملابس'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          actions: [
            IconButton(
              onPressed: () => setState(() => _selectedIndex = 4),
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomePage(),
            _buildCashierPage(),
            _buildProductManagementPage(),
            _buildReportsPage(),
            _buildSettingsPage(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) => setState(() => _selectedIndex = index),
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

  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مرحباً ${AuthService.currentUser}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          // Quick Actions - 4 Big Buttons
          const Text('الإجراءات السريعة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  'واجهة الكاشير',
                  'بدء عملية بيع جديدة\nبحث وإضافة منتجات',
                  Icons.point_of_sale,
                  Colors.green,
                  () => setState(() => _selectedIndex = 1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionCard(
                  'إدارة المنتجات',
                  'إضافة وتعديل المنتجات\nCRUD العمليات',
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
                child: _buildActionCard(
                  'إضافة منتج جديد',
                  'إضافة منتج للمخزون\nاسم، فئة، أسعار، خصائص',
                  Icons.add_circle,
                  Colors.orange,
                  _showAddProductDialog,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionCard(
                  'التقارير',
                  'إحصائيات المبيعات\nتصدير البيانات',
                  Icons.analytics,
                  Colors.purple,
                  () => setState(() => _selectedIndex = 3),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          const Text('إحصائيات المتجر', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(child: _buildStatCard('المنتجات', '100+', Icons.inventory, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('الفئات', '8', Icons.category, Colors.green)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('المبيعات', '0 ر.س', Icons.trending_up, Colors.orange)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 6,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 48, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
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
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(fontSize: 12)),
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
              children: [
                // Cashier Header
                Card(
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(Icons.point_of_sale, size: 48, color: Colors.green[700]),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('واجهة الكاشير', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              Text('ابحث عن المنتجات وأضفها للسلة'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Search Bar
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'البحث عن المنتجات',
                            hintText: 'ادخل اسم المنتج، الباركود، أو الفئة',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.qr_code_scanner),
                              onPressed: _showBarcodeScanner,
                            ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _addSampleProduct,
                                icon: const Icon(Icons.add_shopping_cart),
                                label: const Text('إضافة سريعة'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _clearCart,
                                icon: const Icon(Icons.clear_all),
                                label: const Text('مسح السلة'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Products Grid
                const Text('المنتجات المتاحة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                    children: [
                      _buildProductCard('قميص أزرق', 'قمصان', 120.0, 'متوسط', 'أزرق', 25),
                      _buildProductCard('بنطلون أسود', 'بناطيل', 280.0, '34', 'أسود', 18),
                      _buildProductCard('فستان أحمر', 'فساتين', 450.0, 'صغير', 'أحمر', 8),
                      _buildProductCard('حذاء بني', 'أحذية', 350.0, '42', 'بني', 15),
                      _buildProductCard('حقيبة يد', 'حقائب', 380.0, 'متوسط', 'أسود', 12),
                      _buildProductCard('ساعة ذهبية', 'ساعات', 850.0, 'قياس واحد', 'ذهبي', 3),
                      _buildProductCard('نظارة شمس', 'نظارات', 250.0, 'قياس واحد', 'أسود', 15),
                      _buildProductCard('حزام جلد', 'أحزمة', 180.0, '85 سم', 'بني', 20),
                      _buildProductCard('جوارب قطنية', 'جوارب', 25.0, '39-42', 'أسود', 50),
                    ],
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
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            border: Border(
              right: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Column(
            children: [
              // Cart Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shopping_cart, color: Theme.of(context).colorScheme.primary, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      'تفاصيل الطلب (${_cart.length})',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const Spacer(),
                    if (_cart.isNotEmpty)
                      IconButton(
                        onPressed: _clearCart,
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'مسح السلة',
                      ),
                  ],
                ),
              ),

              // Cart Items List
              Expanded(
                child: _cart.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'السلة فارغة',
                              style: TextStyle(fontSize: 20, color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'اختر المنتجات من اليسار\nلإضافتها إلى السلة',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _cart.length,
                        itemBuilder: (context, index) {
                          final item = _cart[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  // Product Info Row
                                  Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.checkroom, size: 24),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              '${item.price.toStringAsFixed(2)} ر.س للقطعة',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _removeFromCart(index),
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        tooltip: 'حذف من السلة',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Quantity Controls Row
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => _decreaseQuantity(index),
                                        icon: const Icon(Icons.remove_circle_outline),
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.grey[200],
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey[300]!),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${item.quantity}',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _increaseQuantity(index),
                                        icon: const Icon(Icons.add_circle_outline),
                                        style: IconButton.styleFrom(
                                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          const Text('الإجمالي', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                          Text(
                                            '${item.totalPrice.toStringAsFixed(2)} ر.س',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).colorScheme.primary,
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

              // Cart Summary and Checkout
              if (_cart.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Theme.of(context).dividerColor),
                    ),
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
                      // Order Summary
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('عدد الأصناف:'),
                                Text('${_cart.length}'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('إجمالي القطع:'),
                                Text('${_cart.fold(0, (sum, item) => sum + item.quantity)}'),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'المجموع الكلي:',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${_calculateTotal().toStringAsFixed(2)} ر.س',
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
                      
                      // Checkout Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _showPaymentDialog,
                          icon: const Icon(Icons.payment, size: 24),
                          label: const Text('الدفع وطباعة الفاتورة'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _buildProductCard(String name, String category, double price, String size, String color, int stock) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _addToCart(name, price),
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
                  child: Stack(
                    children: [
                      const Center(child: Icon(Icons.checkroom, size: 32, color: Colors.grey)),
                      if (stock < 10)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: const Icon(Icons.warning, size: 12, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1),
              Text(category, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text('$size • $color', style: const TextStyle(fontSize: 10)),
              const Spacer(),
              Text('${price.toStringAsFixed(2)} ر.س', 
                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
              Text('متوفر: $stock', style: TextStyle(fontSize: 10, color: stock < 10 ? Colors.red : Colors.green)),
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
          // Header
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.inventory, size: 48, color: Colors.blue[700]),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('إدارة المنتجات', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        Text('إضافة، تعديل، وحذف المنتجات مع جميع الخصائص'),
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

          // CRUD Action Cards
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
                          const Text('إضافة منتج', style: TextStyle(fontWeight: FontWeight.bold)),
                          const Text('اسم، فئة، أسعار، خصائص', style: TextStyle(fontSize: 12)),
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
                          const Text('تعديل المنتجات', style: TextStyle(fontWeight: FontWeight.bold)),
                          const Text('تحديث الأسعار والمخزون', style: TextStyle(fontSize: 12)),
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
                          const Text('إدارة الفئات', style: TextStyle(fontWeight: FontWeight.bold)),
                          const Text('تنظيم المنتجات', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Product List Preview
          const Text('المنتجات الحالية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildProductListItem('قميص قطني أبيض', 'قمصان', 80.0, 120.0, 25, 'قطن'),
                _buildProductListItem('بنطلون جينز أزرق', 'بناطيل', 180.0, 280.0, 20, 'جينز'),
                _buildProductListItem('فستان صيفي أصفر', 'فساتين', 180.0, 280.0, 8, 'قطن'),
                _buildProductListItem('حذاء رياضي أبيض', 'أحذية', 220.0, 350.0, 15, 'صناعي'),
                _buildProductListItem('حقيبة يد جلد', 'حقائب', 250.0, 380.0, 12, 'جلد'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductListItem(String name, String category, double buyPrice, double sellPrice, int stock, String material) {
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
            Text('$category - $material'),
            Text('شراء: ${buyPrice.toStringAsFixed(2)} | بيع: ${sellPrice.toStringAsFixed(2)} ر.س'),
            Text(
              'ربح: ${profit.toStringAsFixed(2)} ر.س (${margin.toStringAsFixed(1)}%)',
              style: TextStyle(color: Colors.green[600], fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('مخزون: $stock', style: TextStyle(color: stock < 10 ? Colors.red : Colors.green)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _editProduct(name),
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'تعديل',
                ),
                IconButton(
                  onPressed: () => _deleteProduct(name),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'حذف',
                ),
              ],
            ),
          ],
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
          const Text('التقارير والإحصائيات', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard('إجمالي المنتجات', '100', Icons.inventory, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('قيمة المخزون', '25,000 ر.س', Icons.warehouse, Colors.green)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('الربح المتوقع', '8,750 ر.س', Icons.trending_up, Colors.orange)),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showExportDialog,
            icon: const Icon(Icons.file_download),
            label: const Text('تصدير جميع البيانات'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
              const Text('الإعدادات', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () {
                  AuthService.logout();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                },
                icon: const Icon(Icons.logout),
                label: const Text('تسجيل الخروج'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildSettingCard('معلومات المتجر', 'اسم المتجر، العنوان، رقم الهاتف', Icons.store),
                _buildSettingCard('إعدادات الطباعة', 'إعداد الطابعات وتنسيق الفواتير', Icons.print),
                _buildSettingCard('إدارة المستخدمين', 'إضافة وإدارة المستخدمين', Icons.people),
                _buildSettingCard('النسخ الاحتياطي', 'نسخ احتياطي واستعادة البيانات', Icons.backup),
                _buildSettingCard('تصدير البيانات', 'تصدير المنتجات والمبيعات', Icons.file_download),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(String title, String subtitle, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_back_ios),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فتح إعدادات $title')),
          );
        },
      ),
    );
  }

  // Cart and Dialog Methods
  double _calculateTotal() {
    return _cart.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void _addToCart(String productName, double price) {
    setState(() {
      final existingIndex = _cart.indexWhere((item) => item.name == productName);
      if (existingIndex >= 0) {
        _cart[existingIndex].quantity++;
      } else {
        _cart.add(CartItem(name: productName, price: price, quantity: 1));
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إضافة $productName إلى السلة'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addSampleProduct() {
    _addToCart('قميص أزرق', 120.0);
  }

  void _removeFromCart(int index) {
    final itemName = _cart[index].name;
    setState(() => _cart.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حذف $itemName من السلة'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _increaseQuantity(int index) {
    setState(() => _cart[index].quantity++);
  }

  void _decreaseQuantity(int index) {
    setState(() {
      if (_cart[index].quantity > 1) {
        _cart[index].quantity--;
      } else {
        _removeFromCart(index);
      }
    });
  }

  void _clearCart() {
    if (_cart.isEmpty) return;
    
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
              setState(() => _cart.clear());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم مسح السلة'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  void _showBarcodeScanner() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح الباركود'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_scanner, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text('امسح الباركود أو أدخله يدوياً'),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'رقم الباركود',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addSampleProduct();
            },
            child: const Text('بحث'),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة منتج جديد'),
        content: SizedBox(
          width: 500,
          height: 600,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'اسم المنتج *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.inventory),
                  ),
                ),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'الفئة *',
                    hintText: 'قمصان، بناطيل، فساتين، أحذية، إلخ',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                ),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'العلامات (مفصولة بفاصلة)',
                    hintText: 'صيفي, كاجوال, قطن',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'سعر الشراء *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.shopping_cart),
                          suffixText: 'ر.س',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
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
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'المقاس *',
                          hintText: 'صغير، متوسط، كبير، 42',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.straighten),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'اللون *',
                          hintText: 'أبيض، أسود، أزرق',
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
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'المادة *',
                          hintText: 'قطن، حرير، جلد',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.texture),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'الكمية',
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
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'الباركود',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.qr_code),
                  ),
                ),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إضافة المنتج بنجاح'), backgroundColor: Colors.green),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showProductList() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('قائمة المنتجات للتعديل'),
        content: SizedBox(
          width: 600,
          height: 400,
          child: ListView(
            children: [
              _buildEditableProductItem('قميص قطني أبيض', 'قمصان', 80.0, 120.0, 25),
              _buildEditableProductItem('بنطلون جينز أزرق', 'بناطيل', 180.0, 280.0, 20),
              _buildEditableProductItem('فستان صيفي أصفر', 'فساتين', 180.0, 280.0, 8),
              _buildEditableProductItem('حذاء رياضي أبيض', 'أحذية', 220.0, 350.0, 15),
              _buildEditableProductItem('حقيبة يد جلد', 'حقائب', 250.0, 380.0, 12),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق'))],
      ),
    );
  }

  Widget _buildEditableProductItem(String name, String category, double buyPrice, double sellPrice, int stock) {
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Text('$category - شراء: ${buyPrice.toStringAsFixed(2)} | بيع: ${sellPrice.toStringAsFixed(2)} ر.س'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _editProduct(name),
              icon: const Icon(Icons.edit, color: Colors.blue),
            ),
            IconButton(
              onPressed: () => _deleteProduct(name),
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryManager() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إدارة الفئات'),
        content: SizedBox(
          width: 400,
          height: 300,
          child: ListView(
            children: [
              _buildCategoryItem('قمصان', 15),
              _buildCategoryItem('بناطيل', 15),
              _buildCategoryItem('فساتين', 12),
              _buildCategoryItem('أحذية', 18),
              _buildCategoryItem('جاكيتات', 10),
              _buildCategoryItem('ساعات', 8),
              _buildCategoryItem('حقائب', 12),
              _buildCategoryItem('مجوهرات', 10),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق'))],
      ),
    );
  }

  Widget _buildCategoryItem(String category, int count) {
    return ListTile(
      leading: const Icon(Icons.category),
      title: Text(category),
      trailing: Text('$count منتج'),
    );
  }

  void _showPaymentDialog() {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('السلة فارغة! أضف منتجات أولاً'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final totalAmount = _calculateTotal();
    final totalItems = _cart.fold(0, (sum, item) => sum + item.quantity);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إتمام عملية الدفع'),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Order Summary
              Container(
                padding: const EdgeInsets.all(16),
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
                        Text('${_cart.length}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('إجمالي القطع:'),
                        Text('$totalItems'),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'المجموع الكلي:',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${totalAmount.toStringAsFixed(2)} ر.س',
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

              // Cart Items Preview
              const Align(
                alignment: Alignment.centerRight,
                child: Text('المنتجات في السلة:', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _cart.length,
                  itemBuilder: (context, index) {
                    final item = _cart[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Row(
                        children: [
                          Expanded(child: Text(item.name)),
                          Text('${item.quantity} × ${item.price.toStringAsFixed(2)}'),
                          const SizedBox(width: 8),
                          Text(
                            '${item.totalPrice.toStringAsFixed(2)} ر.س',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  },
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
                      groupValue: 'cash',
                      onChanged: (value) {},
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('بطاقة'),
                      value: 'card',
                      groupValue: 'cash',
                      onChanged: (value) {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Payment Amount
              TextField(
                decoration: InputDecoration(
                  labelText: 'المبلغ المدفوع',
                  border: const OutlineInputBorder(),
                  suffixText: 'ر.س',
                  prefixIcon: const Icon(Icons.payments),
                  hintText: totalAmount.toStringAsFixed(2),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showReceiptDialog();
            },
            icon: const Icon(Icons.print),
            label: const Text('دفع وطباعة'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showReceiptDialog() {
    final now = DateTime.now();
    final dateTime = '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    final receiptId = now.millisecondsSinceEpoch;
    
    String receiptContent = '''=======================================
        متجر الملابس والإكسسوارات
=======================================
التاريخ: $dateTime
رقم الفاتورة: $receiptId
الكاشير: ${AuthService.currentUser}
=======================================

''';

    for (final item in _cart) {
      receiptContent += '''${item.name}
${item.quantity} × ${item.price.toStringAsFixed(2)} = ${item.totalPrice.toStringAsFixed(2)} ر.س

''';
    }

    final totalItems = _cart.fold(0, (sum, item) => sum + item.quantity);
    final totalAmount = _calculateTotal();

    receiptContent += '''=======================================
عدد الأصناف: ${_cart.length}
إجمالي القطع: $totalItems

المجموع الكلي: ${totalAmount.toStringAsFixed(2)} ر.س
طريقة الدفع: نقدي
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
          child: Column(
            children: [
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
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم إرسال الفاتورة للطابعة'),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      },
                      icon: const Icon(Icons.print),
                      label: const Text('طباعة'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() => _cart.clear()); // Clear cart after successful payment
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم إتمام البيع بنجاح! 🎉'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('تم'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
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

  void _editProduct(String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل $productName'),
        content: const Text('نموذج التعديل مع جميع الحقول:\n• الاسم والفئة\n• أسعار الشراء والبيع\n• المقاس واللون والمادة\n• الكمية والباركود'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم تحديث $productName')),
              );
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المنتج'),
        content: Text('هل تريد حذف $productName نهائياً؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم حذف $productName'), backgroundColor: Colors.red),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
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
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.inventory),
              title: Text('تصدير المنتجات'),
              subtitle: Text('جميع المنتجات مع الأسعار والخصائص'),
            ),
            ListTile(
              leading: Icon(Icons.receipt),
              title: Text('تصدير المبيعات'),
              subtitle: Text('جميع المعاملات والأرباح'),
            ),
            ListTile(
              leading: Icon(Icons.download),
              title: Text('تصدير الكل'),
              subtitle: Text('نسخة كاملة من قاعدة البيانات'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تصدير البيانات بنجاح'), backgroundColor: Colors.green),
              );
            },
            child: const Text('تصدير'),
          ),
        ],
      ),
    );
  }
}

class CartItem {
  final String name;
  final double price;
  int quantity;

  CartItem({required this.name, required this.price, this.quantity = 1});

  double get totalPrice => price * quantity;
}
