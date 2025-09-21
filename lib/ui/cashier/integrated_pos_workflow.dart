import 'package:flutter/material.dart';
import 'package:possystem/models/clothing/clothing_product.dart';
import 'package:possystem/models/clothing/product_variant.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/ui/barcode/barcode_scanner_widget.dart';
import 'package:possystem/services/barcode_service.dart';

class IntegratedPOSWorkflow extends StatefulWidget {
  const IntegratedPOSWorkflow({Key? key}) : super(key: key);

  @override
  State<IntegratedPOSWorkflow> createState() => _IntegratedPOSWorkflowState();
}

class _IntegratedPOSWorkflowState extends State<IntegratedPOSWorkflow> {
  final List<SaleItem> _cartItems = [];
  double _customerPayment = 0.0;
  bool _isProcessingPayment = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نقطة البيع المتكاملة'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Row(
        children: [
          // Left Panel - Scanning and Products
          Expanded(
            flex: 2,
            child: _buildScanningPanel(),
          ),
          
          // Right Panel - Cart and Payment
          Container(
            width: 400,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
              ),
            ),
            child: _buildPaymentPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scanning Header
          Row(
            children: [
              Icon(
                Icons.qr_code_scanner,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'مسح المنتجات',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showBarcodeScanner,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('مسح باركود'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Quick Scan Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'امسح أو اكتب الباركود هنا...',
                    prefixIcon: Icon(Icons.qr_code),
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: _handleBarcodeInput,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _showBarcodeScanner,
                icon: const Icon(Icons.camera_alt),
                tooltip: 'فتح الكاميرا',
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Recent Scans
          Text(
            'المنتجات الممسوحة:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Expanded(
            child: _cartItems.isEmpty 
              ? _buildEmptyScans()
              : _buildScannedProducts(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyScans() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'ابدأ بمسح المنتجات',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'استخدم الكاميرا أو الماسح المتصل',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannedProducts() {
    return ListView.builder(
      itemCount: _cartItems.length,
      itemBuilder: (context, index) {
        final item = _cartItems[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Container(
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
            title: Text(
              item.productName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item.size} - ${item.color}'),
                Text('الباركود: ${item.barcode}'),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.price.toStringAsFixed(2)} ر.س',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text('الكمية: ${item.quantity}'),
              ],
            ),
            onTap: () => _showProductDetails(item),
          ),
        );
      },
    );
  }

  Widget _buildPaymentPanel() {
    final subtotal = _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    final vat = subtotal * 0.15; // 15% VAT for Saudi Arabia
    final total = subtotal + vat;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment Header
          Row(
            children: [
              Icon(
                Icons.payment,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'الدفع والإيصال',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Cart Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildSummaryRow('المجموع الفرعي:', '${subtotal.toStringAsFixed(2)} ر.س'),
                _buildSummaryRow('ضريبة القيمة المضافة (15%):', '${vat.toStringAsFixed(2)} ر.س'),
                const Divider(),
                _buildSummaryRow(
                  'الإجمالي:', 
                  '${total.toStringAsFixed(2)} ر.س',
                  isTotal: true,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Payment Input
          TextField(
            decoration: const InputDecoration(
              labelText: 'المبلغ المدفوع (ر.س)',
              prefixIcon: Icon(Icons.attach_money),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _customerPayment = double.tryParse(value) ?? 0.0;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Change Calculation
          if (_customerPayment > 0) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _customerPayment >= total 
                  ? Colors.green[50] 
                  : Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _customerPayment >= total 
                    ? Colors.green[300]! 
                    : Colors.red[300]!,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('المبلغ المدفوع:'),
                      Text(
                        '${_customerPayment.toStringAsFixed(2)} ر.س',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('الباقي:'),
                      Text(
                        '${(_customerPayment - total).toStringAsFixed(2)} ر.س',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _customerPayment >= total 
                            ? Colors.green[700] 
                            : Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                  
                  // Change Breakdown
                  if (_customerPayment > total) ...[
                    const SizedBox(height: 8),
                    const Divider(),
                    const Text('تفصيل الباقي:'),
                    const SizedBox(height: 4),
                    _buildChangeBreakdown(_customerPayment - total),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Action Buttons
          const Spacer(),
          
          Column(
            children: [
              // Process Payment Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _cartItems.isNotEmpty && _customerPayment >= total && !_isProcessingPayment
                    ? _processPaymentAndPrint
                    : null,
                  icon: _isProcessingPayment 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.payment),
                  label: Text(_isProcessingPayment ? 'جاري المعالجة...' : 'دفع وطباعة الإيصال'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Clear Cart Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _cartItems.isNotEmpty ? _clearCart : null,
                  icon: const Icon(Icons.clear),
                  label: const Text('مسح السلة'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isTotal ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeBreakdown(double change) {
    // Calculate optimal change breakdown
    final breakdown = _calculateChangeBreakdown(change);
    
    return Column(
      children: breakdown.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${item['count']}× ${item['denomination']}'),
              Text('${item['total']} ر.س'),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Map<String, dynamic>> _calculateChangeBreakdown(double change) {
    final denominations = [100.0, 50.0, 20.0, 10.0, 5.0, 1.0, 0.50, 0.25, 0.10, 0.05];
    final breakdown = <Map<String, dynamic>>[];
    double remaining = change;

    for (final denom in denominations) {
      if (remaining >= denom) {
        final count = (remaining / denom).floor();
        if (count > 0) {
          breakdown.add({
            'denomination': denom >= 1 ? '${denom.toInt()} ر.س' : '${(denom * 100).toInt()} هللة',
            'count': count,
            'total': (count * denom).toStringAsFixed(2),
          });
          remaining = (remaining - (count * denom));
          remaining = double.parse(remaining.toStringAsFixed(2)); // Fix floating point precision
        }
      }
    }

    return breakdown;
  }

  void _showBarcodeScanner() {
    showDialog(
      context: context,
      builder: (context) => BarcodeScannerDialog(
        title: 'مسح باركود المنتج',
        subtitle: 'وجه الكاميرا نحو باركود المنتج',
        onBarcodeDetected: _handleScannedProduct,
      ),
    );
  }

  void _handleBarcodeInput(String barcode) {
    if (barcode.trim().isEmpty) return;
    
    final result = BarcodeService.instance.lookupProductByBarcode(barcode.trim());
    _handleScannedProduct(result);
  }

  void _handleScannedProduct(BarcodeResult result) {
    if (result.hasProduct && result.hasVariant) {
      // Product found - add to cart
      final saleItem = SaleItem(
        productName: result.product!.name,
        brand: result.product!.brand,
        size: result.variant!.size,
        color: result.variant!.color,
        barcode: result.code,
        price: result.product!.getVariantPrice(result.variant!.id).toDouble(),
        quantity: 1,
        sku: result.variant!.sku,
      );
      
      setState(() {
        _cartItems.add(saleItem);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إضافة: ${result.product!.name}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Product not found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('منتج غير موجود: ${result.code}'),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'إضافة منتج',
            onPressed: () => _showAddProductDialog(result.code),
          ),
        ),
      );
    }
  }

  void _showProductDetails(SaleItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.productName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الماركة: ${item.brand}'),
            Text('المقاس: ${item.size}'),
            Text('اللون: ${item.color}'),
            Text('الباركود: ${item.barcode}'),
            Text('السعر: ${item.price.toStringAsFixed(2)} ر.س'),
            Text('الكمية: ${item.quantity}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removeFromCart(item);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف من السلة'),
          ),
        ],
      ),
    );
  }

  void _processPaymentAndPrint() async {
    setState(() {
      _isProcessingPayment = true;
    });

    try {
      // 1. Calculate totals
      final subtotal = _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
      final vat = subtotal * 0.15;
      final total = subtotal + vat;
      final change = _customerPayment - total;

      // 2. Update cash drawer
      await _updateCashDrawer(_customerPayment, change);

      // 3. Generate receipt
      final receipt = _generateArabicReceipt(subtotal, vat, total, _customerPayment, change);

      // 4. Print receipt
      await _printReceipt(receipt);

      // 5. Clear cart and reset
      setState(() {
        _cartItems.clear();
        _customerPayment = 0.0;
        _isProcessingPayment = false;
      });

      // 6. Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إتمام البيع وطباعة الإيصال بنجاح!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

    } catch (e) {
      setState(() {
        _isProcessingPayment = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في معالجة الدفع: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateCashDrawer(double payment, double change) async {
    // Update cash drawer with payment received and change given
    // This would integrate with the actual Cashier model
    
    // Add payment to drawer
    // Remove change from drawer
    // Update denomination counts
    
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate processing
  }

  String _generateArabicReceipt(double subtotal, double vat, double total, double paid, double change) {
    final now = DateTime.now();
    final receiptNumber = now.millisecondsSinceEpoch.toString().substring(7);
    
    return '''
════════════════════════════════════
         متجر الأناقة للأزياء
        Anaqah Fashion Store
════════════════════════════════════

التاريخ: ${now.day}/${now.month}/${now.year}
الوقت: ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}
رقم الإيصال: $receiptNumber
الكاشير: أحمد محمد

────────────────────────────────────
المنتجات:
${_cartItems.map((item) => '''
${item.productName}
${item.size} - ${item.color}
${item.quantity} × ${item.price.toStringAsFixed(2)} ر.س = ${(item.quantity * item.price).toStringAsFixed(2)} ر.س
الباركود: ${item.barcode}
''').join('\n')}
────────────────────────────────────

المجموع الفرعي:        ${subtotal.toStringAsFixed(2)} ر.س
ضريبة القيمة المضافة:   ${vat.toStringAsFixed(2)} ر.س
────────────────────────────────────
الإجمالي:             ${total.toStringAsFixed(2)} ر.س
المدفوع:              ${paid.toStringAsFixed(2)} ر.س
الباقي:               ${change.toStringAsFixed(2)} ر.س
────────────────────────────────────

طريقة الدفع: نقداً
حالة الدفع: مكتمل

════════════════════════════════════
        شكراً لتسوقكم معنا!
      Thank you for shopping!
        
    للاستفسارات: 920001234
    www.anaqah-fashion.com
════════════════════════════════════
''';
  }

  Future<void> _printReceipt(String receipt) async {
    // This would integrate with the actual printer service
    // For now, show the receipt in a dialog
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 400,
          height: 600,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.receipt),
                    const SizedBox(width: 12),
                    const Text(
                      'إيصال البيع',
                      style: TextStyle(
                        fontSize: 18,
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
              
              // Receipt Content
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Text(
                      receipt,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.black,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
              ),
              
              // Print Actions
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        label: const Text('إغلاق'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم إرسال الإيصال للطابعة'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        icon: const Icon(Icons.print),
                        label: const Text('طباعة'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
      _customerPayment = 0.0;
    });
  }

  void _removeFromCart(SaleItem item) {
    setState(() {
      _cartItems.remove(item);
    });
  }

  void _showAddProductDialog(String barcode) {
    // Show dialog to add new product with scanned barcode
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة منتج جديد'),
        content: Text('تم مسح باركود جديد: $barcode\nهل تريد إضافة منتج جديد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to add product screen
            },
            child: const Text('إضافة منتج'),
          ),
        ],
      ),
    );
  }
}

class SaleItem {
  final String productName;
  final String brand;
  final String size;
  final String color;
  final String barcode;
  final double price;
  final int quantity;
  final String sku;

  SaleItem({
    required this.productName,
    required this.brand,
    required this.size,
    required this.color,
    required this.barcode,
    required this.price,
    required this.quantity,
    required this.sku,
  });
}
