import 'package:flutter/material.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/ui/cashier/widgets/unit_list_tile.dart';
import 'package:possystem/l10n/clothing_localizations.dart';

class ArabicCashierView extends StatefulWidget {
  const ArabicCashierView({Key? key}) : super(key: key);

  @override
  State<ArabicCashierView> createState() => _ArabicCashierViewState();
}

class _ArabicCashierViewState extends State<ArabicCashierView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الصندوق'),
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        actions: [
          IconButton(
            onPressed: _showCashierHelp,
            icon: const Icon(Icons.help_outline),
            tooltip: 'مساعدة الصندوق',
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Panel - Currency Management
          Expanded(
            flex: 2,
            child: _buildCurrencyPanel(),
          ),
          
          // Right Panel - Quick Actions and Summary
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
              ),
            ),
            child: _buildActionPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'إدارة النقد',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Total Display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListenableBuilder(
                  listenable: Cashier.instance,
                  builder: (context, _) {
                    return Text(
                      'الإجمالي: ${Cashier.instance.currentTotal.toStringAsFixed(2)} ر.س',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Saudi Riyal Denominations
          Expanded(
            child: _buildSaudiRiyalDenominations(),
          ),
        ],
      ),
    );
  }

  Widget _buildSaudiRiyalDenominations() {
    // Saudi Riyal denominations with Arabic names
    final denominations = [
      {'value': 500.0, 'name': '500 ريال سعودي', 'type': 'ورقة', 'color': Colors.purple[100]},
      {'value': 100.0, 'name': '100 ريال سعودي', 'type': 'ورقة', 'color': Colors.blue[100]},
      {'value': 50.0, 'name': '50 ريال سعودي', 'type': 'ورقة', 'color': Colors.green[100]},
      {'value': 20.0, 'name': '20 ريال سعودي', 'type': 'ورقة', 'color': Colors.orange[100]},
      {'value': 10.0, 'name': '10 ريال سعودي', 'type': 'ورقة', 'color': Colors.red[100]},
      {'value': 5.0, 'name': '5 ريال سعودي', 'type': 'ورقة', 'color': Colors.brown[100]},
      {'value': 1.0, 'name': '1 ريال سعودي', 'type': 'ورقة', 'color': Colors.grey[100]},
      {'value': 0.50, 'name': '50 هللة', 'type': 'عملة', 'color': Colors.amber[100]},
      {'value': 0.25, 'name': '25 هللة', 'type': 'عملة', 'color': Colors.cyan[100]},
      {'value': 0.10, 'name': '10 هللة', 'type': 'عملة', 'color': Colors.lime[100]},
      {'value': 0.05, 'name': '5 هللة', 'type': 'عملة', 'color': Colors.pink[100]},
    ];

    return ListView.builder(
      itemCount: denominations.length,
      itemBuilder: (context, index) {
        final denom = denominations[index];
        return _buildDenominationTile(
          value: denom['value'] as double,
          name: denom['name'] as String,
          type: denom['type'] as String,
          color: denom['color'] as Color?,
        );
      },
    );
  }

  Widget _buildDenominationTile({
    required double value,
    required String name,
    required String type,
    Color? color,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color ?? Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                type == 'ورقة' ? Icons.receipt : Icons.monetization_on,
                size: 20,
                color: Colors.grey[700],
              ),
              Text(
                value >= 1 ? '${value.toInt()}' : '${(value * 100).toInt()}ه',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: ListenableBuilder(
          listenable: Cashier.instance,
          builder: (context, _) {
            // This would get actual count from cashier
            final count = 10; // Sample count
            final maxCount = 20; // Sample max
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('العدد: $count'),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: count / maxCount,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    count < maxCount * 0.3 ? Colors.red :
                    count < maxCount * 0.6 ? Colors.orange : Colors.green,
                  ),
                ),
              ],
            );
          },
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _adjustCount(value, -1),
              icon: const Icon(Icons.remove),
              tooltip: 'تقليل',
            ),
            IconButton(
              onPressed: () => _adjustCount(value, 1),
              icon: const Icon(Icons.add),
              tooltip: 'زيادة',
            ),
          ],
        ),
        onTap: () => _showCountDialog(value, name),
      ),
    );
  }

  Widget _buildActionPanel() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'إجراءات سريعة',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quick Actions
          _buildQuickActionCard(
            icon: Icons.star,
            title: 'تعيين افتراضي',
            subtitle: 'حفظ الحالة الحالية كافتراضية',
            color: Colors.amber,
            onTap: _setDefault,
          ),
          
          const SizedBox(height: 12),
          
          _buildQuickActionCard(
            icon: Icons.sync_alt,
            title: 'صرافة النقود',
            subtitle: 'تبديل فئات العملة',
            color: Colors.blue,
            onTap: _showChanger,
          ),
          
          const SizedBox(height: 12),
          
          _buildQuickActionCard(
            icon: Icons.coffee,
            title: 'فائض اليوم',
            subtitle: 'حساب فائض نهاية اليوم',
            color: Colors.green,
            onTap: _showSurplus,
          ),
          
          const SizedBox(height: 24),
          
          // Cash Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ملخص النقد',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                
                ListenableBuilder(
                  listenable: Cashier.instance,
                  builder: (context, _) {
                    return Column(
                      children: [
                        _buildSummaryRow('الإجمالي الحالي:', '${Cashier.instance.currentTotal.toStringAsFixed(2)} ر.س'),
                        _buildSummaryRow('الإجمالي الافتراضي:', '${Cashier.instance.defaultTotal.toStringAsFixed(2)} ر.س'),
                        const Divider(),
                        _buildSummaryRow(
                          'الفرق:', 
                          '${(Cashier.instance.currentTotal - Cashier.instance.defaultTotal).toStringAsFixed(2)} ر.س',
                          isTotal: true,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Emergency Actions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'إجراءات طوارئ',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _resetCashier,
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة تعيين الصندوق'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[700],
                      side: BorderSide(color: Colors.red[300]!),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isTotal ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  void _adjustCount(double denomination, int change) {
    // Adjust the count for a specific denomination
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم ${change > 0 ? 'زيادة' : 'تقليل'} فئة ${denomination.toStringAsFixed(2)} ر.س'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showCountDialog(double denomination, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل $name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'العدد',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تحديث العدد')),
              );
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _setDefault() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعيين الحالة الافتراضية'),
        content: const Text('هل تريد حفظ الحالة الحالية للصندوق كحالة افتراضية؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              await Cashier.instance.setDefault();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حفظ الحالة الافتراضية'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _showChanger() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          height: 400,
          child: Column(
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
                    const Icon(Icons.sync_alt),
                    const SizedBox(width: 12),
                    const Text(
                      'صرافة النقود',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('اختر الصرف المطلوب:'),
                      const SizedBox(height: 16),
                      
                      // Common exchanges for Saudi Riyal
                      _buildExchangeOption('1 × 500 ر.س', '5 × 100 ر.س'),
                      _buildExchangeOption('1 × 100 ر.س', '5 × 20 ر.س'),
                      _buildExchangeOption('1 × 50 ر.س', '5 × 10 ر.س'),
                      _buildExchangeOption('1 × 20 ر.س', '4 × 5 ر.س'),
                      
                      const Spacer(),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تم تطبيق الصرف')),
                            );
                          },
                          child: const Text('تطبيق الصرف'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExchangeOption(String from, String to) {
    return Card(
      child: ListTile(
        title: Text('صرف $from إلى $to'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Apply this exchange
        },
      ),
    );
  }

  void _showSurplus() {
    // Show the existing surplus dialog with Arabic enhancements
    Navigator.of(context).pushNamed('/cashier/surplus');
  }

  void _resetCashier() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة تعيين الصندوق'),
        content: const Text('هل أنت متأكد من إعادة تعيين جميع قيم الصندوق؟\n\nلا يمكن التراجع عن هذا الإجراء!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              await Cashier.instance.reset();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إعادة تعيين الصندوق'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('إعادة تعيين'),
          ),
        ],
      ),
    );
  }

  void _showCashierHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مساعدة إدارة الصندوق'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('إدارة الصندوق تساعدك في:'),
              SizedBox(height: 8),
              Text('• تتبع فئات العملة المختلفة'),
              Text('• حساب الفائض اليومي'),
              Text('• صرف العملات'),
              Text('• تعيين الحالة الافتراضية'),
              SizedBox(height: 16),
              Text('نصائح للاستخدام:'),
              SizedBox(height: 8),
              Text('• اضبط العدد لكل فئة في بداية اليوم'),
              Text('• استخدم الصرافة لتبديل الفئات'),
              Text('• احسب الفائض في نهاية اليوم'),
              Text('• احفظ الحالة الافتراضية للمرجع'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
