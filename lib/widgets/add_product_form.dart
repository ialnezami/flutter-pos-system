import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/enhanced_product.dart';
import '../services/enhanced_database_service.dart';

class AddProductForm extends StatefulWidget {
  final Function(EnhancedProduct) onProductAdded;
  final EnhancedProduct? editProduct;

  const AddProductForm({
    super.key,
    required this.onProductAdded,
    this.editProduct,
  });

  @override
  State<AddProductForm> createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ProductFormData _formData = ProductFormData();
  final TextEditingController _tagsController = TextEditingController();
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // If editing, populate form
    if (widget.editProduct != null) {
      final product = widget.editProduct!;
      _formData.name = product.name;
      _formData.category = product.category;
      _formData.tags = List.from(product.tags);
      _formData.buyPrice = product.buyPrice;
      _formData.sellPrice = product.sellPrice;
      _formData.size = product.size;
      _formData.color = product.color;
      _formData.material = product.material;
      _formData.stockQuantity = product.stockQuantity;
      _formData.minStockLevel = product.minStockLevel;
      _formData.barcode = product.barcode ?? '';
      _formData.description = product.description ?? '';
      _tagsController.text = product.tags.join(', ');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _updateTags(String tagsText) {
    _formData.tags = tagsText.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate() || !_formData.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_formData.validationError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final product = _formData.toProduct();
      final dbService = EnhancedDatabaseService();
      
      if (widget.editProduct != null) {
        // Update existing product
        await dbService.updateProduct(widget.editProduct!.id!, product.toMap());
      } else {
        // Insert new product
        await dbService.insertProduct(product.toMap());
      }
      
      widget.onProductAdded(product);
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.editProduct != null ? 'تم تحديث المنتج بنجاح' : 'تم إضافة المنتج بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في حفظ المنتج: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.editProduct != null ? 'تعديل المنتج' : 'إضافة منتج جديد'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          actions: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              TextButton.icon(
                onPressed: _saveProduct,
                icon: const Icon(Icons.save),
                label: const Text('حفظ'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.green[700],
                ),
              ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.info), text: 'المعلومات الأساسية'),
              Tab(icon: Icon(Icons.attach_money), text: 'الأسعار'),
              Tab(icon: Icon(Icons.palette), text: 'الخصائص'),
              Tab(icon: Icon(Icons.inventory), text: 'المخزون'),
            ],
          ),
        ),
        body: Form(
          key: _formKey,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBasicInfoTab(),
              _buildPricingTab(),
              _buildAttributesTab(),
              _buildInventoryTab(),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveProduct,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(widget.editProduct != null ? 'تحديث' : 'إضافة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name
          TextFormField(
            initialValue: _formData.name,
            decoration: const InputDecoration(
              labelText: 'اسم المنتج *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.inventory),
            ),
            validator: (value) => value?.isEmpty == true ? 'اسم المنتج مطلوب' : null,
            onChanged: (value) => _formData.name = value,
          ),
          const SizedBox(height: 16),

          // Category Dropdown
          DropdownButtonFormField<String>(
            value: _formData.category.isEmpty ? null : _formData.category,
            decoration: const InputDecoration(
              labelText: 'الفئة *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category),
            ),
            items: ProductCategory.values.map((category) {
              return DropdownMenuItem(
                value: category.arabicName,
                child: Text(category.arabicName),
              );
            }).toList(),
            validator: (value) => value?.isEmpty == true ? 'فئة المنتج مطلوبة' : null,
            onChanged: (value) => setState(() => _formData.category = value ?? ''),
          ),
          const SizedBox(height: 16),

          // Tags
          TextFormField(
            controller: _tagsController,
            decoration: const InputDecoration(
              labelText: 'العلامات (مفصولة بفاصلة)',
              hintText: 'مثال: صيفي, كاجوال, قطن',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.label),
            ),
            onChanged: _updateTags,
          ),
          const SizedBox(height: 8),
          if (_formData.tags.isNotEmpty)
            Wrap(
              spacing: 8,
              children: _formData.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  onDeleted: () {
                    setState(() {
                      _formData.tags.remove(tag);
                      _tagsController.text = _formData.tags.join(', ');
                    });
                  },
                );
              }).toList(),
            ),
          const SizedBox(height: 16),

          // Description
          TextFormField(
            initialValue: _formData.description,
            decoration: const InputDecoration(
              labelText: 'الوصف',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
            onChanged: (value) => _formData.description = value,
          ),
          const SizedBox(height: 16),

          // Barcode
          TextFormField(
            initialValue: _formData.barcode,
            decoration: InputDecoration(
              labelText: 'الباركود',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.qr_code),
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: () {
                  // Generate random barcode for demo
                  final randomBarcode = DateTime.now().millisecondsSinceEpoch.toString();
                  setState(() => _formData.barcode = randomBarcode);
                },
              ),
            ),
            onChanged: (value) => _formData.barcode = value,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Buy Price
          TextFormField(
            initialValue: _formData.buyPrice > 0 ? _formData.buyPrice.toString() : '',
            decoration: const InputDecoration(
              labelText: 'سعر الشراء (ر.س) *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.shopping_cart),
              suffixText: 'ر.س',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
            validator: (value) {
              final price = double.tryParse(value ?? '');
              if (price == null || price <= 0) return 'سعر الشراء مطلوب ويجب أن يكون أكبر من صفر';
              return null;
            },
            onChanged: (value) {
              _formData.buyPrice = double.tryParse(value) ?? 0;
              setState(() {}); // Refresh to update profit calculation
            },
          ),
          const SizedBox(height: 16),

          // Sell Price
          TextFormField(
            initialValue: _formData.sellPrice > 0 ? _formData.sellPrice.toString() : '',
            decoration: const InputDecoration(
              labelText: 'سعر البيع (ر.س) *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.sell),
              suffixText: 'ر.س',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
            validator: (value) {
              final price = double.tryParse(value ?? '');
              if (price == null || price <= 0) return 'سعر البيع مطلوب ويجب أن يكون أكبر من صفر';
              if (price <= _formData.buyPrice) return 'سعر البيع يجب أن يكون أكبر من سعر الشراء';
              return null;
            },
            onChanged: (value) {
              _formData.sellPrice = double.tryParse(value) ?? 0;
              setState(() {}); // Refresh to update profit calculation
            },
          ),
          const SizedBox(height: 24),

          // Profit Analysis
          if (_formData.buyPrice > 0 && _formData.sellPrice > 0)
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تحليل الربحية',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('الربح لكل قطعة:'),
                        Text(
                          '${(_formData.sellPrice - _formData.buyPrice).toStringAsFixed(2)} ر.س',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('هامش الربح:'),
                        Text(
                          '${((_formData.sellPrice - _formData.buyPrice) / _formData.sellPrice * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: (_formData.sellPrice - _formData.buyPrice) / _formData.sellPrice > 0.3 
                                ? Colors.green 
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Quick Pricing Buttons
          const Text('تسعير سريع:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildQuickPricingButton('هامش 50%', 1.5),
              _buildQuickPricingButton('هامش 100%', 2.0),
              _buildQuickPricingButton('هامش 150%', 2.5),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPricingButton(String label, double multiplier) {
    return ElevatedButton(
      onPressed: _formData.buyPrice > 0 ? () {
        setState(() {
          _formData.sellPrice = _formData.buyPrice * multiplier;
        });
      } : null,
      child: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[50],
        foregroundColor: Colors.blue[700],
      ),
    );
  }

  Widget _buildAttributesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Size Selection
          const Text('المقاس *', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _formData.size.isEmpty ? null : _formData.size,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.straighten),
            ),
            items: ProductSize.values.map((size) {
              return DropdownMenuItem(
                value: size.arabicName,
                child: Text(size.arabicName),
              );
            }).toList(),
            validator: (value) => value?.isEmpty == true ? 'المقاس مطلوب' : null,
            onChanged: (value) => setState(() => _formData.size = value ?? ''),
          ),
          const SizedBox(height: 16),

          // Color Selection
          const Text('اللون *', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _formData.color.isEmpty ? null : _formData.color,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.palette),
            ),
            items: ProductColor.values.map((color) {
              return DropdownMenuItem(
                value: color.arabicName,
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _getColorFromName(color.name),
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(color.arabicName),
                  ],
                ),
              );
            }).toList(),
            validator: (value) => value?.isEmpty == true ? 'اللون مطلوب' : null,
            onChanged: (value) => setState(() => _formData.color = value ?? ''),
          ),
          const SizedBox(height: 16),

          // Material Selection
          const Text('المادة *', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _formData.material.isEmpty ? null : _formData.material,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.texture),
            ),
            items: ProductMaterial.values.map((material) {
              return DropdownMenuItem(
                value: material.arabicName,
                child: Text(material.arabicName),
              );
            }).toList(),
            validator: (value) => value?.isEmpty == true ? 'المادة مطلوبة' : null,
            onChanged: (value) => setState(() => _formData.material = value ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stock Quantity
          TextFormField(
            initialValue: _formData.stockQuantity.toString(),
            decoration: const InputDecoration(
              labelText: 'الكمية المتوفرة',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.inventory_2),
              suffixText: 'قطعة',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) => _formData.stockQuantity = int.tryParse(value) ?? 0,
          ),
          const SizedBox(height: 16),

          // Minimum Stock Level
          TextFormField(
            initialValue: _formData.minStockLevel.toString(),
            decoration: const InputDecoration(
              labelText: 'الحد الأدنى للمخزون',
              hintText: 'تنبيه عند انخفاض المخزون لهذا الحد',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.warning),
              suffixText: 'قطعة',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) => _formData.minStockLevel = int.tryParse(value) ?? 5,
          ),
          const SizedBox(height: 24),

          // Stock Value Analysis
          if (_formData.stockQuantity > 0 && _formData.buyPrice > 0 && _formData.sellPrice > 0)
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تحليل قيمة المخزون',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('قيمة الشراء الإجمالية:'),
                        Text(
                          '${(_formData.stockQuantity * _formData.buyPrice).toStringAsFixed(2)} ر.س',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('قيمة البيع المتوقعة:'),
                        Text(
                          '${(_formData.stockQuantity * _formData.sellPrice).toStringAsFixed(2)} ر.س',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('الربح المتوقع:'),
                        Text(
                          '${(_formData.stockQuantity * (_formData.sellPrice - _formData.buyPrice)).toStringAsFixed(2)} ر.س',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
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
    );
  }

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'white': return Colors.white;
      case 'black': return Colors.black;
      case 'red': return Colors.red;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'yellow': return Colors.yellow;
      case 'pink': return Colors.pink;
      case 'purple': return Colors.purple;
      case 'orange': return Colors.orange;
      case 'brown': return Colors.brown;
      case 'gray': return Colors.grey;
      case 'beige': return Colors.brown[100]!;
      case 'navy': return Colors.indigo;
      case 'gold': return Colors.amber;
      case 'silver': return Colors.grey[300]!;
      default: return Colors.grey;
    }
  }
}

// Extension to add updateProduct method to EnhancedDatabaseService
extension DatabaseUpdate on EnhancedDatabaseService {
  Future<void> updateProduct(int id, Map<String, dynamic> product) async {
    final db = await database;
    product['updated_date'] = DateTime.now().toIso8601String();
    await db.update('products', product, where: 'id = ?', whereArgs: [id]);
  }
}
