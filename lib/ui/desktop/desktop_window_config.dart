import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class DesktopWindowConfig {
  static Future<void> initialize() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Ensure window manager is initialized
      await windowManager.ensureInitialized();

      // Configure window options
      WindowOptions windowOptions = const WindowOptions(
        size: Size(1400, 900), // Optimal size for POS system
        minimumSize: Size(1200, 800), // Minimum usable size
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
        windowButtonVisibility: true,
        title: 'نظام نقاط البيع - Clothing Store POS',
      );

      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });

      // Set window properties
      await windowManager.setTitle('نظام نقاط البيع - Clothing Store POS');
      await windowManager.setIcon('assets/logo.png');
    }
  }

  static Future<void> setFullscreen(bool fullscreen) async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await windowManager.setFullScreen(fullscreen);
    }
  }

  static Future<void> minimize() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await windowManager.minimize();
    }
  }

  static Future<void> maximize() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await windowManager.maximize();
    }
  }

  static Future<void> restore() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await windowManager.unmaximize();
    }
  }

  static Future<bool> isMaximized() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return await windowManager.isMaximized();
    }
    return false;
  }

  static Future<void> center() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await windowManager.center();
    }
  }

  static Future<void> setAlwaysOnTop(bool alwaysOnTop) async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await windowManager.setAlwaysOnTop(alwaysOnTop);
    }
  }
}

class DesktopTitleBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showWindowControls;

  const DesktopTitleBar({
    Key? key,
    required this.title,
    this.actions,
    this.showWindowControls = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // App Icon and Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 32,
                  height: 32,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.store,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Actions
          if (actions != null) ...actions!,
          
          // Window Controls (for custom title bar)
          if (showWindowControls && (Platform.isWindows || Platform.isLinux))
            _buildWindowControls(context),
        ],
      ),
    );
  }

  Widget _buildWindowControls(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => DesktopWindowConfig.minimize(),
          icon: const Icon(Icons.minimize),
          tooltip: 'تصغير',
        ),
        FutureBuilder<bool>(
          future: DesktopWindowConfig.isMaximized(),
          builder: (context, snapshot) {
            final isMaximized = snapshot.data ?? false;
            return IconButton(
              onPressed: isMaximized 
                ? () => DesktopWindowConfig.restore()
                : () => DesktopWindowConfig.maximize(),
              icon: Icon(isMaximized ? Icons.fullscreen_exit : Icons.fullscreen),
              tooltip: isMaximized ? 'استعادة' : 'تكبير',
            );
          },
        ),
        IconButton(
          onPressed: () => _showCloseConfirmation(context),
          icon: const Icon(Icons.close),
          tooltip: 'إغلاق',
          color: Colors.red[700],
        ),
      ],
    );
  }

  void _showCloseConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إغلاق التطبيق'),
        content: const Text('هل أنت متأكد من إغلاق نظام نقاط البيع؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Close the application
              if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
                windowManager.close();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class DesktopStatusBar extends StatelessWidget {
  final String? connectionStatus;
  final String? lastSync;
  final int? totalProducts;
  final int? lowStockItems;

  const DesktopStatusBar({
    Key? key,
    this.connectionStatus,
    this.lastSync,
    this.totalProducts,
    this.lowStockItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Connection Status
          if (connectionStatus != null) ...[
            Icon(
              Icons.wifi,
              size: 16,
              color: connectionStatus == 'متصل' ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 4),
            Text(
              connectionStatus!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(width: 16),
          ],
          
          // Last Sync
          if (lastSync != null) ...[
            Icon(
              Icons.sync,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              'آخر مزامنة: $lastSync',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(width: 16),
          ],
          
          const Spacer(),
          
          // Product Count
          if (totalProducts != null) ...[
            Icon(
              Icons.inventory,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              'المنتجات: $totalProducts',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(width: 16),
          ],
          
          // Low Stock Alert
          if (lowStockItems != null && lowStockItems! > 0) ...[
            Icon(
              Icons.warning,
              size: 16,
              color: Colors.orange[700],
            ),
            const SizedBox(width: 4),
            Text(
              'مخزون قليل: $lowStockItems',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.orange[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          
          // Current Time
          StreamBuilder<DateTime>(
            stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final now = snapshot.data!;
                final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
                return Text(
                  timeString,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

// Intent classes for shortcuts
class SearchIntent extends Intent {}
class NewProductIntent extends Intent {}
class CheckoutIntent extends Intent {}
class InventoryIntent extends Intent {}
class CustomersIntent extends Intent {}
class ReportsIntent extends Intent {}
class SettingsIntent extends Intent {}
class HelpIntent extends Intent {}
class ClearIntent extends Intent {}

// Desktop-specific responsive breakpoints
class DesktopBreakpoints {
  static const double small = 1200;   // Small desktop
  static const double medium = 1400;  // Medium desktop
  static const double large = 1600;   // Large desktop
  static const double extraLarge = 1920; // Extra large desktop

  static bool isSmallDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= small && 
           MediaQuery.of(context).size.width < medium;
  }

  static bool isMediumDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= medium && 
           MediaQuery.of(context).size.width < large;
  }

  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= large && 
           MediaQuery.of(context).size.width < extraLarge;
  }

  static bool isExtraLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= extraLarge;
  }

  static int getProductGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= extraLarge) return 5;
    if (width >= large) return 4;
    if (width >= medium) return 3;
    return 2;
  }

  static double getSidebarWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= extraLarge) return 350;
    if (width >= large) return 320;
    if (width >= medium) return 300;
    return 280;
  }

  static double getCartSidebarWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= extraLarge) return 400;
    if (width >= large) return 380;
    if (width >= medium) return 350;
    return 320;
  }
}
