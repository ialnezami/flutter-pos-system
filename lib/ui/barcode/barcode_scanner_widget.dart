import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:possystem/services/barcode_service.dart';
import 'package:possystem/models/clothing/product_variant.dart';
import 'package:possystem/models/clothing/clothing_product.dart';
import 'package:possystem/l10n/clothing_localizations.dart';

class BarcodeScannerWidget extends StatefulWidget {
  final Function(BarcodeResult) onBarcodeDetected;
  final Function(String)? onError;
  final bool showControls;
  final bool autoStart;

  const BarcodeScannerWidget({
    Key? key,
    required this.onBarcodeDetected,
    this.onError,
    this.showControls = true,
    this.autoStart = true,
  }) : super(key: key);

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  MobileScannerController? _controller;
  bool _isFlashlightOn = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _initializeScanner();
  }

  Future<void> _initializeScanner() async {
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
      returnImage: false,
    );

    if (widget.autoStart) {
      await _startScanning();
    }
  }

  Future<void> _startScanning() async {
    if (_isScanning) return;
    
    try {
      setState(() {
        _isScanning = true;
      });
      
      await _controller?.start();
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      widget.onError?.call('خطأ في بدء المسح: $e');
    }
  }

  Future<void> _stopScanning() async {
    if (!_isScanning) return;
    
    try {
      await _controller?.stop();
      setState(() {
        _isScanning = false;
        _isFlashlightOn = false;
      });
    } catch (e) {
      widget.onError?.call('خطأ في إيقاف المسح: $e');
    }
  }

  Future<void> _toggleFlashlight() async {
    try {
      await _controller?.toggleTorch();
      setState(() {
        _isFlashlightOn = !_isFlashlightOn;
      });
    } catch (e) {
      widget.onError?.call('خطأ في تشغيل الضوء: $e');
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _controller?.switchCamera();
    } catch (e) {
      widget.onError?.call('خطأ في تبديل الكاميرا: $e');
    }
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first;
    final code = barcode.rawValue;
    
    if (code == null || code.isEmpty) return;

    // Look up product
    final result = BarcodeService.instance.lookupProductByBarcode(code);
    widget.onBarcodeDetected(result);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            // Camera View
            if (_controller != null)
              MobileScanner(
                controller: _controller!,
                onDetect: _onBarcodeDetected,
              ),
            
            // Overlay
            _buildScannerOverlay(),
            
            // Controls
            if (widget.showControls) _buildControls(),
            
            // Status
            _buildStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Container(
      decoration: ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderColor: Theme.of(context).colorScheme.primary,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 4,
          cutOutSize: MediaQuery.of(context).size.width * 0.6,
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Flashlight Toggle
          FloatingActionButton(
            heroTag: 'flashlight',
            onPressed: _toggleFlashlight,
            backgroundColor: _isFlashlightOn 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
            child: Icon(
              _isFlashlightOn ? Icons.flash_on : Icons.flash_off,
              color: _isFlashlightOn 
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          
          // Start/Stop Scanning
          FloatingActionButton.extended(
            heroTag: 'scan_toggle',
            onPressed: _isScanning ? _stopScanning : _startScanning,
            backgroundColor: _isScanning 
              ? Colors.red[700]
              : Theme.of(context).colorScheme.primary,
            icon: Icon(_isScanning ? Icons.stop : Icons.play_arrow),
            label: Text(_isScanning ? 'إيقاف المسح' : 'بدء المسح'),
          ),
          
          // Switch Camera
          FloatingActionButton(
            heroTag: 'camera_switch',
            onPressed: _switchCamera,
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: Icon(
              Icons.switch_camera,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatus() {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isScanning ? Icons.qr_code_scanner : Icons.qr_code,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _isScanning ? 'جاري المسح...' : 'اضغط لبدء المسح',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

// Custom overlay shape for barcode scanner
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path _getLeftTopPath(double s) {
      return Path()
        ..moveTo(s, s + borderLength)
        ..lineTo(s, s + borderRadius)
        ..quadraticBezierTo(s, s, s + borderRadius, s)
        ..lineTo(s + borderLength, s);
    }

    Path _getRightTopPath(double s) {
      return Path()
        ..moveTo(s - borderLength, s)
        ..lineTo(s - borderRadius, s)
        ..quadraticBezierTo(s, s, s, s + borderRadius)
        ..lineTo(s, s + borderLength);
    }

    Path _getRightBottomPath(double s) {
      return Path()
        ..moveTo(s, s - borderLength)
        ..lineTo(s, s - borderRadius)
        ..quadraticBezierTo(s, s, s - borderRadius, s)
        ..lineTo(s - borderLength, s);
    }

    Path _getLeftBottomPath(double s) {
      return Path()
        ..moveTo(s + borderLength, s)
        ..lineTo(s + borderRadius, s)
        ..quadraticBezierTo(s, s, s, s - borderRadius)
        ..lineTo(s, s - borderLength);
    }

    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderHeightSize = height / 2;
    final cutOutWidth = cutOutSize < width ? cutOutSize : width - borderWidth;
    final cutOutHeight = cutOutSize < height ? cutOutSize : height - borderWidth;

    final cutOutWidthSize = cutOutWidth / 2;
    final cutOutHeightSize = cutOutHeight / 2;

    final cutOutX = borderWidthSize - cutOutWidthSize;
    final cutOutY = borderHeightSize - cutOutHeightSize;

    return Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(rect)
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            cutOutX,
            cutOutY,
            cutOutWidth,
            cutOutHeight,
          ),
          Radius.circular(borderRadius),
        ),
      );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderHeightSize = height / 2;
    final cutOutWidth = cutOutSize < width ? cutOutSize : width - borderWidth;
    final cutOutHeight = cutOutSize < height ? cutOutSize : height - borderWidth;

    final cutOutWidthSize = cutOutWidth / 2;
    final cutOutHeightSize = cutOutHeight / 2;

    final cutOutX = borderWidthSize - cutOutWidthSize;
    final cutOutY = borderHeightSize - cutOutHeightSize;

    final cutOutRect = Rect.fromLTWH(
      cutOutX,
      cutOutY,
      cutOutWidth,
      cutOutHeight,
    );

    final paint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // Draw overlay
    canvas.drawPath(getOuterPath(rect), paint);

    // Draw border corners
    final leftTopPath = Path()
      ..moveTo(cutOutRect.left, cutOutRect.top + borderLength)
      ..lineTo(cutOutRect.left, cutOutRect.top + borderRadius)
      ..quadraticBezierTo(cutOutRect.left, cutOutRect.top, cutOutRect.left + borderRadius, cutOutRect.top)
      ..lineTo(cutOutRect.left + borderLength, cutOutRect.top);

    final rightTopPath = Path()
      ..moveTo(cutOutRect.right - borderLength, cutOutRect.top)
      ..lineTo(cutOutRect.right - borderRadius, cutOutRect.top)
      ..quadraticBezierTo(cutOutRect.right, cutOutRect.top, cutOutRect.right, cutOutRect.top + borderRadius)
      ..lineTo(cutOutRect.right, cutOutRect.top + borderLength);

    final rightBottomPath = Path()
      ..moveTo(cutOutRect.right, cutOutRect.bottom - borderLength)
      ..lineTo(cutOutRect.right, cutOutRect.bottom - borderRadius)
      ..quadraticBezierTo(cutOutRect.right, cutOutRect.bottom, cutOutRect.right - borderRadius, cutOutRect.bottom)
      ..lineTo(cutOutRect.right - borderLength, cutOutRect.bottom);

    final leftBottomPath = Path()
      ..moveTo(cutOutRect.left + borderLength, cutOutRect.bottom)
      ..lineTo(cutOutRect.left + borderRadius, cutOutRect.bottom)
      ..quadraticBezierTo(cutOutRect.left, cutOutRect.bottom, cutOutRect.left, cutOutRect.bottom - borderRadius)
      ..lineTo(cutOutRect.left, cutOutRect.bottom - borderLength);

    canvas.drawPath(leftTopPath, borderPaint);
    canvas.drawPath(rightTopPath, borderPaint);
    canvas.drawPath(rightBottomPath, borderPaint);
    canvas.drawPath(leftBottomPath, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}

class BarcodeScannerDialog extends StatefulWidget {
  final Function(BarcodeResult) onBarcodeDetected;
  final String title;
  final String subtitle;

  const BarcodeScannerDialog({
    Key? key,
    required this.onBarcodeDetected,
    this.title = 'مسح الباركود',
    this.subtitle = 'وجه الكاميرا نحو الباركود',
  }) : super(key: key);

  @override
  State<BarcodeScannerDialog> createState() => _BarcodeScannerDialogState();
}

class _BarcodeScannerDialogState extends State<BarcodeScannerDialog> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        height: 600,
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
                  Icon(
                    Icons.qr_code_scanner,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          widget.subtitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
            ),
            
            // Scanner
            Expanded(
              child: _isProcessing 
                ? _buildProcessingView()
                : BarcodeScannerWidget(
                    onBarcodeDetected: _handleBarcodeDetected,
                    onError: _handleScanError,
                  ),
            ),
            
            // Manual Input Option
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'أو أدخل الباركود يدوياً:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'أدخل رمز الباركود',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: _handleManualBarcode,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          // Handle manual input
                        },
                        icon: const Icon(Icons.check),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'جاري البحث عن المنتج...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  void _handleBarcodeDetected(BarcodeResult result) {
    setState(() {
      _isProcessing = true;
    });

    // Simulate processing delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pop();
        widget.onBarcodeDetected(result);
      }
    });
  }

  void _handleManualBarcode(String barcode) {
    if (barcode.trim().isEmpty) return;
    
    final result = BarcodeService.instance.lookupProductByBarcode(barcode.trim());
    _handleBarcodeDetected(result);
  }

  void _handleScanError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red[700],
      ),
    );
  }
}

class BarcodeInputField extends StatefulWidget {
  final Function(String) onBarcodeEntered;
  final String? initialValue;
  final String hintText;

  const BarcodeInputField({
    Key? key,
    required this.onBarcodeEntered,
    this.initialValue,
    this.hintText = 'أدخل أو امسح الباركود',
  }) : super(key: key);

  @override
  State<BarcodeInputField> createState() => _BarcodeInputFieldState();
}

class _BarcodeInputFieldState extends State<BarcodeInputField> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: const Icon(Icons.qr_code),
              suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _controller.clear();
                      widget.onBarcodeEntered('');
                    },
                    icon: const Icon(Icons.clear),
                  )
                : null,
              border: const OutlineInputBorder(),
            ),
            onChanged: widget.onBarcodeEntered,
            onSubmitted: widget.onBarcodeEntered,
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: () => _showScannerDialog(),
          icon: const Icon(Icons.qr_code_scanner),
          tooltip: 'مسح الباركود',
        ),
      ],
    );
  }

  void _showScannerDialog() {
    showDialog(
      context: context,
      builder: (context) => BarcodeScannerDialog(
        onBarcodeDetected: (result) {
          _controller.text = result.code;
          widget.onBarcodeEntered(result.code);
          _focusNode.unfocus();
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
