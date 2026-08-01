import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';

class MyListingsView extends ConsumerStatefulWidget {
  const MyListingsView({super.key});

  @override
  ConsumerState<MyListingsView> createState() => _MyListingsViewState();
}

class _MyListingsViewState extends ConsumerState<MyListingsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    final myUid = authState.userModel?.uid ?? '';
    final myListings = productState.products.where((p) => p.sellerUid == myUid).toList();

    final activeListings = myListings.where((p) => p.status == 'active').toList();
    final soldListings = myListings.where((p) => p.status == 'sold').toList();
    final draftListings = myListings.where((p) => p.status == 'draft').toList();

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
          'My Listings',
          style: TextStyle(fontWeight: FontWeight.extrabold, color: theme.colorScheme.onBackground),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onBackground.withOpacity(0.4),
          indicatorColor: theme.colorScheme.primary,
          tabs: [
            Tab(text: 'Active (${activeListings.length})'),
            Tab(text: 'Sold (${soldListings.length})'),
            Tab(text: 'Drafts (${draftListings.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListingsTab(context, activeListings, isSold: false),
          _buildListingsTab(context, soldListings, isSold: true),
          _buildListingsTab(context, draftListings, isSold: false),
        ],
      ),
    );
  }

  Widget _buildListingsTab(BuildContext context, List myList, {required bool isSold}) {
    final theme = Theme.of(context);
    
    if (myList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: theme.colorScheme.onBackground.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No items in this category',
              style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.4)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: myList.length,
      itemBuilder: (context, index) {
        final product = myList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        product.image,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 72,
                          height: 72,
                          color: theme.colorScheme.surfaceVariant,
                          child: const Icon(Icons.broken_image_rounded),
                        ),
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
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.visibility_outlined, size: 12, color: theme.colorScheme.onBackground.withOpacity(0.4)),
                              const SizedBox(width: 4),
                              Text(
                                '${product.views} views',
                                style: TextStyle(fontSize: 11, color: theme.colorScheme.onBackground.withOpacity(0.4)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Delete Button
                    TextButton.icon(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () => _confirmDelete(context, product.id),
                    ),
                    const SizedBox(width: 8),
                    // Status Action
                    if (!isSold)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                        label: const Text('Mark Sold'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          ref.read(productProvider.notifier).updateProductStatus(product.id, 'sold');
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to remove this product listing permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(productProvider.notifier).deleteProduct(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
