import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import 'search_view.dart';
import 'add_listing_view.dart';
import 'chats_view.dart';
import 'profile_view.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  int _currentIndex = 0;
  late final PageController _pageController;

  final List<Map<String, dynamic>> _categories = [
    {'id': 'Books', 'icon': Icons.menu_book_rounded, 'colors': [Colors.orange, Colors.red]},
    {'id': 'Electronics', 'icon': Icons.laptop_mac_rounded, 'colors': [Colors.blue, Colors.cyan]},
    {'id': 'Cycles', 'icon': Icons.directions_bike_rounded, 'colors': [Colors.teal, Colors.green]},
    {'id': 'Calculators', 'icon': Icons.calculate_rounded, 'colors': [Colors.purple, Colors.pink]},
    {'id': 'Furniture', 'icon': Icons.chair_rounded, 'colors': [Colors.amber, Colors.orangeAccent]},
    {'id': 'Lab Equipment', 'icon': Icons.science_rounded, 'colors': [Colors.green, Colors.tealAccent]},
    {'id': 'Lab Coat', 'icon': Icons.medical_services_rounded, 'colors': [Colors.cyan, Colors.teal]},
    {'id': 'Sports', 'icon': Icons.sports_basketball_rounded, 'colors': [Colors.red, Colors.pinkAccent]},
    {'id': 'Fashion', 'icon': Icons.checkroom_rounded, 'colors': [Colors.blueGrey, Colors.grey]},
    {'id': 'Accessories', 'icon': Icons.watch_rounded, 'colors': [Colors.indigo, Colors.indigoAccent]},
    {'id': 'Hostel', 'icon': Icons.bed_rounded, 'colors': [Colors.deepOrange, Colors.orange]},
    {'id': 'Miscellaneous', 'icon': Icons.more_horiz_rounded, 'colors': [Colors.grey, Colors.black87]},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavigation(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, ThemeData theme) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFF6C4CF7) : Colors.grey;

    return Expanded(
      child: InkWell(
        onTap: () => _onNavigation(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final productState = ref.watch(productProvider);
    final theme = Theme.of(context);

    final user = authState.userModel;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      extendBody: false,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Tab 0: Home Feed
          SafeArea(
              bottom: false,
              child: RefreshIndicator(
                onRefresh: () => ref.read(productProvider.notifier).fetchProducts(),
                child: CustomScrollView(
                  slivers: [
                    // Top Bar / Header
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.between,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hey, ${user?.name.split(" ")[0] ?? "Student"} 👋',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_rounded, size: 16, color: theme.colorScheme.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      user?.college ?? 'SRM University',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onBackground,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Notifications Icon
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined),
                              onPressed: () => showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Notifications'),
                                  content: const Text('No new alerts. Your items and chats are up-to-date!'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Search Bar Trigger
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverToBoxAdapter(
                        child: GestureDetector(
                          onTap: () => _onNavigation(1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: theme.colorScheme.onBackground.withOpacity(0.05)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search_rounded, color: theme.colorScheme.onBackground.withOpacity(0.4)),
                                const SizedBox(width: 12),
                                Text(
                                  'Search books, electronics, bikes...',
                                  style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.4)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Categories Scroll Header
                    SliverPadding(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 12),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.between,
                          children: [
                            Text(
                              'Browse Categories',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.extrabold,
                                color: theme.colorScheme.onBackground,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.push('/categories'),
                              child: const Text('See All'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Categories Horizontal List
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final cat = _categories[index];
                            return GestureDetector(
                              onTap: () {
                                ref.read(productProvider.notifier).updateFilter(
                                  ProductFilter(category: cat['id']),
                                );
                                _onNavigation(1);
                              },
                              child: Container(
                                width: 80,
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: cat['colors'],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (cat['colors'][0] as Color).withOpacity(0.25),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Icon(cat['icon'], color: Colors.white, size: 24),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      cat['id'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Listings Section Header
                    SliverPadding(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 12),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          'Featured Listings',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.extrabold,
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                      ),
                    ),

                    // Listings Grid
                    if (productState.isLoading)
                      const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      )
                    else if (productState.products.isEmpty)
                      SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Text(
                              'No listings active on your campus yet!',
                              style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.4)),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 220,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final product = productState.products[index];
                              final isFav = productState.favoriteIds.contains(product.id);

                              return GestureDetector(
                                onTap: () {
                                  ref.read(productProvider.notifier).incrementViews(product.id, product.views);
                                  context.push('/product-details/${product.id}');
                                },
                                child: Card(
                                  clipBehavior: Clip.antiAlias,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Product Image + Favorite
                                      Expanded(
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.network(
                                              product.image,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                color: theme.colorScheme.surfaceVariant,
                                                child: const Icon(Icons.broken_image_rounded),
                                              ),
                                            ),
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: CircleAvatar(
                                                radius: 16,
                                                backgroundColor: Colors.white.withOpacity(0.9),
                                                child: IconButton(
                                                  padding: EdgeInsets.zero,
                                                  icon: Icon(
                                                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                                    size: 18,
                                                    color: isFav ? Colors.red : Colors.grey,
                                                  ),
                                                  onPressed: () => ref.read(productProvider.notifier).toggleFavorite(product.id),
                                                ),
                                              ),
                                            ),
                                            if (product.status == 'sold')
                                              Container(
                                                color: Colors.black.withOpacity(0.6),
                                                child: const Center(
                                                  child: Text(
                                                    'SOLD',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.black,
                                                      fontSize: 16,
                                                      letterSpacing: 1,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      // Product Details
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
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
                                            const SizedBox(height: 6),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.between,
                                              children: [
                                                Text(
                                                  product.condition,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: theme.colorScheme.onBackground.withOpacity(0.4),
                                                  ),
                                                ),
                                                Text(
                                                  product.college.split(" ")[0],
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: theme.colorScheme.primary.withOpacity(0.8),
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
                              );
                            },
                            childCount: productState.products.length,
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                ),
              ),
            ),
            const SearchView(),
            const AddListingView(),
            const ChatsView(),
            const ProfileView(),
          ],
        ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: BottomAppBar(
          height: 84,
          padding: EdgeInsets.zero,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          clipBehavior: Clip.antiAlias,
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.15),
          color: theme.colorScheme.surface,
          child: Row(
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home', theme),
              _buildNavItem(1, Icons.search_rounded, 'Search', theme),
              const SizedBox(width: 64),
              _buildNavItem(3, Icons.chat_bubble_rounded, 'Chats', theme),
              _buildNavItem(4, Icons.person_rounded, 'Profile', theme),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onNavigation(2),
        elevation: 4,
        shape: const CircleBorder(),
        backgroundColor: const Color(0xFF6C4CF7),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
