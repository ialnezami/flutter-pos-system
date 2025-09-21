import 'package:flutter/material.dart';
import 'package:possystem/models/clothing/clothing_product.dart';
import 'package:possystem/models/clothing/product_variant.dart';
import 'package:possystem/ui/clothing/size_color_selector.dart';
import 'package:possystem/l10n/clothing_localizations.dart';

class ProductVariantCard extends StatefulWidget {
  final ClothingProduct product;
  final Function(ClothingProduct, ProductVariant?) onAddToCart;
  final bool showFullDetails;
  final bool isCompact;

  const ProductVariantCard({
    Key? key,
    required this.product,
    required this.onAddToCart,
    this.showFullDetails = true,
    this.isCompact = false,
  }) : super(key: key);

  @override
  State<ProductVariantCard> createState() => _ProductVariantCardState();
}

class _ProductVariantCardState extends State<ProductVariantCard> {
  ProductVariant? _selectedVariant;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isCompact) {
      return _buildCompactCard();
    }
    
    return _buildFullCard();
  }

  Widget _buildCompactCard() {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showVariantSelectionDialog(),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product Image
              _buildProductImage(size: 60),
              const SizedBox(width: 12),
              
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.product.brand,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildPriceRange(),
                  ],
                ),
              ),
              
              // Stock Status
              _buildStockStatus(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullCard() {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Header
          _buildProductHeader(),
          
          // Product Details
          if (widget.showFullDetails) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductInfo(),
                  const SizedBox(height: 16),
                  
                  // Variant Selection
                  SizeColorSelector(
                    product: widget.product,
                    selectedVariant: _selectedVariant,
                    onVariantSelected: (variant) {
                      setState(() {
                        _selectedVariant = variant;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                ],
              ),
            ),
          ] else ...[
            // Collapsed view with quick actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildQuickInfo(),
                  const SizedBox(height: 12),
                  _buildQuickActions(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductHeader() {
    return Container(
      height: 200,
      child: Stack(
        children: [
          // Product Image
          Container(
            width: double.infinity,
            height: 200,
            child: _buildProductImage(),
          ),
          
          // Overlay with product basic info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        widget.product.brand,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const Spacer(),
                      _buildCategoryChip(),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Collection badge (if applicable)
          if (widget.product.collection != null)
            Positioned(
              top: 8,
              right: 8,
              child: _buildCollectionBadge(),
            ),
        ],
      ),
    );
  }

  Widget _buildProductImage({double? size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: size != null ? BorderRadius.circular(8) : null,
        image: widget.product.imagePath != null
            ? DecorationImage(
                image: NetworkImage(widget.product.imagePath!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: widget.product.imagePath == null
          ? Icon(
              Icons.checkroom,
              size: size != null ? size * 0.4 : 80,
              color: Colors.grey[400],
            )
          : null,
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price Range
        _buildPriceRange(),
        const SizedBox(height: 8),
        
        // Product Attributes
        if (widget.product.material != null) ...[
          _buildInfoRow('Material', widget.product.material!),
          const SizedBox(height: 4),
        ],
        
        if (widget.product.careInstructions != null) ...[
          _buildInfoRow('Care', widget.product.careInstructions!),
          const SizedBox(height: 4),
        ],
        
        _buildInfoRow('Season', widget.product.season),
        const SizedBox(height: 4),
        _buildInfoRow('Gender', widget.product.gender.displayName),
        
        // Tags
        if (widget.product.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: widget.product.tags.take(3).map((tag) => Chip(
              label: Text(
                tag,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            )).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
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
    );
  }

  Widget _buildPriceRange() {
    final minPrice = widget.product.minPrice;
    final maxPrice = widget.product.maxPrice;
    
    String priceText;
    if (minPrice == maxPrice) {
      priceText = '\$${minPrice.toStringAsFixed(2)}';
    } else {
      priceText = '\$${minPrice.toStringAsFixed(2)} - \$${maxPrice.toStringAsFixed(2)}';
    }
    
    return Text(
      priceText,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        widget.product.category.displayName,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCollectionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        widget.product.collection!,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStockStatus() {
    final totalStock = widget.product.totalStock;
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (totalStock <= 0) {
      statusColor = Colors.red;
      statusText = 'Out of Stock';
      statusIcon = Icons.error;
    } else if (totalStock <= 10) {
      statusColor = Colors.orange;
      statusText = 'Low Stock';
      statusIcon = Icons.warning;
    } else {
      statusColor = Colors.green;
      statusText = 'In Stock';
      statusIcon = Icons.check_circle;
    }

    return Column(
      children: [
        Icon(statusIcon, color: statusColor, size: 20),
        const SizedBox(height: 2),
        Text(
          statusText,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickInfo() {
    return Row(
      children: [
        Expanded(child: _buildPriceRange()),
        _buildStockStatus(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showVariantSelectionDialog(),
            icon: const Icon(Icons.visibility),
            label: const Text('View Details'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _selectedVariant != null && _selectedVariant!.isAvailable
                ? () => widget.onAddToCart(widget.product, _selectedVariant)
                : null,
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Add to Cart'),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showVariantSelectionDialog(),
            child: const Text('Select Variant'),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _showVariantSelectionDialog(),
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }

  void _showVariantSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => ProductVariantSelectionDialog(
        product: widget.product,
        onVariantSelected: (variant) {
          if (variant != null) {
            widget.onAddToCart(widget.product, variant);
          }
        },
      ),
    );
  }
}

class ProductVariantSelectionDialog extends StatefulWidget {
  final ClothingProduct product;
  final Function(ProductVariant?) onVariantSelected;

  const ProductVariantSelectionDialog({
    Key? key,
    required this.product,
    required this.onVariantSelected,
  }) : super(key: key);

  @override
  State<ProductVariantSelectionDialog> createState() => _ProductVariantSelectionDialogState();
}

class _ProductVariantSelectionDialogState extends State<ProductVariantSelectionDialog> {
  ProductVariant? _selectedVariant;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        maxWidth: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.product.brand,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Variant Selection
                    SizeColorSelector(
                      product: widget.product,
                      selectedVariant: _selectedVariant,
                      onVariantSelected: (variant) {
                        setState(() {
                          _selectedVariant = variant;
                        });
                      },
                    ),
                    
                    // Quantity Selection
                    if (_selectedVariant != null) ...[
                      const SizedBox(height: 16),
                      _buildQuantitySelector(),
                    ],
                  ],
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedVariant != null && _selectedVariant!.isAvailable
                          ? () {
                              widget.onVariantSelected(_selectedVariant);
                              Navigator.of(context).pop();
                            }
                          : null,
                      child: Text('Add $_quantity to Cart'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    final maxQuantity = _selectedVariant!.stockQuantity.clamp(1, 10);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
              icon: const Icon(Icons.remove),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _quantity.toString(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              onPressed: _quantity < maxQuantity ? () => setState(() => _quantity++) : null,
              icon: const Icon(Icons.add),
            ),
            const Spacer(),
            Text(
              '${_selectedVariant!.stockQuantity} available',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
