import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

import '../widgets.dart';

/// Scan any ShilpSetu tag / certificate QR (at an exhibition or on a parcel) and verify it.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool handled = false;

  void _onDetect(BarcodeCapture cap) {
    if (handled) return;
    for (final b in cap.barcodes) {
      final raw = b.rawValue;
      if (raw == null) continue;
      final uri = Uri.tryParse(raw);
      final segs = uri?.pathSegments ?? const [];
      final i = segs.indexOf('v');
      if (uri != null && i >= 0 && i + 1 < segs.length) {
        handled = true;
        context.pushReplacement('/store/cert/${segs[i + 1]}?s=${Uri.encodeQueryComponent(uri.queryParameters['s'] ?? '')}');
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.scanQr)),
      backgroundColor: SS.tealDeep,
      body: Stack(children: [
        MobileScanner(onDetect: _onDetect),
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(border: Border.all(color: SS.marigold, width: 4), borderRadius: BorderRadius.circular(24)),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 32,
          child: Text(l.scanCertificate, textAlign: TextAlign.center, style: const TextStyle(color: SS.cream, fontSize: 18)),
        ),
      ]),
    );
  }
}
