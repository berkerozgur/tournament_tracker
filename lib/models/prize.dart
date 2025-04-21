import 'package:decimal/decimal.dart' show Decimal;

class Prize {
  int id;
  Decimal? amount;
  double? percentage;
  String placeName;
  int placeNumber;

  Prize({
    required this.id,
    this.amount,
    this.percentage,
    required this.placeName,
    required this.placeNumber,
  });

  Prize.fromStrings({
    required String id,
    required String amount,
    required String percentage,
    required this.placeName,
    required String placeNumber,
  })  : id = int.parse(id),
        amount = Decimal.tryParse(amount) ?? Decimal.zero,
        percentage = double.tryParse(percentage) ?? 0,
        placeNumber = int.parse(placeNumber);

  @override
  String toString() =>
      'Prize(id: $id, amount: $amount, percentage: $percentage '
      'placeName: $placeName, placeNumber: $placeNumber)';
}
