class ClothingProduct {
  final String name;
  final String category;
  final double price;
  final String size;
  final String color;
  
  ClothingProduct({
    required this.name,
    required this.category,
    required this.price,
    required this.size,
    required this.color,
  });
}

class CartItem {
  final ClothingProduct product;
  int quantity;
  double discount; // Discount amount for this item
  
  CartItem({
    required this.product,
    this.quantity = 1,
    this.discount = 0.0,
  });
  
  double get subtotal => product.price * quantity;
  double get total => subtotal - discount;
}

