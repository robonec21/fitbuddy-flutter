import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmButtonText;
  final Color? confirmButtonColor;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmButtonText = 'Delete',
    this.confirmButtonColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: confirmButtonColor != null
            ? ElevatedButton.styleFrom(
                backgroundColor: confirmButtonColor,
                foregroundColor: Colors.white,
              )
            : null,
          child: Text(confirmButtonText),
        ),
      ],
    );
  }
}