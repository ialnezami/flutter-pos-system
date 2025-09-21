import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:possystem/models/clothing/clothing_product.dart';
import 'package:possystem/models/clothing/product_variant.dart';
import 'package:possystem/services/barcode_service.dart';
import 'package:possystem/ui/barcode/barcode_scanner_widget.dart';
import 'package:possystem/ui/barcode/barcode_generator_widget.dart';

class DesktopBarcodeManager extends StatefulWidget {
  final Function(BarcodeResult)? onBarcodeScanned;
  final List<ClothingProduct>? products;

  const DesktopBarcodeManager({
    Key? key,
    this.onBarcodeScanned,
    this.products,
  }) : super(key: key);

  @override
  State<DesktopBarcodeManager> createState() => _DesktopBarcodeManagerState();
}

class _DesktopBarcodeManagerState extends State<DesktopBarcodeManager> 
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _usbScannerController = TextEditingController();
  final FocusNode _usbScannerFocus = FocusNode();
  
  // USB Scanner simulation (for desktop)
  bool _isUSBScannerActive = false;
  String _lastUSBScan = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Auto-focus USB scanner input for desktop
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _usbScannerFocus.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      child: Column(
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  icon: const Icon(Icons.keyboard),
                  text: 'ماسح USB',
                ),
                Tab(
                  icon: const Icon(Icons.camera_alt),
                  text: 'كاميرا',
                ),
                Tab(
                  icon: const Icon(Icons.qr_code),
                  text: 'إنشاء باركود',
                ),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUSBScannerTab(),
                _buildCameraScannerTab(),
                _buildBarcodeGeneratorTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUSBScannerTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'اضغط هنا وامسح الباركود باستخدام الماسح المتصل بـ USB',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // USB Scanner Input
          TextField(
            controller: _usbScannerController,
            focusNode: _usbScannerFocus,
            decoration: InputDecoration(
              labelText: 'ماسح الباركود USB',
              hintText: 'امسح الباركود أو اكتبه هنا...',
              prefixIcon: Icon(
                _isUSBScannerActive ? Icons.qr_code_scanner : Icons.keyboard,
                color: _isUSBScannerActive ? Colors.green : null,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_usbScannerController.text.isNotEmpty)
                    IconButton(
                      onPressed: _clearUSBInput,
                      icon: const Icon(Icons.clear),
                    ),
                  IconButton(
                    onPressed: _toggleUSBScanner,
                    icon: Icon(
                      _isUSBScannerActive ? Icons.stop : Icons.play_arrow,
                      color: _isUSBScannerActive ? Colors.red : Colors.green,
                    ),
                    tooltip: _isUSBScannerActive ? 'إيقاف الماسح' : 'تشغيل الماسح',
                  ),
                ],
              ),
              border: const OutlineInputBorder(),
            ),
            onChanged: _handleUSBScannerInput,
            onSubmitted: _processUSBBarcode,
            // Enable rapid barcode input
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z\-]')),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Recent Scans
          if (_lastUSBScan.isNotEmpty) ...[
            Text(
              'آخر مسح:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.history),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _lastUSBScan,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _processUSBBarcode(_lastUSBScan),
                    icon: const Icon(Icons.replay),
                    tooltip: 'إعادة المعالجة',
                  ),
                ],
              ),
            ),
          ],
          
          // USB Scanner Status
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isUSBScannerActive 
                ? Colors.green.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isUSBScannerActive ? Colors.green : Colors.grey,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isUSBScannerActive ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: _isUSBScannerActive ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  _isUSBScannerActive ? 'الماسح نشط - جاهز للمسح' : 'اضغط لتنشيط الماسح',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _isUSBScannerActive ? Colors.green[700] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraScannerTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Camera Scanner
          Expanded(
            child: BarcodeScannerWidget(
              onBarcodeDetected: (result) {
                widget.onBarcodeScanned?.call(result);
                _showBarcodeResultDialog(result);
              },
              onError: (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطأ في المسح: $error'),
                    backgroundColor: Colors.red[700],
                  ),
                );
              },
            ),
          ),
          
          // Camera Instructions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.camera_alt),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'وجه الكاميرا نحو الباركود. يدعم النظام جميع أنواع الباركود الشائعة.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarcodeGeneratorTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إنشاء باركود للمنتجات:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Sample product selection
            if (widget.products != null && widget.products!.isNotEmpty) ...[
              DropdownButtonFormField<ClothingProduct>(
                decoration: const InputDecoration(
                  labelText: 'اختر منتج',
                  border: OutlineInputBorder(),
                ),
                items: widget.products!.map((product) {
                  return DropdownMenuItem(
                    value: product,
                    child: Text(product.name),
                  );
                }).toList(),
                onChanged: (product) {
                  if (product != null && product.variants.isNotEmpty) {
                    final firstVariant = product.variants.values.first;
                    setState(() {
                      // Update generator with selected product
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
            
            // Barcode Generator
            BarcodeGeneratorWidget(
              variant: widget.products?.isNotEmpty == true 
                ? widget.products!.first.variants.values.firstOrNull
                : null,
              product: widget.products?.isNotEmpty == true 
                ? widget.products!.first
                : null,
            ),
          ],
        ),
      ),
    );
  }

  void _handleUSBScannerInput(String value) {
    // Detect when a complete barcode is scanned (usually ends with Enter)
    if (value.length >= 8 && value.endsWith('\n')) {
      final barcode = value.trim();
      _processUSBBarcode(barcode);
    }
  }

  void _processUSBBarcode(String barcode) {
    if (barcode.isEmpty) return;
    
    setState(() {
      _lastUSBScan = barcode;
    });
    
    final result = BarcodeService.instance.lookupProductByBarcode(barcode);
    widget.onBarcodeScanned?.call(result);
    _showBarcodeResultDialog(result);
    
    // Clear input for next scan
    _usbScannerController.clear();
    _usbScannerFocus.requestFocus();
  }

  void _clearUSBInput() {
    _usbScannerController.clear();
    _usbScannerFocus.requestFocus();
  }

  void _toggleUSBScanner() {
    setState(() {
      _isUSBScannerActive = !_isUSBScannerActive;
    });
    
    if (_isUSBScannerActive) {
      _usbScannerFocus.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تنشيط الماسح - امسح الباركود الآن'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showBarcodeResultDialog(BarcodeResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              result.hasProduct ? Icons.check_circle : Icons.error_outline,
              color: result.hasProduct ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(result.hasProduct ? 'تم العثور على المنتج' : 'منتج غير موجود'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الباركود: ${result.code}'),
            Text('النوع: ${result.format.displayName}'),
            const SizedBox(height: 8),
            
            if (result.hasProduct) ...[
              Text('المنتج: ${result.product!.name}'),
              Text('الماركة: ${result.product!.brand}'),
              if (result.hasVariant) ...[
                Text('المقاس: ${result.variant!.size}'),
                Text('اللون: ${result.variant!.color}'),
                Text('المخزون: ${result.variant!.stockQuantity}'),
                Text('السعر: ${result.product!.getVariantPrice(result.variant!.id).toStringAsFixed(2)} ر.س'),
              ],
            ] else ...[
              const Text('هذا الباركود غير مسجل في النظام'),
              const SizedBox(height: 8),
              const Text('يمكنك إضافة منتج جديد بهذا الباركود'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
          if (result.hasProduct && result.hasVariant)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                // Add to cart or perform action
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('أضف للسلة'),
            )
          else
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                // Show add product dialog
              },
              icon: const Icon(Icons.add),
              label: const Text('إضافة منتج'),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _usbScannerController.dispose();
    _usbScannerFocus.dispose();
    super.dispose();
  }
}

class BarcodeQuickActions extends StatelessWidget {
  final Function()? onScanBarcode;
  final Function()? onGenerateBarcode;
  final Function()? onManageProducts;

  const BarcodeQuickActions({
    Key? key,
    this.onScanBarcode,
    this.onGenerateBarcode,
    this.onManageProducts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionCard(
              context,
              icon: Icons.qr_code_scanner,
              title: 'مسح الباركود',
              subtitle: 'امسح باركود المنتج',
              color: Colors.blue,
              onTap: onScanBarcode,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionCard(
              context,
              icon: Icons.qr_code,
              title: 'إنشاء باركود',
              subtitle: 'أنشئ باركود للمنتجات',
              color: Colors.green,
              onTap: onGenerateBarcode,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionCard(
              context,
              icon: Icons.inventory,
              title: 'إدارة المنتجات',
              subtitle: 'تحديث باركود المنتجات',
              color: Colors.orange,
              onTap: onManageProducts,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
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
}

// Desktop-specific barcode utilities
class DesktopBarcodeUtils {
  /// Simulate USB barcode scanner input
  static Stream<String> simulateUSBScanner() async* {
    // This would integrate with actual USB scanner drivers
    // For now, simulate periodic scans
    while (true) {
      await Future.delayed(const Duration(seconds: 5));
      yield '1234567890123'; // Sample barcode
    }
  }

  /// Check if USB scanner is connected
  static Future<bool> isUSBScannerConnected() async {
    // This would check for actual USB scanner devices
    // For now, return true for simulation
    return true;
  }

  /// Get list of connected USB scanners
  static Future<List<String>> getConnectedScanners() async {
    // This would enumerate USB HID devices
    return ['USB Scanner 1', 'USB Scanner 2'];
  }

  /// Configure USB scanner settings
  static Future<void> configureUSBScanner({
    bool enableSound = true,
    bool enableVibration = false,
    int scanDelay = 100,
  }) async {
    // This would configure actual USB scanner settings
  }
}
