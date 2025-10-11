import 'package:flutter/material.dart';

class ProductManagementPage extends StatelessWidget {
  final VoidCallback onShowAddProductDialog;
  final VoidCallback onShowProductList;
  final VoidCallback onShowCategoryManager;
  final Future<List<Map<String, dynamic>>> Function() getAllProducts;
  final Function(int) onEditProduct;
  final Function(int) onDeleteProduct;

  const ProductManagementPage({
    super.key,
    required this.onShowAddProductDialog,
    required this.onShowProductList,
    required this.onShowCategoryManager,
    required this.getAllProducts,
    required this.onEditProduct,
    required this.onDeleteProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Add Button
          _buildHeader(context),
          const SizedBox(height: 16),

          // CRUD Operations Cards
          _buildCrudOperations(),
          const SizedBox(height: 24),

          // Product List from Database
          _buildProductListSection(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
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
              onPressed: onShowAddProductDialog,
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
    );
  }

  Widget _buildCrudOperations() {
    return Row(
      children: [
        Expanded(
          child: _buildOperationCard(
            'إضافة منتج جديد',
            'اسم، فئة، أسعار، خصائص',
            Icons.add_circle,
            Colors.green[600]!,
            onShowAddProductDialog,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildOperationCard(
            'تعديل المنتجات',
            'تحديث الأسعار والمخزون',
            Icons.edit,
            Colors.blue[600]!,
            onShowProductList,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildOperationCard(
            'إدارة الفئات',
            'تنظيم المنتجات بالفئات',
            Icons.category,
            Colors.orange[600]!,
            onShowCategoryManager,
          ),
        ),
      ],
    );
  }

  Widget _buildOperationCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductListSection(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
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
                onPressed: () {
                  // Trigger rebuild
                },
                icon: const Icon(Icons.refresh),
                label: const Text('تحديث'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: getAllProducts(),
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
                          onPressed: onShowAddProductDialog,
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
                        onPressed: () => onEditProduct(productId),
                        icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                        tooltip: 'تعديل',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () => onDeleteProduct(productId),
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
}

