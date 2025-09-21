import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const WorkingPOSApp());
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

class WorkingPOSApp extends StatelessWidget {
  const WorkingPOSApp({super.key});

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
      home: AuthService.isLoggedIn ? const WorkingHomePage() : const LoginPage(),
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
          MaterialPageRoute(builder: (context) => const WorkingHomePage()),
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

class WorkingHomePage extends StatefulWidget {
  const WorkingHomePage({super.key});

  @override
  State<WorkingHomePage> createState() => _WorkingHomePageState();
}

class _WorkingHomePageState extends State<WorkingHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
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
    return Padding(
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'واجهة الكاشير',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        const Text('ابحث عن المنتجات وأضفها للسلة'),
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
                          onPressed: _showQuickAddDialog,
                          icon: const Icon(Icons.add_circle),
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

          // Sample Products Grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildProductCard('قميص أزرق', 'قمصان', 120.0, 'متوسط', 'أزرق'),
                _buildProductCard('بنطلون أسود', 'بناطيل', 280.0, '34', 'أسود'),
                _buildProductCard('فستان أحمر', 'فساتين', 450.0, 'صغير', 'أحمر'),
                _buildProductCard('حذاء بني', 'أحذية', 350.0, '42', 'بني'),
                _buildProductCard('حقيبة يد', 'حقائب', 380.0, 'متوسط', 'أسود'),
                _buildProductCard('ساعة ذهبية', 'ساعات', 850.0, 'قياس واحد', 'ذهبي'),
                _buildProductCard('نظارة شمس', 'نظارات', 250.0, 'قياس واحد', 'أسود'),
                _buildProductCard('حزام جلد', 'أحزمة', 180.0, '85 سم', 'بني'),
              ],
            ),
          ),

          // Cart Summary
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.shopping_cart, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text('السلة: 0 منتجات'),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _showPaymentDialog,
                    icon: const Icon(Icons.payment),
                    label: const Text('الدفع وطباعة الفاتورة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(String name, String category, double price, String size, String color) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم إضافة $name إلى السلة'),
              backgroundColor: Colors.green,
            ),
          );
        },
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
                name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                category,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '$size • $color',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              Text(
                '${price.toStringAsFixed(2)} ر.س',
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

          // Sample Product List
          Text(
            'المنتجات الحالية (عينة)',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildProductListItem('قميص قطني أبيض', 'قمصان', 80.0, 120.0, 25, 'أبيض'),
                _buildProductListItem('بنطلون جينز أزرق', 'بناطيل', 180.0, 280.0, 20, 'أزرق'),
                _buildProductListItem('فستان صيفي أصفر', 'فساتين', 180.0, 280.0, 8, 'أصفر'),
                _buildProductListItem('حذاء رياضي أبيض', 'أحذية', 220.0, 350.0, 15, 'أبيض'),
                _buildProductListItem('حقيبة يد جلد', 'حقائب', 250.0, 380.0, 12, 'أسود'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductListItem(String name, String category, double buyPrice, double sellPrice, int stock, String color) {
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
        trailing: Column(
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
          Text(
            'التقارير والإحصائيات',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
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
            label: const Text('تصدير البيانات'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة منتج جديد'),
        content: SizedBox(
          width: 400,
          height: 500,
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
                    Expanded(
                      child: TextField(
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
                        decoration: const InputDecoration(
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إضافة المنتج بنجاح'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('إضافة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showProductList() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('قائمة المنتجات'),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableProductItem(String name, String category, double buyPrice, double sellPrice, int stock) {
    final profit = sellPrice - buyPrice;
    final margin = (profit / sellPrice * 100);
    
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$category - مخزون: $stock'),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم مسح السلة'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إتمام عملية الدفع'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('إجمالي المبلغ: 0.00 ر.س'),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'المبلغ المدفوع',
                border: OutlineInputBorder(),
                suffixText: 'ر.س',
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
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showReceiptDialog();
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
    );
  }

  void _showReceiptDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('فاتورة البيع'),
        content: Container(
          width: 300,
          height: 400,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: const Text(
            '''=======================================
        متجر الملابس والإكسسوارات
=======================================
التاريخ: 21/09/2025 14:30
رقم الفاتورة: 12345
الكاشير: admin
=======================================

لا توجد منتجات في السلة

=======================================
الإجمالي: 0.00 ر.س
طريقة الدفع: نقدي
=======================================
        شكراً لتسوقكم معنا
    نتطلع لخدمتكم مرة أخرى
=======================================''',
            style: TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.print),
            label: const Text('طباعة'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
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

  void _showCategoryManager() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إدارة الفئات'),
        content: SizedBox(
          width: 400,
          height: 300,
          child: Column(
            children: [
              const Text('الفئات المتاحة:'),
              const SizedBox(height: 16),
              Expanded(
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
    );
  }

  Widget _buildCategoryItem(String category, int count) {
    return ListTile(
      leading: const Icon(Icons.category),
      title: Text(category),
      trailing: Text('$count منتج'),
    );
  }

  void _editProduct(String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل $productName'),
        content: const Text('سيتم فتح نموذج التعديل هنا'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
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
        content: Text('هل تريد حذف $productName؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم حذف $productName')),
              );
            },
            child: const Text('حذف'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
              subtitle: const Text('جميع المنتجات مع الأسعار والخصائص'),
              onTap: () => _exportData('products'),
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('تصدير المبيعات'),
              subtitle: const Text('جميع المعاملات والأرباح'),
              onTap: () => _exportData('sales'),
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

  void _exportData(String type) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تصدير $type بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
