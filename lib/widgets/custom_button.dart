import 'package:flutter/material.dart';

enum ButtonType { filled, outlined, text }

class CustomButton extends StatelessWidget {
  final ButtonType buttonType;
  final bool enabled;
  final VoidCallback? onPressed;
  final String text;
  final double? width;

  const CustomButton({
    super.key,
    required this.buttonType,
    this.enabled = true,
    required this.onPressed,
    required this.text,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
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
