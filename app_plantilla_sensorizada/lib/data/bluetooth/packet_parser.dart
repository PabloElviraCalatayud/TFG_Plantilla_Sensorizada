// lib/data/bluetooth/packet_parser.dart
import 'dart:async';
import 'dart:typed_data';

/// Parser de paquetes binarios enviados por el ESP32 (ver especificación).
///
/// Formato:
///  byte 0: FLAGS (bits 7-6: tipo 00=error 01=pulse 10=imu 11=both)
///  bytes 1..4: timestamp uint32_t (ms desde arranque)  (little-endian)
///  IMU payload (si presente) = 14 bytes (little-endian)
///    int16 accel_x_mg, accel_y_mg, accel_z_mg
///    int16 gyro_x_d10, gyro_y_d10, gyro_z_d10
///    uint16 sample_id
///  Pulse payload (si presente) = 2 bytes (uint16 pulse value)
///
/// Tamaños totales:
///  pulse: 1 + 4 + 2 = 7
///  imu:   1 + 4 + 14 = 19
///  both:  1 + 4 + 14 + 2 = 21
class PacketParser {
  final StreamController<ImuSample> _imuCtrl =
  StreamController<ImuSample>.broadcast();
  final StreamController<PulseSample> _pulseCtrl =
  StreamController<PulseSample>.broadcast();
  final StreamController<String> _logCtrl =
  StreamController<String>.broadcast();

  final BytesBuilder _bufBuilder = BytesBuilder(copy: false);
  bool _closed = false;

  PacketParser();

  Stream<ImuSample> get imuStream => _imuCtrl.stream;
  Stream<PulseSample> get pulseStream => _pulseCtrl.stream;
  Stream<String> get logStream => _logCtrl.stream;

  void addBytes(Uint8List data) {
    if (_closed) return;
    if (data.isEmpty) return;
    _bufBuilder.add(data);
    _tryParseBuffer();
  }

  Future<void> dispose() async {
    if (_closed) return;
    _closed = true;
    await _imuCtrl.close();
    await _pulseCtrl.close();
    await _logCtrl.close();
    _bufBuilder.clear();
  }

  void _tryParseBuffer() {
    final bytes = _bufBuilder.toBytes();
    int offset = 0;
    final length = bytes.length;

    while (true) {
      if (offset + 5 > length) break; // need header + timestamp

      final header = bytes[offset];
      final typeBits = (header & 0xC0) >> 6;
      int expectedTotal;
      if (typeBits == 0x0) expectedTotal = 5; // treat as minimal error packet
      else if (typeBits == 0x1) expectedTotal = 1 + 4 + 2; // 7
      else if (typeBits == 0x2) expectedTotal = 1 + 4 + 14; // 19
      else expectedTotal = 1 + 4 + 14 + 2; // 21

      if (offset + expectedTotal > length) break; // incomplete

      final packet = Uint8List.view(bytes.buffer, bytes.offsetInBytes + offset, expectedTotal);

      final parsed = _parsePacket(packet);
      if (!parsed) {
        // If parsing failed, skip one byte and try to resync
        offset += 1;
        continue;
      }

      offset += expectedTotal;
    }

    if (offset == 0) {
      return;
    } else if (offset >= length) {
      _bufBuilder.clear();
    } else {
      final remaining = bytes.sublist(offset);
      _bufBuilder.clear();
      _bufBuilder.add(remaining);
    }
  }

  bool _parsePacket(Uint8List pkt) {
    try {
      if (pkt.length < 5) return false;
      final header = pkt[0];
      final typeBits = (header & 0xC0) >> 6;
      final ts = _readUint32LE(pkt, 1);
      int pos = 5;

      if (typeBits == 0x0) {
        _logCtrl.add("PACKET: tipo=ERROR at $ts ms");
        return true;
      }

      if (typeBits == 0x2 || typeBits == 0x3) {
        if (pos + 14 > pkt.length) return false;
        final ax = _readInt16LE(pkt, pos);
        final ay = _readInt16LE(pkt, pos + 2);
        final az = _readInt16LE(pkt, pos + 4);
        final gx = _readInt16LE(pkt, pos + 6);
        final gy = _readInt16LE(pkt, pos + 8);
        final gz = _readInt16LE(pkt, pos + 10);
        final sampleId = _readUint16LE(pkt, pos + 12);
        pos += 14;

        final imu = ImuSample(
          timestampMs: ts,
          accelXmg: ax,
          accelYmg: ay,
          accelZmg: az,
          gyroXd10: gx,
          gyroYd10: gy,
          gyroZd10: gz,
          sampleId: sampleId,
        );

        _imuCtrl.add(imu);
      }

      if (typeBits == 0x1 || typeBits == 0x3) {
        if (pos + 2 > pkt.length) return false;
        final pv = _readUint16LE(pkt, pos);
        final pulse = PulseSample(timestampMs: ts, value: pv);
        _pulseCtrl.add(pulse);
        pos += 2;
      }

      return true;
    } catch (e, st) {
      _logCtrl.add("Parser error: $e\n$st");
      return false;
    }
  }

  static int _readInt16LE(Uint8List b, int offset) {
    final lo = b[offset];
    final hi = b[offset + 1];
    final val = (hi << 8) | lo;
    return (val & 0x8000) != 0 ? val - 0x10000 : val;
  }

  static int _readUint16LE(Uint8List b, int offset) {
    final lo = b[offset];
    final hi = b[offset + 1];
    return (hi << 8) | lo;
  }

  static int _readUint32LE(Uint8List b, int offset) {
    final v0 = b[offset];
    final v1 = b[offset + 1];
    final v2 = b[offset + 2];
    final v3 = b[offset + 3];
    return (v3 << 24) | (v2 << 16) | (v1 << 8) | v0;
  }
}

class ImuSample {
  final int timestampMs;
  final int accelXmg;
  final int accelYmg;
  final int accelZmg;
  final int gyroXd10;
  final int gyroYd10;
  final int gyroZd10;
  final int sampleId;

  ImuSample({
    required this.timestampMs,
    required this.accelXmg,
    required this.accelYmg,
    required this.accelZmg,
    required this.gyroXd10,
    required this.gyroYd10,
    required this.gyroZd10,
    required this.sampleId,
  });

  double accelXg() => accelXmg / 1000.0;
  double accelYg() => accelYmg / 1000.0;
  double accelZg() => accelZmg / 1000.0;

  double gyroXdeg() => gyroXd10 / 10.0;
  double gyroYdeg() => gyroYd10 / 10.0;
  double gyroZdeg() => gyroZd10 / 10.0;

  @override
  String toString() =>
      'ImuSample(ts:$timestampMs ms, sid:$sampleId, ax:${accelXmg}mg ay:${accelYmg}mg az:${accelZmg}mg, gx:${gyroXd10}d10 gy:${gyroYd10}d10 gz:${gyroZd10}d10)';
}

class PulseSample {
  final int timestampMs;
  final int value;

  PulseSample({required this.timestampMs, required this.value});

  @override
  String toString() => 'PulseSample(ts:$timestampMs ms, value:$value)';
}
