import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart'; // make sure this has both CartProvider + CartItem classes

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  List<String> addons = [];
  List<int> addonPrices = [];
  List<String> types = [];
  List<int> typePrices = [];

  List<bool> selectedAddons = [];
  int selectedTypeIndex = 0;
  int quantity = 1;

  int get basePrice => widget.product['price'];

  int calculateTotalPrice() {
    int total = basePrice;
    for (int i = 0; i < selectedAddons.length; i++) {
      if (selectedAddons[i]) total += addonPrices[i];
    }
    total += typePrices.isNotEmpty ? typePrices[selectedTypeIndex] : 0;
    return total * quantity;
  }

  @override
  void initState() {
    super.initState();
    fetchCategoryOptions();
  }

  void fetchCategoryOptions() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('categories')
            .where('name', isEqualTo: widget.product['category'])
            .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      final fetchedAddons = List<String>.from(data['addons'] ?? []);
      final fetchedAddonPrices = List<int>.from(data['addons_price'] ?? []);
      final fetchedTypes = List<String>.from(data['type'] ?? []);
      final fetchedTypePrices = List<int>.from(data['type_price'] ?? []);

      setState(() {
        addons = fetchedAddons;
        addonPrices = fetchedAddonPrices;
        types = fetchedTypes;
        typePrices = fetchedTypePrices;
        selectedAddons = List.generate(addons.length, (_) => false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                widget.product['image'],
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.product['name'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.product['description'],
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Quantity", style: TextStyle(color: Colors.white)),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          quantity = (quantity > 1) ? quantity - 1 : 1;
                        });
                      },
                      icon: const Icon(Icons.remove, color: Colors.white),
                    ),
                    Text(
                      '$quantity',
                      style: const TextStyle(color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() => quantity++);
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (addons.isNotEmpty) ...[
              const Text(
                "Add-ons",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...List.generate(addons.length, (index) {
                return CheckboxListTile(
                  value: selectedAddons[index],
                  onChanged: (val) {
                    setState(() => selectedAddons[index] = val ?? false);
                  },
                  activeColor: const Color(0xFFF9A825),
                  title: Text(
                    "${addons[index]} (+Rs ${addonPrices[index]})",
                    style: const TextStyle(color: Colors.white),
                  ),
                  checkboxShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                );
              }),
              const SizedBox(height: 10),
            ],

            if (types.isNotEmpty) ...[
              const Text(
                "Type",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...List.generate(types.length, (index) {
                return RadioListTile(
                  value: index,
                  groupValue: selectedTypeIndex,
                  onChanged: (val) {
                    setState(() => selectedTypeIndex = val as int);
                  },
                  activeColor: const Color(0xFFF9A825),
                  title: Text(
                    "${types[index]} (+Rs ${typePrices[index]})",
                    style: const TextStyle(color: Colors.white),
                  ),
                  contentPadding: EdgeInsets.zero,
                );
              }),
              const SizedBox(height: 10),
            ],

            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF9A825),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final selectedAddonsList = <String>[];
                final selectedAddonPricesList = <int>[];

                for (int i = 0; i < selectedAddons.length; i++) {
                  if (selectedAddons[i]) {
                    selectedAddonsList.add(addons[i]);
                    selectedAddonPricesList.add(addonPrices[i]);
                  }
                }

                final item = CartItem(
                  name: widget.product['name'],
                  image: widget.product['image'],
                  quantity: quantity,
                  price:
                      basePrice +
                      (typePrices.isNotEmpty
                          ? typePrices[selectedTypeIndex]
                          : 0) +
                      selectedAddonPricesList.fold(
                        0,
                        (sum, price) => sum + price,
                      ),
                  type: types.isNotEmpty ? types[selectedTypeIndex] : null,
                  addons: selectedAddonsList,
                );

                cartProvider.addItem(item);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Added to cart!"),
                    backgroundColor: Colors.green,
                  ),
                );

                Navigator.pop(context);
              },
              child: Text(
                "Add to Cart  -  Rs ${calculateTotalPrice()}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
