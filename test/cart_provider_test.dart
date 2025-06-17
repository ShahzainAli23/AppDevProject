import 'package:flutter_test/flutter_test.dart';
import 'package:darb_food_app/views/cart_provider.dart';

void main() {
  group('CartProvider', () {
    late CartProvider cartProvider;
    late CartItem burger;
    late CartItem pizza;

    setUp(() {
      cartProvider = CartProvider();

      burger = CartItem(
        name: 'Burger',
        image: 'burger.png',
        price: 300,
        quantity: 2,
        addons: ['Cheese', 'Lettuce'],
        type: 'Beef',
      );

      pizza = CartItem(
        name: 'Pizza',
        image: 'pizza.png',
        price: 500,
        quantity: 1,
        addons: [],
        type: null,
      );
    });

    test('initial cart should be empty', () {
      expect(cartProvider.items, isEmpty);
      expect(cartProvider.subtotal, 0);
    });

    test('addItem adds item to cart', () {
      cartProvider.addItem(burger);
      expect(cartProvider.items.length, 1);
      expect(cartProvider.items.first.name, 'Burger');
    });

    test('removeItem removes correct item', () {
      cartProvider.addItem(burger);
      cartProvider.addItem(pizza);
      cartProvider.removeItem(burger);
      expect(cartProvider.items.length, 1);
      expect(cartProvider.items.first.name, 'Pizza');
    });

    test('clearCart empties the cart', () {
      cartProvider.addItem(burger);
      cartProvider.addItem(pizza);
      cartProvider.clearCart();
      expect(cartProvider.items, isEmpty);
    });

    test('subtotal calculates total correctly', () {
      cartProvider.addItem(burger); // 300 * 2 = 600
      cartProvider.addItem(pizza); // 500 * 1 = 500
      expect(cartProvider.subtotal, 1100);
    });

    test('CartItem equality comparison works', () {
      final burgerCopy = CartItem(
        name: 'Burger',
        image: 'burger.png',
        price: 300,
        quantity: 2,
        addons: ['Cheese', 'Lettuce'],
        type: 'Beef',
      );

      expect(burger, burgerCopy); // equality only
    });
  });
}
