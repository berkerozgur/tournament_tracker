import 'package:flutter/material.dart';

class HeadlineSmallText extends StatelessWidget {
  final String text;

  const HeadlineSmallText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }
}
