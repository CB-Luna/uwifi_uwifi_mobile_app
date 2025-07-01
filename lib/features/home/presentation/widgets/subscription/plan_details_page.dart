import 'package:flutter/material.dart';

class PlanDetailsPage extends StatelessWidget {
  const PlanDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Plan Details',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de plan activo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/homeimage/launcher.png',
                    height: 48,
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'U-Wifi Internet',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Recurring Charge',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Due date: Apr 23',
                          style: TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Transaction History
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[600]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.list_alt, color: Colors.black54),
                      const SizedBox(width: 6),
                      const Text(
                        'Transaction History',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.sort, size: 18, color: Colors.black45),
                            SizedBox(width: 4),
                            Text(
                              'newest',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 18,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Lista de transacciones (scroll interno, máximo 5 visibles)
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 320,
                    ), // 5 * aprox 64px
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: _transactions.length,
                      itemBuilder: (context, i) => _transactionItem(
                        _transactions[i]['date'],
                        _transactions[i]['type'],
                        _transactions[i]['id'],
                        _transactions[i]['amount'],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // My user group
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[600]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.groups, size: 20, color: Colors.black54),
                      SizedBox(width: 8),
                      Text(
                        'My user group',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.keyboard_arrow_up, color: Colors.black45),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 120,
                    ), // Más compacto
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: _users.length > 3 ? 3 : _users.length,
                      itemBuilder: (context, i) => _userItem(
                        _users[i]['name'],
                        _users[i]['initials'],
                        isMain: _users[i]['isMain'] ?? false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _transactionItem(String date, String type, String id, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.attach_money,
              color: Colors.green,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Transaction ID: $id',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  date,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(1)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _userItem(String name, String initials, {bool isMain = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[400],
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
          if (isMain) const Icon(Icons.star, color: Colors.amber, size: 20),
        ],
      ),
    );
  }
}

// Listas mock para transacciones y usuarios fuera de la clase
const List<Map<String, dynamic>> _transactions = [
  {
    'date': '2025/06/08',
    'type': 'Recurring Charge',
    'id': '1565',
    'amount': 38.0,
  },
  {
    'date': '2025/05/08',
    'type': 'Recurring Charge',
    'id': '1375',
    'amount': 38.0,
  },
  {'date': '2025/04/25', 'type': 'Payment', 'id': '1258', 'amount': 0.0},
  {'date': '2025/04/25', 'type': 'Payment', 'id': '1257', 'amount': 0.0},
  {'date': '2025/03/25', 'type': 'Payment', 'id': '1200', 'amount': 0.0},
  {'date': '2025/02/25', 'type': 'Payment', 'id': '1199', 'amount': 0.0},
  {'date': '2025/01/25', 'type': 'Payment', 'id': '1198', 'amount': 0.0},
  {'date': '2024/12/25', 'type': 'Payment', 'id': '1197', 'amount': 0.0},
  {'date': '2024/11/25', 'type': 'Payment', 'id': '1196', 'amount': 0.0},
  {'date': '2024/10/25', 'type': 'Payment', 'id': '1195', 'amount': 0.0},
];
const List<Map<String, dynamic>> _users = [
  {'name': 'Frank Befera', 'initials': 'FB', 'isMain': true},
  {'name': 'Alex Castillo', 'initials': 'AC'},
  {'name': 'Edna Bañaga', 'initials': 'EB'},
  {'name': 'Edna Halaga', 'initials': 'EH'},
  {'name': 'Maria Lopez', 'initials': 'ML'},
  {'name': 'John Doe', 'initials': 'JD'},
  {'name': 'Jane Smith', 'initials': 'JS'},
  {'name': 'Carlos Perez', 'initials': 'CP'},
  {'name': 'Ana Torres', 'initials': 'AT'},
  {'name': 'Luis Gomez', 'initials': 'LG'},
];
