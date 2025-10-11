import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onShowExportDialog;

  const SettingsPage({
    super.key,
    required this.onLogout,
    required this.onShowExportDialog,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإعدادات',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout),
                label: const Text('تسجيل الخروج'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildSettingCard(
                  'معلومات المتجر',
                  'اسم المتجر، العنوان، رقم الهاتف',
                  Icons.store,
                  () {},
                ),
                _buildSettingCard(
                  'إعدادات الطباعة',
                  'إعداد الطابعات وتنسيق الفواتير',
                  Icons.print,
                  () {},
                ),
                _buildSettingCard(
                  'إدارة المستخدمين',
                  'إضافة وإدارة المستخدمين والصلاحيات',
                  Icons.people,
                  () {},
                ),
                _buildSettingCard(
                  'النسخ الاحتياطي',
                  'نسخ احتياطي واستعادة البيانات',
                  Icons.backup,
                  () {},
                ),
                _buildSettingCard(
                  'تصدير البيانات',
                  'تصدير المنتجات والمبيعات',
                  Icons.file_download,
                  onShowExportDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_back_ios),
        onTap: onTap,
      ),
    );
  }
}

