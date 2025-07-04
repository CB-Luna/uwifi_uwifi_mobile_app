import 'package:flutter/material.dart';
import 'speedtest/speed_test_page.dart';

class WifiSettingsPage extends StatelessWidget {
  const WifiSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wi-Fi Settings'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Center(
              child: Image.asset(
                'assets/images/homeimage/realGateway.png',
                height: 200,
                width: 200,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            // 2.4 GHz
            _wifiCard(
              context,
              title: '2.4 GHz',
              networkName: 'Risky Reels',
              password: 'Password',
            ),
            const SizedBox(height: 16),
            // 5 GHz
            _wifiCard(
              context,
              title: '5 GHz',
              networkName: 'Speed Reels 5G',
              password: '********',
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SpeedTestPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.speed, color: Colors.green),
                      label: const Text('Speed Test'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.restart_alt, color: Colors.purple),
                      label: const Text('Reboot Gateway'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.purple,
                        side: const BorderSide(color: Colors.purple),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _wifiCard(
    BuildContext context, {
    required String title,
    required String networkName,
    required String password,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wifi, color: Colors.black),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.info_outline, color: Colors.grey.shade400),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        title == '2.4 GHz'
                            ? '2.4 GHz Network'
                            : '5 GHz Network',
                      ),
                      content: Text(
                        title == '2.4 GHz'
                            ? "This network covers a larger area and goes through walls better, but it's a bit slower. It's great for older devices or when you're farther from the router."
                            : "This one is faster but has a shorter range. It's perfect for streaming, gaming, or using the internet near the router.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Ok'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Network Name', style: TextStyle(color: Colors.grey.shade600)),
          Row(
            children: [
              Expanded(
                child: Text(
                  networkName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.copy, size: 18),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.edit, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Password', style: TextStyle(color: Colors.grey.shade600)),
          Row(
            children: [
              Expanded(
                child: Text(
                  password,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.visibility_off, size: 18),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.copy, size: 18),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.edit, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
