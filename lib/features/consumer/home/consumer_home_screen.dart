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
  String _searchQuery = '';

  final List<Map<String, String>> _categories = [
    {'name': 'All', 'icon': '🥗'},
    {'name': 'Vegetables', 'icon': '🍅'},
    {'name': 'Greens', 'icon': '🥬'},
    {'name': 'Fruits', 'icon': '🍎'},
    {'name': 'Organic Grains', 'icon': '🌾'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              appState: widget.appState,
              title: 'Fresh Farm Groceries',
              location: 'Delivering to: ${widget.appState.currentUser.location}',
            ),
            Expanded(
              child: Stack(
                children: [
                  IndexedStack(
                    index: _currentTabIndex,
                    children: [
                      _buildConsumerShopTab(context),
                      _buildSearchTab(context),
                      ConsumerCartScreen(appState: widget.appState),
                      ConsumerTrackingScreen(appState: widget.appState),
                      _buildConsumerProfileTab(context),
                    ],
                  ),

                  // Floating Cart Bar (Swiggy / Blinkit Style)
                  if (_currentTabIndex == 0 && widget.appState.cartCount > 0)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 12,
                      child: _buildFloatingCartBar(context),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
        currentIndex: _currentTabIndex,
        selectedItemColor: const Color(0xFF164E2A),
        unselectedItemColor: const Color(0xFF94A3B8),
        selectedFontSize: 11,
        unselectedFontSize: 10,
        onTap: (idx) => setState(() => _currentTabIndex = idx),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront_rounded),
            label: 'Shop',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            activeIcon: Icon(Icons.search_rounded),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('${widget.appState.cartCount}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              isLabelVisible: widget.appState.cartCount > 0,
              backgroundColor: const Color(0xFFD97706),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            activeIcon: const Icon(Icons.shopping_cart_rounded),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: 'Orders',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildConsumerShopTab(BuildContext context) {
    final allProducts = widget.appState.consumerProducts;

    final filteredProducts = allProducts.where((p) {
      final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    final flashDeals = allProducts.where((p) => p.isBestseller).toList();
    final leafyGreens = allProducts.where((p) => p.category == 'Greens').toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: widget.appState.cartCount > 0 ? 80 : 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Delivery Timer Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '⚡ 15-25 MINS',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF164E2A),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '• Direct from Ranga Reddy FPO Hub',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 2. Search Box
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                hintText: 'Search "tomatoes", "palak", "mangoes"…',
                hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF164E2A), size: 20),
                suffixIcon: Icon(Icons.mic_none_rounded, color: Color(0xFF64748B), size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 3. FPO Impact Promo Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF164E2A), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F164E2A),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Direct From Farm Clusters',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Zero middlemen markup • 100% fair pay to local farmers',
                        style: TextStyle(color: Color(0xFFDCFCE7), fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🌾', style: TextStyle(fontSize: 24)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 4. Horizontal Smooth Scrolling Category Pills
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat['name'] == _selectedCategory;

                return InkWell(
                  onTap: () => setState(() => _selectedCategory = cat['name']!),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF164E2A) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF164E2A) : const Color(0xFFE2E8F0),
                        width: 1.2,
                      ),
                      boxShadow: isSelected
                          ? const [
                              BoxShadow(
                                color: Color(0x33164E2A),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(cat['icon']!, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          cat['name']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? Colors.white : const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 5. Horizontal Flash Deals Section (if on 'All' or 'Vegetables')
          if (_selectedCategory == 'All' && _searchQuery.isEmpty) ...[
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '🔥 Harvested Today • Flash Deals',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Up to 30% Off',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFD97706),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: flashDeals.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 155,
                    child: _buildGroceryCard(context, flashDeals[index]),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // 6. Horizontal Leafy Greens Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '🥬 Fresh Leafy Greens & Herbs',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Farm Fresh',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: leafyGreens.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 155,
                    child: _buildGroceryCard(context, leafyGreens[index]),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 18),

          // 7. Main Grid Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedCategory == 'All' ? '🍅 All Farm Fresh Produce' : 'Fresh $_selectedCategory',
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                '${filteredProducts.length} items',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 8. Product Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (context, index) {
              return _buildGroceryCard(context, filteredProducts[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGroceryCard(BuildContext context, ConsumerProduct product) {
    final cartQty = _getProductQuantityInCart(product.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pushNamed(context, '/consumer/product', arguments: product);
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Emoji Container + Discount Badge
                Stack(
                  children: [
                    Container(
                      height: 95,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          product.iconEmoji,
                          style: const TextStyle(fontSize: 44),
                        ),
                      ),
                    ),

                    // Discount Badge (e.g. 25% OFF)
                    if (product.discountPercentage > 0)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A34A),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${product.discountPercentage}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),

                    // Delivery time pill
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          product.deliveryTime,
                          style: const TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Name
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 1),

                // Unit & Harvest Tag
                Text(
                  '${product.unit} • ${product.harvestFreshness}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const Spacer(),

                // Price Row & Smart ADD / Counter Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Prices
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '₹${product.pricePerKg.toInt()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          if (product.mrpPrice > product.pricePerKg)
                            Text(
                              '₹${product.mrpPrice.toInt()}',
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFF94A3B8),
                                decoration: TextDecoration.lineThrough,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Add / Quantity Controller Button
                    if (cartQty > 0)
                      Container(
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF164E2A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {
                                widget.appState.removeFromCart(product.id);
                                setState(() {});
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Icon(Icons.remove, size: 14, color: Colors.white),
                              ),
                            ),
                            Text(
                              '${cartQty.toInt()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 11.5,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                widget.appState.addToCart(product, 1.0);
                                setState(() {});
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Icon(Icons.add, size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      InkWell(
                        onTap: () {
                          widget.appState.addToCart(product, 1.0);
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added ${product.name} to Cart'),
                              duration: const Duration(milliseconds: 900),
                              backgroundColor: const Color(0xFF164E2A),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF16A34A), width: 1.2),
                          ),
                          child: const Text(
                            'ADD',
                            style: TextStyle(
                              color: Color(0xFF164E2A),
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getProductQuantityInCart(String productId) {
    final item = widget.appState.cart.firstWhere(
      (c) => c.product.id == productId,
      orElse: () => CartItem(
        product: widget.appState.consumerProducts.first,
        quantityKg: 0,
      ),
    );
    return item.quantityKg;
  }

  Widget _buildFloatingCartBar(BuildContext context) {
    final total = widget.appState.cartTotal;
    final count = widget.appState.cartCount;

    return Material(
      color: Colors.transparent,
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => setState(() => _currentTabIndex = 2), // switch to Cart tab
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF164E2A),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33164E2A),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$count ${count == 1 ? 'ITEM' : 'ITEMS'} • ₹${total.toInt()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                    ),
                  ),
                  const Text(
                    'Direct from Farm Hub • Free Delivery',
                    style: TextStyle(
                      color: Color(0xFFDCFCE7),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: const [
                  Text(
                    'View Cart',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                ],
              ),
            ],
          ),
        ),
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
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search farm vegetables, fruits, grains…',
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF164E2A)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Trending Farm Searches',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSearchChip('🍅 Organic Tomato', 'Tomato'),
              _buildSearchChip('🥔 Jyoti Potato', 'Potato'),
              _buildSearchChip('🧅 Fresh Red Onion', 'Onion'),
              _buildSearchChip('🥬 Palak Spinach', 'Palak'),
              _buildSearchChip('🥭 Sweet Mangoes', 'Mango'),
              _buildSearchChip('🍌 Golden Bananas', 'Banana'),
              _buildSearchChip('🌾 Sona Masoori Rice', 'Rice'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchChip(String label, String filter) {
    return InkWell(
      onTap: () {
        setState(() {
          _searchQuery = filter;
          _currentTabIndex = 0;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w600),
        ),
      ),
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
            backgroundColor: const Color(0xFF164E2A),
            child: Text(
              widget.appState.currentUser.name.isNotEmpty
                  ? widget.appState.currentUser.name[0].toUpperCase()
                  : 'C',
              style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.appState.currentUser.name,
            style: AppTypography.headlineSmall.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Household Consumer • ${widget.appState.currentUser.location}',
            style: AppTypography.bodySmall.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
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
