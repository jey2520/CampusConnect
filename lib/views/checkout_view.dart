import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../models/product_model.dart';

class CheckoutView extends ConsumerStatefulWidget {
  final String productId;

  const CheckoutView({super.key, required this.productId});

  @override
  ConsumerState<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends ConsumerState<CheckoutView> {
  String _selectedDelivery = 'handover'; // handover, dorm
  String _selectedPayment = 'upi'; // upi, pickup

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
    final theme = Theme.of(context);

    final product = productState.products.firstWhere(
      (p) => p.id == widget.productId,
      orElse: () => ProductModel(
        id: '',
        title: 'Product not found',
        price: 0,
        negotiable: false,
        condition: '',
        category: '',
        college: '',
        description: '',
        image: '',
        images: [],
        sellerUid: '',
        sellerName: '',
        sellerRating: '',
        sellerInitials: '',
        status: '',
        views: 0,
        createdAt: DateTime.now(),
      ),
    );

    if (product.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
        body: const Center(child: Text('Product not found.')),
      );
    }

    final subtotal = product.price;
    final deliveryFee = _selectedDelivery == 'dorm' ? 40.0 : 0.0;
    final total = subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onBackground),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Secure Checkout',
          style: TextStyle(fontWeight: FontWeight.extrabold, color: theme.colorScheme.onBackground),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product card summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.onBackground.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${product.price}',
                          style: TextStyle(
                            fontWeight: FontWeight.extrabold,
                            color: theme.colorScheme.primary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Delivery Options
            const Text('Delivery Option', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5, color: Colors.grey)),
            const SizedBox(height: 8),
            _buildOptionCard(
              context,
              isSelected: _selectedDelivery == 'handover',
              title: 'Campus Handover',
              subtitle: 'Meet the seller at library or canteen',
              trailing: 'FREE',
              onTap: () => setState(() => _selectedDelivery = 'handover'),
            ),
            const SizedBox(height: 10),
            _buildOptionCard(
              context,
              isSelected: _selectedDelivery == 'dorm',
              title: 'Deliver to Dorm',
              subtitle: 'Courier brings it directly to your room',
              trailing: '+₹40',
              onTap: () => setState(() => _selectedDelivery = 'dorm'),
            ),
            const SizedBox(height: 24),

            // Payment Options
            const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5, color: Colors.grey)),
            const SizedBox(height: 8),
            _buildOptionCard(
              context,
              isSelected: _selectedPayment == 'upi',
              title: 'UPI / Google Pay',
              subtitle: 'Instant authorization & secure transfer',
              trailing: '',
              onTap: () => setState(() => _selectedPayment = 'upi'),
            ),
            const SizedBox(height: 10),
            _buildOptionCard(
              context,
              isSelected: _selectedPayment == 'pickup',
              title: 'Pay on Pickup',
              subtitle: 'Cash or UPI during student handover',
              trailing: '',
              onTap: () => setState(() => _selectedPayment = 'pickup'),
            ),
            const SizedBox(height: 24),

            // Order Summary Card
            const Text('Order Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.onBackground.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      const Text('Subtotal', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Text('₹$subtotal', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      const Text('Delivery fee', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Text('₹$deliveryFee', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      const Text('Total Amount', style: TextStyle(fontSize: 15, fontWeight: FontWeight.extrabold)),
                      Text('₹$total', style: TextStyle(fontSize: 15, fontWeight: FontWeight.extrabold, color: theme.colorScheme.primary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: () async {
                final user = ref.read(authProvider).userModel;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please log in to place an order.'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                // Show loading indicator dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );

                try {
                  final String orderId = FirebaseFirestore.instance.collection('orders').doc().id;
                  await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
                    'buyerUID': user.id,
                    'sellerUID': product.sellerUid,
                    'listingID': product.id,
                    'status': 'Pending',
                    'createdAt': FieldValue.serverTimestamp(),
                    'title': product.title,
                    'price': product.price,
                    'image': product.image,
                  });

                  // Update product status to sold
                  await FirebaseFirestore.instance.collection('items').doc(product.id).update({
                    'status': 'sold',
                  });

                  // Refresh local product cache
                  ref.read(productProvider.notifier).fetchProducts();

                  if (!mounted) return;
                  Navigator.pop(context); // Dismiss loading dialog
                  context.pushReplacement('/tracking');
                } catch (e) {
                  if (!mounted) return;
                  Navigator.pop(context); // Dismiss loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error placing order: $e'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Place Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required bool isSelected,
    required String title,
    required String subtitle,
    required String trailing,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withOpacity(0.03) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onBackground.withOpacity(0.05),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 10, color: theme.colorScheme.onBackground.withOpacity(0.4)),
                  ),
                ],
              ),
            ),
            if (trailing.isNotEmpty)
              Text(
                trailing,
                style: TextStyle(fontWeight: FontWeight.black, color: theme.colorScheme.primary, fontSize: 13),
              ),
          ],
        ),
      ),
    );
  }
}
