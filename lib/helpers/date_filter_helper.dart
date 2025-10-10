class DateFilterHelper {
  static Future<List<Map<String, dynamic>>> filterSalesByDate(
    List<Map<String, dynamic>> allSales,
    String dateFilter,
  ) async {
    if (dateFilter == 'all') {
      return allSales;
    }
    
    final now = DateTime.now();
    DateTime startDate;
    
    switch (dateFilter) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'quarter':
        startDate = DateTime(now.year, now.month - 3, now.day);
        break;
      default:
        return allSales;
    }
    
    return allSales.where((sale) {
      final saleDate = DateTime.parse(sale['sale_date'] as String);
      return saleDate.isAfter(startDate) || saleDate.isAtSameMomentAs(startDate);
    }).toList();
  }
  
  static String getDateRangeText(String dateFilter) {
    final now = DateTime.now();
    
    switch (dateFilter) {
      case 'today':
        return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      case 'month':
        return 'من ${now.year}-${now.month.toString().padLeft(2, '0')}-01';
      case 'quarter':
        final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
        return 'من ${threeMonthsAgo.year}-${threeMonthsAgo.month.toString().padLeft(2, '0')}-${threeMonthsAgo.day.toString().padLeft(2, '0')}';
      default:
        return '';
    }
  }
  
  static String getFilterLabel(String dateFilter) {
    switch (dateFilter) {
      case 'all':
        return 'جميع';
      case 'today':
        return 'اليوم';
      case 'month':
        return 'هذا الشهر';
      case 'quarter':
        return '3 أشهر';
      default:
        return 'جميع';
    }
  }
}

