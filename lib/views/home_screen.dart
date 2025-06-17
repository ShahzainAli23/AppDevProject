import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:darb_food_app/views/product_detail_screen.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'cart_provider.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> categories = [];
  String selectedCategory = '';
  int currentBannerIndex = 0;
  late PageController _pageController;
  List banners = [];
  late Stream<QuerySnapshot> bannerStream;
  Stream<QuerySnapshot>? menuStream;
  Timer? autoScrollTimer;

  @override
  void initState() {
    super.initState();
    fetchCategories();
    _pageController = PageController();
    bannerStream = FirebaseFirestore.instance.collection('banners').snapshots();
    startAutoScroll();
  }

  void startAutoScroll() {
    autoScrollTimer?.cancel();
    autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients && banners.isNotEmpty) {
        int nextPage = currentBannerIndex + 1;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    autoScrollTimer?.cancel();
    super.dispose();
  }

  void fetchCategories() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    setState(() {
      categories = snapshot.docs.map((doc) => doc['name'] as String).toList();
      if (categories.isNotEmpty) {
        selectedCategory = categories[0];
        menuStream =
            FirebaseFirestore.instance
                .collection('menu_items')
                .where('category', isEqualTo: selectedCategory)
                .snapshots();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTopBar(),
            const SizedBox(height: 12),
            buildBannerSlider(),
            const SizedBox(height: 16),
            buildCategoryChips(),
            const SizedBox(height: 8),
            Expanded(child: buildMenuGrid()),
          ],
        ),
      ),
    );
  }

  Widget buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/darbs_logo.png', height: 60),

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: const Icon(Icons.person_outline, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget buildBannerSlider() {
    return StreamBuilder(
      stream: bannerStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade800,
              highlightColor: Colors.grey.shade700,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );
        }

        List allBanners = snapshot.data!.docs;
        banners = [allBanners.last, ...allBanners, allBanners.first];

        return SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            itemCount: banners.length,
            onPageChanged: (index) {
              if (index == 0) {
                Future.delayed(const Duration(milliseconds: 350), () {
                  _pageController.jumpToPage(banners.length - 2);
                  setState(() {
                    currentBannerIndex = banners.length - 2;
                  });
                });
              } else if (index == banners.length - 1) {
                Future.delayed(const Duration(milliseconds: 350), () {
                  _pageController.jumpToPage(1);
                  setState(() {
                    currentBannerIndex = 1;
                  });
                });
              } else {
                setState(() {
                  currentBannerIndex = index;
                });
              }
              startAutoScroll();
            },
            itemBuilder: (context, index) {
              final imageUrl = banners[index]['image'];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                  }
                  return Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 32,
                      height: 150,
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Shimmer.fromColors(
                          baseColor: Colors.grey.shade800,
                          highlightColor: Colors.grey.shade700,
                          child: Container(color: Colors.grey.shade900),
                        );
                      },
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            color: Colors.grey.shade900,
                            child: const Center(
                              child: Icon(Icons.error, color: Colors.red),
                            ),
                          ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget buildCategoryChips() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final selected = cat == selectedCategory;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  selectedCategory = cat;
                  menuStream =
                      FirebaseFirestore.instance
                          .collection('menu_items')
                          .where('category', isEqualTo: selectedCategory)
                          .snapshots();
                });
              },
              selectedColor: const Color(0xFFF9A825),
              backgroundColor: Colors.grey.shade900,
              labelStyle: TextStyle(
                color: selected ? Colors.black : Colors.white,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildMenuGrid() {
    if (menuStream == null) {
      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        itemBuilder: (context, index) => buildShimmerCard(),
      );
    }
    return StreamBuilder(
      stream: menuStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 4,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) => buildShimmerCard(),
          );
        }

        final items = snapshot.data!.docs;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return buildMenuCard(item);
            },
          ),
        );
      },
    );
  }

  Widget buildMenuCard(QueryDocumentSnapshot item) {
    final data = item.data() as Map<String, dynamic>;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: data)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: Image.network(
                data['image'],
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Shimmer.fromColors(
                    baseColor: Colors.grey.shade800,
                    highlightColor: Colors.grey.shade700,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey.shade900,
                    ),
                  );
                },
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey.shade900,
                      child: const Center(
                        child: Icon(Icons.error, color: Colors.red),
                      ),
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['description'],
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rs ${data['price']}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () {
                          final cartProvider = Provider.of<CartProvider>(
                            context,
                            listen: false,
                          );
                          cartProvider.addItem(
                            CartItem(
                              name: data['name'],
                              price: data['price'],
                              image: data['image'],
                              quantity: 1,
                              addons: [],
                              type: null,
                            ),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Added to cart"),
                              backgroundColor: Color(0xFFF9A825),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },

                        child: const Icon(
                          Icons.shopping_cart_checkout,
                          color: Color(0xFFF9A825),
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
  }

  Widget buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade700,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  SizedBox(height: 16, width: double.infinity),
                  SizedBox(height: 8),
                  SizedBox(height: 12, width: double.infinity),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
