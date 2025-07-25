import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/send_affiliate_invitation.dart';
import 'affiliate_event.dart';
import 'affiliate_state.dart';

class AffiliateBloc extends Bloc<AffiliateEvent, AffiliateState> {
  final SendAffiliateInvitation sendAffiliateInvitation;

  AffiliateBloc({required this.sendAffiliateInvitation}) : super(AffiliateInitial()) {
    on<SendAffiliateInvitationEvent>(_onSendAffiliateInvitation);
  }

  Future<void> _onSendAffiliateInvitation(
    SendAffiliateInvitationEvent event,
    Emitter<AffiliateState> emit,
  ) async {
    emit(AffiliateLoading());

    final result = await sendAffiliateInvitation(
      SendAffiliateInvitationParams(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        phone: event.phone,
        customerId: event.customerId,
      ),
    );

    result.fold(
      (failure) => emit(AffiliateError(message: failure.message)),
      (_) => emit(const AffiliateSuccess()),
    );
  }
}
