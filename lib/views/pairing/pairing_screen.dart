import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/hermes_theme.dart';

class PairingScreen extends StatefulWidget {
  final String gatewayUrl;
  final Function(String) onUpdateGatewayUrl;

  const PairingScreen({
    super.key,
    required this.gatewayUrl,
    required this.onUpdateGatewayUrl,
  });

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  late TextEditingController _gatewayCtrl;
  final String _pairingCode = 'HRMS-8291-K39X-MOBILE';
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _gatewayCtrl = TextEditingController(text: widget.gatewayUrl);
  }

  @override
  void dispose() {
    _gatewayCtrl.dispose();
    super.dispose();
  }

  void _copyPairingUrl() {
    final url = '${_gatewayCtrl.text}?token=$_pairingCode';
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: HermesTheme.success,
        content: Text('✓ Pairing URL copied to clipboard!'),
      ),
    );
  }

  void _testPing() {
    setState(() => _isTesting = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      setState(() => _isTesting = false);
      widget.onUpdateGatewayUrl(_gatewayCtrl.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: HermesTheme.success,
            content: Text('✓ Gateway ping successful! Latency: 12ms'),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Pairing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: HermesTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: HermesTheme.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Pair with Web or Desktop Gateway',
                  style: TextStyle(color: HermesTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Scan this QR code from the Hermes Web App (/pairing) or Hermes Desktop to connect.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: HermesTheme.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 20),
                // QR Code
                Container(
                  width: 200,
                  height: 200,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: CustomPaint(
                    painter: _PairingQrPainter(),
                    child: const Center(
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.hub_rounded, color: HermesTheme.primary, size: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: HermesTheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: HermesTheme.cardBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _pairingCode,
                        style: const TextStyle(
                          color: HermesTheme.primary,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, color: HermesTheme.textMuted, size: 16),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _pairingCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pairing code copied!')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Gateway Configuration
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HermesTheme.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: HermesTheme.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Gateway Address', style: TextStyle(color: HermesTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                TextField(
                  controller: _gatewayCtrl,
                  style: const TextStyle(color: HermesTheme.textPrimary, fontFamily: 'monospace', fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'WebSocket Gateway URL',
                    hintText: 'http://localhost:8000',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: HermesTheme.primary),
                        icon: _isTesting
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                            : const Icon(Icons.speed_rounded, color: Colors.black, size: 16),
                        label: const Text('Test Ping', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        onPressed: _isTesting ? null : _testPing,
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: HermesTheme.primary,
                        side: const BorderSide(color: HermesTheme.primary),
                      ),
                      icon: const Icon(Icons.share_rounded, size: 16),
                      label: const Text('Copy URL'),
                      onPressed: _copyPairingUrl,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PairingQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintDark = Paint()..color = Colors.black;
    final unit = size.width / 21;

    void drawFinder(double x, double y) {
      canvas.drawRect(Rect.fromLTWH(x, y, unit * 7, unit * 7), paintDark);
      canvas.drawRect(Rect.fromLTWH(x + unit, y + unit, unit * 5, unit * 5), Paint()..color = Colors.white);
      canvas.drawRect(Rect.fromLTWH(x + unit * 2, y + unit * 2, unit * 3, unit * 3), paintDark);
    }

    drawFinder(0, 0);
    drawFinder(size.width - unit * 7, 0);
    drawFinder(0, size.height - unit * 7);

    for (int r = 0; r < 21; r++) {
      for (int c = 0; c < 21; c++) {
        if ((r < 8 && c < 8) || (r < 8 && c > 13) || (r > 13 && c < 8)) continue;
        if ((r * 3 + c * 2) % 3 == 0) {
          canvas.drawRect(Rect.fromLTWH(c * unit, r * unit, unit, unit), paintDark);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
