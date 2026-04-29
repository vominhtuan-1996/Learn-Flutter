import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'scanner_service.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _checking = true;
  bool _supported = false;
  bool _scanning = false;
  String? _lastPath;

  @override
  void initState() {
    super.initState();
    _checkSupport();
  }

  Future<void> _checkSupport() async {
    final ok = await ScannerService.isSupported();
    if (!mounted) return;
    setState(() {
      _supported = ok;
      _checking = false;
    });
  }

  Future<void> _start() async {
    await ScannerService.startScan();
    if (!mounted) return;
    setState(() => _scanning = true);
  }

  Future<void> _stop() async {
    await ScannerService.stopScan();
    if (!mounted) return;
    setState(() => _scanning = false);
  }

  Future<void> _export(String format) async {
    try {
      final path = await ScannerService.exportScan(format: format);
      if (!mounted) return;
      setState(() => _lastPath = path);
      _snack('Exported: $path');
    } on PlatformException catch (e) {
      if (!mounted) return;
      _snack('Export failed: ${e.message}');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LiDAR Scanner')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _checking ? _loading() : _content(),
      ),
    );
  }

  Widget _loading() => const Center(child: CircularProgressIndicator());

  Widget _content() {
    if (!Platform.isIOS) {
      return const Center(child: Text('LiDAR scanner is iOS only.'));
    }
    if (!_supported) {
      return const Center(
        child: Text(
          'This device does not support LiDAR scene reconstruction.\n'
          'Use iPhone Pro / iPad Pro with a LiDAR sensor.',
          textAlign: TextAlign.center,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          icon: const Icon(Icons.view_in_ar),
          label: Text(_scanning ? 'Stop Scan' : 'Start Scan'),
          onPressed: _scanning ? _stop : _start,
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: const Icon(Icons.download),
          label: const Text('Export OBJ'),
          onPressed: _scanning ? () => _export('obj') : null,
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: const Icon(Icons.download),
          label: const Text('Export USDZ'),
          onPressed: _scanning ? () => _export('usdz') : null,
        ),
        const SizedBox(height: 24),
        if (_lastPath != null) ...[
          const Text('Last exported file:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          SelectableText(_lastPath!),
        ],
        const Spacer(),
        const Text(
          'Tip: scan slowly, move around the object, and call Export while '
          'the scanner is still open.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
