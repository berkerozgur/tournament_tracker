import 'package:flutter/material.dart';

typedef Validator = String? Function(String? value)?;

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final bool isOutlined;
  final String label;
  final Validator validator;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
    this.isOutlined = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        label: Text(label),
        border: isOutlined ? const OutlineInputBorder() : null,
      ),
      validator: validator,
    );
  }
}
