import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'cart_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'ActiveOrdersScreen.dart';

class CheckoutScreen extends StatefulWidget {
  final bool isGuest;
  const CheckoutScreen({super.key, required this.isGuest});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String orderType = 'Delivery';
  String paymentMethod = 'Cash on delivery';
  String? selectedBuilding;
  String? selectedRoom;
  String notes = '';

  List<Map<String, dynamic>> locations = [];
  List<String> roomList = [];
  bool loadingLocations = true;

  @override
  void initState() {
    super.initState();
    if (!widget.isGuest) {
      fetchLocations();
    }
  }

  void fetchLocations() async {
    final snap = await FirebaseFirestore.instance.collection('locations').get();
    locations =
        snap.docs
            .map(
              (e) => {
                'id': e.id,
                'name': e['name'],
                'rooms': List<String>.from(e['rooms']),
              },
            )
            .toList();

    locations.sort((a, b) => a['name'].compareTo(b['name']));

    setState(() {
      loadingLocations = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isGuest) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF9A825),
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginScreen(returnToCheckout: true),
                ),
              );
            },
            child: const Text('Sign In to Checkout'),
          ),
        ),
      );
    }

    final bool isDeliveryIncomplete =
        orderType == 'Delivery' &&
        (selectedBuilding == null || selectedRoom == null);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFF9A825)),
          onPressed: () {
            Navigator.pop(context); // Will return to Cart
          },
        ),
        title: const Text(
          'CHECKOUT',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body:
          loadingLocations
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSection(
                    title: 'Order Type',
                    child: Column(
                      children: [
                        RadioListTile(
                          title: const Text(
                            'Delivery',
                            style: TextStyle(color: Colors.white),
                          ),
                          value: 'Delivery',
                          groupValue: orderType,
                          activeColor: const Color(0xFFF9A825),
                          onChanged:
                              (value) => setState(() => orderType = value!),
                        ),
                        RadioListTile(
                          title: const Text(
                            'Take Away',
                            style: TextStyle(color: Colors.white),
                          ),
                          value: 'Take Away',
                          groupValue: orderType,
                          activeColor: const Color(0xFFF9A825),
                          onChanged:
                              (value) => setState(() => orderType = value!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSection(
                    title: 'Payment Methods',
                    child: RadioListTile(
                      title: const Text(
                        'Cash on delivery',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: 'Cash on delivery',
                      groupValue: paymentMethod,
                      activeColor: const Color(0xFFF9A825),
                      onChanged:
                          (value) => setState(() => paymentMethod = value!),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (orderType == 'Delivery') ...[
                    _buildDropdownSection(
                      title: 'Select Building',
                      value: selectedBuilding,
                      items:
                          locations.map((e) => e['name'].toString()).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedBuilding = value;
                          roomList =
                              locations
                                  .firstWhere(
                                    (loc) => loc['name'] == value,
                                  )['rooms']
                                  .cast<String>();
                          roomList.sort();
                          selectedRoom = null;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    if (selectedBuilding != null)
                      _buildDropdownSection(
                        title: 'Select Room',
                        value: selectedRoom,
                        items: roomList,
                        onChanged: (val) => setState(() => selectedRoom = val),
                      ),
                  ],
                  const SizedBox(height: 12),
                  _buildSection(
                    title: 'Notes',
                    child: TextField(
                      onChanged: (val) => notes = val,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(),
                        hintText: 'Any additional instructions...',
                        hintStyle: TextStyle(color: Colors.white54),
                      ),
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDeliveryIncomplete
                              ? Colors.grey.shade800
                              : const Color(0xFFF9A825),
                      foregroundColor:
                          isDeliveryIncomplete ? Colors.white30 : Colors.black,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed:
                        isDeliveryIncomplete
                            ? null
                            : () async {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user == null) return;

                              final cartProvider = Provider.of<CartProvider>(
                                context,
                                listen: false,
                              );
                              final cartItems =
                                  cartProvider.items.map((item) {
                                    return {
                                      'name': item.name,
                                      'quantity': item.quantity,
                                      'price': item.price,
                                      'addons': item.addons,
                                      'type': item.type ?? '',
                                    };
                                  }).toList();

                              final total = cartProvider.subtotal;

                              await FirebaseFirestore.instance
                                  .collection('orders')
                                  .add({
                                    'userId': user.uid,
                                    'items': cartItems,
                                    'total': total,
                                    'timestamp': Timestamp.now(),
                                    'status': 'pending',
                                    'orderType': orderType,
                                    'paymentMethod': paymentMethod,
                                    'building': selectedBuilding ?? '',
                                    'room': selectedRoom ?? '',
                                    'notes': notes,
                                  });

                              cartProvider.clearCart();

                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Order placed successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ActiveOrdersScreen(),
                                ),
                                (route) => false,
                              );
                            },
                    child: const Text(
                      'Place Order',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildDropdownSection({
    required String title,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return _buildSection(
      title: title,
      child: DropdownButton<String>(
        value: value,
        hint: const Text('Select', style: TextStyle(color: Colors.white54)),
        dropdownColor: Colors.black,
        isExpanded: true,
        items:
            items
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, style: const TextStyle(color: Colors.white)),
                  ),
                )
                .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
