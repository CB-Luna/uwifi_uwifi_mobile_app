import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/utils/app_logger.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import 'account_security_faq_page.dart';
import 'submit_ticket_page.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacityAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Help Center',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Check out more information in the FAQs',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return AnimatedOpacity(
                  opacity: _opacityAnim.value,
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedSlide(
                    offset: _slideAnim.value,
                    duration: const Duration(milliseconds: 300),
                    child: child,
                  ),
                );
              },
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 2.5,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _HelpCategoryButton(
                    icon: Icons.lock_outline,
                    label: 'Account\n& Security',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AccountSecurityFaqPage(),
                        ),
                      );
                    },
                  ),
                  const _HelpCategoryButton(
                    icon: Icons.signal_cellular_alt,
                    label: 'Connection\n& Devices',
                  ),
                  const _HelpCategoryButton(
                    icon: Icons.ondemand_video,
                    label: 'Videos\n& Rewards',
                  ),
                  const _HelpCategoryButton(
                    icon: Icons.emoji_events,
                    label: 'Points\n& Discounts',
                  ),
                  const _HelpCategoryButton(
                    icon: Icons.handshake,
                    label: 'Affiliates\n& Referrals',
                  ),
                  const _HelpCategoryButton(
                    icon: Icons.settings,
                    label: 'App Usage',
                  ),
                  const _HelpCategoryButton(
                    icon: Icons.credit_card,
                    label: 'Payments\n& Plans',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Contact Us',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 14),
            Column(
              children: [
                _ContactOption(
                  icon: Icons.phone,
                  label: 'Call Us',
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Call Customer Support'),
                        content: const Text(
                          'Your phone will open to dial directly to the U-wifi service number',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Call'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      final uri = Uri(scheme: 'tel', path: '+1234567890');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    }
                  },
                ),
                const SizedBox(height: 10),
                _ContactOption(
                  icon: Icons.confirmation_number_outlined,
                  label: 'Tickets',
                  onTap: () {
                    // Verificamos si podemos obtener el AuthBloc del contexto actual
                    try {
                      final authBloc = BlocProvider.of<AuthBloc>(context);
                      AppLogger.navInfo(
                        'HelpCenterPage: Estado de AuthBloc: ${authBloc.state.runtimeType}',
                      );

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BlocProvider.value(
                            value: authBloc,
                            child: const SubmitTicketPageProvider(),
                          ),
                        ),
                      );
                    } catch (e) {
                      AppLogger.navError(
                        'Error al obtener AuthBloc en HelpCenterPage: $e',
                      );
                      // Si no podemos obtener el AuthBloc, mostramos un mensaje de error
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Error: No se pudo acceder a la información de autenticación',
                          ),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                _ContactOption(
                  icon: Icons.email_outlined,
                  label: 'Email Us',
                  onTap: () async {
                    final uri = Uri(
                      scheme: 'mailto',
                      path: 'support@uwifi.com',
                      query: 'subject=Support Request',
                    );
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                ),
                const SizedBox(height: 10),
                const _ContactOption(
                  icon: Icons.chat_bubble_outline,
                  label: 'Chatbot',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpCategoryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _HelpCategoryButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE0E3E8),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 28, color: Colors.black87),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _ContactOption({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE0E3E8),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: Colors.black87, size: 22),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
