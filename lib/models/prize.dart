import 'package:decimal/decimal.dart' show Decimal;
import 'package:flutter/material.dart';

@immutable
class Prize {
  final Decimal amount;
  final double percentage;
  final String placeName;
  final int placeNumber;

  const Prize({
    required this.amount,
    required this.percentage,
    required this.placeName,
    required this.placeNumber,
  });
}
