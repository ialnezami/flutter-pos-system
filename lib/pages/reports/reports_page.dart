import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  final int productsCount;
  final String salesToday;
  final String totalTransactions;
  final String dateFilter;
  final Future<List<Map<String, dynamic>>> Function() getFilteredSales;
  final Function(String) onDateFilterChanged;
  final VoidCallback onRefresh;
  final VoidCallback onShowExportDialog;
  final Function(Map<String, dynamic>) onShowSaleDetails;

  const ReportsPage({
    super.key,
    required this.productsCount,
    required this.salesToday,
    required this.totalTransactions,
    required this.dateFilter,
    required this.getFilteredSales,
    required this.onDateFilterChanged,
    required this.onRefresh,
    required this.onShowExportDialog,
    required this.onShowSaleDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context),
          const SizedBox(height: 16),
          
          // Statistics Cards
          _buildStatisticsCards(),
          const SizedBox(height: 24),
          
          // Sales History Section
          _buildSalesHistorySection(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'التقارير والإحصائيات',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        ElevatedButton.icon(
          onPressed: onShowExportDialog,
          icon: const Icon(Icons.file_download),
          label: const Text('تصدير CSV'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('إجمالي المنتجات', '$productsCount', Icons.inventory, Colors.blue)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('المبيعات اليوم', salesToday, Icons.trending_up, Colors.green)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('إجمالي العمليات', totalTransactions, Icons.receipt, Colors.orange)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesHistorySection(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'سجل المبيعات',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('تحديث'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Date Filter Buttons
          _buildDateFilter(),
          const SizedBox(height: 16),
          
          // Sales History List
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: getFilteredSales(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Text('خطأ في تحميل السجل: ${snapshot.error}'),
                  );
                }
                
                final sales = snapshot.data ?? [];
                
                if (sales.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد عمليات بيع بعد',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: sales.length,
                  itemBuilder: (context, index) => _buildSaleItem(sales[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.blue, size: 20),
            const SizedBox(width: 12),
            const Text('تصفية حسب:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
            _buildFilterChip('الكل', 'all'),
            const SizedBox(width: 8),
            _buildFilterChip('اليوم', 'today'),
            const SizedBox(width: 8),
            _buildFilterChip('هذا الشهر', 'month'),
            const SizedBox(width: 8),
            _buildFilterChip('3 أشهر', 'quarter'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = dateFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => onDateFilterChanged(value),
      selectedColor: Colors.blue[300],
      backgroundColor: Colors.white,
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildSaleItem(Map<String, dynamic> sale) {
    final saleDate = DateTime.parse(sale['sale_date'] as String);
    final totalAmount = (sale['total_amount'] as num).toDouble();
    final profitAmount = (sale['profit_amount'] as num).toDouble();
    final paymentMethod = sale['payment_method'] as String;
    final discountAmount = sale['discount_amount'] != null ? (sale['discount_amount'] as num).toDouble() : 0.0;
    final subtotal = sale['subtotal'] != null ? (sale['subtotal'] as num).toDouble() : totalAmount;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Icon(
            paymentMethod == 'cash' ? Icons.money : Icons.credit_card,
            color: Colors.green[700],
          ),
        ),
        title: Row(
          children: [
            Text(
              'فاتورة #${sale['id']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: paymentMethod == 'cash' ? Colors.blue[50] : Colors.purple[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                paymentMethod == 'cash' ? 'نقدي' : 'بطاقة',
                style: TextStyle(
                  fontSize: 12,
                  color: paymentMethod == 'cash' ? Colors.blue[700] : Colors.purple[700],
                ),
              ),
            ),
            if (discountAmount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.discount, size: 12, color: Colors.orange[700]),
                    const SizedBox(width: 4),
                    Text(
                      'خصم',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${saleDate.day}/${saleDate.month}/${saleDate.year} - ${saleDate.hour}:${saleDate.minute.toString().padLeft(2, '0')}',
            ),
            Text(
              'الكاشير: ${sale['cashier_name']}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (discountAmount > 0)
              Text(
                'خصم: ${discountAmount.toStringAsFixed(2)} ر.س',
                style: TextStyle(fontSize: 12, color: Colors.orange[700], fontWeight: FontWeight.bold),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (discountAmount > 0) ...[
              Text(
                '${subtotal.toStringAsFixed(2)} ر.س',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
            Text(
              '${totalAmount.toStringAsFixed(2)} ر.س',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Text(
              'ربح: ${profitAmount.toStringAsFixed(2)} ر.س',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        onTap: () => onShowSaleDetails(sale),
      ),
    );
  }
}

