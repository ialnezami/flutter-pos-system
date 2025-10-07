
// Bluetooth stub for POS system compilation
// This is a simplified version to allow the app to compile without the external package

import 'dart:async';
import 'dart:typed_data';

class BluetoothDevice {
  final String address;
  final String name;
  final bool connected;
  
  BluetoothDevice({
    required this.address, 
    required this.name, 
    this.connected = false
  });
  
  Stream<BluetoothSignal> createSignalStream() => Stream.periodic(
    Duration(seconds: 2), 
    (_) => BluetoothSignal.normal
  );
}

class PrinterManufactory {
  final int widthBits;
  
  const PrinterManufactory({required this.widthBits});
  
  static PrinterManufactory tryGuess(String name) {
    return const PrinterManufactory(widthBits: 384);
  }
}

enum BluetoothSignal { 
  weak, normal, good;
}

enum PrinterStatus { 
  good, unrecoverable, writeFailed, paperJams, paperNotFound, 
  lowBattery, tooHot, uncovering, noResponse, unknown, printing;
  
  int get priority {
    switch (this) {
      case good: return 0;
      case printing: return 1;
      case unknown: return 2;
      case noResponse: return 3;
      case uncovering: return 4;
      case tooHot: return 5;
      case lowBattery: return 6;
      case paperNotFound: return 7;
      case paperJams: return 8;
      case writeFailed: return 9;
      case unrecoverable: return 10;
    }
  }
}

enum PrinterDensity { 
  normal, tight;
}

enum BluetoothExceptionCode {
  timeout, deviceIsDisconnected, serviceNotFound, characteristicNotFound,
  adapterIsOff, connectionCanceled, userRejected
}

enum BluetoothExceptionFrom { scan, connect, write }

class BluetoothException implements Exception {
  final int code;
  final BluetoothExceptionFrom from;
  final String message;
  final String? description;
  final String? function;
  
  BluetoothException(this.code, this.from, this.message, {this.description, this.function});
}

class BluetoothOffException extends BluetoothException {
  BluetoothOffException() : super(0, BluetoothExceptionFrom.scan, 'Bluetooth is off');
}

class Printer {
  final String address;
  final PrinterManufactory manufactory;
  final Printer? other;
  final bool connected;
  final BluetoothDevice? device;
  final Stream<PrinterStatus> statusStream;
  
  Printer({
    required this.address, 
    required this.manufactory, 
    this.other,
    this.connected = false,
    this.device,
  }) : statusStream = Stream.periodic(Duration(seconds: 1), (_) => PrinterStatus.good);
  
  void addListener(Function listener) {
    // Stub implementation
  }
  
  Future<bool> connect() async {
    // Stub implementation
    return true;
  }
  
  Future<void> disconnect() async {
    // Stub implementation
  }
  
  Stream<double> draw(Uint8List image, {PrinterDensity? density}) {
    // Stub implementation - returns progress stream
    return Stream.periodic(Duration(milliseconds: 100), (count) => (count + 1) * 10.0).take(10);
  }
}

class CatPrinter extends PrinterManufactory {
  final int feedPaperByteSize;
  
  const CatPrinter({required this.feedPaperByteSize}) : super(widthBits: 384);
}

class EpsonPrinter extends PrinterManufactory {
  const EpsonPrinter() : super(widthBits: 384);
}

class XPrinter extends PrinterManufactory {
  const XPrinter() : super(widthBits: 384);
}

class Bluetooth {
  static final Bluetooth i = Bluetooth._();
  Bluetooth._();
  
  Stream<List<BluetoothDevice>> startScan() {
    // Return empty stream for stub
    return Stream.value([]);
  }
  
  Future<void> stopScan() async {
    // Stub implementation
  }
}

class Logger {
  static LogLevel level = LogLevel.debug;
}

enum LogLevel { debug, info, warning, error }
