import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/product_provider.dart';

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(productProvider).filter.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet(BuildContext context, ProductState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            final currentFilter = state.filter;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onBackground.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Filter & Sort',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.extrabold),
                  ),
                  const SizedBox(height: 20),

                  // Category Selector
                  const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: currentFilter.category,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    items: ['All', 'Books', 'Electronics', 'Cycles', 'Calculators', 'Furniture', 'Lab Equipment', 'Lab Coat', 'Sports', 'Fashion', 'Accessories', 'Hostel', 'Miscellaneous']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) {
                      setModalState(() {
                        ref.read(productProvider.notifier).updateFilter(currentFilter.copyWith(category: val));
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Price Range
                  Text(
                    'Price Range (₹${currentFilter.minPrice.round()} - ₹${currentFilter.maxPrice.round()})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  RangeSlider(
                    values: RangeValues(currentFilter.minPrice, currentFilter.maxPrice),
                    min: 0.0,
                    max: 100000.0,
                    divisions: 100,
                    labels: RangeLabels('₹${currentFilter.minPrice.round()}', '₹${currentFilter.maxPrice.round()}'),
                    onChanged: (values) {
                      setModalState(() {
                        ref.read(productProvider.notifier).updateFilter(
                          currentFilter.copyWith(minPrice: values.start, maxPrice: values.end),
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Condition
                  const Text('Condition', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: currentFilter.condition,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    items: ['All', 'Brand New', 'Like New', 'Gently Used', 'Heavily Used']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) {
                      setModalState(() {
                        ref.read(productProvider.notifier).updateFilter(currentFilter.copyWith(condition: val));
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Sort By
                  const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: currentFilter.sortBy,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    items: const [
                      DropdownMenuItem(value: 'newest', child: Text('Newest Listings')),
                      DropdownMenuItem(value: 'oldest', child: Text('Oldest Listings')),
                      DropdownMenuItem(value: 'low_price', child: Text('Price: Low to High')),
                      DropdownMenuItem(value: 'high_price', child: Text('Price: High to Low')),
                    ],
                    onChanged: (val) {
                      setModalState(() {
                        ref.read(productProvider.notifier).updateFilter(currentFilter.copyWith(sortBy: val));
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0.5,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onBackground),
                onPressed: () {
                  ref.read(productProvider.notifier).updateFilter(ProductFilter());
                  context.pop();
                },
              )
            : null,
        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(productProvider.notifier).updateFilter(
                              productState.filter.copyWith(searchQuery: ''),
                            );
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onChanged: (val) {
              ref.read(productProvider.notifier).updateFilter(
                    productState.filter.copyWith(searchQuery: val),
                  );
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => _showFilterBottomSheet(context, productState),
          ),
        ],
      ),
      body: productState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : productState.filteredProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 64, color: theme.colorScheme.onBackground.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text(
                        'No matches found for your query',
                        style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.4)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 120),
                  itemCount: productState.filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = productState.filteredProducts[index];
                    return GestureDetector(
                      onTap: () => context.push('/product-details/${product.id}'),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  product.image,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 80,
                                    height: 80,
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
                                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹${product.price}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.extrabold,
                                        color: theme.colorScheme.primary,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.background,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            product.condition,
                                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          product.college,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: theme.colorScheme.onBackground.withOpacity(0.5),
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
                      ),
                    );
                  },
                ),
    );
  }
}
