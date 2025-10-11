import 'package:flutter/material.dart';
import '../../models/clothing_product.dart';

class CashierPage extends StatelessWidget {
  final List<ClothingProduct> products;
  final List<ClothingProduct> filteredProducts;
  final List<CartItem> cartItems;
  final TextEditingController searchController;
  final double subtotal;
  final double totalDiscount;
  final double finalTotal;
  final VoidCallback onClearCart;
  final VoidCallback onShowDiscountDialog;
  final VoidCallback onShowPaymentDialog;
  final VoidCallback onShowBarcodeScanner;
  final Function(ClothingProduct) onAddToCart;
  final Function(int) onRemoveCartItem;
  final Function(int, int) onUpdateQuantity;
  final Function(String) onSearchAndAddByBarcode;

  const CashierPage({
    super.key,
    required this.products,
    required this.filteredProducts,
    required this.cartItems,
    required this.searchController,
    required this.subtotal,
    required this.totalDiscount,
    required this.finalTotal,
    required this.onClearCart,
    required this.onShowDiscountDialog,
    required this.onShowPaymentDialog,
    required this.onShowBarcodeScanner,
    required this.onAddToCart,
    required this.onRemoveCartItem,
    required this.onUpdateQuantity,
    required this.onSearchAndAddByBarcode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Products Panel (Left Side)
        Expanded(
          flex: 2,
          child: _buildProductsPanel(context),
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
          child: _buildCartPanel(context),
        ),
      ],
    );
  }

  Widget _buildProductsPanel(BuildContext context) {
    return Padding(
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
          
          // Search Bar with Barcode Support
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'البحث عن المنتجات أو الباركود',
              hintText: 'ادخل الباركود واضغط Enter للإضافة المباشرة',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => searchController.clear(),
                      tooltip: 'مسح',
                    ),
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: onShowBarcodeScanner,
                    tooltip: 'مسح الباركود',
                  ),
                ],
              ),
              border: const OutlineInputBorder(),
              helperText: 'ابحث بالاسم أو الفئة، أو اكتب الباركود واضغط Enter',
              helperMaxLines: 2,
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                onSearchAndAddByBarcode(value.trim());
              }
            },
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 16),
          
          // Products Grid (Filtered)
          Expanded(
            child: filteredProducts.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) => _buildProductCard(context, filteredProducts[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'لا توجد نتائج',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'جرب البحث بكلمات مختلفة',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ClothingProduct product) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => onAddToCart(product),
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

  Widget _buildCartPanel(BuildContext context) {
    return Column(
      children: [
        // Cart Header
        _buildCartHeader(context),
        
        // Cart Items List
        Expanded(
          child: cartItems.isEmpty
            ? _buildEmptyCart()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cartItems.length,
                itemBuilder: (context, index) => _buildCartItem(context, index),
              ),
        ),
        
        // Cart Summary & Actions
        _buildCartSummary(context),
      ],
    );
  }

  Widget _buildCartHeader(BuildContext context) {
    return Container(
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
                  '${cartItems.length} منتجات',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (cartItems.isNotEmpty)
            IconButton(
              onPressed: onClearCart,
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              tooltip: 'مسح السلة',
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
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
    );
  }

  Widget _buildCartItem(BuildContext context, int index) {
    final item = cartItems[index];
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
                  onPressed: () => onRemoveCartItem(index),
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
                        onPressed: () => onUpdateQuantity(index, item.quantity - 1),
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
                        onPressed: () => onUpdateQuantity(index, item.quantity + 1),
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
  }

  Widget _buildCartSummary(BuildContext context) {
    return Container(
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
              Text('${subtotal.toStringAsFixed(2)} ر.س', style: const TextStyle(fontSize: 16)),
            ],
          ),
          
          // Discount
          if (totalDiscount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الخصم:', style: TextStyle(fontSize: 16, color: Colors.green)),
                Text(
                  '-${totalDiscount.toStringAsFixed(2)} ر.س',
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
                '${finalTotal.toStringAsFixed(2)} ر.س',
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
          if (cartItems.isNotEmpty) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onShowDiscountDialog,
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
              onPressed: cartItems.isEmpty ? null : onShowPaymentDialog,
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
    );
  }
}

