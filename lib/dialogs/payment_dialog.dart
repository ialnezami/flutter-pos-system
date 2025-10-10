import 'package:flutter/material.dart';

class PaymentDialog extends StatefulWidget {
  final double finalTotal;
  final Function(double paidAmount, String paymentMethod) onComplete;

  const PaymentDialog({
    super.key,
    required this.finalTotal,
    required this.onComplete,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  String _paymentMethod = 'cash';
  final TextEditingController _paidAmountController = TextEditingController();
  double _changeAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _paidAmountController.text = widget.finalTotal.toStringAsFixed(2);
    _paidAmountController.addListener(_calculateChange);
  }

  @override
  void dispose() {
    _paidAmountController.dispose();
    super.dispose();
  }

  void _calculateChange() {
    final paidAmount = double.tryParse(_paidAmountController.text) ?? 0.0;
    setState(() {
      _changeAmount = paidAmount - widget.finalTotal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.payment, color: Colors.blue),
          SizedBox(width: 8),
          Text('إتمام الدفع'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment method selection
            const Text('طريقة الدفع:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'cash',
                  label: Text('نقدي'),
                  icon: Icon(Icons.money),
                ),
                ButtonSegment(
                  value: 'card',
                  label: Text('بطاقة'),
                  icon: Icon(Icons.credit_card),
                ),
              ],
              selected: {_paymentMethod},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _paymentMethod = newSelection.first;
                  if (_paymentMethod == 'card') {
                    _paidAmountController.text = widget.finalTotal.toStringAsFixed(2);
                  }
                });
              },
            ),
            const SizedBox(height: 24),
            
            // Total amount
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('المبلغ الإجمالي:', style: TextStyle(fontSize: 16)),
                  Text(
                    '${widget.finalTotal.toStringAsFixed(2)} ر.س',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Paid amount (only for cash)
            if (_paymentMethod == 'cash') ...[
              TextField(
                controller: _paidAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'المبلغ المدفوع',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                  suffixText: 'ر.س',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              
              // Change amount
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _changeAmount < 0 ? Colors.red[50] : Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _changeAmount < 0 ? Colors.red : Colors.green,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _changeAmount < 0 ? 'المبلغ غير كافٍ:' : 'الباقي:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _changeAmount < 0 ? Colors.red : Colors.green,
                      ),
                    ),
                    Text(
                      '${_changeAmount.abs().toStringAsFixed(2)} ر.س',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _changeAmount < 0 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            if (_paymentMethod == 'cash' && _changeAmount < 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('المبلغ المدفوع غير كافٍ!'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            
            final paidAmount = _paymentMethod == 'cash'
                ? double.tryParse(_paidAmountController.text) ?? widget.finalTotal
                : widget.finalTotal;
            
            widget.onComplete(paidAmount, _paymentMethod);
          },
          icon: const Icon(Icons.print),
          label: const Text('دفع وطباعة'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

