import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_tokens.dart';
import '../../services/open_food_facts_service.dart';
import '../../src/domain/entities/food_item.dart';

/// Full-screen live barcode scanner for packaged food lookup.
///
/// On first launch shows an animated tutorial overlay (stored in SharedPreferences).
/// On barcode detection, queries Open Food Facts and pops with a [FoodItem] result.
class BarcodeScannerView extends StatefulWidget {
  const BarcodeScannerView({super.key});

  @override
  State<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}
class _BarcodeScannerViewState extends State<BarcodeScannerView>
    with TickerProviderStateMixin {
  static const _tutorialKey = 'barcode_scanner_seen';

  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _showTutorial = false;
  bool _isLookingUp = false;
  bool _hasScanned = false;
  String _statusText = 'Point camera at a barcode';
  String? _errorText;

  // Tutorial animations
  late final AnimationController _scanLineCtrl;
  late final Animation<double> _scanLineAnim;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  // Scanner overlay animation
  late final AnimationController _overlayLineCtrl;
  late final Animation<double> _overlayLineAnim;

  @override
  void initState() {
    super.initState();

    // Scanner sweep line
    _overlayLineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _overlayLineAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _overlayLineCtrl, curve: Curves.easeInOut),
    );

    // Tutorial scan line
    _scanLineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _scanLineAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanLineCtrl, curve: Curves.easeInOut),
    );

    // Tutorial corner pulse
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _checkTutorial();
  }
  Future<void> _checkTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_tutorialKey) ?? false;
    if (!seen && mounted) {
      setState(() => _showTutorial = true);
    }
  }

  Future<void> _dismissTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialKey, true);
    if (mounted) setState(() => _showTutorial = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scanLineCtrl.dispose();
    _pulseCtrl.dispose();
    _overlayLineCtrl.dispose();
    super.dispose();
  }

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (_hasScanned || _isLookingUp || _showTutorial) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;
    final code = barcode.rawValue!;
    if (!mounted) return;

    setState(() {
      _hasScanned = true;
      _isLookingUp = true;
      _statusText = 'Found barcode! Looking up product...';
      _errorText = null;
    });

    await _controller.stop();

    try {
      final item = await OpenFoodFactsService.lookup(code);
      if (!mounted) return;

      if (item != null) {
        Navigator.pop(context, item);
      } else {
        setState(() {
          _isLookingUp = false;
          _hasScanned = false;
          _errorText = 'Product not found in database.\nTry scanning again or enter manually.';
          _statusText = 'Product not found';
        });
        await _controller.start();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLookingUp = false;
        _hasScanned = false;
        _errorText = 'Unable to look up product.\nCheck your internet connection.';
        _statusText = 'Connection error';
      });
      await _controller.start();
    }
  }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Live camera feed ──
          MobileScanner(
            controller: _controller,
            onDetect: _onBarcodeDetected,
          ),

          // ── Scanner frame overlay ──
          if (!_showTutorial) _buildScannerOverlay(),

          // ── AppBar ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: _buildAppBar(isDark),
            ),
          ),

          // ── Bottom status panel ──
          if (!_showTutorial)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildStatusPanel(isDark),
            ),

          // ── Tutorial overlay ──
          if (_showTutorial)
            _BarcodeTutorialOverlay(
              scanLineAnimation: _scanLineAnim,
              pulseAnimation: _pulseAnim,
              onDismiss: _dismissTutorial,
            ),

          // ── Loading overlay ──
          if (_isLookingUp)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: AppThemeTokens.brandPrimary,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Looking up product...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  Widget _buildAppBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Scan Barcode',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.flashlight_on, color: Colors.white),
            tooltip: 'Toggle torch',
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return AnimatedBuilder(
      animation: _overlayLineAnim,
      builder: (context, _) {
        return CustomPaint(
          painter: _ScannerOverlayPainter(
            scanProgress: _overlayLineAnim.value,
            hasError: _errorText != null,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildStatusPanel(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_errorText != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppThemeTokens.error.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
              ),
              child: Text(
                _errorText!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            _statusText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Supported: EAN-13, UPC-A, QR codes',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ── Scanner Frame Overlay Painter ─────────────────────────────────────────────

class _ScannerOverlayPainter extends CustomPainter {
  final double scanProgress;
  final bool hasError;

  const _ScannerOverlayPainter({
    required this.scanProgress,
    required this.hasError,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final frameColor = hasError ? AppThemeTokens.error : AppThemeTokens.brandPrimary;
    final frameW = size.width * 0.72;
    final frameH = frameW * 0.55;
    final left = (size.width - frameW) / 2;
    final top = (size.height - frameH) / 2 - 30;
    final right = left + frameW;
    final bottom = top + frameH;
    const cornerLen = 28.0;
    const cornerStroke = 4.0;

    // Dim everything outside the scan frame
    final dimPaint = Paint()..color = Colors.black.withValues(alpha: 0.55);
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, top), dimPaint);
    canvas.drawRect(Rect.fromLTRB(0, bottom, size.width, size.height), dimPaint);
    canvas.drawRect(Rect.fromLTRB(0, top, left, bottom), dimPaint);
    canvas.drawRect(Rect.fromLTRB(right, top, size.width, bottom), dimPaint);

    // Corner brackets
    final cornerPaint = Paint()
      ..color = frameColor
      ..strokeWidth = cornerStroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-left
    canvas.drawLine(Offset(left, top + cornerLen), Offset(left, top), cornerPaint);
    canvas.drawLine(Offset(left, top), Offset(left + cornerLen, top), cornerPaint);
    // Top-right
    canvas.drawLine(Offset(right - cornerLen, top), Offset(right, top), cornerPaint);
    canvas.drawLine(Offset(right, top), Offset(right, top + cornerLen), cornerPaint);
    // Bottom-left
    canvas.drawLine(Offset(left, bottom - cornerLen), Offset(left, bottom), cornerPaint);
    canvas.drawLine(Offset(left, bottom), Offset(left + cornerLen, bottom), cornerPaint);
    // Bottom-right
    canvas.drawLine(Offset(right - cornerLen, bottom), Offset(right, bottom), cornerPaint);
    canvas.drawLine(Offset(right, bottom), Offset(right, bottom - cornerLen), cornerPaint);

    // Animated scan line
    if (!hasError) {
      final scanY = top + (bottom - top) * scanProgress;
      final scanPaint = Paint()
        ..color = AppThemeTokens.brandPrimary
        ..strokeWidth = 2.5
        ..shader = LinearGradient(
          colors: [
            AppThemeTokens.brandPrimary.withValues(alpha: 0.0),
            AppThemeTokens.brandPrimary,
            AppThemeTokens.brandPrimary.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTRB(left, scanY, right, scanY + 1));
      canvas.drawLine(Offset(left + 4, scanY), Offset(right - 4, scanY), scanPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter old) =>
      old.scanProgress != scanProgress || old.hasError != hasError;
}

// ── First-Time Tutorial Overlay ──────────────────────────────────────────────────

class _BarcodeTutorialOverlay extends StatelessWidget {
  final Animation<double> scanLineAnimation;
  final Animation<double> pulseAnimation;
  final VoidCallback onDismiss;

  const _BarcodeTutorialOverlay({
    required this.scanLineAnimation,
    required this.pulseAnimation,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.92),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'How to Scan a Barcode',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Animated barcode illustration
              ScaleTransition(
                scale: pulseAnimation,
                child: SizedBox(
                  height: 140,
                  child: AnimatedBuilder(
                    animation: scanLineAnimation,
                    builder: (context, _) => CustomPaint(
                      painter: _TutorialBarcodePainter(
                        scanProgress: scanLineAnimation.value,
                      ),
                      size: const Size(double.infinity, 140),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Step instructions
              _TutorialStep(
                number: '1',
                icon: Icons.crop_free,
                text: 'Hold your camera 15–30 cm from the barcode on the package',
              ),
              const SizedBox(height: 16),
              _TutorialStep(
                number: '2',
                icon: Icons.center_focus_strong,
                text: 'Keep the barcode fully inside the scanning frame',
              ),
              const SizedBox(height: 16),
              _TutorialStep(
                number: '3',
                icon: Icons.bolt,
                text: 'Hold steady — it detects and looks up nutrition automatically',
              ),

              const SizedBox(height: 40),

              // CTA button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onDismiss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemeTokens.brandPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Got it!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TutorialStep extends StatelessWidget {
  final String number;
  final IconData icon;
  final String text;

  const _TutorialStep({
    required this.number,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppThemeTokens.brandPrimary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppThemeTokens.brandPrimary, size: 20),
              const SizedBox(height: 4),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Tutorial Barcode Painter ─────────────────────────────────────────────────────────────

class _TutorialBarcodePainter extends CustomPainter {
  final double scanProgress;

  const _TutorialBarcodePainter({required this.scanProgress});

  // Fixed bar widths for a realistic-looking barcode
  static const _bars = [
    3.0, 1.0, 2.0, 1.0, 4.0, 1.0, 1.0, 3.0, 2.0, 1.0,
    3.0, 2.0, 1.0, 4.0, 1.0, 1.0, 2.0, 3.0, 1.0, 2.0,
    4.0, 1.0, 2.0, 1.0, 3.0, 2.0, 1.0, 1.0, 4.0, 2.0,
    1.0, 3.0, 2.0, 1.0, 1.0, 3.0,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 20.0;
    final frameLeft = padding;
    final frameRight = size.width - padding;
    final frameTop = 10.0;
    final frameBottom = size.height - 24.0;
    const barHeight = 85.0;
    final barTop = frameTop + (frameBottom - frameTop - barHeight) / 2;

    // Draw corner frame around barcode
    final framePaint = Paint()
      ..color = AppThemeTokens.brandPrimary.withValues(alpha: 0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    const cLen = 14.0;
    final corners = [
      [Offset(frameLeft, frameTop + cLen), Offset(frameLeft, frameTop), Offset(frameLeft + cLen, frameTop)],
      [Offset(frameRight - cLen, frameTop), Offset(frameRight, frameTop), Offset(frameRight, frameTop + cLen)],
      [Offset(frameLeft, frameBottom - cLen), Offset(frameLeft, frameBottom), Offset(frameLeft + cLen, frameBottom)],
      [Offset(frameRight - cLen, frameBottom), Offset(frameRight, frameBottom), Offset(frameRight, frameBottom - cLen)],
    ];
    for (final corner in corners) {
      canvas.drawLine(corner[0], corner[1], framePaint);
      canvas.drawLine(corner[1], corner[2], framePaint);
    }

    // Draw barcode bars
    final totalWeight = _bars.fold(0.0, (a, b) => a + b) + _bars.length * 0.5;
    final unitW = (frameRight - frameLeft - 20) / totalWeight;
    double x = frameLeft + 10;
    bool isBar = true;

    final barPaint = Paint()..style = PaintingStyle.fill;

    for (final w in _bars) {
      final barW = w * unitW;
      if (isBar) {
        barPaint.color = Colors.white.withValues(alpha: 0.85);
        canvas.drawRect(Rect.fromLTWH(x, barTop, barW, barHeight), barPaint);
      }
      x += barW + unitW * 0.5;
      isBar = !isBar;
    }

    // Number string below bars
    const numText = '4 012345 678901';
    final tp = TextPainter(
      text: TextSpan(
        text: numText,
        style: const TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 1.5),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(
      frameLeft + (frameRight - frameLeft - tp.width) / 2,
      barTop + barHeight + 6,
    ));

    // Animated red scan line
    final scanY = frameTop + (frameBottom - frameTop) * scanProgress;
    final scanPaint = Paint()
      ..strokeWidth = 2.5
      ..color = AppThemeTokens.error
      ..shader = LinearGradient(
        colors: [
          AppThemeTokens.error.withValues(alpha: 0.0),
          AppThemeTokens.error.withValues(alpha: 0.9),
          AppThemeTokens.error.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTRB(frameLeft, scanY, frameRight, scanY + 1));
    canvas.drawLine(Offset(frameLeft + 4, scanY), Offset(frameRight - 4, scanY), scanPaint);
  }

  @override
  bool shouldRepaint(covariant _TutorialBarcodePainter old) =>
      old.scanProgress != scanProgress;
}
