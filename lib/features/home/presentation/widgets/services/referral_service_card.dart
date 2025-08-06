import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uwifiapp/core/utils/responsive_font_sizes_screen.dart';

import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../customer/presentation/bloc/customer_details_bloc.dart';
import 'qr_referral_modal.dart';

class ReferralServiceCard extends StatelessWidget {
  const ReferralServiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Imagen animada de fondo
          Positioned(
            top: 0, // Alineada con el borde superior de la tarjeta
            bottom: 0, // Alineada con el borde inferior de la tarjeta
            right: 0, // Alineada con el borde derecho de la tarjeta
            child: SizedBox(
              width: 200, // Tamaño de la imagen
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: Opacity(
                  opacity: 0.8, // Transparencia para que no tape completamente
                  child: Image.asset(
                    'assets/images/homeimage/metalgif.gif',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
          ),

          // Contenido principal de la tarjeta (encima de la imagen)
          Container(
            padding: const EdgeInsets.only(top: 16, left: 16, bottom: 16),
            child: Row(
              children: [
                // Contenido del lado izquierdo
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título con imagen UserMetalic
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/homeimage/UserMetalic.png',
                            height: 35,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Refer & Win!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: responsiveFontSizesScreen.bodyLarge(
                                context,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Texto descriptivo
                      Text(
                        'Invite a friend — you\'ll both get exclusive\nperks when they sign up with your link.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: responsiveFontSizesScreen.bodyMedium(
                            context,
                          ),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 16),

                      // Botón QR Code (justificado a la izquierda)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Obtener los detalles del cliente actuales
                            final customerState = context
                                .read<CustomerDetailsBloc>()
                                .state;
                            String referralLink;

                            if (customerState is CustomerDetailsLoaded &&
                                customerState
                                    .customerDetails
                                    .sharedLinkId
                                    .isNotEmpty) {
                              // Usar el sharedLinkId del cliente para generar el enlace
                              final sharedLinkId =
                                  customerState.customerDetails.sharedLinkId;
                              referralLink =
                                  '${ApiEndpoints.inviteBaseUrl}/$sharedLinkId';

                              AppLogger.navInfo(
                                'ReferralServiceCard: Usando sharedLinkId para QR - $sharedLinkId',
                              );
                            } else {
                              // Enlace de fallback si no hay sharedLinkId disponible
                              referralLink =
                                  '${ApiEndpoints.inviteBaseUrl}/DEMO001';

                              AppLogger.navInfo(
                                'ReferralServiceCard: Usando enlace de fallback para QR',
                              );
                            }

                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              builder: (context) =>
                                  QrReferralModal(referralLink: referralLink),
                            );
                          },
                          icon: const Icon(
                            Icons.qr_code_rounded,
                            color: Colors.green,
                            size: 16,
                          ),
                          label: Text(
                            'QR Code',
                            style: TextStyle(
                              fontSize: responsiveFontSizesScreen.bodySmall(
                                context,
                              ),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green,
                            side: const BorderSide(color: Colors.green),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Espacio para la imagen de fondo
                const SizedBox(width: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
