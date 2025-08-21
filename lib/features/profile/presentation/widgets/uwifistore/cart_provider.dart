import 'package:flutter/foundation.dart';

class CartItem {
  final String name;
  final double price;
  final String image;
  final String? model;
  final int category;
  int quantity;

  CartItem({
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    this.model,
    this.quantity = 1,
  });

  CartItem copyWith({
    String? name,
    double? price,
    String? image,
    String? model,
    int? category,
    int? quantity,
  }) {
    return CartItem(
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      model: model ?? this.model,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'image': image,
      'model': model,
      'category': category,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    // Manejo de diferentes tipos de precio (string o número)
    dynamic rawPrice = map['price'] ?? 0;
    double finalPrice;
    
    if (rawPrice is String) {
      // Si es un rango como "25 - 200", tomamos el valor mínimo
      if (rawPrice.contains('-')) {
        try {
          finalPrice = double.parse(rawPrice.split('-')[0].trim());
        } catch (e) {
          finalPrice = 0.0; // Valor por defecto si hay error
        }
      } else {
        // Intentar convertir directamente
        try {
          finalPrice = double.parse(rawPrice);
        } catch (e) {
          finalPrice = 0.0; // Valor por defecto si hay error
        }
      }
    } else {
      // Si ya es un número
      finalPrice = (rawPrice is num) ? rawPrice.toDouble() : 0.0;
    }
    
    return CartItem(
      name: map['name'] ?? '',
      price: finalPrice,
      image: map['image'] ?? '',
      model: map['model'],
      category: map['category'] ?? 0,
      quantity: map['quantity'] ?? 1,
    );
  }
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.length;

  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  double get shipping => _items.isNotEmpty ? 4.99 : 0.0;

  double get tax => _items.isNotEmpty ? 2.54 : 0.0;

  double get total => subtotal + shipping + tax;

  bool get isEmpty => _items.isEmpty;

  void addItem(Map<String, dynamic> product) {
    final existingIndex = _items.indexWhere(
      (item) => item.name == product['name'],
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem.fromMap(product));
    }
    notifyListeners();
  }

  void incrementQuantity(int index) {
    if (index >= 0 && index < _items.length) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(int index) {
    if (index >= 0 && index < _items.length) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void updateItemQuantity(int index, int quantity) {
    if (index >= 0 && index < _items.length) {
      if (quantity > 0) {
        _items[index].quantity = quantity;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  bool isInCart(String productName) {
    return _items.any((item) => item.name == productName);
  }

  int getItemQuantity(String productName) {
    final item = _items.firstWhere(
      (item) => item.name == productName,
      orElse: () =>
          CartItem(name: '', price: 0, image: '', category: 0, quantity: 0),
    );
    return item.quantity;
  }
}
