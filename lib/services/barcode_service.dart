import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:possystem/models/clothing/clothing_product.dart';
import 'package:possystem/models/clothing/product_variant.dart';
import 'package:possystem/helpers/logger.dart';

enum BarcodeFormat {
  ean8('EAN-8'),
  ean13('EAN-13'),
  upcA('UPC-A'),
  upcE('UPC-E'),
  code128('Code 128'),
  code39('Code 39'),
  qrCode('QR Code'),
  pdf417('PDF417'),
  dataMatrix('Data Matrix');

  const BarcodeFormat(this.displayName);
  final String displayName;
}

class BarcodeResult {
  final String code;
  final BarcodeFormat format;
  final ProductVariant? variant;
  final ClothingProduct? product;
  final DateTime scannedAt;

  BarcodeResult({
    required this.code,
    required this.format,
    this.variant,
    this.product,
    DateTime? scannedAt,
  }) : scannedAt = scannedAt ?? DateTime.now();

  bool get hasProduct => product != null;
  bool get hasVariant => variant != null;
}

class BarcodeService extends ChangeNotifier {
  static final BarcodeService instance = BarcodeService._();
  BarcodeService._();

  MobileScannerController? _controller;
  StreamSubscription<BarcodeCapture>? _subscription;
  
  // Cache for barcode-to-product mapping
  final Map<String, ProductVariant> _barcodeCache = {};
  final Map<String, ClothingProduct> _productCache = {};
  
  // Scanning state
  bool _isScanning = false;
  bool _hasPermission = false;
  String? _lastScannedCode;
  DateTime? _lastScanTime;

  bool get isScanning => _isScanning;
  bool get hasPermission => _hasPermission;
  String? get lastScannedCode => _lastScannedCode;

  /// Initialize the barcode service
  Future<void> initialize() async {
    try {
      _controller = MobileScannerController(
        formats: [
          BarcodeFormat.ean8,
          BarcodeFormat.ean13,
          BarcodeFormat.upcA,
          BarcodeFormat.upcE,
          BarcodeFormat.code128,
          BarcodeFormat.code39,
          BarcodeFormat.qrCode,
        ],
        returnImage: false, // Don't return images for better performance
      );
      
      // Check camera permission
      _hasPermission = await _checkCameraPermission();
      
      Log.out('BarcodeService initialized', 'barcode_service');
    } catch (e) {
      Log.err(e, 'barcode_service_init');
    }
  }

  /// Start barcode scanning
  Future<void> startScanning({
    required Function(BarcodeResult) onBarcodeDetected,
    Function(String)? onError,
  }) async {
    if (_isScanning) return;

    try {
      if (!_hasPermission) {
        _hasPermission = await _checkCameraPermission();
        if (!_hasPermission) {
          onError?.call('Camera permission denied');
          return;
        }
      }

      _isScanning = true;
      notifyListeners();

      _subscription = _controller?.barcodes.listen(
        (BarcodeCapture capture) {
          _handleBarcodeDetected(capture, onBarcodeDetected);
        },
        onError: (error) {
          Log.err(error, 'barcode_scanning');
          onError?.call(error.toString());
        },
      );

      await _controller?.start();
      Log.out('Barcode scanning started', 'barcode_service');
    } catch (e) {
      _isScanning = false;
      notifyListeners();
      Log.err(e, 'barcode_start_scanning');
      onError?.call(e.toString());
    }
  }

  /// Stop barcode scanning
  Future<void> stopScanning() async {
    if (!_isScanning) return;

    try {
      await _subscription?.cancel();
      await _controller?.stop();
      
      _isScanning = false;
      notifyListeners();
      
      Log.out('Barcode scanning stopped', 'barcode_service');
    } catch (e) {
      Log.err(e, 'barcode_stop_scanning');
    }
  }

  /// Handle detected barcode
  void _handleBarcodeDetected(
    BarcodeCapture capture,
    Function(BarcodeResult) onBarcodeDetected,
  ) {
    if (capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first;
    final code = barcode.rawValue;
    
    if (code == null || code.isEmpty) return;

    // Prevent duplicate scans (debounce)
    final now = DateTime.now();
    if (_lastScannedCode == code && 
        _lastScanTime != null && 
        now.difference(_lastScanTime!).inMilliseconds < 1000) {
      return;
    }

    _lastScannedCode = code;
    _lastScanTime = now;

    // Look up product by barcode
    final result = lookupProductByBarcode(code);
    onBarcodeDetected(result);

    Log.out('Barcode detected: $code', 'barcode_service');
  }

  /// Look up product by barcode
  BarcodeResult lookupProductByBarcode(String barcode) {
    // Check cache first
    final cachedVariant = _barcodeCache[barcode];
    if (cachedVariant != null) {
      final cachedProduct = _productCache[cachedVariant.productId];
      return BarcodeResult(
        code: barcode,
        format: _detectBarcodeFormat(barcode),
        variant: cachedVariant,
        product: cachedProduct,
      );
    }

    // TODO: Implement actual database lookup
    // This would query the database for products with matching barcodes
    
    return BarcodeResult(
      code: barcode,
      format: _detectBarcodeFormat(barcode),
    );
  }

  /// Detect barcode format from code
  BarcodeFormat _detectBarcodeFormat(String code) {
    if (code.length == 8 && RegExp(r'^\d{8}$').hasMatch(code)) {
      return BarcodeFormat.ean8;
    } else if (code.length == 13 && RegExp(r'^\d{13}$').hasMatch(code)) {
      return BarcodeFormat.ean13;
    } else if (code.length == 12 && RegExp(r'^\d{12}$').hasMatch(code)) {
      return BarcodeFormat.upcA;
    } else if (code.length == 8 && RegExp(r'^\d{8}$').hasMatch(code)) {
      return BarcodeFormat.upcE;
    } else if (RegExp(r'^[A-Z0-9\-. \$\/\+%]+$').hasMatch(code)) {
      return BarcodeFormat.code39;
    } else if (code.length >= 6) {
      return BarcodeFormat.code128;
    } else {
      return BarcodeFormat.qrCode;
    }
  }

  /// Add product variant to barcode cache
  void cacheProductVariant(String barcode, ProductVariant variant, ClothingProduct product) {
    _barcodeCache[barcode] = variant;
    _productCache[variant.productId] = product;
    Log.out('Cached barcode: $barcode for variant: ${variant.id}', 'barcode_service');
  }

  /// Remove from cache
  void removeCachedBarcode(String barcode) {
    final variant = _barcodeCache.remove(barcode);
    if (variant != null) {
      _productCache.remove(variant.productId);
    }
  }

  /// Clear all cache
  void clearCache() {
    _barcodeCache.clear();
    _productCache.clear();
    Log.out('Barcode cache cleared', 'barcode_service');
  }

  /// Generate barcode for product variant
  String generateBarcodeForVariant(ProductVariant variant) {
    // Generate a custom barcode based on variant properties
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final sizeCode = variant.size.hashCode.abs().toString().padLeft(3, '0').substring(0, 3);
    final colorCode = variant.color.hashCode.abs().toString().padLeft(3, '0').substring(0, 3);
    
    // Create a 13-digit EAN-13 barcode
    final baseCode = '2${sizeCode}${colorCode}${timestamp.substring(timestamp.length - 5)}';
    final checkDigit = _calculateEAN13CheckDigit(baseCode);
    
    return '$baseCode$checkDigit';
  }

  /// Calculate EAN-13 check digit
  int _calculateEAN13CheckDigit(String code) {
    int sum = 0;
    for (int i = 0; i < code.length; i++) {
      int digit = int.parse(code[i]);
      if (i % 2 == 0) {
        sum += digit;
      } else {
        sum += digit * 3;
      }
    }
    int checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit;
  }

  /// Check camera permission
  Future<bool> _checkCameraPermission() async {
    try {
      // This would check actual camera permissions
      // For now, return true for desktop testing
      return true;
    } catch (e) {
      Log.err(e, 'camera_permission_check');
      return false;
    }
  }

  /// Toggle flashlight (mobile only)
  Future<void> toggleFlashlight() async {
    try {
      await _controller?.toggleTorch();
    } catch (e) {
      Log.err(e, 'toggle_flashlight');
    }
  }

  /// Switch camera (mobile only)
  Future<void> switchCamera() async {
    try {
      await _controller?.switchCamera();
    } catch (e) {
      Log.err(e, 'switch_camera');
    }
  }

  /// Get supported barcode formats
  List<BarcodeFormat> getSupportedFormats() {
    return BarcodeFormat.values;
  }

  /// Validate barcode format
  bool isValidBarcode(String code, BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.ean8:
        return code.length == 8 && RegExp(r'^\d{8}$').hasMatch(code);
      case BarcodeFormat.ean13:
        return code.length == 13 && RegExp(r'^\d{13}$').hasMatch(code);
      case BarcodeFormat.upcA:
        return code.length == 12 && RegExp(r'^\d{12}$').hasMatch(code);
      case BarcodeFormat.upcE:
        return code.length == 8 && RegExp(r'^\d{8}$').hasMatch(code);
      case BarcodeFormat.code39:
        return RegExp(r'^[A-Z0-9\-. \$\/\+%]+$').hasMatch(code);
      case BarcodeFormat.code128:
        return code.length >= 6;
      case BarcodeFormat.qrCode:
        return code.isNotEmpty;
      default:
        return code.isNotEmpty;
    }
  }

  /// Dispose resources
  @override
  void dispose() {
    stopScanning();
    _controller?.dispose();
    super.dispose();
  }
}
