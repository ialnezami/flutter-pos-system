import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:possystem/models/clothing/product_variant.dart';
import 'package:possystem/models/clothing/clothing_product.dart';
import 'package:possystem/services/barcode_service.dart';

enum BarcodeType {
  ean13('EAN-13'),
  ean8('EAN-8'),
  upcA('UPC-A'),
  code128('Code 128'),
  code39('Code 39'),
  qrCode('QR Code');

  const BarcodeType(this.displayName);
  final String displayName;
}

class BarcodeGeneratorWidget extends StatefulWidget {
  final ProductVariant? variant;
  final ClothingProduct? product;
  final String? customData;
  final BarcodeType defaultType;

  const BarcodeGeneratorWidget({
    Key? key,
    this.variant,
    this.product,
    this.customData,
    this.defaultType = BarcodeType.ean13,
  }) : super(key: key);

  @override
  State<BarcodeGeneratorWidget> createState() => _BarcodeGeneratorWidgetState();
}

class _BarcodeGeneratorWidgetState extends State<BarcodeGeneratorWidget> {
  late BarcodeType _selectedType;
  late String _barcodeData;
  late TextEditingController _dataController;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.defaultType;
    _barcodeData = _generateInitialData();
    _dataController = TextEditingController(text: _barcodeData);
  }

  String _generateInitialData() {
    if (widget.customData != null) {
      return widget.customData!;
    }
    
    if (widget.variant != null && widget.variant!.barcode != null) {
      return widget.variant!.barcode!;
    }
    
    if (widget.variant != null) {
      return BarcodeService.instance.generateBarcodeForVariant(widget.variant!);
    }
    
    // Generate a sample barcode
    return '1234567890123';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barcode Type Selection
        _buildTypeSelector(),
        
        const SizedBox(height: 16),
        
        // Barcode Data Input
        _buildDataInput(),
        
        const SizedBox(height: 16),
        
        // Barcode Display
        _buildBarcodeDisplay(),
        
        const SizedBox(height: 16),
        
        // Product Information
        if (widget.variant != null || widget.product != null)
          _buildProductInfo(),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع الباركود:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: BarcodeType.values.map((type) {
            final isSelected = _selectedType == type;
            return FilterChip(
              label: Text(type.displayName),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedType = type;
                    // Regenerate barcode data for new type if needed
                    if (widget.variant != null && widget.variant!.barcode == null) {
                      _barcodeData = _generateBarcodeForType(type);
                      _dataController.text = _barcodeData;
                    }
                  });
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDataInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'بيانات الباركود:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _dataController,
                decoration: const InputDecoration(
                  hintText: 'أدخل بيانات الباركود',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _barcodeData = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _generateNewBarcode,
              icon: const Icon(Icons.refresh),
              tooltip: 'إنشاء باركود جديد',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBarcodeDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Barcode Widget
          Container(
            height: 100,
            child: _buildBarcodeWidget(),
          ),
          
          const SizedBox(height: 8),
          
          // Barcode Text
          Text(
            _barcodeData,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: _copyToClipboard,
                icon: const Icon(Icons.copy),
                label: const Text('نسخ'),
              ),
              TextButton.icon(
                onPressed: _saveBarcode,
                icon: const Icon(Icons.save),
                label: const Text('حفظ'),
              ),
              TextButton.icon(
                onPressed: _printBarcode,
                icon: const Icon(Icons.print),
                label: const Text('طباعة'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarcodeWidget() {
    try {
      if (_selectedType == BarcodeType.qrCode) {
        return QrImageView(
          data: _barcodeData,
          version: QrVersions.auto,
          size: 100,
          backgroundColor: Colors.white,
        );
      } else {
        return BarcodeWidget(
          barcode: _getBarcodeLibraryType(_selectedType),
          data: _barcodeData,
          width: double.infinity,
          height: 100,
          style: const TextStyle(fontSize: 0), // Hide text below barcode
          errorBuilder: (context, error) => Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red[700],
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'باركود غير صحيح',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      return Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[700],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'خطأ في إنشاء الباركود',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildProductInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات المنتج:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          
          if (widget.product != null) ...[
            _buildInfoRow('المنتج:', widget.product!.name),
            _buildInfoRow('الماركة:', widget.product!.brand),
            _buildInfoRow('الفئة:', widget.product!.category.displayName),
          ],
          
          if (widget.variant != null) ...[
            _buildInfoRow('المقاس:', widget.variant!.size),
            _buildInfoRow('اللون:', widget.variant!.color),
            _buildInfoRow('رمز المنتج:', widget.variant!.sku),
            _buildInfoRow('المخزون:', '${widget.variant!.stockQuantity}'),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Barcode _getBarcodeLibraryType(BarcodeType type) {
    switch (type) {
      case BarcodeType.ean13:
        return Barcode.ean13();
      case BarcodeType.ean8:
        return Barcode.ean8();
      case BarcodeType.upcA:
        return Barcode.upcA();
      case BarcodeType.code128:
        return Barcode.code128();
      case BarcodeType.code39:
        return Barcode.code39();
      case BarcodeType.qrCode:
        return Barcode.qrCode();
    }
  }

  String _generateBarcodeForType(BarcodeType type) {
    switch (type) {
      case BarcodeType.ean13:
        return BarcodeService.instance.generateBarcodeForVariant(widget.variant!);
      case BarcodeType.ean8:
        return DateTime.now().millisecondsSinceEpoch.toString().substring(5, 13);
      case BarcodeType.upcA:
        return DateTime.now().millisecondsSinceEpoch.toString().substring(1, 13);
      case BarcodeType.code128:
      case BarcodeType.code39:
        return 'CLO${widget.variant!.sku}';
      case BarcodeType.qrCode:
        return '{"productId":"${widget.variant!.productId}","variantId":"${widget.variant!.id}","sku":"${widget.variant!.sku}"}';
    }
  }

  void _generateNewBarcode() {
    setState(() {
      _barcodeData = _generateBarcodeForType(_selectedType);
      _dataController.text = _barcodeData;
    });
  }

  void _copyToClipboard() {
    // Copy barcode to clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الباركود'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _saveBarcode() {
    // Save barcode to variant
    if (widget.variant != null) {
      // Update variant with new barcode
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ الباركود'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _printBarcode() {
    // Print barcode label
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري طباعة الباركود...'),
      ),
    );
  }

  @override
  void dispose() {
    _dataController.dispose();
    super.dispose();
  }
}
