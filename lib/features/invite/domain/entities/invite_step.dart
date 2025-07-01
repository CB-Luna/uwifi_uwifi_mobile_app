import 'package:equatable/equatable.dart';

/// Entidad que representa un paso del proceso de invitación
class InviteStep extends Equatable {
  final int stepNumber;
  final String title;
  final String description;
  final String iconPath;

  const InviteStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.iconPath,
  });

  @override
  List<Object?> get props => [stepNumber, title, description, iconPath];
}

/// Pasos predefinidos del proceso de invitación
class InviteSteps {
  static const List<InviteStep> steps = [
    InviteStep(
      stepNumber: 1,
      title: 'Share the link or QR code with a friend',
      description: 'Send your unique referral link to friends and family',
      iconPath: 'assets/icons/share.png',
    ),
    InviteStep(
      stepNumber: 2,
      title: 'Your friend joins U-wifi',
      description: 'They sign up using your referral link',
      iconPath: 'assets/icons/join.png',
    ),
    InviteStep(
      stepNumber: 3,
      title: 'Your friend will receive a discount on their plan! (Just like U)',
      description: 'Both you and your friend get exclusive benefits',
      iconPath: 'assets/icons/discount.png',
    ),
  ];
}
