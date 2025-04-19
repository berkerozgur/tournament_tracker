import 'package:flutter/material.dart';

typedef Validator = String? Function(String? value)?;

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Validator validator;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
        filled: true,
        label: Text(label),
      ),
      validator: validator,
    );
  }
}
