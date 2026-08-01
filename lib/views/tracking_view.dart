import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TrackingView extends ConsumerStatefulWidget {
  const TrackingView({super.key});

  @override
  ConsumerState<TrackingView> createState() => _TrackingViewState();
}

class _TrackingViewState extends ConsumerState<TrackingView> {
  int _currentStep = 0; // 0: Placed, 1: Picked Up, 2: On Way, 3: Near, 4: Delivered
  double _markerX = 30.0;
  double _markerY = 80.0;
  String _mapStatus = 'Seller is preparing package...';
  
  final List<String> _activityFeed = [
    'Order placed successfully. Awaiting seller confirmation.'
  ];

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  void _startSimulation() {
    // 3s: Picked Up
    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _currentStep = 1;
        _markerX = 80.0;
        _markerY = 80.0;
        _mapStatus = 'Courier picking up item...';
        _activityFeed.insert(0, 'Courier arrived at seller location. Picking up package.');
      });
    });

    // 6s: On the Way
    _timer = Timer(const Duration(seconds: 6), () {
      if (!mounted) return;
      setState(() {
        _currentStep = 2;
        _markerX = 130.0;
        _markerY = 80.0;
        _mapStatus = 'Courier is on the way...';
        _activityFeed.insert(0, 'Package picked up. Courier is transit-bound.');
      });
    });

    // 9s: Nearby 100m
    _timer = Timer(const Duration(seconds: 9), () {
      if (!mounted) return;
      setState(() {
        _currentStep = 3;
        _markerX = 130.0;
        _markerY = 40.0;
        _mapStatus = 'Courier is nearby (100m away)!';
        _activityFeed.insert(0, 'Courier is approaching your building (within 100m).');
      });
    });

    // 12s: Delivered
    _timer = Timer(const Duration(seconds: 12), () {
      if (!mounted) return;
      setState(() {
        _currentStep = 4;
        _markerX = 250.0;
        _markerY = 40.0;
        _mapStatus = 'Courier arrived! Handover completed.';
        _activityFeed.insert(0, 'Handover completed. Order delivered successfully!');
      });

      _showSuccessDialog();
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.stars, color: Colors.green),
            SizedBox(width: 10),
            Text('Order Delivered!'),
          ],
        ),
        content: const Text('Your student courier has completed the handover. Thank you for buying on CampusConnect!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/home');
            },
            child: const Text('Return to Home', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.home_rounded, color: theme.colorScheme.onBackground),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          'Order Tracking',
          style: TextStyle(fontWeight: FontWeight.extrabold, color: theme.colorScheme.onBackground),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Map Visual Card Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.colorScheme.onBackground.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  // Vector Map Canvas representing transit route
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark 
                          ? const Color(0xFF1D1F26) 
                          : const Color(0xFFF1F2F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        // Map grid line mockups
                        CustomPaint(
                          size: const Size(double.infinity, 120),
                          painter: MapPathPainter(
                            primaryColor: theme.colorScheme.primary,
                            markerX: _markerX,
                            markerY: _markerY,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Banner Details
                  Row(
                    children: [
                      const Icon(Icons.local_shipping, color: Color(0xFF6C4CF7)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _mapStatus,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stepper UI
            _buildStepper(theme),
            const SizedBox(height: 24),

            // Activity Log
            const Text('Activity Feed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5, color: Colors.grey)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.onBackground.withOpacity(0.05)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _activityFeed.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final log = _activityFeed[index];
                  final isLatest = index == 0;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isLatest ? theme.colorScheme.primary : Colors.grey.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isLatest ? FontWeight.bold : FontWeight.normal,
                                color: isLatest ? theme.colorScheme.onBackground : theme.colorScheme.onBackground.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text('Just Now', style: TextStyle(fontSize: 9, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
                foregroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Return to Home', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper(ThemeData theme) {
    return Column(
      children: [
        _buildStepItem(theme, index: 0, title: 'Order Placed', time: 'Just Now'),
        _buildStepDivider(0),
        _buildStepItem(theme, index: 1, title: 'Courier Picked Up', time: _currentStep >= 1 ? 'Just Now' : 'Pending'),
        _buildStepDivider(1),
        _buildStepItem(theme, index: 2, title: 'On the Way', time: _currentStep >= 2 ? 'Just Now' : 'Pending'),
        _buildStepDivider(2),
        _buildStepItem(theme, index: 3, title: 'Arriving (Near you 100m)', time: _currentStep >= 3 ? 'Just Now' : 'Pending'),
        _buildStepDivider(3),
        _buildStepItem(theme, index: 4, title: 'Delivered & Completed', time: _currentStep >= 4 ? 'Just Now' : 'Pending'),
      ],
    );
  }

  Widget _buildStepItem(ThemeData theme, {required int index, required String title, required String time}) {
    final isActive = _currentStep >= index;
    final isCompleted = _currentStep > index;

    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: isCompleted 
              ? Colors.green 
              : (isActive ? theme.colorScheme.primary : Colors.grey.withOpacity(0.2)),
          child: Icon(
            isCompleted ? Icons.check : (index == 4 ? Icons.verified : Icons.local_shipping),
            size: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isActive ? theme.colorScheme.onBackground : theme.colorScheme.onBackground.withOpacity(0.4),
                ),
              ),
              Text(
                time,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(int afterIndex) {
    final isActive = _currentStep > afterIndex;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 15),
        width: 2,
        height: 20,
        color: isActive ? Colors.green : Colors.grey.withOpacity(0.2),
      ),
    );
  }
}

class MapPathPainter extends CustomPainter {
  final Color primaryColor;
  final double markerX;
  final double markerY;

  MapPathPainter({required this.primaryColor, required this.markerX, required this.markerY});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

    // Draw grid background mockup
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // Path painter
    final pathPaint = Paint()
      ..color = primaryColor.withOpacity(0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(30, 80)
      ..lineTo(130, 80)
      ..lineTo(130, 40)
      ..lineTo(250, 40);

    canvas.drawPath(path, pathPaint);

    // Start / End Nodes
    final nodePaint = Paint()..style = PaintingStyle.fill;

    // Seller Node
    nodePaint.color = Colors.redAccent;
    canvas.drawCircle(const Offset(30, 80), 6, nodePaint);

    // Buyer Node
    nodePaint.color = const Color(0xFF00D4A6);
    canvas.drawCircle(const Offset(250, 40), 6, nodePaint);

    // Courier Marker Dot
    final markerPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(markerX, markerY), 7, markerPaint);
    
    // Pulse outer circle
    final pulsePaint = Paint()
      ..color = primaryColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(markerX, markerY), 12, pulsePaint);
  }

  @override
  bool shouldRepaint(covariant MapPathPainter oldDelegate) {
    return oldDelegate.markerX != markerX || oldDelegate.markerY != markerY;
  }
}
