class CsvHelper {
  static String convertSalesToCSV(List<Map<String, dynamic>> sales) {
    if (sales.isEmpty) {
      return 'رقم الفاتورة,التاريخ,الكاشير,الإجمالي,التكلفة,الربح,المبلغ المدفوع,الباقي,طريقة الدفع,الخصم,الإجمالي قبل الخصم\n';
    }
    
    final header = 'رقم الفاتورة,التاريخ,الكاشير,الإجمالي,التكلفة,الربح,المبلغ المدفوع,الباقي,طريقة الدفع,الخصم,الإجمالي قبل الخصم\n';
    final rows = sales.map((sale) {
      final id = sale['id'];
      final date = sale['sale_date'];
      final cashier = sale['cashier_name'] ?? 'admin';
      final total = sale['total_amount'];
      final cost = sale['total_cost'] ?? 0;
      final profit = sale['profit_amount'] ?? 0;
      final paid = sale['paid_amount'] ?? total;
      final change = sale['change_amount'] ?? 0;
      final paymentMethod = sale['payment_method'] == 'cash' ? 'نقدي' : 'بطاقة';
      final discount = sale['discount_amount'] ?? 0;
      final subtotal = sale['subtotal'] ?? total;
      
      return '$id,$date,$cashier,$total,$cost,$profit,$paid,$change,$paymentMethod,$discount,$subtotal';
    }).join('\n');
    
    return header + rows;
  }
}

