import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_provider.dart';

class UwifiStorePage extends StatefulWidget {
  const UwifiStorePage({super.key});

  @override
  State<UwifiStorePage> createState() => _UwifiStorePageState();
}

class _UwifiStorePageState extends State<UwifiStorePage> {
  int selectedCategory = 0;
  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.card_giftcard, 'label': 'Gift Cards'},
    {'icon': Icons.router, 'label': 'Devices'},
    {'icon': Icons.add_box_outlined, 'label': 'Add-ons'},
  ];

  // Productos para la categoría Devices
  final List<Map<String, dynamic>> deviceProducts = [
    {
      'name': 'Signal Extender',
      'price': 99,
      'image': 'assets/images/profile/signal_extender.jpeg',
      'category': 1,
    },
    {
      'name': 'Wi-Fi Range Extender',
      'price': 39,
      'image': 'assets/images/profile/wifi_range_extender.jpg',
      'category': 1,
    },
  ];

  // Tarjetas de regalo para la categoría Gift Cards
  final List<Map<String, dynamic>> giftCards = [
    {
      'name': 'Visa Gift Card',
      'price': '25 - 200',
      'image': 'assets/images/profile/visa-gift-cardsm.png',
      'description': 'Use anywhere Visa is accepted',
    },
    {
      'name': 'Walmart Gift Card',
      'price': '10 - 500',
      'image': 'assets/images/profile/walmart.png',
      'description': 'Shop at Walmart stores or online',
    },
  ];

  // Add-ons para la categoría Add-ons
  final List<Map<String, dynamic>> addOns = [
    {
      'name': 'Premium Support',
      'price': 5,
      'image': 'assets/images/profile/premium_support.png',
      'description': '24/7 priority technical support',
      'period': 'monthly',
    },
    {
      'name': 'Data Boost',
      'price': 10,
      'image': 'assets/images/profile/data_boost.png',
      'description': 'Extra 5GB of high-speed data',
      'period': 'one-time',
    },
    {
      'name': 'Family Plan',
      'price': 15,
      'image': 'assets/images/profile/family_plan.png',
      'description': 'Add up to 4 family members',
      'period': 'monthly',
    },
  ];

  // Free gift card para la sección de bonus
  final Map<String, dynamic> freeGiftCard = {
    'name': 'Free Gift Card',
    'price': '25',
    'description': 'Earned by Bonus Points',
  };

  void addToCart(Map<String, dynamic> product) {
    context.read<CartProvider>().addItem(product);
  }

  // Construye el contenido según la categoría seleccionada
  Widget _buildCategoryContent() {
    switch (selectedCategory) {
      case 0: // Gift Cards
        return _buildGiftCardsContent();
      case 1: // Devices
        return _buildDevicesContent();
      case 2: // Add-ons
        return _buildAddOnsContent();
      default:
        return const SizedBox.shrink();
    }
  }

  // Contenido para Gift Cards
  Widget _buildGiftCardsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título y botón Ver Todo
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recommended for you',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'See All',
                style: TextStyle(
                  color: Color(0xFF7B3FF2),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Gift Cards recomendadas
        SizedBox(
          height: 280,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: giftCards.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final giftCard = giftCards[index];
              // Aseguramos que tenga la propiedad category para consistencia
              if (!giftCard.containsKey('category')) {
                giftCard['category'] = 0; // Categoría 0 para Gift Cards
              }

              return Consumer<CartProvider>(
                builder: (context, cart, child) {
                  final isInCart = cart.isInCart(giftCard['name']);
                  final quantity = cart.getItemQuantity(giftCard['name']);

                  return Container(
                    width: 170,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              giftCard['image'],
                              fit: BoxFit.contain,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.blue.shade100,
                                  child: Center(
                                    child: Text(
                                      giftCard['name'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          giftCard['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "\$${giftCard['price']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => addToCart(giftCard),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isInCart
                                  ? Colors.green
                                  : Colors.white,
                              foregroundColor: isInCart
                                  ? Colors.white
                                  : Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: const BorderSide(
                                  color: Colors.green,
                                  width: 1.5,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 0,
                            ),
                            child: Text(
                              isInCart ? 'In Cart ($quantity)' : 'Add to Cart',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),

        const SizedBox(height: 24),

        // Free Gift Card section
        const Text(
          'Free Gift Card',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(height: 4),
        const Text(
          'Earned by Bonus Points',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade400,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Free Gift Card',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "\$${freeGiftCard['price']}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.card_giftcard, color: Colors.white, size: 48),
            ],
          ),
        ),
      ],
    );
  }

  // Contenido para Devices
  Widget _buildDevicesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Available Devices',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'See All',
                style: TextStyle(
                  color: Color(0xFF7B3FF2),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: deviceProducts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final product = deviceProducts[index];
              return Consumer<CartProvider>(
                builder: (context, cart, child) {
                  final isInCart = cart.isInCart(product['name']);
                  final quantity = cart.getItemQuantity(product['name']);

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(
                        context,
                      ).pushNamed('/productdetails', arguments: product);
                    },
                    child: Container(
                      width: 170,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                product['image'],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            product['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "\$${product['price']}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => addToCart(product),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isInCart
                                    ? Colors.green
                                    : Colors.white,
                                foregroundColor: isInCart
                                    ? Colors.white
                                    : Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  side: const BorderSide(
                                    color: Colors.green,
                                    width: 1.5,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                isInCart
                                    ? 'In Cart ($quantity)'
                                    : 'Add to Cart',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Contenido para Add-ons
  Widget _buildAddOnsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Add-ons',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: addOns.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final addon = addOns[index];
            return Consumer<CartProvider>(
              builder: (context, cart, child) {
                final isInCart = cart.isInCart(addon['name']);
                final quantity = cart.getItemQuantity(addon['name']);

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            index == 0
                                ? Icons.support_agent
                                : index == 1
                                ? Icons.data_usage
                                : Icons.family_restroom,
                            color: Colors.blue.shade800,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              addon['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              addon['description'],
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  "\$${addon['price']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF7B3FF2),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "/${addon['period']}",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => addToCart(addon),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isInCart
                              ? Colors.green
                              : const Color(0xFF7B3FF2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: Text(isInCart ? 'Added ($quantity)' : 'Add'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  void goToCart() {
    final cartProvider = context.read<CartProvider>();
    if (cartProvider.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cart is empty'),
          content: const Text('You have not added any products to your cart.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pushNamed('/shoppingcart');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'U-wifi Store',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.black,
                    ),
                    onPressed: goToCart,
                  ),
                  if (cart.totalQuantity > 0)
                    Positioned(
                      right: 12,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          cart.totalQuantity.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search for products',
                          border: InputBorder.none,
                        ),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              // Promo banner
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B3FF2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Boost Your Home Signal',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Find products to enhance your internet connection and ensure a strong signal throughout your home.',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD44B),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.arrow_right_alt),
                      label: const Text(
                        'Explore Products',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Categories
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final bool selected = index == selectedCategory;
                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedCategory = index);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF7B3FF2)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              cat['icon'],
                              color: selected ? Colors.white : Colors.black54,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              cat['label'],
                              style: TextStyle(
                                color: selected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Contenido según la categoría seleccionada
              _buildCategoryContent(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
