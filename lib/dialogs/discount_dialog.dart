import 'package:flutter/material.dart';

class DiscountDialog extends StatefulWidget {
  final Function(double, String) onApplyDiscount;
  final double currentDiscount;
  final String currentDiscountType;

  const DiscountDialog({
    super.key,
    required this.onApplyDiscount,
    required this.currentDiscount,
    required this.currentDiscountType,
  });

  @override
  State<DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<DiscountDialog> {
  late TextEditingController _discountController;
  late String _discountType;

  @override
  void initState() {
    super.initState();
    _discountController = TextEditingController(
      text: widget.currentDiscount > 0 ? widget.currentDiscount.toString() : '',
    );
    _discountType = widget.currentDiscountType;
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.local_offer, color: Colors.orange),
          SizedBox(width: 8),
          Text('إضافة خصم'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'percentage',
                label: Text('نسبة %'),
                icon: Icon(Icons.percent),
              ),
              ButtonSegment(
                value: 'fixed',
                label: Text('مبلغ ثابت'),
                icon: Icon(Icons.money),
              ),
            ],
            selected: {_discountType},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _discountType = newSelection.first;
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _discountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: _discountType == 'percentage' ? 'نسبة الخصم (%)' : 'مبلغ الخصم (ر.س)',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(
                _discountType == 'percentage' ? Icons.percent : Icons.money,
              ),
            ),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        if (widget.currentDiscount > 0)
          TextButton(
            onPressed: () {
              widget.onApplyDiscount(0.0, 'percentage');
              Navigator.pop(context);
            },
            child: const Text('إزالة الخصم', style: TextStyle(color: Colors.red)),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            final discount = double.tryParse(_discountController.text) ?? 0.0;
            widget.onApplyDiscount(discount, _discountType);
            Navigator.pop(context);
          },
          child: const Text('تطبيق'),
        ),
      ],
    );
  }
}

