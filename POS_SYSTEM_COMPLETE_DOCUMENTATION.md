# POS System - Complete Documentation
## Features & Data Models Reference

**Generated:** October 7, 2025  
**Version:** 1.0  
**Platform:** Flutter 3.35.x with Dart 3.3+

---

## 📋 Table of Contents

1. [Complete Feature List](#complete-feature-list)
2. [Data Models Architecture](#data-models-architecture)
3. [Core Data Models](#core-data-models)
4. [Business Logic Models](#business-logic-models)
5. [Repository Pattern](#repository-pattern)
6. [Data Transfer Objects](#data-transfer-objects)

---

## 🎯 Complete Feature List

### **1. Menu Management System**
**Location:** `lib/models/menu/`, `lib/ui/menu/`

#### Features:
- ✅ **Hierarchical Organization**: Catalogs → Products → Ingredients → Quantities
- ✅ **Product Management**:
  - Create, Read, Update, Delete (CRUD) operations
  - Product naming and pricing
  - Cost tracking for profit analysis
  - Product images
  - Availability status toggle
  - Product search by name
  - Product categorization
- ✅ **Ingredient System**:
  - Recipe component tracking
  - Ingredient quantities per product
  - Automatic inventory deduction
  - Multiple measurement units
- ✅ **Pricing Features**:
  - Base price configuration
  - Cost price tracking
  - Profit margin calculation
  - Quantity-based pricing
- ✅ **Catalog Management**:
  - Product grouping
  - Category creation
  - Catalog reordering
  - Bulk operations
- ✅ **Import/Export**:
  - Bulk product import
  - Menu data export
  - CSV/Excel support

---

### **2. Point of Sale (POS) Interface**
**Location:** `lib/ui/order/`, `lib/models/order/`

#### Features:
- ✅ **Order Creation**:
  - Touch-optimized product selection
  - Quick add to cart
  - Product search during ordering
  - Visual product display
- ✅ **Shopping Cart**:
  - Add/remove products
  - Quantity adjustment
  - Real-time price calculation
  - Cart subtotal/total display
  - Tax calculation
  - Discount application
- ✅ **Order Attributes**:
  - Customizable order properties
  - Customer preferences (size, temperature, etc.)
  - Special instructions/notes
  - Order attribute options
- ✅ **Order Processing**:
  - Order stashing (save for later)
  - Multiple draft orders
  - Order completion
  - Order history
  - Receipt generation
- ✅ **Payment Processing**:
  - Cash payment handling
  - Change calculation
  - Payment confirmation
  - Receipt printing

---

### **3. Inventory Management**
**Location:** `lib/models/stock/`, `lib/ui/stock/`

#### Features:
- ✅ **Stock Tracking**:
  - Real-time inventory levels
  - Automatic stock deduction on sales
  - Manual stock adjustments
  - Stock movement history
  - Current stock display
- ✅ **Ingredient Management**:
  - Ingredient master list
  - Ingredient naming
  - Current amount tracking
  - Last updated timestamp
  - Product usage tracking
- ✅ **Replenishment System**:
  - Purchase order creation
  - Replenishment planning
  - Stock receiving
  - Replenishment history
  - Automatic amount calculation
- ✅ **Quantity Units**:
  - Multiple units of measure
  - Quantity proportions
  - Unit conversions
  - Default quantity settings
- ✅ **Stock Alerts**:
  - Low stock warnings
  - Out of stock indicators
  - Replenishment suggestions
- ✅ **Stock Analysis**:
  - Ingredient usage reports
  - Stock movement tracking
  - Waste tracking capabilities

---

### **4. Cash Register (Cashier)**
**Location:** `lib/models/repository/cashier.dart`, `lib/ui/cashier/`

#### Features:
- ✅ **Cash Drawer Management**:
  - Multiple denomination tracking
  - Current cash amounts
  - Cash unit configuration
  - Denomination display
- ✅ **Daily Operations**:
  - Opening cash count
  - Closing cash reconciliation
  - Cash flow monitoring
  - Daily balance calculation
- ✅ **Change Calculator**:
  - Intelligent change-making
  - Optimal denomination suggestions
  - Change batch favorites
  - Quick change calculations
  - Denomination warnings
- ✅ **Cash Handling**:
  - Cash-in operations
  - Cash-out operations
  - Surplus management
  - Shortage tracking
  - Cash movement audit
- ✅ **Reporting**:
  - Daily cash report
  - Denomination breakdown
  - Cash variance analysis

---

### **5. Analytics & Reporting**
**Location:** `lib/models/analysis/`, `lib/ui/analysis/`

#### Features:
- ✅ **Sales Analytics**:
  - Revenue tracking
  - Sales trends
  - Top products analysis
  - Hourly sales patterns
  - Daily/weekly/monthly reports
- ✅ **Custom Charts**:
  - Line charts for trends
  - Pie charts for distributions
  - Bar graphs for comparisons
  - Chart customization
  - Chart reordering
- ✅ **Historical Data**:
  - Complete order history
  - Transaction details
  - Order breakdown
  - Customer data analysis
- ✅ **Performance Metrics**:
  - Sales velocity
  - Average order value
  - Product performance
  - Category analysis
- ✅ **Date Range Analysis**:
  - Flexible reporting periods
  - Custom date selection
  - Period comparison
  - Trend analysis
- ✅ **Visual Dashboards**:
  - Interactive charts
  - Real-time updates
  - Multiple chart views
- ✅ **Data Export**:
  - Export to CSV
  - Export to Excel
  - Google Sheets integration

---

### **6. Receipt Printing System**
**Location:** `lib/models/printer.dart`, `lib/ui/printer/`

#### Features:
- ✅ **Printer Management**:
  - Multiple printer support
  - Bluetooth printer pairing
  - Printer status monitoring
  - Connection management
  - Auto-connect option
- ✅ **Receipt Customization**:
  - Custom header/footer
  - Logo insertion
  - Receipt templates
  - Paper size configuration
  - Print density settings
- ✅ **Printing Operations**:
  - Print preview
  - Direct printing
  - Batch printing
  - Print queue management
  - Error handling
- ✅ **Printer Types**:
  - CAT Printer support
  - Epson Printer support
  - XPrinter support
  - Generic Bluetooth printers
- ✅ **Print Status**:
  - Connection status
  - Signal strength
  - Paper status
  - Error notifications

---

### **7. Data Import/Export (Transit)**
**Location:** `lib/ui/transit/`, `lib/services/`

#### Features:
- ✅ **Export Formats**:
  - CSV files
  - Excel spreadsheets (.xlsx)
  - Google Sheets integration
  - Plain text export
- ✅ **Import Capabilities**:
  - Bulk product import
  - Menu structure import
  - CSV data import
  - Google Sheets sync
- ✅ **Data Categories**:
  - Order export
  - Menu export
  - Stock data export
  - Cashier data export
  - Analytics export
- ✅ **Cloud Integration**:
  - Google Drive connectivity
  - Google Sheets API
  - OAuth authentication
  - Automatic sync
- ✅ **Backup/Restore**:
  - Complete system backup
  - Data restoration
  - Selective backup
  - Scheduled backups
- ✅ **Date Range Selection**:
  - Custom date ranges
  - Quick presets (today, week, month)
  - Historical data export

---

### **8. Multi-Language Support**
**Location:** `lib/l10n/`

#### Features:
- ✅ **Language Options**:
  - English (en)
  - Chinese Traditional (zh)
  - Arabic (ar)
- ✅ **Localization Features**:
  - Runtime language switching
  - Complete UI translation
  - Number formatting
  - Date/time formatting
  - Currency formatting
  - RTL support (for Arabic)
- ✅ **Content Types**:
  - UI text localization
  - Error messages
  - Help text
  - Labels and buttons
  - System messages

---

### **9. Responsive Design System**
**Location:** `lib/components/`, `lib/constants/`

#### Features:
- ✅ **Adaptive Layouts**:
  - Responsive design across all devices
  - Automatic layout adjustment
  - Breakpoint-based rendering
  - Orientation support
- ✅ **Navigation Patterns**:
  - **Mobile** (< 600px): Bottom navigation bar
  - **Tablet** (600-1200px): Drawer navigation
  - **Desktop** (> 1200px): Rail navigation
- ✅ **Breakpoints**:
  - Compact: < 600px (phones)
  - Medium: 600-840px (small tablets)
  - Expanded: 840-1200px (tablets)
  - Large: 1200-1600px (desktop)
  - Extra Large: > 1600px (large screens)
- ✅ **Touch Optimization**:
  - Large touch targets
  - Gesture support
  - Retail-friendly interface
- ✅ **Themes**:
  - Light theme
  - Dark theme
  - System theme following
  - Custom color schemes
- ✅ **Accessibility**:
  - Screen reader support
  - High contrast modes
  - Keyboard navigation
  - Focus management

---

### **10. Settings & Configuration**
**Location:** `lib/settings/`

#### Features:
- ✅ **Display Settings**:
  - Theme selection (light/dark/system)
  - Language preferences
  - Font size adjustment
- ✅ **Business Settings**:
  - Currency configuration
  - Tax rate settings
  - Receipt customization
  - Store information
- ✅ **Order Settings**:
  - Order flow customization
  - Default order attributes
  - Order numbering
  - Screen timeout settings
- ✅ **Privacy Controls**:
  - Analytics opt-in/out
  - Crash reporting
  - Performance monitoring
  - Event collection
- ✅ **Feature Toggles**:
  - Enable/disable features
  - Module management
  - Advanced settings
- ✅ **System Settings**:
  - Database management
  - Cache settings
  - Storage preferences

---

### **11. Customer Attributes System**
**Location:** `lib/models/order/`, `lib/ui/order_attr/`

#### Features:
- ✅ **Attribute Management**:
  - Create custom attributes
  - Attribute naming
  - Default options
  - Required/optional flags
  - Attribute ordering
- ✅ **Attribute Options**:
  - Multiple choice options
  - Option pricing
  - Option availability
  - Default selection
  - Option reordering
- ✅ **Order Integration**:
  - Attribute selection during order
  - Attribute-based pricing
  - Order customization
  - Attribute history

---

### **12. Offline-First Architecture**

#### Features:
- ✅ **Local Storage**:
  - SQLite database
  - Sembast key-value store
  - Complete offline functionality
  - No internet required
- ✅ **Data Persistence**:
  - Automatic data saving
  - Transaction integrity
  - Data recovery
  - Conflict resolution
- ✅ **Sync Capabilities**:
  - Optional cloud sync
  - Data export for backup
  - Multi-device support (via export/import)

---

### **13. Debug & Development Tools**
**Location:** `lib/debug/`

#### Features (Debug Mode Only):
- ✅ **Debug Console**:
  - Event logging
  - Error tracking
  - Performance monitoring
- ✅ **Development Tools**:
  - Database inspection
  - State debugging
  - Route debugging
  - Feature testing

---

## 🏗️ Data Models Architecture

### **Model Hierarchy**

```
Models (Base Layer)
├── Repository Pattern (Data Access Layer)
│   ├── Menu (Product Catalog)
│   ├── Stock (Inventory)
│   ├── Cashier (Cash Management)
│   ├── OrderAttributes (Customer Preferences)
│   ├── Quantities (Units of Measure)
│   ├── Replenisher (Purchase Orders)
│   ├── Seller (Order Processing)
│   ├── Cart (Shopping Cart)
│   └── StashedOrders (Draft Orders)
│
├── Domain Models (Business Entities)
│   ├── Menu System
│   │   ├── Catalog
│   │   ├── Product
│   │   ├── ProductIngredient
│   │   └── ProductQuantity
│   │
│   ├── Stock System
│   │   ├── Ingredient
│   │   ├── Quantity
│   │   └── Replenishment
│   │
│   ├── Order System
│   │   ├── CartProduct
│   │   ├── OrderAttribute
│   │   └── OrderAttributeOption
│   │
│   └── Analysis System
│       ├── Analysis
│       ├── Chart
│       └── ChartObject
│
└── Data Transfer Objects (DTOs)
    ├── MenuObject
    ├── StockObject
    ├── OrderObject
    ├── CashierObject
    └── OrderAttributeObject
```

---

## 📊 Core Data Models

### **1. Menu System Models**

#### **Catalog Model**
**File:** `lib/models/menu/catalog.dart`

```dart
class Catalog extends Model<CatalogObject> {
  // Properties
  int index;                    // Display order
  List<Product> products;       // Products in this catalog
  
  // Computed Properties
  int get length;               // Number of products
  List<Product> get itemList;   // Sorted product list
  bool get isEmpty;             // Has no products
  bool get isNotEmpty;          // Has products
  
  // Methods
  Product? getProduct(String id);
  void addProduct(Product product);
  void removeProduct(String id);
  void reorderProduct(int oldIndex, int newIndex);
}
```

**Key Features:**
- Hierarchical product organization
- Product ordering and sorting
- CRUD operations for products
- Integration with menu repository

---

#### **Product Model**
**File:** `lib/models/menu/product.dart`

```dart
class Product extends Model<ProductObject> {
  // Properties
  num price;                           // Selling price
  num cost;                            // Cost price
  int index;                           // Display order in catalog
  Catalog catalog;                     // Parent catalog
  List<ProductIngredient> ingredients; // Recipe ingredients
  XFile? avator;                       // Product image
  
  // Computed Properties
  num get profit;                      // price - cost
  bool get isEmpty;                    // Has no ingredients
  bool get isNotEmpty;                 // Has ingredients
  int get length;                      // Number of ingredients
  
  // Methods
  ProductIngredient? getIngredient(String id);
  void addIngredient(ProductIngredient ingredient);
  void removeIngredient(String id);
  num calculateCost();                 // Sum of ingredient costs
}
```

**Key Features:**
- Pricing and cost tracking
- Ingredient composition
- Profit calculation
- Image support
- Recipe management

---

#### **ProductIngredient Model**
**File:** `lib/models/menu/product_ingredient.dart`

```dart
class ProductIngredient extends Model<ProductIngredientObject> {
  // Properties
  String ingredientId;              // Link to Stock.Ingredient
  num amount;                       // Base amount used
  List<ProductQuantity> quantities; // Quantity variations
  
  // Computed Properties
  Ingredient get ingredient;        // Resolved ingredient from Stock
  num get cost;                     // ingredient.currentAmount * amount
  
  // Methods
  ProductQuantity? getQuantity(String id);
  void addQuantity(ProductQuantity quantity);
  num calculateAmount(String quantityId);
}
```

**Key Features:**
- Links products to inventory
- Quantity variations
- Cost calculation
- Stock integration

---

#### **ProductQuantity Model**
**File:** `lib/models/menu/product_quantity.dart`

```dart
class ProductQuantity extends Model<ProductQuantityObject> {
  // Properties
  String quantityId;     // Link to Quantities repository
  num amount;            // Amount multiplier
  num additionalPrice;   // Extra cost for this quantity
  num additionalCost;    // Extra cost price
  
  // Computed Properties
  Quantity get quantity; // Resolved from Quantities repository
  
  // Methods
  num getTotalPrice(num basePrice);
  num getTotalCost(num baseCost);
}
```

---

### **2. Stock/Inventory Models**

#### **Ingredient Model**
**File:** `lib/models/stock/ingredient.dart`

```dart
class Ingredient extends Model<IngredientObject> {
  // Properties
  num currentAmount;           // Current stock level
  num lastAmount;              // Previous stock amount
  DateTime? lastAddedAt;       // Last restock timestamp
  DateTime? updatedAt;         // Last update
  num totalAmount;             // Cumulative amount added
  num restockQuantity;         // Quantity per restock
  
  // Computed Properties
  bool get isOutOfStock;       // currentAmount <= 0
  bool get isLowStock;         // currentAmount < threshold
  num get usageRate;           // Based on history
  
  // Methods
  void updateStock(num amount);
  void restock(num quantity);
  void resetDaily();
}
```

**Key Features:**
- Real-time stock tracking
- Usage history
- Restock management
- Low stock detection

---

#### **Quantity Model**
**File:** `lib/models/stock/quantity.dart`

```dart
class Quantity extends Model<QuantityObject> {
  // Properties
  num defaultProportion;    // Default quantity multiplier
  
  // Methods
  num calculateAmount(num baseAmount);
}
```

**Usage:** Represents units of measure (Small, Medium, Large, etc.)

---

#### **Replenishment Model**
**File:** `lib/models/stock/replenishment.dart`

```dart
class Replenishment extends Model<ReplenishmentObject> {
  // Properties
  Map<String, num> data;     // ingredientId -> quantity
  DateTime createdAt;        // Creation timestamp
  
  // Computed Properties
  List<Ingredient> get ingredients;
  num get totalCost;
  int get itemCount;
  
  // Methods
  void addItem(String ingredientId, num quantity);
  void removeItem(String ingredientId);
  void apply();              // Apply to inventory
}
```

**Key Features:**
- Purchase order creation
- Batch restocking
- Inventory updates

---

### **3. Order System Models**

#### **Cart Model**
**File:** `lib/models/repository/cart.dart`

```dart
class Cart extends ChangeNotifier {
  // Properties
  List<CartProduct> products;           // Items in cart
  Map<String, String> attributes;       // Selected order attributes
  String? note;                          // Order notes
  
  // Computed Properties
  num get price;                         // Total with attributes
  num get productsPrice;                 // Subtotal
  int get itemCount;                     // Number of items
  bool get isEmpty;
  bool get isNotEmpty;
  
  // Methods
  void add(Product product);
  void update(int index, CartProduct item);
  void remove(int index);
  void clear();
  void chooseAttribute(String attrId, String optionId);
  void updateNote(String note);
  Order toOrder();                       // Convert to completed order
}
```

---

#### **CartProduct Model**
**File:** `lib/models/order/cart_product.dart`

```dart
class CartProduct {
  // Properties
  Product product;                    // Reference product
  int count;                          // Quantity
  num singlePrice;                    // Unit price
  num? singleCost;                    // Unit cost
  Map<String, ProductQuantity> ingredients; // Selected quantities
  
  // Computed Properties
  num get totalPrice;                 // singlePrice * count
  num? get totalCost;                 // singleCost * count
  String get productName;
  String get ingredientName;          // Summary of selections
  
  // Methods
  void updateCount(int newCount);
  void updateIngredient(String ingredientId, ProductQuantity quantity);
  CartProduct copyWith({...});
}
```

---

#### **OrderAttribute Model**
**File:** `lib/models/order/order_attribute.dart`

```dart
class OrderAttribute extends Model<OrderAttributeObject> {
  // Properties
  int index;                              // Display order
  String? defaultOption;                  // Default selection
  List<OrderAttributeOption> options;     // Available options
  OrderAttributeMode mode;                // changePrice or changeDiscount
  
  // Computed Properties
  bool get isEmpty;
  bool get isNotEmpty;
  OrderAttributeOption? get defaultOptionObject;
  
  // Methods
  OrderAttributeOption? getOption(String id);
  void addOption(OrderAttributeOption option);
  void removeOption(String id);
  num calculatePrice(num basePrice, String? optionId);
}

enum OrderAttributeMode {
  changePrice,      // Modify price directly
  changeDiscount,   // Apply discount
}
```

---

#### **OrderAttributeOption Model**
**File:** `lib/models/order/order_attribute_option.dart`

```dart
class OrderAttributeOption extends Model<OrderAttributeOptionObject> {
  // Properties
  int index;              // Display order
  num modeValue;          // Price change or discount amount
  bool isDefault;         // Is default selection
  
  // Methods
  num apply(num basePrice, OrderAttributeMode mode);
}
```

---

### **4. Analysis Models**

#### **Analysis Repository**
**File:** `lib/models/analysis/analysis.dart`

```dart
class Analysis extends ChangeNotifier with Repository<Chart> {
  // Properties
  List<Chart> charts;           // User-defined charts
  
  // Methods
  void addChart(Chart chart);
  void removeChart(String id);
  void reorderChart(int oldIndex, int newIndex);
  Chart? getChart(String id);
  
  // Data Methods
  Map<String, dynamic> getOrderData(DateTimeRange range);
  Map<String, dynamic> getProductData(DateTimeRange range);
  Map<String, dynamic> getCategoryData(DateTimeRange range);
}
```

---

#### **Chart Model**
**File:** `lib/models/analysis/chart.dart`

```dart
class Chart extends Model<ChartObject> {
  // Properties
  int index;                    // Display order
  ChartType type;               // line, pie, bar
  String title;                 // Chart title
  ChartDataType dataType;       // What to analyze
  
  // Methods
  ChartData getData(DateTimeRange range);
}

enum ChartType {
  line,
  pie,
  bar,
}

enum ChartDataType {
  revenue,
  productCount,
  orderCount,
  averagePrice,
}
```

---

### **5. Cashier Models**

#### **Cashier Repository**
**File:** `lib/models/repository/cashier.dart`

```dart
class Cashier extends ChangeNotifier {
  // Properties
  Map<int, num> units;              // denomination -> count
  List<CashierChangeBatch> batches; // Favorite change combinations
  
  // Computed Properties
  num get totalPrice;               // Sum of all denominations
  Map<int, num> get warning;        // Denominations running low
  
  // Methods
  void updateUnit(int denomination, num count);
  void reset();                     // Start new day
  Map<int, num> calculateChange(num amount);
  void addBatch(CashierChangeBatch batch);
  Map<int, num> getSurplus();       // End of day surplus/shortage
}
```

---

#### **Printer Model**
**File:** `lib/models/printer.dart`

```dart
class Printer extends Model<PrinterObject> {
  // Properties
  String address;                  // Bluetooth MAC address
  bool autoConnect;                // Connect on app start
  PrinterProvider provider;        // Printer manufacturer
  bt.Printer p;                    // Bluetooth printer instance
  
  // Computed Properties
  bool get connected;              // Connection status
  
  // Methods
  Future<bool> connect();
  Future<void> disconnect();
  Stream<double> draw(Uint8List image);
}

enum PrinterProvider {
  cat1,           // CAT Printer (1 byte feed)
  cat2,           // CAT Printer (2 byte feed)
  epsonPrinter,   // Epson printer
  xPrinter,       // XPrinter
}
```

---

## 🔄 Repository Pattern

### **Base Repository Class**
**File:** `lib/models/repository.dart`

```dart
mixin Repository<T extends Model> on ChangeNotifier {
  // Properties
  Map<String, T> items;
  
  // Computed Properties
  List<T> get itemList;
  int get length;
  bool get isEmpty;
  bool get isNotEmpty;
  
  // Methods
  T? getItem(String id);
  bool hasItem(String id);
  Future<void> addItem(T item);
  Future<void> removeItem(String id);
  Future<void> replaceItems(Map<String, T> items);
  
  // Storage
  Future<void> initialize();
  Future<void> resetAll();
}
```

---

### **Implemented Repositories**

1. **Menu** - Product catalog management
2. **Stock** - Inventory management
3. **Cashier** - Cash register
4. **OrderAttributes** - Customer preferences
5. **Quantities** - Units of measure
6. **Replenisher** - Purchase orders
7. **Seller** - Order processing
8. **Cart** - Shopping cart
9. **StashedOrders** - Draft orders
10. **Printers** - Printer management
11. **Analysis** - Analytics and charts

---

## 📦 Data Transfer Objects (DTOs)

### **MenuObject**
```dart
class CatalogObject {
  String? id;
  String? name;
  int? index;
  Map<String, ProductObject>? products;
}

class ProductObject {
  String? id;
  String? name;
  num? price;
  num? cost;
  int? index;
  String? imagePath;
  Map<String, ProductIngredientObject>? ingredients;
}

class ProductIngredientObject {
  String? id;
  String? ingredientId;
  num? amount;
  Map<String, ProductQuantityObject>? quantities;
}

class ProductQuantityObject {
  String? id;
  String? quantityId;
  num? amount;
  num? additionalPrice;
  num? additionalCost;
}
```

---

### **StockObject**
```dart
class IngredientObject {
  String? id;
  String? name;
  num? currentAmount;
  num? lastAmount;
  int? lastAddedAt;
  int? updatedAt;
  num? totalAmount;
  num? restockQuantity;
}

class QuantityObject {
  String? id;
  String? name;
  num? defaultProportion;
}

class ReplenishmentObject {
  String? id;
  String? name;
  Map<String, num>? data;
  int? createdAt;
}
```

---

### **OrderObject**
```dart
class OrderObject {
  int? id;
  num? price;
  num? cost;
  num? productsPrice;
  num? paid;
  int? createdAt;
  String? encodedProducts;
  Map<String, String>? attributes;
  String? note;
}

class OrderAttributeObject {
  String? id;
  String? name;
  int? index;
  String? defaultOption;
  String? mode;
  Map<String, OrderAttributeOptionObject>? options;
}

class OrderAttributeOptionObject {
  String? id;
  String? name;
  int? index;
  num? modeValue;
  bool? isDefault;
}
```

---

### **CashierObject**
```dart
class CashierObject {
  Map<String, num>? units;
  List<CashierChangeBatchObject>? batches;
}

class CashierUnitObject {
  int? unit;
  num? count;
}

class CashierChangeBatchObject {
  String? id;
  String? name;
  Map<String, num>? data;
}
```

---

## 🗄️ Database Schema

### **Tables Structure**

#### **orders**
```sql
CREATE TABLE orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  price REAL NOT NULL,
  cost REAL,
  productsPrice REAL,
  paid REAL,
  createdAt INTEGER NOT NULL,
  encodedProducts TEXT,
  attributes TEXT,
  note TEXT
);
```

#### **menu**
```sql
-- Stored as key-value with repository pattern
-- Key: catalog.{catalogId}
-- Value: JSON of CatalogObject
```

#### **stock**
```sql
-- Key: ingredient.{ingredientId}
-- Value: JSON of IngredientObject
```

#### **quantities**
```sql
-- Key: quantity.{quantityId}
-- Value: JSON of QuantityObject
```

#### **order_attributes**
```sql
-- Key: order_attr.{attributeId}
-- Value: JSON of OrderAttributeObject
```

---

## 🔑 Key Design Patterns

### **1. Repository Pattern**
- Centralized data access
- Consistent CRUD operations
- Change notification
- Storage abstraction

### **2. Model-Object Pattern**
- Domain models for business logic
- DTOs for data transfer
- Separation of concerns
- Clean serialization

### **3. Provider Pattern**
- Reactive state management
- UI auto-updates
- Scoped dependencies
- Lifecycle management

### **4. Offline-First**
- Local SQLite storage
- No network dependency
- Data persistence
- Export/import for sync

---

## 📱 Platform Support

- ✅ Android (Google Play)
- ✅ iOS (In Development)
- ✅ Web (Chrome, Safari, Firefox)
- ✅ macOS (Desktop)
- ✅ Windows (Desktop)
- ✅ Linux (Desktop)

---

## 🔐 Security Features

- ✅ Local data storage only
- ✅ No cloud data transmission
- ✅ Privacy-focused design
- ✅ Complete audit trail
- ✅ Transaction integrity

---

## 📈 Performance Features

- ✅ Lazy loading
- ✅ Efficient queries
- ✅ Memory optimization
- ✅ 24/7 operation support
- ✅ Minimal resource usage

---

## 🎨 UI/UX Features

- ✅ Material Design 3
- ✅ Touch-optimized
- ✅ Responsive layouts
- ✅ Dark/light themes
- ✅ Accessibility support
- ✅ Multi-language
- ✅ RTL support

---

## 📚 Additional Resources

### **Documentation Files**
- `README.md` - Project overview
- `FEATURE_OVERVIEW.md` - Detailed features
- `PRD-pos.md` - Product requirements

### **Key Directories**
- `lib/models/` - All data models
- `lib/ui/` - UI components
- `lib/services/` - Core services
- `lib/settings/` - Configuration
- `test/` - Test suites

---

## 🏁 Conclusion

This POS system is a comprehensive, production-ready application built with Flutter, featuring:

- **Complete offline functionality** - Works without internet
- **Privacy-first design** - All data stays local
- **Rich feature set** - Everything a small business needs
- **Cross-platform** - Runs on all major platforms
- **Well-architected** - Clean, maintainable code
- **Extensible** - Easy to customize and enhance

The system successfully implements a full-featured POS solution suitable for restaurants, retail stores, and small businesses, with excellent support for inventory management, sales tracking, cash handling, and analytics.

---

**End of Documentation**



