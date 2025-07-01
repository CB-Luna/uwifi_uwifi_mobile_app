import 'package:flutter/material.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Wallet',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Free U Points',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '30',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 6),
                Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text('Points', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Row(
              children: [
                Text(
                  'My Accumulated U-Points',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
                SizedBox(width: 6),
                Tooltip(
                  message: 'Total U-Points accumulated',
                  child: Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: LinearProgressIndicator(
                value: 0.3,
                minHeight: 18,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
            const SizedBox(height: 6),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$0',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('\$10', style: TextStyle(color: Colors.grey)),
                Text('\$20', style: TextStyle(color: Colors.grey)),
                Text('\$38', style: TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Text(
                  'Me and my affiliated users',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
                const SizedBox(width: 6),
                const Tooltip(
                  message: 'Users affiliated to your account',
                  child: Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Colors.black45,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/adduser');
                  },
                  icon: const Icon(Icons.add, color: Colors.green),
                  label: const Text(
                    'Add User',
                    style: TextStyle(color: Colors.green),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                _UserCircle(initials: 'FB', color: Colors.green),
                _UserCircle(initials: 'AC'),
                _UserCircle(initials: 'EB'),
                _UserCircle(initials: 'EH'),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  'My Payment Methods',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/addcard');
                  },
                  icon: const Icon(Icons.add, color: Colors.green),
                  label: const Text(
                    'Add Card',
                    style: TextStyle(color: Colors.green),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/profile/CreditCardUI.png',
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _UserCircle extends StatelessWidget {
  final String initials;
  final Color? color;
  const _UserCircle({required this.initials, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: CircleAvatar(
        radius: 22,
        backgroundColor: color ?? Colors.grey.shade300,
        child: Text(
          initials,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
