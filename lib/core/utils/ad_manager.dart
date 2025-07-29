import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Clase para gestionar los anuncios en la aplicación
class AdManager {
  static String get bannerAdUnitId {
    if (kDebugMode) {
      // Usar IDs de prueba en modo debug
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111'; // ID de prueba para Android
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716'; // ID de prueba para iOS
      }
    } else {
      // Usar IDs reales en producción
      if (Platform.isAndroid) {
        return 'ca-app-pub-1952833225330412/6313142118';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-1952833225330412/3708241645';
      }
    }
    throw UnsupportedError('Plataforma no soportada para anuncios');
  }

  /// Inicializa el SDK de Google Mobile Ads
  static Future<void> initialize() async {
    if (kDebugMode) {
      print('Inicializando Google Mobile Ads SDK...');
    }
    
    await MobileAds.instance.initialize();
    
    // Configuración para anuncios de prueba en entorno de desarrollo
    if (kDebugMode) {
      MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          // Incluir el ID de tu dispositivo real y el simulador
          testDeviceIds: [
            '40C19B4D1D0CF5052F610654390F5301', // ID de tu dispositivo Motorola
            'kGADSimulatorID', // Para simuladores
          ],
        ),
      );
      print('Google Mobile Ads SDK inicializado con configuración de prueba');
    }
  }

  /// Crea un BannerAd
  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            print('Ad loaded: ${ad.adUnitId}');
          }
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            print('Ad failed to load: ${ad.adUnitId}, $error');
          }
          ad.dispose();
        },
        onAdOpened: (ad) {
          if (kDebugMode) {
            print('Ad opened: ${ad.adUnitId}');
          }
        },
        onAdClosed: (ad) {
          if (kDebugMode) {
            print('Ad closed: ${ad.adUnitId}');
          }
        },
      ),
    );
  }
}
