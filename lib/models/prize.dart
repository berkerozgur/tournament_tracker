import 'package:decimal/decimal.dart' show Decimal;
// import 'package:flutter/material.dart';

/// Represents a prize in a competition or contest.
///
/// This immutable class holds information about a specific prize, including its
/// monetary value, percentage of total prize pool, placement name, and numerical position.
// @immutable
class Prize {
  /// Unique identifier for the prize.
  int? id;

  /// The monetary value of the prize, stored as a [Decimal] for precise calculations.
  Decimal? amount;

  /// The percentage this prize represents of the total prize pool.
  ///
  /// Value should be between 0 and 100.
  double? percentage;

  /// The descriptive name of the placement (e.g., "First Place", "Runner Up").
  String placeName;

  /// The numerical position of this prize (e.g., 1 for first place, 2 for second place).
  ///
  /// Should be a positive integer.
  int placeNumber;

  /// Creates a new [Prize] instance.
  Prize({
    required this.id,
    this.amount,
    this.percentage,
    required this.placeName,
    required this.placeNumber,
  });

  Prize.fromStrings({
    required String amount,
    required String percentage,
    required this.placeName,
    required String placeNumber,
  })  : amount = Decimal.tryParse(amount),
        percentage = double.tryParse(percentage),
        placeNumber = int.tryParse(placeNumber) ?? -1;

  @override
  String toString() {
    return 'Prize(id: $id, amount: $amount, percentage: $percentage, '
        'placeName: $placeName, '
        'placeNumber: $placeNumber)';
  }
}
