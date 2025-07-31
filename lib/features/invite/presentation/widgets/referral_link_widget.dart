import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../customer/domain/entities/customer_details.dart';
import '../../../customer/presentation/bloc/customer_details_bloc.dart';
import '../bloc/invite_bloc.dart';
import '../bloc/invite_event.dart';

/// Widget para mostrar y compartir el enlace de referido
class ReferralLinkWidget extends StatelessWidget {
  final String referralLink;
  final String referralCode;

  const ReferralLinkWidget({
    required this.referralLink,
    required this.referralCode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y contenedor del enlace en una sola fila
          Row(
            children: [
              const Text(
                'Share your invitation link',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              // Botón de copiar
              GestureDetector(
                onTap: () {
                  final customerState = context.read<CustomerDetailsBloc>().state;
                  CustomerDetails? customerDetails;
                  
                  if (customerState is CustomerDetailsLoaded) {
                    customerDetails = customerState.customerDetails;
                    AppLogger.navInfo(
                      'ReferralLinkWidget: Copiando enlace - sharedLinkId: ${customerDetails.sharedLinkId}',
                    );
                  }
                  
                  context.read<InviteBloc>().add(
                    CopyReferralLinkEvent(referralLink, customerDetails: customerDetails),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.copy,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Contenedor del enlace
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              referralLink,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 12),

          // Botones de acción
          Row(
            children: [
              // Botón Share Link
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final customerState = context.read<CustomerDetailsBloc>().state;
                    CustomerDetails? customerDetails;
                    
                    if (customerState is CustomerDetailsLoaded) {
                      customerDetails = customerState.customerDetails;
                    }
                    
                    context.read<InviteBloc>().add(
                      ShareReferralLinkEvent(referralLink, customerDetails: customerDetails),
                    );
                  },
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text('Share Link'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Botón QR Code
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showQRCodeDialog(context);
                  },
                  icon: const Icon(Icons.qr_code, size: 16),
                  label: const Text('QR Code'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showQRCodeDialog(BuildContext context) {
    context.read<InviteBloc>().add(GenerateQRCodeEvent(referralLink));

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<InviteBloc>(),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'QR Code',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                // QR Code
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: QrImageView(
                    data: referralLink,
                    size: 200.0,
                    backgroundColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Scan this QR code to access the referral link',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
