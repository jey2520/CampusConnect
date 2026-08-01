import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/chat_provider.dart';
import '../models/product_model.dart';

class ProductDetailsView extends ConsumerWidget {
  final String productId;

  const ProductDetailsView({super.key, required this.productId});

  Future<void> _initiateChat(BuildContext context, WidgetRef ref, ProductModel product) async {
    final authState = ref.read(authProvider);
    final user = authState.userModel;

    if (user == null) return;
    if (product.sellerUid == user.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You cannot chat with yourself about your own product."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final chatId = await ref.read(chatProvider.notifier).getOrCreateChatRoom(
          otherUid: product.sellerUid,
          otherName: product.sellerName,
          otherAvatar: product.sellerInitials,
          productTitle: product.title,
        );

    if (context.mounted && chatId.isNotEmpty) {
      context.push('/chat-screen/$chatId');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch(productProvider);
    final theme = Theme.of(context);

    final product = productState.products.firstWhere(
      (p) => p.id == productId,
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
        body: const Center(child: Text('Product could not be found or has been deleted.')),
      );
    }

    final isFav = productState.favoriteIds.contains(product.id);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Product Image Carousel (Hero)
                Stack(
                  children: [
                    Image.network(
                      product.image,
                      height: 320,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 320,
                        color: theme.colorScheme.surfaceVariant,
                        child: const Icon(Icons.broken_image_rounded, size: 48),
                      ),
                    ),
                    // Gradient shading overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.2),
                              Colors.transparent,
                              Colors.black.withOpacity(0.05),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Details Card Panel
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Tag & Views
                      Row(
                        mainAxisAlignment: MainAxisAlignment.between,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.category,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.visibility_outlined, size: 14, color: theme.colorScheme.onBackground.withOpacity(0.4)),
                              const SizedBox(width: 4),
                              Text(
                                '${product.views} views',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onBackground.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        product.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.extrabold,
                          color: theme.colorScheme.onBackground,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Price Row
                      Row(
                        children: [
                          Text(
                            '₹${product.price}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.black,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (product.negotiable)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00D4A6).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Negotiable',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00D4A6),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Condition, College Metadata Grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetaCard(
                              context,
                              icon: Icons.layers_outlined,
                              title: 'Condition',
                              value: product.condition,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetaCard(
                              context,
                              icon: Icons.school_outlined,
                              title: 'Location',
                              value: product.college,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Description
                      Text(
                        'Description',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.extrabold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onBackground.withOpacity(0.7),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Seller Card
                      Text(
                        'Seller Information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.extrabold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.colorScheme.onBackground.withOpacity(0.05)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                              child: Text(
                                product.sellerInitials,
                                style: TextStyle(
                                  fontWeight: FontWeight.extrabold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.sellerName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${product.sellerRating} Rating',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onBackground.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100), // Spacing for bottom CTA
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating Top App Bar Buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black87),
                    onPressed: () => context.pop(),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 18,
                      color: isFav ? Colors.red : Colors.black87,
                    ),
                    onPressed: () => ref.read(productProvider.notifier).toggleFavorite(product.id),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Fixed Action Call-To-Actions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(top: BorderSide(color: theme.colorScheme.onBackground.withOpacity(0.05))),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -4)),
                ],
              ),
              child: Row(
                children: [
                  // Secondary Outline Action: Chat
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _initiateChat(context, ref, product),
                      icon: const Icon(Icons.chat_bubble_outline_rounded),
                      label: const Text('Chat Seller'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Primary Action: Buy Now
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.push('/checkout/${product.id}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D4A6), // Green Buy Button
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text('Buy Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaCard(BuildContext context, {required IconData icon, required String title, required String value}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.onBackground.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
