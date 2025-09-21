import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DesktopShortcuts extends StatelessWidget {
  final Widget child;
  final VoidCallback? onSearch;
  final VoidCallback? onNewProduct;
  final VoidCallback? onCheckout;
  final VoidCallback? onInventory;
  final VoidCallback? onCustomers;
  final VoidCallback? onReports;
  final VoidCallback? onSettings;

  const DesktopShortcuts({
    Key? key,
    required this.child,
    this.onSearch,
    this.onNewProduct,
    this.onCheckout,
    this.onInventory,
    this.onCustomers,
    this.onReports,
    this.onSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        // Search: Ctrl+F
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF): SearchIntent(),
        
        // New Product: Ctrl+N
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN): NewProductIntent(),
        
        // Checkout: Ctrl+Enter
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.enter): CheckoutIntent(),
        
        // Inventory: Ctrl+I
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyI): InventoryIntent(),
        
        // Customers: Ctrl+U
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyU): CustomersIntent(),
        
        // Reports: Ctrl+R
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyR): ReportsIntent(),
        
        // Settings: Ctrl+S
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS): SettingsIntent(),
        
        // Help: F1
        LogicalKeySet(LogicalKeyboardKey.f1): HelpIntent(),
        
        // Escape: Clear/Cancel
        LogicalKeySet(LogicalKeyboardKey.escape): ClearIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          SearchIntent: CallbackAction<SearchIntent>(
            onInvoke: (SearchIntent intent) {
              onSearch?.call();
              return null;
            },
          ),
          NewProductIntent: CallbackAction<NewProductIntent>(
            onInvoke: (NewProductIntent intent) {
              onNewProduct?.call();
              return null;
            },
          ),
          CheckoutIntent: CallbackAction<CheckoutIntent>(
            onInvoke: (CheckoutIntent intent) {
              onCheckout?.call();
              return null;
            },
          ),
          InventoryIntent: CallbackAction<InventoryIntent>(
            onInvoke: (InventoryIntent intent) {
              onInventory?.call();
              return null;
            },
          ),
          CustomersIntent: CallbackAction<CustomersIntent>(
            onInvoke: (CustomersIntent intent) {
              onCustomers?.call();
              return null;
            },
          ),
          ReportsIntent: CallbackAction<ReportsIntent>(
            onInvoke: (ReportsIntent intent) {
              onReports?.call();
              return null;
            },
          ),
          SettingsIntent: CallbackAction<SettingsIntent>(
            onInvoke: (SettingsIntent intent) {
              onSettings?.call();
              return null;
            },
          ),
          HelpIntent: CallbackAction<HelpIntent>(
            onInvoke: (HelpIntent intent) {
              _showHelpDialog(context);
              return null;
            },
          ),
          ClearIntent: CallbackAction<ClearIntent>(
            onInvoke: (ClearIntent intent) {
              // Handle escape key - could clear search, close dialogs, etc.
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختصارات لوحة المفاتيح'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShortcutRow('Ctrl + F', 'البحث'),
              _buildShortcutRow('Ctrl + N', 'منتج جديد'),
              _buildShortcutRow('Ctrl + Enter', 'الدفع'),
              _buildShortcutRow('Ctrl + I', 'المخزون'),
              _buildShortcutRow('Ctrl + U', 'العملاء'),
              _buildShortcutRow('Ctrl + R', 'التقارير'),
              _buildShortcutRow('Ctrl + S', 'الإعدادات'),
              _buildShortcutRow('F1', 'المساعدة'),
              _buildShortcutRow('Escape', 'إلغاء/مسح'),
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

  Widget _buildShortcutRow(String shortcut, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: Text(
              shortcut,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(description),
          ),
        ],
      ),
    );
  }
}

// Intent classes for keyboard shortcuts
class SearchIntent extends Intent {}
class NewProductIntent extends Intent {}
class CheckoutIntent extends Intent {}
class InventoryIntent extends Intent {}
class CustomersIntent extends Intent {}
class ReportsIntent extends Intent {}
class SettingsIntent extends Intent {}
class HelpIntent extends Intent {}
class ClearIntent extends Intent {}
