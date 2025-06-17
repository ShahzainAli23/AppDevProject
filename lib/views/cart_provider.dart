import 'package:flutter/material.dart';

class CartItem {
  final String name;
  final String image;
  final int price;
  final int quantity;
  final List<String> addons;
  final String? type;

  CartItem({
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    required this.addons,
    this.type,
  });

  // Important: equality override so removeItem(item) works correctly
  @override
  bool operator ==(Object other) {
    return other is CartItem &&
        other.name == name &&
        other.image == image &&
        other.price == price &&
        other.quantity == quantity &&
        other.type == type &&
        _listEquals(other.addons, addons);
  }

  @override
  int get hashCode =>
      name.hashCode ^
      image.hashCode ^
      price.hashCode ^
      quantity.hashCode ^
      type.hashCode ^
      addons.hashCode;

  bool _listEquals(List a, List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addItem(CartItem item) {
    _items.add(item);
    notifyListeners();
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  num get subtotal =>
      _items.fold(0, (total, item) => total + item.price * item.quantity);
}
