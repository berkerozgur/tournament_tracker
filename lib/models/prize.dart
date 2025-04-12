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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount?.toString(),
      'percentage': percentage,
      'placeName': placeName,
      'placeNumber': placeNumber,
    };
  }

  factory Prize.fromJson(Map<String, dynamic> json) {
    return Prize(
      id: json['id'] as int,
      amount: json['amount'] != null ? Decimal.tryParse(json['amount']) : null,
      percentage: (json['percentage'] as num?)?.toDouble(),
      placeName: json['placeName'] as String,
      placeNumber: json['placeNumber'] as int,
    );
  }
  @override
  String toString() =>
      'Prize(id: $id, amount: $amount, percentage: $percentage '
      'placeName: $placeName, placeNumber: $placeNumber)';
}
