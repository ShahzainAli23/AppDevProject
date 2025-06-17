import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'checkout_screen.dart';
import 'cart_provider.dart';

class CartScreen extends StatelessWidget {
  final bool isGuest;
  const CartScreen({super.key, required this.isGuest});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cart = cartProvider.items;

    num subtotal = 0;
    for (var item in cart) {
      subtotal += item.price * item.quantity;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'YOUR CART',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFF9A825)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          cart.isEmpty
              ? const Center(
                child: Text(
                  'Cart is empty.',
                  style: TextStyle(color: Colors.white70),
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cart.length,
                      itemBuilder: (_, i) {
                        final item = cart[i];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white24),
                            color: Colors.grey.shade900,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  item.image,
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (item.type != null)
                                      Text(
                                        'Type: ${item.type}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    if (item.addons.isNotEmpty)
                                      Text(
                                        'Add-ons: ${item.addons.join(', ')}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    Text(
                                      '${item.quantity} x Rs ${item.price}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    TextButton(
                                      onPressed: () {
                                        cartProvider.removeItem(item);
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: const Text(
                                        'Remove Item',
                                        style: TextStyle(
                                          color: Color(0xFFF9A825),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.white24)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Subtotal',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              'Rs $subtotal',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tax',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              'Included',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => CheckoutScreen(isGuest: isGuest),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF9A825),
                            foregroundColor: Colors.black,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Checkout',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
