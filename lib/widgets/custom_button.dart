import 'package:flutter/material.dart';

enum ButtonType { filled, outlined, text }

class CustomButton extends StatelessWidget {
  final ButtonType buttonType;
  final bool enabled;
  final double? minWidth;
  final VoidCallback? onPressed;
  final String text;

  const CustomButton({
    super.key,
    required this.buttonType,
    this.enabled = true,
    this.minWidth,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minWidth ?? 0,
      ),
      child: switch (buttonType) {
        ButtonType.filled => FilledButton(
            onPressed: enabled ? onPressed : null,
            child: Text(text),
          ),
        ButtonType.outlined => OutlinedButton(
            onPressed: enabled ? onPressed : null,
            child: Text(text),
          ),
        ButtonType.text => TextButton(
            onPressed: enabled ? onPressed : null,
            child: Text(text),
          ),
      },
    );
  }
}
