import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/product_provider.dart';

class CategoriesView extends ConsumerWidget {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> categories = [
      {'id': 'Books', 'icon': Icons.menu_book_rounded, 'colors': [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)]},
      {'id': 'Electronics', 'icon': Icons.laptop_mac_rounded, 'colors': [const Color(0xFF4E65FF), const Color(0xFF92EFFD)]},
      {'id': 'Cycles', 'icon': Icons.directions_bike_rounded, 'colors': [const Color(0xFF00D2B8), const Color(0xFF00F2FE)]},
      {'id': 'Calculators', 'icon': Icons.calculate_rounded, 'colors': [const Color(0xFFB155FF), const Color(0xFFF55555)]},
      {'id': 'Furniture', 'icon': Icons.chair_rounded, 'colors': [const Color(0xFFF39C12), const Color(0xFFF1C40F)]},
      {'id': 'Lab Equipment', 'icon': Icons.science_rounded, 'colors': [const Color(0xFF1ABC9C), const Color(0xFF2ECC71)]},
      {'id': 'Sports', 'icon': Icons.sports_basketball_rounded, 'colors': [const Color(0xFFE74C3C), const Color(0xFF9B59B6)]},
      {'id': 'Fashion', 'icon': Icons.checkroom_rounded, 'colors': [const Color(0xFF34495E), const Color(0xFF2C3E50)]},
      {'id': 'Accessories', 'icon': Icons.watch_rounded, 'colors': [const Color(0xFF3498DB), const Color(0xFF2980B9)]},
      {'id': 'Hostel', 'icon': Icons.bed_rounded, 'colors': [const Color(0xFFFF5E36), const Color(0xFFFFAE33)]},
      {'id': 'Miscellaneous', 'icon': Icons.more_horiz_rounded, 'colors': [const Color(0xFF7F8C8D), const Color(0xFFBDC3C7)]},
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onBackground),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'All Categories',
          style: TextStyle(
            fontWeight: FontWeight.extrabold,
            color: theme.colorScheme.onBackground,
          ),
        ),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () {
              ref.read(productProvider.notifier).updateFilter(
                ProductFilter(category: cat['id']),
              );
              context.push('/search');
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: cat['colors'],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (cat['colors'][0] as Color).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(cat['icon'], color: Colors.white, size: 20),
                  ),
                  Text(
                    cat['id'],
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.extrabold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
