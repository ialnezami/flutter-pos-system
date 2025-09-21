import 'package:flutter/material.dart';
import 'package:possystem/models/clothing/clothing_product.dart';
import 'package:possystem/models/clothing/product_variant.dart';
import 'package:possystem/models/clothing/color.dart';
import 'package:possystem/l10n/clothing_localizations.dart';

class SizeColorSelector extends StatefulWidget {
  final ClothingProduct product;
  final ProductVariant? selectedVariant;
  final Function(ProductVariant?) onVariantSelected;
  final bool showPriceAdjustment;
  final bool showStockInfo;

  const SizeColorSelector({
    Key? key,
    required this.product,
    this.selectedVariant,
    required this.onVariantSelected,
    this.showPriceAdjustment = true,
    this.showStockInfo = true,
  }) : super(key: key);

  @override
  State<SizeColorSelector> createState() => _SizeColorSelectorState();
}

class _SizeColorSelectorState extends State<SizeColorSelector> {
  String? _selectedSize;
  String? _selectedColor;
  ProductVariant? _selectedVariant;

  @override
  void initState() {
    super.initState();
    if (widget.selectedVariant != null) {
      _selectedSize = widget.selectedVariant!.size;
      _selectedColor = widget.selectedVariant!.color;
      _selectedVariant = widget.selectedVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Size Selection
        _buildSizeSection(),
        const SizedBox(height: 16),
        
        // Color Selection
        _buildColorSection(),
        
        // Stock and Price Info
        if (_selectedVariant != null) ...[
          const SizedBox(height: 16),
          _buildVariantInfo(),
        ],
      ],
    );
  }

  Widget _buildSizeSection() {
    final availableSizes = widget.product.availableSizes.toList()
      ..sort(); // Sort sizes alphabetically

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.clothingL10n.selectSize,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableSizes.map((size) {
            final isSelected = _selectedSize == size;
            final hasStock = widget.product.getVariantsBySize(size)
                .any((v) => v.stockQuantity > 0);
            
            return _SizeChip(
              size: size,
              isSelected: isSelected,
              hasStock: hasStock,
              onSelected: hasStock ? () => _onSizeSelected(size) : null,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSection() {
    if (_selectedSize == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Color',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.clothingL10n.selectSizeFirst,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      );
    }

    final availableColors = widget.product.getVariantsBySize(_selectedSize!)
        .where((v) => v.stockQuantity > 0)
        .map((v) => v.color)
        .toSet()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.clothingL10n.selectColor,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableColors.map((color) {
            final isSelected = _selectedColor == color;
            final variant = widget.product.getVariant(_selectedSize!, color);
            
            return _ColorChip(
              color: color,
              isSelected: isSelected,
              stockQuantity: variant?.stockQuantity ?? 0,
              onSelected: () => _onColorSelected(color),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVariantInfo() {
    if (_selectedVariant == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SKU and Stock Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SKU: ${_selectedVariant!.sku}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.showStockInfo)
                _StockIndicator(variant: _selectedVariant!),
            ],
          ),
          
          // Price Information
          if (widget.showPriceAdjustment && _selectedVariant!.priceAdjustment != 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Base Price:',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '\$${widget.product.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Variant Price:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '\$${widget.product.getVariantPrice(_selectedVariant!.id).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _selectedVariant!.priceAdjustment > 0 
                        ? Colors.red[700] 
                        : Colors.green[700],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _onSizeSelected(String size) {
    setState(() {
      _selectedSize = size;
      _selectedColor = null;
      _selectedVariant = null;
    });
    widget.onVariantSelected(null);
  }

  void _onColorSelected(String color) {
    setState(() {
      _selectedColor = color;
      try {
        _selectedVariant = widget.product.getVariant(_selectedSize!, color);
      } catch (e) {
        _selectedVariant = null;
      }
    });
    widget.onVariantSelected(_selectedVariant);
  }
}

class _SizeChip extends StatelessWidget {
  final String size;
  final bool isSelected;
  final bool hasStock;
  final VoidCallback? onSelected;

  const _SizeChip({
    required this.size,
    required this.isSelected,
    required this.hasStock,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : hasStock
                  ? Theme.of(context).colorScheme.surface
                  : Colors.grey[200],
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : hasStock
                    ? Theme.of(context).colorScheme.outline
                    : Colors.grey[400]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          size,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : hasStock
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  final String color;
  final bool isSelected;
  final int stockQuantity;
  final VoidCallback onSelected;

  const _ColorChip({
    required this.color,
    required this.isSelected,
    required this.stockQuantity,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Try to get color from standard colors or use a default
    Color? colorValue;
    try {
      final standardColors = StandardColors.getStandardColors();
      final standardColor = standardColors.firstWhere(
        (c) => c.name.toLowerCase() == color.toLowerCase(),
        orElse: () => throw StateError('Color not found'),
      );
      colorValue = standardColor.color;
    } catch (e) {
      // Default colors for common color names
      final colorMap = {
        'black': Colors.black,
        'white': Colors.white,
        'red': Colors.red,
        'blue': Colors.blue,
        'green': Colors.green,
        'yellow': Colors.yellow,
        'purple': Colors.purple,
        'orange': Colors.orange,
        'pink': Colors.pink,
        'brown': Colors.brown,
        'gray': Colors.grey,
        'grey': Colors.grey,
      };
      colorValue = colorMap[color.toLowerCase()] ?? Colors.grey;
    }

    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: colorValue,
                shape: BoxShape.circle,
                border: colorValue == Colors.white
                    ? Border.all(color: Colors.grey[300]!)
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              color,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (stockQuantity <= 5 && stockQuantity > 0) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.warning_amber_rounded,
                size: 14,
                color: Colors.orange[700],
              ),
            ],
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

class _StockIndicator extends StatelessWidget {
  final ProductVariant variant;

  const _StockIndicator({required this.variant});

  @override
  Widget build(BuildContext context) {
    final stockStatus = variant.stockStatus;
    Color indicatorColor;
    IconData icon;

    switch (stockStatus) {
      case 'In Stock':
        indicatorColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'Low Stock':
        indicatorColor = Colors.orange;
        icon = Icons.warning;
        break;
      case 'Out of Stock':
        indicatorColor = Colors.red;
        icon = Icons.error;
        break;
      default:
        indicatorColor = Colors.grey;
        icon = Icons.info;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: indicatorColor,
        ),
        const SizedBox(width: 4),
            Text(
              context.clothingL10n.stockLeft(variant.stockQuantity),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: indicatorColor,
                fontWeight: FontWeight.w500,
              ),
            ),
      ],
    );
  }
}

// Quick size filter for common sizes
class QuickSizeFilter extends StatelessWidget {
  final List<String> commonSizes;
  final String? selectedSize;
  final Function(String?) onSizeSelected;

  const QuickSizeFilter({
    Key? key,
    required this.commonSizes,
    this.selectedSize,
    required this.onSizeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: commonSizes.length + 1, // +1 for "All" option
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildFilterChip(context, 'All', selectedSize == null);
          }
          
          final size = commonSizes[index - 1];
          return _buildFilterChip(context, size, selectedSize == size);
        },
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          onSizeSelected(selected ? (label == 'All' ? null : label) : null);
        },
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
        checkmarkColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
