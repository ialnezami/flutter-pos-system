import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/enhanced_product.dart';
import '../services/enhanced_database_service.dart';
import 'product_photo_gallery.dart';

class EnhancedProductForm extends StatefulWidget {
  final EnhancedProduct? product;
  final Function(EnhancedProduct) onProductSaved;

  const EnhancedProductForm({
    super.key,
    this.product,
    required this.onProductSaved,
  });

  @override
  State<EnhancedProductForm> createState() => _EnhancedProductFormState();
}

class _EnhancedProductFormState extends State<EnhancedProductForm>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  late ProductFormData _formData;
  final _dbService = EnhancedDatabaseService();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _stockQuantityController = TextEditingController();
  final _minStockLevelController = TextEditingController();
  final _tagController = TextEditingController();

  List<String> _availableCategories = [];
  List<String> _availableTags = [];
  double _profitAmount = 0.0;
  double _profitMargin = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _formData = ProductFormData();
    _loadAvailableOptions();
    
    if (widget.product != null) {
      _populateFormWithProduct(widget.product!);
    }

    _buyPriceController.addListener(_calculateProfit);
    _sellPriceController.addListener(_calculateProfit);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _barcodeController.dispose();
    _buyPriceController.dispose();
    _sellPriceController.dispose();
    _stockQuantityController.dispose();
    _minStockLevelController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _populateFormWithProduct(EnhancedProduct product) {
    _nameController.text = product.name;
    _descriptionController.text = product.description ?? '';
    _barcodeController.text = product.barcode ?? '';
    _buyPriceController.text = product.buyPrice.toStringAsFixed(2);
    _sellPriceController.text = product.sellPrice.toStringAsFixed(2);
    _stockQuantityController.text = product.stockQuantity.toString();
    _minStockLevelController.text = product.minStockLevel.toString();

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
    _formData.imagePaths = List.from(product.imagePaths);

    _calculateProfit();
  }

  Future<void> _loadAvailableOptions() async {
    try {
      final categories = await _dbService.getAllCategories();
      final tags = await _dbService.getAllTags();
      
      setState(() {
        _availableCategories = categories;
        _availableTags = tags;
        
        // Set default category if none selected
        if (_formData.category.isEmpty && categories.isNotEmpty) {
          _formData.category = categories.first;
        }
      });
    } catch (e) {
      print('Error loading options: $e');
    }
  }

  void _calculateProfit() {
    final buy = double.tryParse(_buyPriceController.text) ?? 0.0;
    final sell = double.tryParse(_sellPriceController.text) ?? 0.0;
    setState(() {
      _profitAmount = sell - buy;
      _profitMargin = buy > 0 ? (_profitAmount / buy) * 100 : 0.0;
    });
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_formData.tags.contains(tag)) {
      setState(() {
        _formData.tags.add(tag);
      });
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _formData.tags.remove(tag);
    });
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إكمال جميع الحقول المطلوبة'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Update form data from controllers
    _formData.name = _nameController.text;
    _formData.description = _descriptionController.text;
    _formData.barcode = _barcodeController.text;
    _formData.buyPrice = double.parse(_buyPriceController.text);
    _formData.sellPrice = double.parse(_sellPriceController.text);
    _formData.stockQuantity = int.parse(_stockQuantityController.text);
    _formData.minStockLevel = int.parse(_minStockLevelController.text);

    if (!_formData.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_formData.validationError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final product = _formData.toProduct();
      
      if (widget.product == null) {
        // Adding new product
        await _dbService.insertProduct(product.toMap());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إضافة المنتج بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Updating existing product
        final updatedProduct = product.copyWith(id: widget.product!.id);
        await _dbService.updateProductImages(widget.product!.id!, _formData.imagePaths);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث المنتج بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onProductSaved(updatedProduct);
      }
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في حفظ المنتج: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.product == null ? 'إضافة منتج جديد' : 'تعديل المنتج'),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'معلومات أساسية', icon: Icon(Icons.info_outline)),
              Tab(text: 'التسعير', icon: Icon(Icons.attach_money)),
              Tab(text: 'السمات', icon: Icon(Icons.color_lens_outlined)),
              Tab(text: 'المخزون', icon: Icon(Icons.inventory_2_outlined)),
              Tab(text: 'الصور', icon: Icon(Icons.photo_library_outlined)),
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
              _buildPhotosTab(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _saveProduct,
          label: Text(widget.product == null ? 'حفظ المنتج' : 'تحديث المنتج'),
          icon: const Icon(Icons.save),
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'اسم المنتج *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.shopping_bag_outlined),
            ),
            validator: (value) => value?.isEmpty ?? true ? 'الرجاء إدخال اسم المنتج' : null,
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _formData.category.isEmpty ? null : _formData.category,
            decoration: const InputDecoration(
              labelText: 'الفئة *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: _availableCategories.map((category) {
              return DropdownMenuItem(value: category, child: Text(category));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _formData.category = value ?? '';
              });
            },
            validator: (value) => value?.isEmpty ?? true ? 'الرجاء اختيار الفئة' : null,
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _tagController,
                  decoration: const InputDecoration(
                    labelText: 'إضافة علامة',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.tag),
                  ),
                  onFieldSubmitted: _addTag,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _addTag(_tagController.text),
                child: const Text('إضافة'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          if (_formData.tags.isNotEmpty)
            Wrap(
              spacing: 8.0,
              children: _formData.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  onDeleted: () => _removeTag(tag),
                );
              }).toList(),
            ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'الوصف',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description_outlined),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _barcodeController,
            decoration: const InputDecoration(
              labelText: 'الباركود',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.qr_code_scanner),
            ),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextFormField(
            controller: _buyPriceController,
            decoration: const InputDecoration(
              labelText: 'سعر الشراء (ر.س) *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.money_off),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
            validator: (value) => value?.isEmpty ?? true || double.tryParse(value!) == null 
                ? 'الرجاء إدخال سعر شراء صحيح' : null,
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _sellPriceController,
            decoration: const InputDecoration(
              labelText: 'سعر البيع (ر.س) *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
            validator: (value) => value?.isEmpty ?? true || double.tryParse(value!) == null 
                ? 'الرجاء إدخال سعر بيع صحيح' : null,
          ),
          const SizedBox(height: 16),
          
          Card(
            color: Colors.blueGrey[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('تحليل الربح:', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('مقدار الربح:'),
                      Text(
                        '${_profitAmount.toStringAsFixed(2)} ر.س',
                        style: TextStyle(
                          color: _profitAmount > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('هامش الربح:'),
                      Text(
                        '${_profitMargin.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: _profitAmount > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          const Text('مبالغ سريعة (هامش الربح):', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [25, 50, 75, 100, 150].map((percentage) {
              return ElevatedButton(
                onPressed: () {
                  final buy = double.tryParse(_buyPriceController.text) ?? 0.0;
                  if (buy > 0) {
                    _sellPriceController.text = (buy * (1 + percentage / 100)).toStringAsFixed(2);
                    _calculateProfit();
                  }
                },
                child: Text('+$percentage%'),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _formData.size.isEmpty ? null : _formData.size,
            decoration: const InputDecoration(
              labelText: 'المقاس *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.straighten),
            ),
            items: ProductSize.values.map((size) {
              return DropdownMenuItem(value: size.arabicName, child: Text(size.arabicName));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _formData.size = value ?? '';
              });
            },
            validator: (value) => value?.isEmpty ?? true ? 'الرجاء اختيار المقاس' : null,
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _formData.color.isEmpty ? null : _formData.color,
            decoration: const InputDecoration(
              labelText: 'اللون *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.color_lens_outlined),
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
                        color: _getColorFromName(color.arabicName),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(color.arabicName),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _formData.color = value ?? '';
              });
            },
            validator: (value) => value?.isEmpty ?? true ? 'الرجاء اختيار اللون' : null,
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _formData.material.isEmpty ? null : _formData.material,
            decoration: const InputDecoration(
              labelText: 'المادة *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.texture),
            ),
            items: ProductMaterial.values.map((material) {
              return DropdownMenuItem(value: material.arabicName, child: Text(material.arabicName));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _formData.material = value ?? '';
              });
            },
            validator: (value) => value?.isEmpty ?? true ? 'الرجاء اختيار المادة' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextFormField(
            controller: _stockQuantityController,
            decoration: const InputDecoration(
              labelText: 'الكمية المتوفرة *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.warehouse_outlined),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) => value?.isEmpty ?? true || int.tryParse(value!) == null 
                ? 'الرجاء إدخال كمية صحيحة' : null,
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _minStockLevelController,
            decoration: const InputDecoration(
              labelText: 'الحد الأدنى للمخزون *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.low_priority),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) => value?.isEmpty ?? true || int.tryParse(value!) == null 
                ? 'الرجاء إدخال حد أدنى صحيح' : null,
          ),
          const SizedBox(height: 16),
          
          Card(
            color: Colors.orange[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('تحليل المخزون:', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('قيمة المخزون (سعر البيع):'),
                      Text('${((double.tryParse(_sellPriceController.text) ?? 0.0) * (int.tryParse(_stockQuantityController.text) ?? 0)).toStringAsFixed(2)} ر.س'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('إجمالي الاستثمار (سعر الشراء):'),
                      Text('${((double.tryParse(_buyPriceController.text) ?? 0.0) * (int.tryParse(_stockQuantityController.text) ?? 0)).toStringAsFixed(2)} ر.س'),
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

  Widget _buildPhotosTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ProductPhotoGallery(
        initialImages: _formData.imagePaths,
        onImagesChanged: (images) {
          setState(() {
            _formData.imagePaths = images;
          });
        },
        isEditing: widget.product != null,
      ),
    );
  }

  Color _getColorFromName(String colorName) {
    switch (colorName) {
      case 'أبيض': return Colors.white;
      case 'أسود': return Colors.black;
      case 'أحمر': return Colors.red;
      case 'أزرق': return Colors.blue;
      case 'أخضر': return Colors.green;
      case 'أصفر': return Colors.yellow;
      case 'وردي': return Colors.pink;
      case 'بنفسجي': return Colors.purple;
      case 'برتقالي': return Colors.orange;
      case 'بني': return Colors.brown;
      case 'رمادي': return Colors.grey;
      case 'بيج': return Colors.amber.shade200;
      case 'كحلي': return Colors.indigo;
      case 'ذهبي': return Colors.amber;
      case 'فضي': return Colors.blueGrey;
      default: return Colors.grey;
    }
  }
}
