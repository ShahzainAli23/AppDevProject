import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';

class ActiveOrdersScreen extends StatefulWidget {
  const ActiveOrdersScreen({super.key});

  @override
  State<ActiveOrdersScreen> createState() => _ActiveOrdersScreenState();
}

class _ActiveOrdersScreenState extends State<ActiveOrdersScreen> {
  final Map<String, String> _lastStatuses = {};

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "Please log in to see your orders",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final ordersStream =
        FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .where('status', isNotEqualTo: 'delivered')
            .orderBy('timestamp', descending: true)
            .snapshots();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'CURRENT ORDERS',
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
                'No active orders right now.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          for (final doc in docs) {
            final id = doc.id;
            final status = doc['status'];

            if (_lastStatuses[id] != null && _lastStatuses[id] != status) {
              NotificationService.show(
                "Order Update",
                "Your order #${id.substring(0, 6).toUpperCase()} is now $status",
              );
            }

            _lastStatuses[id] = status;
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final id = doc.id.substring(0, 6).toUpperCase();

              final status = data['status'];
              final total = data['total'];
              final type = data['orderType'];
              final method = data['paymentMethod'];
              final notes = data['notes'];
              final timestamp = (data['timestamp'] as Timestamp).toDate();
              final items = data['items'] as List<dynamic>;

              final timeStr = DateFormat('MMM d, h:mm a').format(timestamp);

              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF9A825).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order ID & Time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order #$id',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.white54,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              timeStr,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Total & Meta
                    Row(
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.white70,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${items.length} items',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.attach_money,
                          color: Colors.white70,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Rs $total',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Tags
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _buildTag(status),
                        _buildTag(type),
                        _buildTag(method),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Items
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          items.map((item) {
                            final name = item['name'] ?? 'Unnamed';
                            final quantity = item['quantity'] ?? 1;
                            final itemType = item['type'] ?? '';
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
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (itemType.isNotEmpty)
                                    Text(
                                      '• Type: $itemType',
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  if (addons.isNotEmpty)
                                    Text(
                                      '• Add-ons: ${addons.join(", ")}',
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),

                    // Notes
                    if (notes.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.note_alt_outlined,
                            size: 16,
                            color: Colors.white38,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              notes,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTag(String text) {
    final lowercase = text.toLowerCase();
    Color tagColor;

    if (lowercase.contains('pending')) {
      tagColor = Colors.orangeAccent;
    } else if (lowercase.contains('preparing')) {
      tagColor = Colors.blueAccent;
    } else if (lowercase.contains('on the way') || lowercase.contains('out')) {
      tagColor = Colors.greenAccent;
    } else {
      tagColor = const Color(0xFFF9A825);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: tagColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
