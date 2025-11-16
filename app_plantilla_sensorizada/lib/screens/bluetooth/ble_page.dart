// lib/pages/ble/ble_page.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

import '../../common/core/permissions.dart';
import '../../common/widgets/primary_button.dart';
import '../../data/bluetooth/ble_manager.dart';
import '../../common/core/colors.dart';
import '../OTA/ota_page.dart';
import '../../data/bluetooth/packet_parser.dart';

class BlePage extends StatefulWidget {
  const BlePage({super.key});

  @override
  State<BlePage> createState() => _BlePageState();
}

class _BlePageState extends State<BlePage> {
  StreamSubscription<DiscoveredDevice>? _scanSub;
  StreamSubscription? _imuSub;
  StreamSubscription? _pulseSub;
  StreamSubscription? _packetLogSub;

  final List<DiscoveredDevice> _devices = [];

  bool _isScanning = false;
  String _status = "Desconectado";
  String _lastMessage = "";

  @override
  void initState() {
    super.initState();

    final ble = context.read<BleManager>();

    // UI messages (text)
    ble.messages.listen((msg) {
      if (!mounted) return;
      setState(() => _lastMessage = msg);
    });

    // Connection state
    ble.connectionStream.listen((connected) {
      if (!mounted) return;
      setState(() {
        _status = connected ? "Conectado" : "Desconectado";
      });
    });

    // Connect parser streams (if someone wants IMU/pulse updates)
    _imuSub = ble.imuStream.listen((dynamic imu) {
      if (!mounted) return;
      setState(() {
        _lastMessage = 'IMU: $imu';
      });
    });

    _pulseSub = ble.pulseStream.listen((dynamic pulse) {
      if (!mounted) return;
      setState(() {
        _lastMessage = 'PULSE: $pulse';
      });
    });

    _packetLogSub = ble.packetLogStream.listen((log) {
      if (!mounted) return;
      // Optionally append or show last log
      setState(() {
        // don't overwrite IMU/pulse message if it's fresh; just set for visibility
        _lastMessage = log;
      });
    });
  }

  Future<void> _scan() async {
    final ble = context.read<BleManager>();
    await PermissionService.requestBlePermissions();

    setState(() {
      _isScanning = true;
      _devices.clear();
      _status = "Buscando dispositivos...";
    });

    final stream = await ble.scan();

    _scanSub = stream.listen((device) {
      if (device.name.isNotEmpty &&
          device.name.startsWith("ESP") &&
          !_devices.any((d) => d.id == device.id)) {
        setState(() => _devices.add(device));
      }
    });
  }

  Future<void> _stopScan() async {
    await _scanSub?.cancel();
    setState(() {
      _isScanning = false;
      _status = "Escaneo detenido";
    });
  }

  Future<void> _connect(DiscoveredDevice device) async {
    final ble = context.read<BleManager>();

    setState(() => _status = "Conectando...");

    await ble.connect(device);

    if (!_devices.any((d) => d.id == device.id)) {
      setState(() {
        _devices.add(DiscoveredDevice(
          id: device.id,
          name: device.name,
          serviceData: const {},
          manufacturerData: Uint8List(0),
          rssi: 0,
          serviceUuids: const [],
        ));
      });
    }
  }

  Future<void> _disconnect() async {
    final ble = context.read<BleManager>();
    await ble.disconnect();
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _imuSub?.cancel();
    _pulseSub?.cancel();
    _packetLogSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ble = context.watch<BleManager>();
    final connected = ble.connectedDevice != null;
    final theme = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: theme == Brightness.dark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text("Conexión Bluetooth"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Estado: $_status",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme == Brightness.dark
                    ? AppColors.darkText
                    : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 14),

            if (!_isScanning)
              PrimaryButton(
                text: "Buscar dispositivos",
                onPressed: _scan,
              )
            else
              PrimaryButton(
                text: "Buscando...",
                onPressed: _stopScan,
              ),

            const SizedBox(height: 14),

            Expanded(
              child: ListView(
                children: [
                  if (ble.connectedDevice != null)
                    Card(
                      color: theme == Brightness.dark
                          ? AppColors.darkSurface
                          : AppColors.lightSecondary,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ble.connectedDevice!.name.isNotEmpty
                                  ? ble.connectedDevice!.name
                                  : "Dispositivo conectado",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ble.connectedDevice!.id,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme == Brightness.dark
                                    ? AppColors.darkText
                                    : AppColors.lightText,
                              ),
                            ),
                            const SizedBox(height: 12),

                            PrimaryButton(
                              text: "Configurar / OTA",
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const OtaPage(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),

                            PrimaryButton(
                              text: "Desconectar",
                              onPressed: _disconnect,
                            ),
                          ],
                        ),
                      ),
                    ),

                  ..._devices.map((d) {
                    final isConnected = ble.connectedDevice?.id == d.id;
                    return Card(
                      color: theme == Brightness.dark
                          ? AppColors.darkSurface
                          : AppColors.lightSurface,
                      child: ListTile(
                        title: Text(d.name),
                        subtitle: Text(d.id),
                        trailing: Icon(
                          Icons.bluetooth,
                          color: isConnected ? Colors.green : null,
                        ),
                        onTap: () => _connect(d),
                      ),
                    );
                  }),
                ],
              ),
            ),

            if (connected) ...[
              const Divider(),
              Text(
                "Último mensaje: $_lastMessage",
                style: TextStyle(
                  color: theme == Brightness.dark
                      ? AppColors.darkText
                      : AppColors.lightText,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
