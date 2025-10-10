import 'package:flutter/material.dart';
import '../models/clothing_item.dart';

class ProductCard extends StatelessWidget {
  final ClothingProduct product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.checkroom, size: 40, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                product.category,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    product.size,
                    style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _getColorFromName(product.color),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${product.price.toStringAsFixed(2)} ر.س',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorFromName(String colorName) {
    final colorMap = {
      'أحمر': Colors.red,
      'أزرق': Colors.blue,
      'أخضر': Colors.green,
      'أصفر': Colors.yellow,
      'أسود': Colors.black,
      'أبيض': Colors.white,
      'بني': Colors.brown,
      'ذهبي': Colors.amber,
      'فضي': Colors.grey[400]!,
      'وردي': Colors.pink,
      'برتقالي': Colors.orange,
      'بنفسجي': Colors.purple,
      'رمادي': Colors.grey,
    };
    return colorMap[colorName] ?? Colors.grey;
  }
}

