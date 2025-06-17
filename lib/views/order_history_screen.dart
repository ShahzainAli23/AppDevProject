import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "Please log in to see order history",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final ordersStream =
        FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .where('status', isEqualTo: 'delivered')
            .orderBy('timestamp', descending: true)
            .snapshots();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'ORDER HISTORY',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: ordersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No past orders.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final timestamp = (data['timestamp'] as Timestamp).toDate();
              final formattedTime = DateFormat(
                'd MMM, yyyy • h:mm a',
              ).format(timestamp);
              final total = data['total'];
              final items = data['items'] as List<dynamic>;
              final itemCount = items.length;
              final building = data['building'];
              final room = data['room'];
              final orderType = data['orderType'];
              final paymentMethod = data['paymentMethod'];

              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white12),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$itemCount item${itemCount > 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Rs $total',
                          style: const TextStyle(
                            color: Color(0xFFF9A825),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Sub info
                    Text(
                      formattedTime,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Text(
                      '$orderType • $paymentMethod',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Delivered to $room, $building',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),

                    const Divider(height: 20, color: Colors.white12),

                    // Items List
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          items.map((item) {
                            final name = item['name'] ?? 'Item';
                            final quantity = item['quantity'] ?? 1;
                            final type = item['type'] ?? '';
                            final addons =
                                (item['addons'] as List<dynamic>?)
                                    ?.whereType<String>()
                                    .toList() ??
                                [];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$name x$quantity',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (type.isNotEmpty)
                                    Text(
                                      '• Type: $type',
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 13,
                                      ),
                                    ),
                                  if (addons.isNotEmpty)
                                    Text(
                                      '• Add-ons: ${addons.join(", ")}',
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 13,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
