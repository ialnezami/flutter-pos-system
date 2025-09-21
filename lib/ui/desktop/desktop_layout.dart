import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:possystem/models/clothing/clothing_product.dart';
import 'package:possystem/models/clothing/product_variant.dart';
import 'package:possystem/ui/clothing/size_color_selector.dart';
import 'package:possystem/ui/clothing/product_variant_card.dart';
import 'package:possystem/l10n/clothing_localizations.dart';

class DesktopPOSLayout extends StatefulWidget {
  const DesktopPOSLayout({Key? key}) : super(key: key);

  @override
  State<DesktopPOSLayout> createState() => _DesktopPOSLayoutState();
}

class _DesktopPOSLayoutState extends State<DesktopPOSLayout> {
  final List<CartItem> _cartItems = [];
  String _searchQuery = '';
  ClothingCategory? _selectedCategory;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus search on desktop
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: _handleKeyboardShortcuts,
        child: Row(
          children: [
            // Left Sidebar - Categories and Search
            Container(
              width: 300,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                border: Border(
                  right: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                    width: 1,
                  ),
                ),
              ),
              child: _buildLeftSidebar(),
            ),
            
            // Center - Product Grid
            Expanded(
              flex: 2,
              child: _buildProductGrid(),
            ),
            
            // Right Sidebar - Cart and Checkout
            Container(
              width: 350,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                    width: 1,
                  ),
                ),
              ),
              child: _buildCartSidebar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftSidebar() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.clothingL10n.formName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Search Bar
              TextField(
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'البحث عن المنتجات... (Ctrl+F)',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ],
          ),
        ),
        
        const Divider(),
        
        // Categories
        Expanded(
          child: _buildCategoryList(),
        ),
        
        // Quick Actions
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddProductDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة منتج جديد'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showInventoryDialog(),
                  icon: const Icon(Icons.inventory),
                  label: const Text('إدارة المخزون'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList() {
    return ListView(
      children: [
        // All Products
        ListTile(
          leading: const Icon(Icons.all_inclusive),
          title: const Text('جميع المنتجات'),
          selected: _selectedCategory == null,
          onTap: () {
            setState(() {
              _selectedCategory = null;
            });
          },
        ),
        
        const Divider(),
        
        // Category List
        ...ClothingCategory.values.map((category) {
          return ListTile(
            leading: _getCategoryIcon(category),
            title: Text(context.clothingL10n.getClothingCategoryName(category)),
            selected: _selectedCategory == category,
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildProductGrid() {
    return Column(
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Text(
                _selectedCategory != null 
                  ? context.clothingL10n.getClothingCategoryName(_selectedCategory!)
                  : 'جميع المنتجات',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // View Options
              ToggleButtons(
                isSelected: [true, false], // Grid view selected by default
                onPressed: (index) {
                  // Toggle between grid and list view
                },
                children: const [
                  Icon(Icons.grid_view),
                  Icon(Icons.list),
                ],
              ),
              const SizedBox(width: 16),
              // Sort Options
              DropdownButton<String>(
                value: 'name',
                items: const [
                  DropdownMenuItem(value: 'name', child: Text('ترتيب حسب الاسم')),
                  DropdownMenuItem(value: 'price', child: Text('ترتيب حسب السعر')),
                  DropdownMenuItem(value: 'stock', child: Text('ترتيب حسب المخزون')),
                ],
                onChanged: (value) {
                  // Handle sorting
                },
              ),
            ],
          ),
        ),
        
        // Product Grid
        Expanded(
          child: _buildProductGridView(),
        ),
      ],
    );
  }

  Widget _buildProductGridView() {
    // This would be connected to actual product data
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 columns for desktop
        childAspectRatio: 0.75, // Taller cards for clothing
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 12, // Sample count
      itemBuilder: (context, index) {
        return _buildSampleProductCard(index);
      },
    );
  }

  Widget _buildSampleProductCard(int index) {
    // Sample product for demonstration
    final sampleProducts = [
      'قميص قطني أزرق',
      'بنطلون جينز أسود',
      'فستان صيفي أبيض',
      'حذاء رياضي رمادي',
      'حقيبة يد بنية',
      'وشاح حريري أحمر',
    ];

    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => _showProductDetailsDialog(index),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Icon(
                  Icons.checkroom,
                  size: 60,
                  color: Colors.grey[400],
                ),
              ),
            ),
            
            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sampleProducts[index % sampleProducts.length],
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'أناقة', // Brand name
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(50 + index * 10).toStringAsFixed(2)} ر.س',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'متوفر',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSidebar() {
    return Column(
      children: [
        // Cart Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.shopping_cart,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                'سلة التسوق',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const Spacer(),
              Chip(
                label: Text('${_cartItems.length}'),
                backgroundColor: Theme.of(context).colorScheme.primary,
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
        
        // Cart Items
        Expanded(
          child: _cartItems.isEmpty 
            ? _buildEmptyCart()
            : _buildCartItems(),
        ),
        
        // Cart Summary and Checkout
        if (_cartItems.isNotEmpty) _buildCartSummary(),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'السلة فارغة',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اختر المنتجات لإضافتها للسلة',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _cartItems.length,
      itemBuilder: (context, index) {
        final item = _cartItems[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Product Image
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.checkroom,
                    color: Colors.grey[400],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.size} - ${item.color}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.price.toStringAsFixed(2)} ر.س',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Quantity Controls
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _updateQuantity(index, item.quantity - 1),
                      icon: const Icon(Icons.remove),
                      iconSize: 20,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.quantity.toString(),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _updateQuantity(index, item.quantity + 1),
                      icon: const Icon(Icons.add),
                      iconSize: 20,
                    ),
                  ],
                ),
                
                // Remove Button
                IconButton(
                  onPressed: () => _removeFromCart(index),
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red[700],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartSummary() {
    final subtotal = _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    final tax = subtotal * 0.15; // 15% VAT (common in Saudi Arabia)
    final total = subtotal + tax;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('المجموع الفرعي:'),
              Text('${subtotal.toStringAsFixed(2)} ر.س'),
            ],
          ),
          const SizedBox(height: 8),
          
          // Tax
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ضريبة القيمة المضافة (15%):'),
              Text('${tax.toStringAsFixed(2)} ر.س'),
            ],
          ),
          const SizedBox(height: 8),
          
          const Divider(),
          
          // Total
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
                '${total.toStringAsFixed(2)} ر.س',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Checkout Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _cartItems.isNotEmpty ? () => _clearCart() : null,
                  icon: const Icon(Icons.clear),
                  label: const Text('مسح السلة'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _cartItems.isNotEmpty ? () => _checkout() : null,
                  icon: const Icon(Icons.payment),
                  label: const Text('الدفع'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Icon _getCategoryIcon(ClothingCategory category) {
    switch (category) {
      case ClothingCategory.shirts:
        return const Icon(Icons.checkroom);
      case ClothingCategory.pants:
        return const Icon(Icons.checkroom);
      case ClothingCategory.dresses:
        return const Icon(Icons.checkroom);
      case ClothingCategory.shoes:
        return const Icon(Icons.sports_soccer);
      case ClothingCategory.accessories:
        return const Icon(Icons.watch);
      case ClothingCategory.outerwear:
        return const Icon(Icons.checkroom);
      case ClothingCategory.underwear:
        return const Icon(Icons.checkroom);
      case ClothingCategory.sportswear:
        return const Icon(Icons.sports);
      case ClothingCategory.bags:
        return const Icon(Icons.work_outline);
      case ClothingCategory.jewelry:
        return const Icon(Icons.diamond);
    }
  }

  void _handleKeyboardShortcuts(KeyEvent event) {
    if (event is KeyDownEvent) {
      // Ctrl+F for search
      if (event.logicalKey == LogicalKeyboardKey.keyF && 
          HardwareKeyboard.instance.isControlPressed) {
        _searchFocusNode.requestFocus();
      }
      // Ctrl+N for new product
      else if (event.logicalKey == LogicalKeyboardKey.keyN && 
               HardwareKeyboard.instance.isControlPressed) {
        _showAddProductDialog();
      }
      // Ctrl+Enter for checkout
      else if (event.logicalKey == LogicalKeyboardKey.enter && 
               HardwareKeyboard.instance.isControlPressed) {
        if (_cartItems.isNotEmpty) _checkout();
      }
      // Escape to clear search
      else if (event.logicalKey == LogicalKeyboardKey.escape) {
        _searchFocusNode.unfocus();
        setState(() {
          _searchQuery = '';
        });
      }
    }
  }

  void _showProductDetailsDialog(int productIndex) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 600,
          height: 500,
          child: Column(
            children: [
              // Dialog Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Text(
                      'تفاصيل المنتج',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              // Dialog Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Product details would go here
                      const Text('محتوى تفاصيل المنتج'),
                      const Spacer(),
                      
                      // Add to Cart Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _addSampleToCart(productIndex);
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('أضف للسلة'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addSampleToCart(int productIndex) {
    setState(() {
      _cartItems.add(CartItem(
        productName: 'منتج تجريبي ${productIndex + 1}',
        size: 'متوسط',
        color: 'أزرق',
        price: 50.0 + (productIndex * 10),
        quantity: 1,
      ));
    });
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeFromCart(index);
    } else {
      setState(() {
        _cartItems[index].quantity = newQuantity;
      });
    }
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
    });
  }

  void _checkout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الدفع'),
        content: Text('هل تريد المتابعة مع ${_cartItems.length} منتج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _processCheckout();
            },
            child: const Text('تأكيد الدفع'),
          ),
        ],
      ),
    );
  }

  void _processCheckout() {
    // Process the checkout
    setState(() {
      _cartItems.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إتمام عملية الدفع بنجاح!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showAddProductDialog() {
    // Show add product dialog
  }

  void _showInventoryDialog() {
    // Show inventory management dialog
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }
}

class CartItem {
  final String productName;
  final String size;
  final String color;
  final double price;
  int quantity;

  CartItem({
    required this.productName,
    required this.size,
    required this.color,
    required this.price,
    required this.quantity,
  });
}
