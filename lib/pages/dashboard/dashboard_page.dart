import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  final String currentUser;
  final int productsCount;
  final VoidCallback onNavigateToCashier;
  final VoidCallback onNavigateToProductManagement;
  final VoidCallback onNavigateToReports;
  final VoidCallback onShowAddProductDialog;

  const DashboardPage({
    super.key,
    required this.currentUser,
    required this.productsCount,
    required this.onNavigateToCashier,
    required this.onNavigateToProductManagement,
    required this.onNavigateToReports,
    required this.onShowAddProductDialog,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مرحباً $currentUser',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Quick Action Cards
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'واجهة الكاشير',
                  'بدء عملية بيع جديدة',
                  Icons.point_of_sale,
                  Colors.green,
                  onNavigateToCashier,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  'إدارة المنتجات',
                  'إضافة وتعديل المنتجات',
                  Icons.inventory,
                  Colors.blue,
                  onNavigateToProductManagement,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'إضافة منتج جديد',
                  'إضافة منتج للمخزون',
                  Icons.add_circle,
                  Colors.orange,
                  onShowAddProductDialog,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  'التقارير والإحصائيات',
                  'عرض تقارير المبيعات',
                  Icons.analytics,
                  Colors.purple,
                  onNavigateToReports,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          Text(
            'إحصائيات سريعة',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard('المنتجات', '$productsCount+', Icons.inventory, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('الفئات', '8', Icons.category, Colors.green)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('المبيعات اليوم', '0 ر.س', Icons.trending_up, Colors.orange)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
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
}

