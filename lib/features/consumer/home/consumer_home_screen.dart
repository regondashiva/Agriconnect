import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../models/consumer_product_model.dart';
import '../../../services/app_state.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/role_switcher_sheet.dart';
import '../cart/consumer_cart_screen.dart';
import '../orders/consumer_tracking_screen.dart';

class ConsumerHomeScreen extends StatefulWidget {
  final AppState appState;

  const ConsumerHomeScreen({super.key, required this.appState});

  @override
  State<ConsumerHomeScreen> createState() => _ConsumerHomeScreenState();
}

class _ConsumerHomeScreenState extends State<ConsumerHomeScreen> {
  int _currentTabIndex = 0;
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Vegetables', 'Fruits', 'Organic Grains', 'Greens'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              appState: widget.appState,
              title: 'Fresh Farm Groceries',
              location: 'Delivering to: ${widget.appState.currentUser.location}',
            ),
            Expanded(
              child: IndexedStack(
                index: _currentTabIndex,
                children: [
                  _buildConsumerShopTab(context),
                  _buildSearchTab(context),
                  ConsumerCartScreen(appState: widget.appState),
                  ConsumerTrackingScreen(appState: widget.appState),
                  _buildConsumerProfileTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentTabIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        onTap: (idx) => setState(() => _currentTabIndex = idx),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: 'Shop'),
          const BottomNavigationBarItem(icon: Icon(Icons.search), activeIcon: Icon(Icons.search), label: 'Explore'),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('${widget.appState.cartCount}', style: const TextStyle(fontSize: 10)),
              isLabelVisible: widget.appState.cartCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            activeIcon: const Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Orders'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildConsumerShopTab(BuildContext context) {
    final filteredProducts = _selectedCategory == 'All'
        ? widget.appState.consumerProducts
        : widget.appState.consumerProducts.where((p) => p.category == _selectedCategory).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          AppCard(
            backgroundColor: AppColors.primaryContainer,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Direct From Local FPOs',
                        style: AppTypography.headlineSmall.copyWith(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Zero middlemen markups. 100% fair payout to cluster farmers.',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text('🌾', style: TextStyle(fontSize: 34)),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Categories Horizontal Scroll
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat == _selectedCategory;
                return ChoiceChip(
                  label: Text(cat, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textDark),
                  onSelected: (val) => setState(() => _selectedCategory = cat),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Fresh From Farmers',
            style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 10),

          // Product Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.68,
            ),
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              return _buildProductCard(context, product);
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ConsumerProduct product) {
    return AppCard(
      onTap: () {
        Navigator.pushNamed(context, '/consumer/product', arguments: product);
      },
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  product.iconEmoji,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.name,
            style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${product.source} • ${product.distanceKm.toInt()}km',
            style: AppTypography.bodySmall.copyWith(fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${product.pricePerKg.toInt()}/kg',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  fontSize: 13,
                ),
              ),
              InkWell(
                onTap: () {
                  widget.appState.addToCart(product, 1.0);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added 1 kg ${product.name} to Cart'),
                      duration: const Duration(seconds: 1),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'ADD',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTab(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search farm vegetables, fruits, grains…',
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          Text('Popular Searches', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSearchChip('🍅 Organic Tomato'),
              _buildSearchChip('🥔 Jyoti Potato'),
              _buildSearchChip('🧅 Fresh Red Onion'),
              _buildSearchChip('🥬 Palak Spinach'),
              _buildSearchChip('🌾 Sona Masoori Rice'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceContainerHigh),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textNavy, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildConsumerProfileTab(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primaryContainer,
            child: Text(
              widget.appState.currentUser.name.isNotEmpty
                  ? widget.appState.currentUser.name[0].toUpperCase()
                  : 'C',
              style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          Text(widget.appState.currentUser.name, style: AppTypography.headlineSmall.copyWith(fontSize: 18, fontWeight: FontWeight.w700), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('Household Consumer • ${widget.appState.currentUser.location}', style: AppTypography.bodySmall.copyWith(fontSize: 12), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 18),

          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              children: [
                _buildProfileRow('Delivery Address', widget.appState.currentUser.location),
                const Divider(),
                _buildProfileRow('Phone', widget.appState.currentUser.phoneNumber),
                const Divider(),
                _buildProfileRow('Active Order', 'AGR-2048 (Out for Delivery)'),
                const Divider(),
                _buildProfileRow('Verified ID', 'SIH-AP-CONSUMER-2026'),
              ],
            ),
          ),

          const SizedBox(height: 18),

          PrimaryButton(
            text: 'SWITCH ROLE FOR DEMO',
            icon: Icons.swap_horiz,
            onPressed: () => RoleSwitcherSheet.show(context, widget.appState),
          ),

          const SizedBox(height: 10),

          SecondaryButton(
            text: 'LOG OUT',
            icon: Icons.logout_rounded,
            borderColor: AppColors.error,
            textColor: AppColors.error,
            onPressed: () {
              widget.appState.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(title, style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 12.5)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              val,
              style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700, fontSize: 12.5),
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
