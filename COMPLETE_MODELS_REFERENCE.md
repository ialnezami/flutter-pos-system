# POS System - Complete Models Reference
## Comprehensive Data Model Documentation

**Generated:** October 7, 2025  
**Last Updated:** October 7, 2025

---

## 📋 Table of Contents

1. [Model Architecture Overview](#model-architecture-overview)
2. [Menu System Models](#menu-system-models)
3. [Stock/Inventory Models](#stockinventory-models)
4. [Order System Models](#order-system-models)
5. [Cashier Models](#cashier-models)
6. [Analysis Models](#analysis-models)
7. [Printer Models](#printer-models)
8. [Clothing Store Extension Models](#clothing-store-extension-models)
9. [Data Transfer Objects (DTOs)](#data-transfer-objects-dtos)
10. [Repository Pattern](#repository-pattern)
11. [Model Relationships](#model-relationships)

---

## 🏗️ Model Architecture Overview

### **Base Model Classes**

#### **Model (Abstract Base)**
**File:** `lib/models/model.dart`

```dart
abstract class Model<T extends ModelObject> extends ChangeNotifier {
  // Core Properties
  String id;                      // Unique identifier
  String name;                    // Display name
  ModelStatus status;             // normal, staged, updated, archived
  
  // Mixins Available
  // - ModelStorage: Persistence capabilities
  // - ModelOrderable: Sorting and ordering
  // - ModelSearchable: Search functionality
  // - ModelImage: Image handling
  
  // Abstract Methods
  T toObject();                   // Convert to DTO
  String get prefix;              // Storage key prefix
  Repository get repository;      // Parent repository
  
  // Common Methods
  Future<void> save();
  Future<void> remove();
  Future<void> update(T object);
  int getSimilarity(String pattern);
}

enum ModelStatus {
  normal,     // Saved and unchanged
  staged,     // New, not yet saved
  updated,    // Modified, needs save
  archived,   // Soft deleted
}
```

---

## 🍔 Menu System Models

### **1. Catalog Model**
**File:** `lib/models/menu/catalog.dart`

```dart
class Catalog extends Model<CatalogObject>
    with ModelStorage, ModelOrderable, ModelImage,
         Repository<Product>, RepositoryStorage<Product> {
  
  // Properties
  final DateTime createdAt;       // Creation timestamp
  int index;                      // Display order
  String? imagePath;              // Catalog image
  Map<String, Product> items;     // Child products
  
  // Constructor
  Catalog({
    String? id,
    ModelStatus status = ModelStatus.normal,
    String name = 'catalog',
    int index = 0,
    String? imagePath,
    DateTime? createdAt,
    Map<String, Product>? products,
  });
  
  // Factory Constructors
  factory Catalog.fromObject(CatalogObject object);
  factory Catalog.fromRow(Catalog? ori, List<String> row, {required int index});
  
  // Computed Properties
  Menu get repository;            // Parent repository
  List<Product> get itemList;     // Sorted products
  int get length;                 // Number of products
  bool get isEmpty;
  bool get isNotEmpty;
  
  // Methods
  Product? getProduct(String id);
  Iterable<MapEntry<Product, double>> getItemsSimilarity(String pattern);
  CatalogObject toObject();
}
```

**Usage Example:**
```dart
final catalog = Catalog(
  name: 'Burgers',
  index: 0,
  imagePath: 'assets/burgers.png',
);

catalog.addItem(Product(name: 'Cheeseburger', price: 8.99));
```

---

### **2. Product Model**
**File:** `lib/models/menu/product.dart`

```dart
class Product extends Model<ProductObject>
    with ModelStorage, ModelOrderable, ModelSearchable, ModelImage,
         Repository<ProductIngredient>, RepositoryStorage<ProductIngredient> {
  
  // Properties
  late final Catalog catalog;                     // Parent catalog
  num cost;                                       // Cost price
  num price;                                      // Selling price
  final DateTime createdAt;                       // Creation time
  DateTime? searchedAt;                           // Last search time
  Map<String, ProductIngredient> items;           // Ingredients
  
  // Constructor
  Product({
    String? id,
    ModelStatus status = ModelStatus.normal,
    String name = 'product',
    int index = 1,
    this.cost = 0,
    this.price = 0,
    String? imagePath,
    DateTime? createdAt,
    this.searchedAt,
    Map<String, ProductIngredient>? ingredients,
  });
  
  // Factory Constructors
  factory Product.fromObject(ProductObject object);
  factory Product.fromRow(Product? ori, List<String> row, {required int index});
  
  // Computed Properties
  num get profit => price - cost;
  Catalog get repository;
  List<ProductIngredient> get itemList;
  bool get isEmpty;
  bool get isNotEmpty;
  
  // Methods
  ProductIngredient? getIngredient(String id);
  bool hasIngredient(String id);
  int getItemsSimilarity(String pattern);
  Future<void> searched();
  ProductObject toObject();
}
```

**Usage Example:**
```dart
final product = Product(
  name: 'Cheeseburger',
  price: 8.99,
  cost: 3.50,
  catalog: burgersCategory,
);

product.addItem(ProductIngredient(
  ingredientId: 'beef-patty',
  amount: 1,
));
```

---

### **3. ProductIngredient Model**
**File:** `lib/models/menu/product_ingredient.dart`

```dart
class ProductIngredient extends Model<ProductIngredientObject>
    with ModelStorage, ModelOrderable,
         Repository<ProductQuantity>, RepositoryStorage<ProductQuantity> {
  
  // Properties
  final String ingredientId;                      // Link to Stock.Ingredient
  num amount;                                     // Base amount used
  Map<String, ProductQuantity> items;             // Quantity options
  
  // Constructor
  ProductIngredient({
    String? id,
    ModelStatus status = ModelStatus.normal,
    required this.ingredientId,
    this.amount = 1,
    Map<String, ProductQuantity>? quantities,
  });
  
  // Factory Constructors
  factory ProductIngredient.fromObject(ProductIngredientObject object);
  
  // Computed Properties
  Ingredient get ingredient;      // Resolved from Stock
  num get cost;                   // Calculated cost
  Product get product;            // Parent product
  
  // Methods
  ProductQuantity? getQuantity(String id);
  num getAmount(String? quantityId);
  ProductIngredientObject toObject();
}
```

---

### **4. ProductQuantity Model**
**File:** `lib/models/menu/product_quantity.dart`

```dart
class ProductQuantity extends Model<ProductQuantityObject> 
    with ModelStorage, ModelOrderable {
  
  // Properties
  final String quantityId;        // Link to Quantities
  num amount;                     // Multiplier
  num additionalPrice;            // Extra price
  num additionalCost;             // Extra cost
  
  // Constructor
  ProductQuantity({
    String? id,
    ModelStatus status = ModelStatus.normal,
    required this.quantityId,
    this.amount = 1,
    this.additionalPrice = 0,
    this.additionalCost = 0,
  });
  
  // Factory Constructor
  factory ProductQuantity.fromObject(ProductQuantityObject object);
  
  // Computed Properties
  Quantity get quantity;          // Resolved from Quantities
  ProductIngredient get ingredient; // Parent ingredient
  
  // Methods
  num getTotalPrice(num basePrice) => basePrice * amount + additionalPrice;
  num getTotalCost(num baseCost) => baseCost * amount + additionalCost;
  ProductQuantityObject toObject();
}
```

---

## 📦 Stock/Inventory Models

### **1. Ingredient Model**
**File:** `lib/models/stock/ingredient.dart`

```dart
class Ingredient extends Model<IngredientObject>
    with ModelStorage, ModelSearchable {
  
  // Properties
  num currentAmount;              // Current stock level
  num? totalAmount;               // Lifetime total
  num? restockPrice;              // Price per restock
  num restockQuantity;            // Quantity per restock
  num? restockLastPrice;          // Last restock price
  num? lastAmount;                // Amount after last restock
  DateTime? updatedAt;            // Last update time
  
  // Constructor
  Ingredient({
    String? id,
    ModelStatus status = ModelStatus.normal,
    String name = 'ingredient',
    this.currentAmount = 0.0,
    this.totalAmount,
    this.restockPrice,
    this.restockQuantity = 1.0,
    this.lastAmount,
    this.updatedAt,
  });
  
  // Factory Constructors
  factory Ingredient.fromObject(IngredientObject object);
  factory Ingredient.fromRow(Ingredient? ori, List<String> row);
  
  // Computed Properties
  double get maxAmount;           // Max of total/last/current
  Stock get repository;
  
  // Methods
  Future<void> setAmount(num amount);
  Map<String, Object?> getUpdateData(num amount, {onlyAmount = false});
  IngredientObject toObject();
}
```

**Key Operations:**
```dart
// Update stock
ingredient.setAmount(50);

// Deduct stock on sale
final updates = ingredient.getUpdateData(-5);

// Restock
ingredient.getUpdateData(100, onlyAmount: false);
```

---

### **2. Quantity Model**
**File:** `lib/models/stock/quantity.dart`

```dart
class Quantity extends Model<QuantityObject>
    with ModelStorage, ModelOrderable, ModelSearchable {
  
  // Properties
  num defaultProportion;          // Default multiplier
  
  // Constructor
  Quantity({
    String? id,
    ModelStatus status = ModelStatus.normal,
    String name = 'quantity',
    this.defaultProportion = 1.0,
  });
  
  // Factory Constructors
  factory Quantity.fromObject(QuantityObject object);
  
  // Computed Properties
  Quantities get repository;
  
  // Methods
  num calculateAmount(num baseAmount) => baseAmount * defaultProportion;
  QuantityObject toObject();
}
```

**Common Quantities:**
- Small (proportion: 0.75)
- Medium (proportion: 1.0)
- Large (proportion: 1.5)
- Extra Large (proportion: 2.0)

---

### **3. Replenishment Model**
**File:** `lib/models/stock/replenishment.dart`

```dart
class Replenishment extends Model<ReplenishmentObject>
    with ModelStorage, ModelOrderable {
  
  // Properties
  Map<String, num> data;          // ingredientId -> quantity
  final DateTime createdAt;       // Creation time
  
  // Constructor
  Replenishment({
    String? id,
    ModelStatus status = ModelStatus.normal,
    String name = 'replenishment',
    Map<String, num>? data,
    DateTime? createdAt,
  });
  
  // Factory Constructor
  factory Replenishment.fromObject(ReplenishmentObject object);
  
  // Computed Properties
  Replenisher get repository;
  List<Ingredient> get ingredients;
  num get totalCost;
  int get itemCount;
  
  // Methods
  void setData(Map<String, num> newData);
  Future<void> apply();           // Apply to inventory
  ReplenishmentObject toObject();
}
```

**Usage:**
```dart
final repl = Replenishment(
  name: 'Weekly Restock',
  data: {
    'beef-patty': 100,
    'cheese-slices': 200,
    'lettuce': 50,
  },
);

await repl.apply();  // Updates inventory
```

---

## 🛒 Order System Models

### **1. Cart Model (Repository)**
**File:** `lib/models/repository/cart.dart`

```dart
class Cart extends ChangeNotifier {
  // Singleton
  static Cart instance = Cart();
  
  // Properties
  final String name;                             // 'cart' or stash name
  final List<CartProduct> products;              // Cart items
  final Map<String, String> attributes;          // attrId -> optionId
  final ValueNotifier<CartProduct?> selectedProduct;
  String note;                                   // Order notes
  int selectedIndex;                             // Selected item index
  
  // Computed Properties
  bool get isEmpty;
  num get productsPrice;                         // Subtotal
  num get productsCost;                          // Total cost
  int get productCount;                          // Total items
  num get price;                                 // Grand total with attributes
  Iterable<CartProduct> get selected;
  Iterable<OrderAttributeOption> get selectedAttributeOptions;
  
  // Methods
  void add(Product product);
  void removeAt(int index);
  void clear();
  void chooseAttribute(String attrId, String optionId);
  void updateNote(String value);
  
  // Selection Methods
  void toggleAll(bool? checked, {CartProduct? except});
  void updateSelection();
  void selectedRemove();
  void selectedUpdateCount(int? count);
  void selectedUpdateDiscount(int? discount);
  void selectedUpdatePrice(num? price);
  
  // Order Methods
  Future<CheckoutStatus> checkout({required num paid, required BuildContext context});
  Future<bool> stash();
  void restore(OrderObject order);
  OrderObject toObject({num paid = 0});
  void rebind();
}

enum CheckoutStatus {
  paidNotEnough,        // Insufficient payment
  cashierNotEnough,     // Not enough change
  cashierUsingSmall,    // Using small denominations
  nothingHappened,      // Cart empty
  stash,                // Stashed order
  restore,              // Restored order
  ok,                   // Success
}
```

**Checkout Flow:**
```dart
// 1. Add products
cart.add(cheeseburger);
cart.add(fries);

// 2. Set attributes
cart.chooseAttribute('size', 'large');
cart.updateNote('No onions');

// 3. Checkout
final status = await cart.checkout(
  paid: 20.00,
  context: context,
);

// 4. Handle result
if (status == CheckoutStatus.ok) {
  // Print receipt, update stock, etc.
}
```

---

### **2. CartProduct Model**
**File:** `lib/models/order/cart_product.dart`

```dart
class CartProduct {
  // Properties
  final Product product;                         // Reference product
  int count;                                     // Quantity ordered
  num singlePrice;                               // Unit price
  num? singleCost;                               // Unit cost
  bool isSelected;                               // Selection state
  Map<String, ProductQuantity> ingredients;      // Selected quantities
  
  // Constructor
  CartProduct(
    this.product, {
    this.count = 1,
    num? singlePrice,
    this.singleCost,
    this.isSelected = false,
  });
  
  // Factory Constructor
  factory CartProduct.fromObject(OrderProductObject object);
  
  // Computed Properties
  String get id => product.id;
  String get productName => product.name;
  num get totalPrice => singlePrice * count;
  num get totalCost => (singleCost ?? product.cost) * count;
  String get ingredientName;                     // Summary of selections
  
  // Methods
  void toggleSelected(bool? value);
  void updateSinglePrice(num price);
  void rebind();                                 // Rebind after menu changes
  OrderProductObject toObject();
}
```

---

### **3. OrderAttribute Model**
**File:** `lib/models/order/order_attribute.dart`

```dart
class OrderAttribute extends Model<OrderAttributeObject>
    with ModelStorage, ModelOrderable,
         Repository<OrderAttributeOption>, RepositoryStorage<OrderAttributeOption> {
  
  // Properties
  String? defaultOption;                         // Default option ID
  OrderAttributeMode mode;                       // How to apply pricing
  Map<String, OrderAttributeOption> items;       // Available options
  
  // Constructor
  OrderAttribute({
    String? id,
    ModelStatus status = ModelStatus.normal,
    String name = 'order_attribute',
    int index = 0,
    this.defaultOption,
    this.mode = OrderAttributeMode.changePrice,
    Map<String, OrderAttributeOption>? options,
  });
  
  // Factory Constructor
  factory OrderAttribute.fromObject(OrderAttributeObject object);
  
  // Computed Properties
  OrderAttributes get repository;
  OrderAttributeOption? get defaultOptionObject;
  List<OrderAttributeOption> get itemList;
  
  // Methods
  OrderAttributeOption? getOption(String id);
  num calculatePrice(num basePrice, String? optionId);
  OrderAttributeObject toObject();
}

enum OrderAttributeMode {
  changePrice,      // Add/subtract fixed amount
  changeDiscount,   // Apply percentage discount
}
```

**Example Attributes:**
```dart
// Size attribute
OrderAttribute(
  name: 'Size',
  mode: OrderAttributeMode.changePrice,
  options: {
    'small': OrderAttributeOption(name: 'Small', modeValue: -1.00),
    'regular': OrderAttributeOption(name: 'Regular', modeValue: 0),
    'large': OrderAttributeOption(name: 'Large', modeValue: 2.00),
  },
);

// Discount attribute
OrderAttribute(
  name: 'Student Discount',
  mode: OrderAttributeMode.changeDiscount,
  options: {
    'yes': OrderAttributeOption(name: 'Apply', modeValue: 10),  // 10% off
    'no': OrderAttributeOption(name: 'No Discount', modeValue: 0),
  },
);
```

---

### **4. OrderAttributeOption Model**
**File:** `lib/models/order/order_attribute_option.dart`

```dart
class OrderAttributeOption extends Model<OrderAttributeOptionObject>
    with ModelStorage, ModelOrderable {
  
  // Properties
  num modeValue;                  // Price change or discount %
  bool isDefault;                 // Default selection
  
  // Constructor
  OrderAttributeOption({
    String? id,
    ModelStatus status = ModelStatus.normal,
    String name = 'option',
    int index = 0,
    this.modeValue = 0,
    this.isDefault = false,
  });
  
  // Factory Constructor
  factory OrderAttributeOption.fromObject(OrderAttributeOptionObject object);
  
  // Computed Properties
  OrderAttribute get attribute;   // Parent attribute
  
  // Methods
  num calculatePrice(num basePrice);
  OrderAttributeOptionObject toObject();
}
```

---

## 💰 Cashier Models

### **Cashier Repository**
**File:** `lib/models/repository/cashier.dart`

```dart
class Cashier extends ChangeNotifier with Repository<CashierChangeBatch> {
  // Singleton
  static Cashier instance = Cashier();
  
  // Properties
  Map<int, num> units;                           // denomination -> count
  Map<int, num> unitHistory;                     // Previous state
  List<CashierChangeBatch> batches;              // Favorite combinations
  
  // Computed Properties
  num get totalPrice;                            // Total cash value
  Map<int, num> get warning;                     // Low denomination warnings
  List<int> get unitList;                        // Sorted denominations
  
  // Methods
  Future<void> reset();                          // Start new day
  Future<CashierUpdateStatus> paid(num paid, num price);
  Map<int, num> calculateChange(num amount);
  Future<void> addUnit(int denomination);
  Future<void> updateUnit(int denomination, num count);
  Future<void> removeUnit(int denomination);
  
  // Batch Methods
  void addBatch(CashierChangeBatch batch);
  void removeBatch(String id);
  Map<int, num> getBatchData(String id);
}

enum CashierUpdateStatus {
  ok,              // Sufficient change
  notEnough,       // Insufficient cash
  usingSmall,      // Using smaller denominations
}
```

**Example Usage:**
```dart
// Initialize cash drawer
cashier.updateUnit(100, 10);  // 10x $100 bills
cashier.updateUnit(50, 20);   // 20x $50 bills
cashier.updateUnit(20, 30);   // 30x $20 bills

// Process payment
final status = await cashier.paid(
  paid: 100,
  price: 75,
);

// Calculate change
final change = cashier.calculateChange(25);  // {20: 1, 5: 1}
```

---

### **CashierChangeBatch Model**

```dart
class CashierChangeBatch extends Model {
  // Properties
  Map<int, num> data;             // denomination -> count
  
  // Constructor
  CashierChangeBatch({
    String? id,
    String name = 'batch',
    required this.data,
  });
  
  // Computed Properties
  num get total;                  // Total value of batch
  
  // Methods
  CashierChangeBatchObject toObject();
}
```

---

## 📊 Analysis Models

### **1. Analysis Repository**
**File:** `lib/models/analysis/analysis.dart`

```dart
class Analysis extends ChangeNotifier 
    with Repository<Chart>, RepositoryStorage<Chart>, RepositoryOrderable<Chart> {
  
  // Singleton
  static Analysis instance = Analysis();
  
  // Properties
  Map<String, Chart> items;       // User-defined charts
  
  // Constructor
  Analysis();
  
  // Methods
  Chart? getChart(String id);
  Future<void> addChart(Chart chart);
  Future<void> removeChart(String id);
  Future<void> reorderChart(int oldIndex, int newIndex);
  
  // Data Methods (for chart generation)
  Future<Map<String, dynamic>> getOrderData(DateTimeRange range);
  Future<Map<String, dynamic>> getProductData(DateTimeRange range);
  Future<Map<String, dynamic>> getCategoryData(DateTimeRange range);
  Future<Map<String, dynamic>> getRevenueData(DateTimeRange range);
}
```

---

### **2. Chart Model**
**File:** `lib/models/analysis/chart.dart`

```dart
class Chart extends Model<ChartObject>
    with ModelStorage, ModelOrderable {
  
  // Properties
  ChartType type;                 // Visual representation
  String title;                   // Chart title
  ChartDataType dataType;         // What to analyze
  DateTimeRange? defaultRange;    // Default time period
  
  // Constructor
  Chart({
    String? id,
    ModelStatus status = ModelStatus.normal,
    String name = 'chart',
    int index = 0,
    required this.type,
    required this.dataType,
    this.title = 'Chart',
    this.defaultRange,
  });
  
  // Factory Constructor
  factory Chart.fromObject(ChartObject object);
  
  // Computed Properties
  Analysis get repository;
  
  // Methods
  Future<ChartData> getData(DateTimeRange range);
  ChartObject toObject();
}

enum ChartType {
  line,           // Line chart for trends
  pie,            // Pie chart for distributions
  bar,            // Bar chart for comparisons
}

enum ChartDataType {
  revenue,        // Revenue over time
  productCount,   // Product sales count
  orderCount,     // Number of orders
  averagePrice,   // Average order value
  topProducts,    // Best sellers
  categoryBreakdown, // Sales by category
}
```

---

## 🖨️ Printer Models

### **Printer Model**
**File:** `lib/models/printer.dart`

```dart
class Printer extends Model<PrinterObject> with ModelStorage {
  // Properties
  String address;                 // Bluetooth MAC address
  bool autoConnect;               // Auto-connect on start
  PrinterProvider provider;       // Manufacturer type
  bt.Printer p;                   // Bluetooth instance
  
  // Constructor
  Printer({
    String? id,
    ModelStatus status = ModelStatus.normal,
    String name = 'printer',
    this.address = '',
    this.autoConnect = false,
    this.provider = PrinterProvider.cat1,
    bt.Printer? other,
  });
  
  // Factory Constructor
  factory Printer.fromObject(PrinterObject object);
  
  // Computed Properties
  bool get connected => p.connected;
  Printers get repository;
  
  // Methods
  Future<bool> connect();
  Future<void> disconnect();
  Stream<double> draw(Uint8List image);
  Future<void> remove();
  PrinterObject toObject();
}

enum PrinterProvider {
  cat1,           // CAT Printer (1 byte feed)
  cat2,           // CAT Printer (2 byte feed)
  epsonPrinter,   // Epson thermal printer
  xPrinter,       // XPrinter series
}
```

---

### **Printers Repository**
**File:** `lib/models/printer.dart`

```dart
class Printers extends ChangeNotifier 
    with Repository<Printer>, RepositoryStorage<Printer> {
  
  // Singleton
  static late Printers instance;
  
  // Properties
  PrinterDensity density;         // Print density setting
  Map<String, Printer> items;     // Connected printers
  
  // Computed Properties
  bool get hasConnected;          // Any printer connected
  List<int> get wantedPixelsWidths; // Required image widths
  
  // Methods
  bool hasAddress(String address);
  Future<void> initialize();
  Future<void> saveProperties();
  
  // Printing Methods
  Future<List<ConvertibleImage>?> generateReceipts({
    required BuildContext context,
    required OrderObject order,
  });
  void printReceipts(List<ConvertibleImage> images);
}

enum PrinterDensity {
  normal,         // Standard density
  tight,          // High density (darker)
}
```

---

## 👔 Clothing Store Extension Models

### **1. ClothingProduct Model**
**File:** `lib/models/clothing/clothing_product.dart`

```dart
class ClothingProduct {
  // Properties
  String id;
  String name;
  String nameArabic;
  String brand;
  String brandArabic;
  String category;
  num price;
  num cost;
  List<ProductVariant> variants;  // Size/color combinations
  String? imagePath;
  String barcode;
  
  // Computed Properties
  num get profit => price - cost;
  int get totalStock => variants.fold(0, (sum, v) => sum + v.stock);
  bool get isInStock => totalStock > 0;
  
  // Methods
  ProductVariant? getVariant(String sizeId, String colorId);
  void updateStock(String variantId, int quantity);
}
```

---

### **2. ProductVariant Model**
**File:** `lib/models/clothing/product_variant.dart`

```dart
class ProductVariant {
  // Properties
  String id;
  String sizeId;                  // Link to Size
  String colorId;                 // Link to Color
  int stock;                      // Current stock
  String? sku;                    // Stock keeping unit
  String? barcode;                // Variant-specific barcode
  
  // Computed Properties
  Size get size;
  Color get color;
  String get displayName;         // "Large / Red"
  
  // Methods
  void addStock(int quantity);
  void removeStock(int quantity);
  bool get isAvailable => stock > 0;
}
```

---

### **3. Size Model**
**File:** `lib/models/clothing/size.dart`

```dart
class Size {
  String id;
  String name;                    // "Small", "Medium", "Large"
  String nameArabic;
  int order;                      // Display order
  
  // Standard sizes
  static const small = Size(id: 'S', name: 'Small', order: 1);
  static const medium = Size(id: 'M', name: 'Medium', order: 2);
  static const large = Size(id: 'L', name: 'Large', order: 3);
  static const extraLarge = Size(id: 'XL', name: 'Extra Large', order: 4);
}
```

---

### **4. Color Model**
**File:** `lib/models/clothing/color.dart`

```dart
class Color {
  String id;
  String name;                    // "Red", "Blue", "Black"
  String nameArabic;
  String hexCode;                 // "#FF0000"
  int order;
  
  // Common colors
  static const black = Color(id: 'black', hexCode: '#000000');
  static const white = Color(id: 'white', hexCode: '#FFFFFF');
  static const red = Color(id: 'red', hexCode: '#FF0000');
  static const blue = Color(id: 'blue', hexCode: '#0000FF');
}
```

---

### **5. Collection Model**
**File:** `lib/models/clothing/collection.dart`

```dart
class Collection {
  // Properties
  String id;
  String name;
  String nameArabic;
  String season;                  // "Spring 2025", "Winter 2024"
  DateTime startDate;
  DateTime? endDate;
  List<String> productIds;        // Products in collection
  
  // Computed Properties
  bool get isActive;              // Current date in range
  int get productCount;
}
```

---

### **6. ClothingCustomer Model**
**File:** `lib/models/clothing/clothing_customer.dart`

```dart
class ClothingCustomer {
  // Properties
  String id;
  String? name;
  String? phone;
  String? email;
  num totalPurchases;
  num totalSpent;
  DateTime? lastPurchase;
  List<String> preferredSizes;
  List<String> preferredColors;
  
  // Computed Properties
  num get averageOrderValue;
  bool get isVIP => totalSpent > 1000;
}
```

---

## 📦 Data Transfer Objects (DTOs)

### **MenuObject**
**File:** `lib/models/objects/menu_object.dart`

```dart
class CatalogObject extends ModelObject<Catalog> {
  final String? id;
  final String? name;
  final int? index;
  final DateTime? createdAt;
  final String? imagePath;
  final List<ProductObject> products;
  
  CatalogObject({
    this.id,
    this.name,
    this.index,
    this.createdAt,
    this.imagePath,
    this.products = const [],
  });
  
  factory CatalogObject.build(Map<String, Object?> data);
  Map<String, Object?> toMap();
  Map<String, Object?> diff(Catalog model);
}

class ProductObject extends ModelObject<Product> {
  final String? id;
  final String? name;
  final int? index;
  final num? price;
  final num? cost;
  final DateTime? createdAt;
  final DateTime? searchedAt;
  final String? imagePath;
  final List<ProductIngredientObject> ingredients;
  
  ProductObject({
    this.id,
    this.name,
    this.index,
    this.price,
    this.cost,
    this.createdAt,
    this.searchedAt,
    this.imagePath,
    this.ingredients = const [],
  });
  
  factory ProductObject.build(Map<String, Object?> data);
  Map<String, Object?> toMap();
  Map<String, Object?> diff(Product model);
  bool get isLatest;              // Version check
}

class ProductIngredientObject extends ModelObject<ProductIngredient> {
  final String? id;
  final String? ingredientId;
  final num? amount;
  final List<ProductQuantityObject> quantities;
  
  ProductIngredientObject({
    this.id,
    this.ingredientId,
    this.amount,
    this.quantities = const [],
  });
  
  factory ProductIngredientObject.build(Map<String, Object?> data);
  Map<String, Object?> toMap();
  Map<String, Object?> diff(ProductIngredient model);
  bool get isLatest;
}

class ProductQuantityObject extends ModelObject<ProductQuantity> {
  final String? id;
  final String? quantityId;
  final num? amount;
  final num? additionalPrice;
  final num? additionalCost;
  
  ProductQuantityObject({
    this.id,
    this.quantityId,
    this.amount,
    this.additionalPrice,
    this.additionalCost,
  });
  
  factory ProductQuantityObject.build(Map<String, Object?> data);
  Map<String, Object?> toMap();
  Map<String, Object?> diff(ProductQuantity model);
  bool get isLatest;
}
```

---

### **StockObject**
**File:** `lib/models/objects/stock_object.dart`

```dart
class IngredientObject extends ModelObject<Ingredient> {
  final String? id;
  final String? name;
  final num? currentAmount;
  final num? totalAmount;
  final num? restockPrice;
  final num? restockQuantity;
  final num? restockLastPrice;
  final num? lastAmount;
  final DateTime? updatedAt;
  
  IngredientObject({
    this.id,
    this.name,
    this.currentAmount,
    this.totalAmount,
    this.restockPrice,
    this.restockQuantity,
    this.restockLastPrice,
    this.lastAmount,
    this.updatedAt,
  });
  
  factory IngredientObject.build(Map<String, Object?> data);
  Map<String, Object?> toMap();
  Map<String, Object?> diff(Ingredient model);
}

class QuantityObject extends ModelObject<Quantity> {
  final String? id;
  final String? name;
  final num? defaultProportion;
  
  QuantityObject({
    this.id,
    this.name,
    this.defaultProportion,
  });
  
  factory QuantityObject.build(Map<String, Object?> data);
  Map<String, Object?> toMap();
  Map<String, Object?> diff(Quantity model);
}

class ReplenishmentObject extends ModelObject<Replenishment> {
  final String? id;
  final String? name;
  final Map<String, num> data;   // ingredientId -> quantity
  final DateTime? createdAt;
  
  ReplenishmentObject({
    this.id,
    this.name,
    required this.data,
    this.createdAt,
  });
  
  factory ReplenishmentObject.build(Map<String, Object?> data);
  Map<String, Object?> toMap();
  Map<String, Object?> diff(Replenishment model);
}
```

---

### **OrderObject**
**File:** `lib/models/objects/order_object.dart`

```dart
class OrderObject {
  // Properties
  int? id;                        // Auto-increment ID
  num price;                      // Total price
  num? cost;                      // Total cost
  num productsPrice;              // Subtotal (before attributes)
  int productsCount;              // Total items
  num paid;                       // Amount paid
  DateTime createdAt;             // Order timestamp
  String? note;                   // Order notes
  List<OrderProductObject> products;
  List<OrderSelectedAttributeObject> attributes;
  
  // Constructor
  OrderObject({
    this.id,
    required this.price,
    this.cost,
    required this.productsPrice,
    required this.productsCount,
    this.paid = 0,
    DateTime? createdAt,
    this.note,
    this.products = const [],
    this.attributes = const [],
  });
  
  // Factory Constructors
  factory OrderObject.fromMap(Map<String, Object?> data);
  factory OrderObject.build(Map<String, Object?> data);
  
  // Computed Properties
  num get change => paid - price;
  List<CartProduct> get productModels;
  Map<String, String> get selectedAttributes;
  
  // Methods
  Map<String, Object?> toMap();
  String encode();                // For database storage
}

class OrderProductObject {
  final String productId;
  final String productName;
  final int count;
  final num singlePrice;
  final num? singleCost;
  final String? ingredientName;
  final Map<String, String> quantities;  // ingredientId -> quantityId
  
  OrderProductObject({
    required this.productId,
    required this.productName,
    required this.count,
    required this.singlePrice,
    this.singleCost,
    this.ingredientName,
    this.quantities = const {},
  });
  
  factory OrderProductObject.fromMap(Map<String, Object?> data);
  Map<String, Object?> toMap();
}

class OrderSelectedAttributeObject {
  final String attributeId;
  final String attributeName;
  final String? optionId;
  final String? optionName;
  final OrderAttributeMode mode;
  final num modeValue;
  
  OrderSelectedAttributeObject({
    required this.attributeId,
    required this.attributeName,
    this.optionId,
    this.optionName,
    required this.mode,
    required this.modeValue,
  });
  
  factory OrderSelectedAttributeObject.fromModel(OrderAttributeOption option);
  factory OrderSelectedAttributeObject.fromMap(Map<String, Object?> data);
  Map<String, Object?> toMap();
}
```

---

### **CashierObject**
**File:** `lib/models/objects/cashier_object.dart`

```dart
class CashierObject {
  final Map<String, num> units;                  // Stored as String keys
  final List<CashierChangeBatchObject>? batches;
  
  CashierObject({
    required this.units,
    this.batches,
  });
  
  factory CashierObject.build(Map<String, Object?> data);
  Map<String, Object?> toMap();
}

class CashierUnitObject {
  final int unit;                 // Denomination value
  final num count;                // Quantity
  
  CashierUnitObject({
    required this.unit,
    required this.count,
  });
  
  factory CashierUnitObject.fromMap(Map<String, Object?> data);
  Map<String, Object?> toMap();
}

class CashierChangeBatchObject {
  final String id;
  final String name;
  final Map<String, num> data;   // denomination -> count
  
  CashierChangeBatchObject({
    required this.id,
    required this.name,
    required this.data,
  });
  
  factory CashierChangeBatchObject.fromMap(Map<String, Object?> data);
  Map<String, Object?> toMap();
}
```

---

## 🔄 Repository Pattern Implementation

### **Base Repository Mixin**
**File:** `lib/models/repository.dart`

```dart
mixin Repository<T extends Model> on ChangeNotifier {
  // Properties
  Map<String, T> items = {};
  
  // Computed Properties
  List<T> get itemList;           // Sorted list
  Iterable<T> get notEmptyItems;  // Active items only
  int get length => items.length;
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  
  // Abstract Methods
  T buildItem(String id, Map<String, Object?> value);
  
  // CRUD Operations
  T? getItem(String id) => items[id];
  bool hasItem(String id) => items.containsKey(id);
  
  Future<void> addItem(T item) async {
    items[item.id] = item;
    item.repository = this;
    await item.save();
    notifyItems();
  }
  
  Future<void> removeItem(String id) async {
    final item = items.remove(id);
    await item?.remove();
    notifyItems();
  }
  
  void replaceItems(Map<String, T> items) {
    this.items = items;
    for (var item in items.values) {
      item.repository = this;
    }
  }
  
  // Notification
  void notifyItems() => notifyListeners();
}

mixin RepositoryStorage<T extends Model> on Repository<T> {
  // Storage Methods
  Future<void> initialize({String? record});
  Future<void> resetAll();
  Stores get storageStore;
  RepositoryStorageType get repoType;
}

enum RepositoryStorageType {
  repoModel,        // Nested model storage
  repoProperties,   // Flat property storage
}
```

---

### **Implemented Repositories**

#### **1. Menu Repository**
```dart
class Menu extends ChangeNotifier 
    with Repository<Catalog>, RepositoryStorage<Catalog>, RepositoryOrderable<Catalog> {
  
  static Menu instance = Menu();
  bool versionChanged = false;
  
  // Special Methods
  Product? getProduct(String id);
  List<Product> get products;
  Future<void> imagined(String catalogId, Uint8List bytes);
}
```

#### **2. Stock Repository**
```dart
class Stock extends ChangeNotifier 
    with Repository<Ingredient>, RepositoryStorage<Ingredient> {
  
  static Stock instance = Stock();
  
  // Inventory Methods
  Future<void> order(OrderObject order);
  Future<void> applyAmounts(Map<String, num> data);
  Future<void> replenish(ReplenishmentObject repl);
}
```

#### **3. OrderAttributes Repository**
```dart
class OrderAttributes extends ChangeNotifier 
    with Repository<OrderAttribute>, RepositoryStorage<OrderAttribute> {
  
  static OrderAttributes instance = OrderAttributes();
  
  // Methods
  num getDiff(Map<String, String> attributes, num price);
}
```

#### **4. Quantities Repository**
```dart
class Quantities extends ChangeNotifier 
    with Repository<Quantity>, RepositoryStorage<Quantity> {
  
  static Quantities instance = Quantities();
}
```

#### **5. Replenisher Repository**
```dart
class Replenisher extends ChangeNotifier 
    with Repository<Replenishment>, RepositoryStorage<Replenishment>, RepositoryOrderable<Replenishment> {
  
  static Replenisher instance = Replenisher();
}
```

#### **6. Seller Repository**
```dart
class Seller extends ChangeNotifier {
  static Seller instance = Seller();
  
  // Order Management
  Future<void> push(OrderObject order);
  Future<List<OrderObject>> getOrders({DateTimeRange? range});
  Future<int> count({DateTimeRange? range});
}
```

#### **7. StashedOrders Repository**
```dart
class StashedOrders extends ChangeNotifier {
  static StashedOrders instance = StashedOrders();
  
  List<OrderObject> orders = [];
  
  Future<void> stash(OrderObject order);
  Future<void> restore(int index);
  Future<void> remove(int index);
}
```

---

## 🔗 Model Relationships

### **Relationship Diagram**

```
Menu (Repository)
├── Catalog (1:N)
│   └── Product (1:N)
│       └── ProductIngredient (N:1) ────┐
│           └── ProductQuantity (N:1) ──┼─> Stock.Ingredient
│                                       │
Stock (Repository)                      │
├── Ingredient (1:N) <──────────────────┘
├── Quantity (1:N) <─────────────┐
└── Replenishment (1:N)          │
                                 │
OrderAttributes (Repository)     │
└── OrderAttribute (1:N)         │
    └── OrderAttributeOption ────┤
                                 │
Cart (Singleton)                 │
├── CartProduct (N:1) ──> Product
│   └── ingredients (N:1) ──> ProductQuantity
└── attributes (N:1) ──> OrderAttributeOption

Cashier (Singleton)
├── units (denomination:count map)
└── CashierChangeBatch (1:N)

Analysis (Repository)
└── Chart (1:N)

Printers (Repository)
└── Printer (1:N)

Seller (Singleton)
└── Orders (persisted in DB)
```

---

### **Key Relationships**

1. **Menu → Stock**
   - `ProductIngredient.ingredientId` → `Ingredient.id`
   - Products consume ingredients from stock

2. **Menu → Quantities**
   - `ProductQuantity.quantityId` → `Quantity.id`
   - Products use standard quantity units

3. **Cart → Menu**
   - `CartProduct.product` → `Product`
   - Cart items reference menu products

4. **Cart → OrderAttributes**
   - `Cart.attributes` → `OrderAttributeOption`
   - Orders use customer preference attributes

5. **Stock → Replenishment**
   - `Replenishment.data[ingredientId]` → `Ingredient.id`
   - Purchase orders restock ingredients

6. **Seller → All**
   - Stores completed `OrderObject` with all relationships

---

## 💾 Storage Architecture

### **Storage Layers**

#### **1. SQLite Database**
**File:** `lib/services/database.dart`

**Tables:**
- `orders` - Completed transactions
- Custom tables for analytics

**Schema:**
```sql
CREATE TABLE orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  price REAL NOT NULL,
  cost REAL,
  productsPrice REAL,
  productsCount INTEGER,
  paid REAL,
  createdAt INTEGER NOT NULL,
  encodedProducts TEXT,
  encodedAttributes TEXT,
  note TEXT
);
```

#### **2. Sembast Key-Value Store**
**File:** `lib/services/storage.dart`

**Stores:**
- `menu` - Product catalogs
- `stock` - Ingredients
- `quantities` - Units of measure
- `orderAttributes` - Customer attributes
- `replenisher` - Purchase orders
- `printers` - Printer configs
- `analysis` - Chart definitions
- `cache` - App cache

**Storage Pattern:**
```dart
// Hierarchical storage
"catalog.{catalogId}" -> CatalogObject
"catalog.{catalogId}.products.{productId}" -> ProductObject
"catalog.{catalogId}.products.{productId}.ingredients.{ingrId}" -> ProductIngredientObject

// Flat storage
"ingredient.{id}" -> IngredientObject
"quantity.{id}" -> QuantityObject
"printer.{id}" -> PrinterObject
```

---

## 🎯 Model Features & Mixins

### **ModelStorage Mixin**
Provides persistence capabilities:
```dart
mixin ModelStorage<T extends ModelObject> on Model<T> {
  Stores get storageStore;
  String get prefix;
  
  Future<void> save();
  Future<void> remove();
  Future<void> update(T object, {String? event});
}
```

### **ModelOrderable Mixin**
Provides ordering capabilities:
```dart
mixin ModelOrderable<T extends ModelObject> on Model<T> {
  int index;
  
  int compareTo(Model other) => index.compareTo(other.index);
}
```

### **ModelSearchable Mixin**
Provides search capabilities:
```dart
mixin ModelSearchable<T extends ModelObject> on Model<T> {
  int getSimilarity(String pattern);
}
```

### **ModelImage Mixin**
Provides image handling:
```dart
mixin ModelImage<T extends ModelObject> on Model<T> {
  String? imagePath;
  XFile? avator;
  
  Future<void> setImage(Uint8List bytes);
  Future<void> removeImage();
}
```

---

## 📈 Data Flow Patterns

### **1. Order Processing Flow**

```
User adds products to Cart
    ↓
Cart calculates totals (products + attributes)
    ↓
User proceeds to checkout with payment
    ↓
Cart.checkout() validates payment
    ↓
┌─── Generate receipt (Printers)
├─── Record sale (Seller)
├─── Update inventory (Stock)
└─── Update cash (Cashier)
    ↓
Clear cart & show success
```

### **2. Stock Update Flow**

```
Order completed
    ↓
Stock.order(orderObject)
    ↓
For each CartProduct:
    ↓
    Get ProductIngredients
    ↓
    For each ingredient:
        ↓
        Calculate quantity used
        ↓
        ingredient.getUpdateData(-quantity)
        ↓
        Update database
        ↓
    Notify listeners
```

### **3. Replenishment Flow**

```
Create Replenishment
    ↓
Add ingredients with quantities
    ↓
Replenishment.apply()
    ↓
For each ingredient:
    ↓
    ingredient.getUpdateData(+quantity)
    ↓
    Update lastAmount
    ↓
    Update database
    ↓
Notify listeners
```

---

## 🔐 Model Validation Rules

### **Product Validation**
- ✅ Price must be >= 0
- ✅ Cost must be >= 0
- ✅ Name must not be empty
- ✅ Must have at least one ingredient (optional)

### **Ingredient Validation**
- ✅ CurrentAmount can be negative (backorder)
- ✅ RestockQuantity must be > 0
- ✅ Name must be unique in Stock repository

### **Order Validation**
- ✅ Paid must be >= price
- ✅ Products list must not be empty
- ✅ ProductsPrice must equal sum of cart items

### **Cashier Validation**
- ✅ Unit counts must be >= 0
- ✅ Denomination must be valid currency value
- ✅ Change must be calculable with available units

---

## 🧪 Model Usage Examples

### **Creating a Complete Product**

```dart
// 1. Create catalog
final catalog = Catalog(
  name: 'Burgers',
  index: 0,
);
await Menu.instance.addItem(catalog);

// 2. Create product
final product = Product(
  name: 'Cheeseburger',
  price: 8.99,
  cost: 3.50,
  catalog: catalog,
);
await catalog.addItem(product);

// 3. Add ingredients
final beefIngr = ProductIngredient(
  ingredientId: 'beef-patty',
  amount: 1,
);
await product.addItem(beefIngr);

// 4. Add quantity options
final large = ProductQuantity(
  quantityId: 'large',
  amount: 1.5,
  additionalPrice: 2.00,
);
await beefIngr.addItem(large);
```

### **Processing an Order**

```dart
// 1. Add to cart
Cart.instance.add(cheeseburger);
Cart.instance.add(fries);

// 2. Set attributes
Cart.instance.chooseAttribute('size', 'large');
Cart.instance.updateNote('Extra cheese');

// 3. Checkout
final status = await Cart.instance.checkout(
  paid: 20.00,
  context: context,
);

// 4. Handle result
switch (status) {
  case CheckoutStatus.ok:
    // Success - receipt printed, stock updated
    break;
  case CheckoutStatus.paidNotEnough:
    // Show error - need more payment
    break;
  case CheckoutStatus.cashierNotEnough:
    // Show warning - insufficient change
    break;
}
```

### **Stock Management**

```dart
// 1. Create ingredient
final beefPatty = Ingredient(
  name: 'Beef Patty',
  currentAmount: 100,
  restockQuantity: 50,
  restockPrice: 25.00,
);
await Stock.instance.addItem(beefPatty);

// 2. Manual restock
await beefPatty.setAmount(150);

// 3. Automatic deduction (on sale)
// Happens automatically in Cart.checkout()
// via Stock.instance.order(orderObject)

// 4. Bulk replenishment
final repl = Replenishment(
  name: 'Weekly Restock',
  data: {
    'beef-patty': 50,
    'cheese': 100,
    'lettuce': 75,
  },
);
await Replenisher.instance.addItem(repl);
await repl.apply();
```

---

## 📊 Model Statistics

### **Total Models Count**

- **Menu System**: 4 models (Catalog, Product, ProductIngredient, ProductQuantity)
- **Stock System**: 3 models (Ingredient, Quantity, Replenishment)
- **Order System**: 3 models (Cart, CartProduct, OrderAttribute, OrderAttributeOption)
- **Cashier System**: 2 models (Cashier, CashierChangeBatch)
- **Analysis System**: 2 models (Analysis, Chart)
- **Printer System**: 2 models (Printers, Printer)
- **Clothing Extension**: 6 models (ClothingProduct, ProductVariant, Size, Color, Collection, ClothingCustomer)
- **Data Objects**: 10+ DTOs for serialization

**Total: 30+ models**

---

## 🔍 Model Search & Filter

### **Searchable Models**
- Product (by name)
- Ingredient (by name)
- Quantity (by name)

### **Search Implementation**
```dart
// Levenshtein distance-based similarity
int getSimilarity(String pattern) {
  return 100 - levenshteinDistance(name.toLowerCase(), pattern.toLowerCase());
}

// Usage
final results = Menu.instance.items
  .expand((catalog) => catalog.items)
  .map((product) => MapEntry(product, product.getSimilarity('burger')))
  .where((entry) => entry.value > 50)
  .sorted((a, b) => b.value.compareTo(a.value));
```

---

## 🧩 Model Extension Points

### **Custom Product Types**
```dart
// Example: Enhanced Product for clothing
class EnhancedProduct extends Product {
  String brand;
  String category;
  List<ProductVariant> variants;
  
  // Override pricing
  @override
  num get price {
    // Custom pricing logic
    return super.price * seasonalMultiplier;
  }
}
```

### **Custom Attributes**
```dart
// Example: Customer demographics
class DemographicAttribute extends OrderAttribute {
  AgeRange ageRange;
  Gender gender;
  
  // Custom validation
  bool validate() {
    return ageRange.isValid && gender != null;
  }
}
```

---

## 🎓 Best Practices

### **Model Creation**
1. Always use factory constructors for deserialization
2. Initialize repositories in `main()` before app start
3. Call `prepareItem()` after construction from objects
4. Use proper `ModelStatus` for tracking changes

### **Repository Management**
1. Access via singleton instances only
2. Initialize repositories in dependency order
3. Always call `notifyListeners()` after mutations
4. Use transactions for multi-model updates

### **Performance**
1. Use lazy loading for large lists
2. Implement pagination for order history
3. Cache computed properties when expensive
4. Use indexed lookups (Map) over linear search

### **Data Integrity**
1. Validate before saving
2. Use transactions for related updates
3. Maintain referential integrity
4. Implement proper error handling

---

## 📝 Model Change Log

### **Recent Changes**
- Added Arabic language support
- Enhanced localization objects
- Fixed enum `values` conflicts
- Updated printer return types
- Added clothing store extension models

---

## 🚀 Future Enhancements

### **Planned Models**
1. **Customer Model** - Full customer management
2. **Loyalty Model** - Points and rewards
3. **Discount Model** - Advanced discount rules
4. **Tax Model** - Multi-tax support
5. **Employee Model** - Staff management
6. **Shift Model** - Shift tracking
7. **Reservation Model** - Table reservations

---

**End of Models Reference**



