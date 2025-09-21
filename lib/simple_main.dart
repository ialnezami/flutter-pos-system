import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const ArabicPOSApp());
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
      home: const POSHomePage(),
    );
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

  final List<Product> _products = [
    Product('قميص أزرق', 'قمصان', 150.0, 'كبير', 'أزرق'),
    Product('بنطلون أسود', 'بناطيل', 200.0, 'متوسط', 'أسود'),
    Product('فستان أحمر', 'فساتين', 300.0, 'صغير', 'أحمر'),
    Product('حذاء بني', 'أحذية', 250.0, '42', 'بني'),
    Product('حقيبة يد', 'إكسسوارات', 180.0, 'متوسط', 'أسود'),
  ];

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

  void _checkout() {
    if (_cartItems.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إتمام عملية الدفع'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('إجمالي المبلغ: ${_totalAmount.toStringAsFixed(2)} ر.س'),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'المبلغ المدفوع',
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
              setState(() {
                _cartItems.clear();
                _calculateTotal();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إتمام عملية البيع بنجاح'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('دفع'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('نظام نقاط البيع - متجر الملابس'),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
        body: Row(
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
                      onPressed: _cartItems.isEmpty ? null : _checkout,
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
        ),
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
  final String name;
  final String category;
  final double price;
  final String size;
  final String color;

  Product(this.name, this.category, this.price, this.size, this.color);
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}
