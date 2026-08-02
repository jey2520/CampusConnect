import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';

class TrackingView extends ConsumerStatefulWidget {
  const TrackingView({super.key});

  @override
  ConsumerState<TrackingView> createState() => _TrackingViewState();
}

class _TrackingViewState extends ConsumerState<TrackingView> {
  int _selectedTab = 0; // 0: Active, 1: Completed, 2: Cancelled
  String? _selectedOrderId;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.userModel;
    final theme = Theme.of(context);

    if (user == null) {
      return Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0.5,
          title: const Text('Order Tracking'),
          centerTitle: true,
        ),
        body: const Center(child: Text('Please log in to track your orders.')),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('buyerUID', isEqualTo: user.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: theme.colorScheme.background,
            appBar: AppBar(
              backgroundColor: theme.colorScheme.surface,
              elevation: 0.5,
              title: const Text('Order Tracking'),
              centerTitle: true,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: theme.colorScheme.background,
            appBar: AppBar(
              backgroundColor: theme.colorScheme.surface,
              elevation: 0.5,
              title: const Text('Order Tracking'),
              centerTitle: true,
            ),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final allOrders = snapshot.data?.docs ?? [];

        // Split into Active, Completed, and Cancelled
        final activeOrders = allOrders.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status'] as String? ?? 'Pending';
          return status != 'Delivered' && status != 'Cancelled';
        }).toList();

        final completedOrders = allOrders.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status'] as String? ?? 'Pending';
          return status == 'Delivered';
        }).toList();

        final cancelledOrders = allOrders.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status'] as String? ?? 'Pending';
          return status == 'Cancelled';
        }).toList();

        // If there's exactly 1 active order, auto-select it when on active tab
        if (_selectedTab == 0 && activeOrders.length == 1 && _selectedOrderId == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _selectedOrderId = activeOrders[0].id;
              });
            }
          });
        }

        // Determine if we should show a detailed tracking page or the list/empty view
        final isDetailView = _selectedOrderId != null;
        DocumentSnapshot? currentOrder;
        if (isDetailView) {
          currentOrder = allOrders.firstWhere(
            (doc) => doc.id == _selectedOrderId,
            orElse: () => allOrders.first, // Fallback
          );
        }

        return Scaffold(
          backgroundColor: theme.colorScheme.background,
          appBar: AppBar(
            backgroundColor: theme.colorScheme.surface,
            elevation: 0.5,
            leading: IconButton(
              icon: Icon(
                Navigator.of(context).canPop()
                    ? Icons.arrow_back_ios_new_rounded
                    : Icons.home_rounded,
                color: theme.colorScheme.onBackground,
              ),
              onPressed: () {
                if (isDetailView && _selectedOrderId != null && allOrders.length > 1) {
                  setState(() {
                    _selectedOrderId = null;
                  });
                } else {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    context.go('/home');
                  }
                }
              },
            ),
            title: Text(
              isDetailView ? 'Order Details' : 'Order Tracking',
              style: TextStyle(fontWeight: FontWeight.extrabold, color: theme.colorScheme.onBackground),
            ),
            centerTitle: true,
          ),
          body: isDetailView
              ? _buildOrderTracker(currentOrder!, theme, user.id)
              : Column(
                  children: [
                    // Tab Bar selection switcher
                    Container(
                      color: theme.colorScheme.surface,
                      child: Row(
                        children: [
                          _buildTabButton('Active (${activeOrders.length})', 0),
                          _buildTabButton('Completed (${completedOrders.length})', 1),
                          _buildTabButton('Cancelled (${cancelledOrders.length})', 2),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _buildTabContent(activeOrders, completedOrders, cancelledOrders, theme),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildTabButton(String title, int tabIndex) {
    final isSelected = _selectedTab == tabIndex;
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = tabIndex;
            _selectedOrderId = null; // Reset selection
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                width: 2.0,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? theme.colorScheme.primary : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(
    List<DocumentSnapshot> active,
    List<DocumentSnapshot> completed,
    List<DocumentSnapshot> cancelled,
    ThemeData theme,
  ) {
    if (_selectedTab == 0) {
      return active.isEmpty ? _buildEmptyState(theme, 'No Active Orders', "You haven't placed any orders yet.", true) : _buildOrderList(active, theme);
    } else if (_selectedTab == 1) {
      return completed.isEmpty ? _buildEmptyState(theme, 'No Completed Orders', 'Your completed orders will show up here.', false) : _buildOrderList(completed, theme);
    } else {
      return cancelled.isEmpty ? _buildEmptyState(theme, 'No Cancelled Orders', 'Your cancelled orders will show up here.', false) : _buildOrderList(cancelled, theme);
    }
  }

  Widget _buildEmptyState(ThemeData theme, String title, String description, bool showButton) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.extrabold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onBackground.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
            if (showButton) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'Browse Marketplace',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<DocumentSnapshot> orders, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 120),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final doc = orders[index];
        final data = doc.data() as Map<String, dynamic>;
        final String orderId = doc.id;
        final String orderTitle = data['title'] as String? ?? 'Campus Product';
        final double orderPrice = (data['price'] as num?)?.toDouble() ?? 0.0;
        final String orderImage = data['image'] as String? ?? '';
        final String orderStatus = data['status'] as String? ?? 'Pending';
        final String? cancelledBy = data['cancelledBy'] as String?;

        String displayStatus = orderStatus;
        if (orderStatus == 'Cancelled' && cancelledBy != null) {
          displayStatus = 'Cancelled by $cancelledBy';
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0.5,
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: orderImage.isNotEmpty
                  ? Image.network(
                      orderImage,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image),
                      ),
                    )
                  : Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[200],
                      child: const Icon(Icons.shopping_bag),
                    ),
            ),
            title: Text(
              orderTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('₹$orderPrice', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(orderStatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    displayStatus,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(orderStatus),
                    ),
                  ),
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () {
              setState(() {
                _selectedOrderId = orderId;
              });
            },
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.grey;
      case 'On the Way':
      case 'Picked Up':
        return Colors.blue;
      case 'Preparing':
      case 'Accepted':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  int _getStatusStep(String status) {
    switch (status) {
      case 'Pending':
        return 0;
      case 'Accepted':
        return 1;
      case 'Preparing':
        return 2;
      case 'Picked Up':
        return 3;
      case 'On the Way':
        return 4;
      case 'Delivered':
        return 5;
      default:
        return 0;
    }
  }

  Widget _buildOrderTracker(DocumentSnapshot doc, ThemeData theme, String currentUserUid) {
    final data = doc.data() as Map<String, dynamic>;
    final String status = data['status'] as String? ?? 'Pending';
    final int currentStep = _getStatusStep(status);
    final isCancelled = status == 'Cancelled';
    final String? cancelledBy = data['cancelledBy'] as String?;

    final String buyerUID = data['buyerUID'] as String? ?? '';
    final String sellerUID = data['sellerUID'] as String? ?? '';
    final isBuyer = currentUserUid == buyerUID;
    final isSeller = currentUserUid == sellerUID;

    final canCancel = status == 'Pending' || status == 'Accepted' || status == 'Preparing';
    final showBuyerOnWayWarning = isBuyer && !canCancel && status != 'Delivered' && status != 'Cancelled';

    double markerX = 30.0;
    double markerY = 80.0;
    bool showMarker = !isCancelled;
    String statusDesc = '';

    switch (status) {
      case 'Pending':
        markerX = 30.0;
        markerY = 80.0;
        statusDesc = 'Awaiting seller confirmation...';
        break;
      case 'Accepted':
        markerX = 30.0;
        markerY = 80.0;
        statusDesc = 'Seller accepted your order!';
        break;
      case 'Preparing':
        markerX = 30.0;
        markerY = 80.0;
        statusDesc = 'Seller is preparing your package...';
        break;
      case 'Picked Up':
        markerX = 80.0;
        markerY = 80.0;
        statusDesc = 'Courier picked up package!';
        break;
      case 'On the Way':
        markerX = 160.0;
        markerY = 60.0;
        statusDesc = 'Courier is transit-bound...';
        break;
      case 'Delivered':
        markerX = 250.0;
        markerY = 40.0;
        statusDesc = 'Order delivered successfully!';
        break;
      case 'Cancelled':
        showMarker = false;
        statusDesc = cancelledBy != null ? 'Cancelled by $cancelledBy' : 'Order was cancelled.';
        break;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isCancelled) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cancel_rounded, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cancelledBy != null ? 'Cancelled by $cancelledBy' : 'Order Cancelled',
                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Map Visual Card Container (Greyed out if Cancelled)
          Opacity(
            opacity: isCancelled ? 0.5 : 1.0,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.colorScheme.onBackground.withOpacity(0.05)),
              ),
              child: Column(
                children: [
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
                        CustomPaint(
                          size: const Size(double.infinity, 120),
                          painter: MapPathPainter(
                            primaryColor: isCancelled ? Colors.grey : theme.colorScheme.primary,
                            markerX: markerX,
                            markerY: markerY,
                            showMarker: showMarker,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        isCancelled ? Icons.cancel_outlined : Icons.local_shipping,
                        color: isCancelled ? Colors.grey : const Color(0xFF6C4CF7),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          statusDesc,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isCancelled ? Colors.grey : theme.colorScheme.onBackground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Stepper UI (Greyed out if Cancelled)
          Opacity(
            opacity: isCancelled ? 0.4 : 1.0,
            child: _buildStepper(theme, currentStep, status),
          ),
          const SizedBox(height: 24),

          // Action Buttons: Cancel Button / Buyer On Way Warning
          if (canCancel) ...[
            OutlinedButton(
              onPressed: () => _showCancelConfirmation(context, doc, isBuyer ? 'Buyer' : 'Seller'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Cancel Order', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
          ] else if (showBuyerOnWayWarning) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Your order is already on the way and can no longer be cancelled.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedOrderId = null;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
              foregroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('Back to Orders List', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context, DocumentSnapshot orderDoc, String cancelledByRole) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel this Order?'),
        content: const Text(
          'Are you sure you want to cancel this order?\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Order', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelOrder(context, orderDoc, cancelledByRole);
            },
            child: const Text('Cancel Order', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelOrder(BuildContext context, DocumentSnapshot orderDoc, String cancelledByRole) async {
    final data = orderDoc.data() as Map<String, dynamic>;
    final String orderId = orderDoc.id;
    final String buyerUID = data['buyerUID'] as String? ?? '';
    final String sellerUID = data['sellerUID'] as String? ?? '';
    final String listingID = data['listingID'] as String? ?? '';
    final String title = data['title'] as String? ?? 'Campus Product';

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final batch = FirebaseFirestore.instance.batch();

      // 1. Update order document status
      final orderRef = FirebaseFirestore.instance.collection('orders').doc(orderId);
      batch.update(orderRef, {
        'status': 'Cancelled',
        'cancelledBy': cancelledByRole,
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      // 2. Make the product listing available again
      final itemRef = FirebaseFirestore.instance.collection('items').doc(listingID);
      batch.update(itemRef, {
        'status': 'active',
      });

      // 3. Create notifications for BOTH Buyer and Seller
      final buyerNotificationRef = FirebaseFirestore.instance.collection('notifications').doc();
      final sellerNotificationRef = FirebaseFirestore.instance.collection('notifications').doc();

      final String buyerNotifBody = cancelledByRole == 'Buyer'
          ? 'You cancelled your order for $title.'
          : 'Seller cancelled your order for $title.';
      
      final String sellerNotifBody = cancelledByRole == 'Buyer'
          ? 'Buyer cancelled the order for $title.'
          : 'You cancelled the order for $title.';

      batch.set(buyerNotificationRef, {
        'userUid': buyerUID,
        'title': 'Order Cancelled',
        'body': buyerNotifBody,
        'type': 'order',
        'referenceId': orderId,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      batch.set(sellerNotificationRef, {
        'userUid': sellerUID,
        'title': 'Order Cancelled',
        'body': sellerNotifBody,
        'type': 'order',
        'referenceId': orderId,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (!mounted) return;
      Navigator.pop(context); // Dismiss loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order cancelled successfully.'),
          backgroundColor: Colors.grey,
        ),
      );

      setState(() {
        _selectedOrderId = null; // Return to list view
      });
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Dismiss loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildStepper(ThemeData theme, int currentStep, String status) {
    final isCancelled = status == 'Cancelled';
    return Column(
      children: [
        _buildStepItem(theme, currentStep, index: 0, title: 'Order Placed', time: 'Completed', isCancelled: isCancelled),
        _buildStepDivider(currentStep, 0),
        _buildStepItem(theme, currentStep, index: 1, title: 'Accepted by Seller', time: currentStep >= 1 ? 'Completed' : 'Pending', isCancelled: isCancelled),
        _buildStepDivider(currentStep, 1),
        _buildStepItem(theme, currentStep, index: 2, title: 'Preparing Package', time: currentStep >= 2 ? 'Completed' : 'Pending', isCancelled: isCancelled),
        _buildStepDivider(currentStep, 2),
        _buildStepItem(theme, currentStep, index: 3, title: 'Courier Picked Up', time: currentStep >= 3 ? 'Completed' : 'Pending', isCancelled: isCancelled),
        _buildStepDivider(currentStep, 3),
        _buildStepItem(theme, currentStep, index: 4, title: 'On the Way', time: currentStep >= 4 ? 'Completed' : 'Pending', isCancelled: isCancelled),
        _buildStepDivider(currentStep, 4),
        _buildStepItem(theme, currentStep, index: 5, title: 'Delivered', time: currentStep >= 5 ? 'Completed' : 'Pending', isCancelled: isCancelled),
      ],
    );
  }

  Widget _buildStepItem(ThemeData theme, int currentStep, {required int index, required String title, required String time, required bool isCancelled}) {
    final isActive = currentStep >= index;
    final isCompleted = currentStep > index;

    IconData icon;
    if (isCompleted) {
      icon = Icons.check;
    } else if (index == 5) {
      icon = Icons.verified;
    } else {
      icon = Icons.local_shipping;
    }

    Color color;
    if (isCancelled) {
      color = Colors.grey.withOpacity(0.2);
      icon = Icons.close;
    } else if (isCompleted) {
      color = Colors.green;
    } else if (isActive) {
      color = theme.colorScheme.primary;
    } else {
      color = Colors.grey.withOpacity(0.2);
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: color,
          child: Icon(
            icon,
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
          key: ValueKey('step-$index'),
        ),
      ],
    );
  }

  Widget _buildStepDivider(int currentStep, int afterIndex) {
    final isActive = currentStep > afterIndex;
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
  final bool showMarker;

  MapPathPainter({
    required this.primaryColor,
    required this.markerX,
    required this.markerY,
    required this.showMarker,
  });

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
    nodePaint.color = Colors.redAccent.withOpacity(primaryColor == Colors.grey ? 0.4 : 1.0);
    canvas.drawCircle(const Offset(30, 80), 6, nodePaint);

    // Buyer Node
    nodePaint.color = const Color(0xFF00D4A6).withOpacity(primaryColor == Colors.grey ? 0.4 : 1.0);
    canvas.drawCircle(const Offset(250, 40), 6, nodePaint);

    if (showMarker) {
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
  }

  @override
  bool shouldRepaint(covariant MapPathPainter oldDelegate) {
    return oldDelegate.markerX != markerX || oldDelegate.markerY != markerY || oldDelegate.showMarker != showMarker || oldDelegate.primaryColor != primaryColor;
  }
}
