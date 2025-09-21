import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const DebugPOSApp());
}

class DebugPOSApp extends StatelessWidget {
  const DebugPOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام نقاط البيع - تجريبي',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF448AFF),
        textTheme: const TextTheme().apply(
          fontFamily: 'NotoSansArabic',
        ),
      ),
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const DebugHomePage(),
    );
  }
}

class DebugHomePage extends StatefulWidget {
  const DebugHomePage({super.key});

  @override
  State<DebugHomePage> createState() => _DebugHomePageState();
}

class _DebugHomePageState extends State<DebugHomePage> {
  int _selectedIndex = 0;

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return _buildSalesPage();
      case 2:
        return _buildInventoryPage();
      case 3:
        return _buildStatisticsPage();
      case 4:
        return _buildSettingsPage();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home, size: 80, color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'الصفحة الرئيسية',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text('مرحباً بك في نظام نقاط البيع'),
        ],
      ),
    );
  }

  Widget _buildSalesPage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart, size: 80, color: Colors.green),
          SizedBox(height: 16),
          Text(
            'صفحة المبيعات',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text('إدارة المبيعات والفواتير'),
        ],
      ),
    );
  }

  Widget _buildInventoryPage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory, size: 80, color: Colors.orange),
          SizedBox(height: 16),
          Text(
            'صفحة المخزون',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text('إدارة المخزون والمنتجات'),
        ],
      ),
    );
  }

  Widget _buildStatisticsPage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 80, color: Colors.purple),
          SizedBox(height: 16),
          Text(
            'صفحة الإحصائيات',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text('التقارير والإحصائيات'),
        ],
      ),
    );
  }

  Widget _buildSettingsPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.settings, size: 80, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'صفحة الإعدادات',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text('إعدادات النظام والتصدير'),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم الوصول إلى الإعدادات بنجاح!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.check),
            label: const Text('اختبار الإعدادات'),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('تصدير البيانات'),
                  content: const Text('وظيفة التصدير تعمل بشكل صحيح!'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('موافق'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('تجربة التصدير'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('نظام نقاط البيع - صفحة ${_getPageName()}'),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
        body: _buildPage(),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
            print('Navigation clicked: index $index to ${_getPageNameByIndex(index)}');
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_cart),
              label: 'المبيعات',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory),
              label: 'المخزون',
            ),
            NavigationDestination(
              icon: Icon(Icons.analytics),
              label: 'الإحصائيات',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'الإعدادات',
            ),
          ],
        ),
      ),
    );
  }

  String _getPageName() {
    switch (_selectedIndex) {
      case 0: return 'الرئيسية';
      case 1: return 'المبيعات';
      case 2: return 'المخزون';
      case 3: return 'الإحصائيات';
      case 4: return 'الإعدادات';
      default: return 'غير معروف';
    }
  }

  String _getPageNameByIndex(int index) {
    switch (index) {
      case 0: return 'الرئيسية';
      case 1: return 'المبيعات';
      case 2: return 'المخزون';
      case 3: return 'الإحصائيات';
      case 4: return 'الإعدادات';
      default: return 'غير معروف';
    }
  }
}
