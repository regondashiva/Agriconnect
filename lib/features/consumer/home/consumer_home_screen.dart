import 'dart:async';
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
import '../orders/consumer_order_history_screen.dart';

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
  int _activeOfferIndex = 0;
  final PageController _offersPageController = PageController(viewportFraction: 0.93);

  final List<Map<String, dynamic>> _offerBanners = [
    {
      'title': '50% OFF First Order',
      'subtitle': 'Farm-fresh vegetables direct from rural FPO clusters',
      'code': 'HARVEST50',
      'tag': 'HOT DEAL',
      'gradient': [Color(0xFF164E2A), Color(0xFF15803D)],
      'imageUrl': 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=600&auto=format&fit=crop&q=80',
    },
    {
      'title': '100% Fair Pay to Farmers',
      'subtitle': 'Zero middlemen markup • Harvested fresh within 12 hours',
      'code': 'DIRECTFARM',
      'tag': 'COMMUNITY IMPACT',
      'gradient': [Color(0xFF0F766E), Color(0xFF0D9488)],
      'imageUrl': 'https://images.unsplash.com/photo-1595974482597-4b8da8879bc5?w=600&auto=format&fit=crop&q=80',
    },
    {
      'title': 'Fresh Market Daily Deals',
      'subtitle': 'Flat ₹20/kg on organic tomatoes, onions & potatoes',
      'code': 'VEGMKT20',
      'tag': 'DAILY DEALS',
      'gradient': [Color(0xFF9A3412), Color(0xFFEA580C)],
      'imageUrl': 'https://images.unsplash.com/photo-1610348725531-843dff563e2c?w=600&auto=format&fit=crop&q=80',
    },
    {
      'title': 'Greens & Herbs Festival',
      'subtitle': 'Crisp Spinach, Methi, Mint & Fresh Coriander at flat ₹15',
      'code': 'GREENS15',
      'tag': 'ORGANIC GREENS',
      'gradient': [Color(0xFF14532D), Color(0xFF16A34A)],
      'imageUrl': 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=600&auto=format&fit=crop&q=80',
    },
  ];

  final List<Map<String, String>> _categories = [
    {'name': 'All', 'icon': '🥗'},
    {'name': 'Vegetables', 'icon': '🍅'},
    {'name': 'Greens', 'icon': '🥬'},
    {'name': 'Fruits', 'icon': '🍎'},
    {'name': 'Herbs', 'icon': '🌿'},
    {'name': 'Grains', 'icon': '🌾'},
  ];

  Timer? _offersTimer;

  @override
  void initState() {
    super.initState();
    _startOffersTimer();
  }

  void _startOffersTimer() {
    _offersTimer?.cancel();
    _offersTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || !_offersPageController.hasClients) return;
      final next = (_activeOfferIndex + 1) % _offerBanners.length;
      _offersPageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _offersTimer?.cancel();
    _offersPageController.dispose();
    super.dispose();
  }

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
                      ConsumerCartScreen(
                        appState: widget.appState,
                        isTab: true,
                        onExplore: () => setState(() => _currentTabIndex = 0),
                      ),
                      ConsumerOrderHistoryScreen(
                        appState: widget.appState,
                        isTab: true,
                      ),
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
      final matchesCategory = _selectedCategory == 'All' ||
          p.category.toLowerCase() == _selectedCategory.toLowerCase() ||
          (_selectedCategory == 'Grains' && p.category.toLowerCase().contains('grain'));
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    final flashDeals = allProducts.where((p) => p.isBestseller).toList();
    final leafyGreens = allProducts.where((p) => p.category == 'Greens').toList();
    final freshFruits = allProducts.where((p) => p.category == 'Fruits').toList();
    final kitchenVeggies = allProducts.where((p) => p.category == 'Vegetables').toList();

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
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 3. Dynamic Promotional Offers Carousel with Verified Real Images
          _buildOffersCarousel(),

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
                  child: Container(
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
                                color: Color(0x22164E2A),
                                blurRadius: 4,
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

          // 5. Horizontal Curated Shelves (Flash Deals, Leafy Greens, Fruits, Kitchen Veggies)
          if (_selectedCategory == 'All' && _searchQuery.isEmpty) ...[
            const SizedBox(height: 16),
            _buildHorizontalShelf(
              context: context,
              emoji: '🔥',
              title: 'Harvested Today • Flash Deals',
              subtitle: 'Up to 30% Off',
              subtitleColor: const Color(0xFFD97706),
              products: flashDeals,
            ),
            const SizedBox(height: 16),
            _buildHorizontalShelf(
              context: context,
              emoji: '🍎',
              title: 'Orchard Fresh Fruits',
              subtitle: '${freshFruits.length} Varieties',
              subtitleColor: const Color(0xFFEA580C),
              products: freshFruits,
            ),
            const SizedBox(height: 16),
            _buildHorizontalShelf(
              context: context,
              emoji: '🥬',
              title: 'Farm Fresh Leafy Greens ("Leaf")',
              subtitle: '${leafyGreens.length} Varieties',
              subtitleColor: const Color(0xFF16A34A),
              products: leafyGreens,
            ),
            const SizedBox(height: 16),

            // Mid-page Seasonal Farm Harvest Offer Banner
            Container(
              height: 112,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        'https://images.unsplash.com/photo-1506802913710-40e2e66339c9?w=600&auto=format&fit=crop&q=80',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.85),
                              Colors.black.withValues(alpha: 0.40),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.70, 1.0],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF16A34A),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    '100% ORGANIC CERTIFIED',
                                    style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w900),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  'Clean Root Veggies & Greens',
                                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Direct from Chevella & Moinabad clusters • Zero pesticides',
                                  style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'Explore',
                              style: TextStyle(color: Color(0xFF164E2A), fontSize: 11, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            _buildHorizontalShelf(
              context: context,
              emoji: '🥕',
              title: 'Kitchen Staples & Root Veggies',
              subtitle: 'Direct from Hubs',
              subtitleColor: const Color(0xFF164E2A),
              products: kitchenVeggies,
            ),
          ] else if (_selectedCategory != 'All' && _searchQuery.isEmpty) ...[
            const SizedBox(height: 16),
            _buildHorizontalShelf(
              context: context,
              emoji: _selectedCategory == 'Fruits'
                  ? '🍎'
                  : (_selectedCategory == 'Greens' ? '🥬' : '🥕'),
              title: 'Popular in $_selectedCategory',
              subtitle: '${filteredProducts.length} Items',
              subtitleColor: const Color(0xFF16A34A),
              products: filteredProducts,
            ),
          ],

          const SizedBox(height: 18),

          // 6. Bottom Section Header
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

          // 7. Bottom Side-Scrollable Cards Shelf
          SizedBox(
            height: 252,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: filteredProducts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 165,
                  child: _buildGroceryCard(context, filteredProducts[index]),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // 8. Grid View of All Products
          Row(
            children: const [
              Icon(Icons.grid_view_rounded, size: 15, color: Color(0xFF164E2A)),
              SizedBox(width: 6),
              Text(
                'Full Produce Catalog',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.69,
            ),
            itemBuilder: (context, index) {
              return _buildGroceryCard(context, filteredProducts[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalShelf({
    required BuildContext context,
    required String emoji,
    required String title,
    required String subtitle,
    required Color subtitleColor,
    required List<ConsumerProduct> products,
  }) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: subtitleColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: subtitleColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 252,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return SizedBox(
                width: 165,
                child: _buildGroceryCard(context, products[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGroceryCard(BuildContext context, ConsumerProduct product) {
    final cartQty = _getProductQuantityInCart(product.id);

    return _AnimatedGroceryCard(
      product: product,
      cartQty: cartQty,
      onTap: () {
        Navigator.pushNamed(context, '/consumer/product', arguments: product);
      },
      onAdd: () {
        widget.appState.addToCart(product, 1.0);
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('Added ${product.name} to Cart'),
              ],
            ),
            duration: const Duration(milliseconds: 900),
            backgroundColor: const Color(0xFF164E2A),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onIncrement: () {
        widget.appState.addToCart(product, 1.0);
        setState(() {});
      },
      onDecrement: () {
        widget.appState.removeFromCart(product.id);
        setState(() {});
      },
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
        onTap: () async {
          await Navigator.pushNamed(context, '/consumer/cart');
          if (mounted) setState(() {});
        },
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
              Expanded(
                child: Column(
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      'Direct from Farm Hub • Free Delivery',
                      style: TextStyle(
                        color: Color(0xFFDCFCE7),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'View Cart',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12.5,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 15),
                  ],
                ),
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
                _buildProfileRow(
                  'Order History',
                  '${widget.appState.consumerOrders.length} Orders • View All ➔',
                  onTap: () => setState(() => _currentTabIndex = 3),
                  isAction: true,
                ),
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

  Widget _buildProfileRow(String title, String val, {VoidCallback? onTap, bool isAction = false}) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(title, style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 12.5)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              val,
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                color: isAction ? const Color(0xFF15803D) : null,
              ),
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: row,
      );
    }
    return row;
  }

  Widget _buildOffersCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 154,
          child: PageView.builder(
            controller: _offersPageController,
            onPageChanged: (index) {
              setState(() {
                _activeOfferIndex = index;
              });
              _startOffersTimer();
            },
            itemCount: _offerBanners.length,
            itemBuilder: (context, index) {
              final offer = _offerBanners[index];
              return AnimatedBuilder(
                animation: _offersPageController,
                builder: (context, child) {
                  double scale = 1.0;
                  if (_offersPageController.position.haveDimensions) {
                    final page = _offersPageController.page ?? _activeOfferIndex.toDouble();
                    scale = (1.0 - ((page - index).abs() * 0.06)).clamp(0.92, 1.0);
                  }
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x24000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        // Background Photography CDN
                        Positioned.fill(
                          child: Image.network(
                            offer['imageUrl'] as String,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: offer['gradient'] as List<Color>,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: const Color(0xFF164E2A),
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Dark Readability Overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.88),
                                  Colors.black.withValues(alpha: 0.45),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.65, 1.0],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                        ),

                        // Banner Content
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFD97706), Color(0xFFB45309)],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x33D97706),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  offer['tag'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                offer['title'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              SizedBox(
                                width: 220,
                                child: Text(
                                  offer['subtitle'] as String,
                                  style: const TextStyle(
                                    color: Color(0xFFE2E8F0),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.20),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.white54, width: 0.8),
                                    ),
                                    child: Text(
                                      offer['code'] as String,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Offer code ${offer['code']} applied to your cart!'),
                                          backgroundColor: const Color(0xFF164E2A),
                                          behavior: SnackBarBehavior.floating,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x1F000000),
                                            blurRadius: 4,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: const Text(
                                        'Apply Code',
                                        style: TextStyle(
                                          color: Color(0xFF164E2A),
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
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
        ),
        const SizedBox(height: 7),

        // Animated Indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_offerBanners.length, (i) {
            final isActive = i == _activeOfferIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 22 : 6,
              height: 5,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF164E2A) : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _AnimatedGroceryCard extends StatefulWidget {
  final ConsumerProduct product;
  final double cartQty;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _AnimatedGroceryCard({
    required this.product,
    required this.cartQty,
    required this.onTap,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  State<_AnimatedGroceryCard> createState() => _AnimatedGroceryCardState();
}

class _AnimatedGroceryCardState extends State<_AnimatedGroceryCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final cartQty = widget.cartQty;

    return AnimatedScale(
      scale: _isPressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 130),
      curve: Curves.easeOutCubic,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cartQty > 0
                ? const Color(0xFF16A34A).withValues(alpha: 0.50)
                : const Color(0xFFE2E8F0),
            width: cartQty > 0 ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: cartQty > 0 ? const Color(0x1816A34A) : const Color(0x0A000000),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Prominent Real-Life Photography Vegetable Header
                  Stack(
                    children: [
                      Container(
                        height: 122,
                        width: double.infinity,
                        color: const Color(0xFFF1F5F9),
                        child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                            ? Image.network(
                                product.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Center(
                                  child: Text(
                                    product.iconEmoji,
                                    style: const TextStyle(fontSize: 48),
                                  ),
                                ),
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: const Color(0xFFF8FAF7),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF16A34A),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Text(
                                  product.iconEmoji,
                                  style: const TextStyle(fontSize: 48),
                                ),
                              ),
                      ),

                      // Subtle gradient shadow overlay at bottom of image
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 38,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.40),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),

                      // Top-Left Discount Badge
                      if (product.discountPercentage > 0)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF16A34A), Color(0xFF15803D)],
                              ),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x3316A34A),
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              '${product.discountPercentage}% OFF',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),

                      // Top-Right Rating Badge
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFBBF24)),
                              const SizedBox(width: 2),
                              Text(
                                '${product.rating}',
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Bottom-Left Harvest Freshness Tag
                      Positioned(
                        bottom: 6,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.60),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.harvestFreshness,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // Bottom-Right 15 min Delivery Tag
                      Positioned(
                        bottom: 6,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.deliveryTime,
                            style: const TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Card Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                            color: Color(0xFF0F172A),
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),

                        // Unit & Distance
                        Row(
                          children: [
                            Text(
                              product.unit,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text('•', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${product.distanceKm} km',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Price & Smart Animated ADD Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Price
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '₹${product.pricePerKg.toInt()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
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

                            // Animated Cart Controller
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                              child: cartQty > 0
                                  ? Container(
                                      key: const ValueKey('counter'),
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF16A34A),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x3316A34A),
                                            blurRadius: 6,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            onTap: widget.onDecrement,
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              child: Icon(Icons.remove, size: 14, color: Colors.white),
                                            ),
                                          ),
                                          Text(
                                            '${cartQty.toInt()}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 12,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: widget.onIncrement,
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              child: Icon(Icons.add, size: 14, color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : InkWell(
                                      key: const ValueKey('add_btn'),
                                      onTap: widget.onAdd,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0FDF4),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: const Color(0xFF16A34A), width: 1.3),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.add, size: 13, color: Color(0xFF16A34A)),
                                            SizedBox(width: 2),
                                            Text(
                                              'ADD',
                                              style: TextStyle(
                                                color: Color(0xFF164E2A),
                                                fontWeight: FontWeight.w900,
                                                fontSize: 11,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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
        ),
      ),
    );
  }
}
