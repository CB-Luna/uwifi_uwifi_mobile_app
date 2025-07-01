import 'package:flutter/material.dart';

enum AutoPayAction { activated, deactivated, cancel }

class MyUwifiPlanAutoPayModal extends StatelessWidget {
  final bool activating;
  const MyUwifiPlanAutoPayModal({required this.activating, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        activating ? 'Activate Autopay?' : 'Deactivate Autopay?',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(
        activating
            ? 'Are you sure you want to activate Autopay? Your payments will be processed automatically on the due date. You can disable this setting anytime.'
            : 'Are you sure you want to deactivate Autopay? You will need to make payments manually before the due date. You can enable this setting anytime.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(AutoPayAction.cancel),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(
            activating ? AutoPayAction.activated : AutoPayAction.deactivated,
          ),
          child: Text(activating ? 'Activate' : 'Deactivate'),
        ),
      ],
    );
  }
}

class MyUwifiPlanAutoPayConfirmationModal extends StatelessWidget {
  final bool activated;
  const MyUwifiPlanAutoPayConfirmationModal({
    required this.activated,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        activated ? 'Auto Payment Activated' : 'Auto Payment Turned Off',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(
        activated
            ? 'Your auto payment is now active. Monthly charges will be made automatically using your saved payment method. Thanks for staying up to date!'
            : 'You\'ve successfully turned off auto payment. Future charges will need to be made manually to keep your plan active.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Ok'),
        ),
      ],
    );
  }
}
