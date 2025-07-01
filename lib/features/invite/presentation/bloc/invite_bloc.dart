import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_user_referral.dart';
import '../../domain/usecases/share_referral_link.dart';
import '../../domain/usecases/generate_qr_code.dart';
import 'invite_event.dart';
import 'invite_state.dart';

/// BLoC para manejar el estado de las invitaciones
class InviteBloc extends Bloc<InviteEvent, InviteState> {
  final GetUserReferral getUserReferral;
  final ShareReferralLink shareReferralLink;
  final GenerateQRCode generateQRCode;

  InviteBloc({
    required this.getUserReferral,
    required this.shareReferralLink,
    required this.generateQRCode,
  }) : super(const InviteInitial()) {
    on<LoadUserReferralEvent>(_onLoadUserReferral);
    on<ShareReferralLinkEvent>(_onShareReferralLink);
    on<GenerateQRCodeEvent>(_onGenerateQRCode);
    on<CopyReferralLinkEvent>(_onCopyReferralLink);
  }

  Future<void> _onLoadUserReferral(
    LoadUserReferralEvent event,
    Emitter<InviteState> emit,
  ) async {
    debugPrint('🔄 InviteBloc: Iniciando carga de referido...');
    emit(const InviteLoading());

    try {
      final result = await getUserReferral(NoParams());
      debugPrint('📊 InviteBloc: Resultado obtenido');

      result.fold(
        (failure) {
          debugPrint('❌ InviteBloc: Error - ${failure.runtimeType}');
          emit(const InviteError('Error al cargar información de referidos'));
        },
        (referral) {
          debugPrint('✅ InviteBloc: Referido cargado exitosamente - ${referral.referralCode}');
          emit(InviteLoaded(referral: referral));
        },
      );
    } catch (e, stackTrace) {
      debugPrint('💥 InviteBloc: Excepción no manejada: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      emit(const InviteError('Error inesperado al cargar información de referidos'));
    }
  }

  Future<void> _onShareReferralLink(
    ShareReferralLinkEvent event,
    Emitter<InviteState> emit,
  ) async {
    final result = await shareReferralLink(
      ShareReferralLinkParams(referralLink: event.referralLink),
    );

    result.fold(
      (failure) => emit(const InviteError('Error al compartir enlace')),
      (success) {
        if (success) {
          emit(const InviteShared('Link shared successfully!'));
          // Volver al estado cargado después de un momento
          Future.delayed(const Duration(seconds: 2), () {
            if (state is InviteLoaded) {
              // Mantener el estado actual
            } else {
              add(const LoadUserReferralEvent());
            }
          });
        } else {
          emit(const InviteError('Failed to share link'));
        }
      },
    );
  }

  Future<void> _onGenerateQRCode(
    GenerateQRCodeEvent event,
    Emitter<InviteState> emit,
  ) async {
    if (state is InviteLoaded) {
      final currentState = state as InviteLoaded;
      
      final result = await generateQRCode(
        GenerateQRCodeParams(referralLink: event.referralLink),
      );

      result.fold(
        (failure) => emit(const InviteError('Error al generar código QR')),
        (qrData) => emit(currentState.copyWith(qrCodeData: qrData)),
      );
    }
  }

  Future<void> _onCopyReferralLink(
    CopyReferralLinkEvent event,
    Emitter<InviteState> emit,
  ) async {
    try {
      await Clipboard.setData(ClipboardData(text: event.referralLink));
      emit(const InviteLinkCopied('Link copied to clipboard!'));
      
      // Volver al estado cargado después de un momento
      Future.delayed(const Duration(seconds: 2), () {
        add(const LoadUserReferralEvent());
      });
    } catch (e) {
      emit(InviteError('Failed to copy link: $e'));
    }
  }
}
