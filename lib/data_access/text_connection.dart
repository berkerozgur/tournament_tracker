import '../models/prize.dart';
import 'data_connection.dart';
import 'text_connection_helper.dart';

class TextConnection extends DataConnection {
  // ignore: constant_identifier_names
  static const _PRIZES_FILE = 'Prizes.csv';

  @override
  Future<Prize> createPrize(Prize prize) async {
    // Load the text file and convert the text to List<Prize>
    final filePath = await TextConnectionHelper.getFilePath(_PRIZES_FILE);
    final lines = await TextConnectionHelper.readLines(filePath);
    final prizes = TextConnectionHelper.convertToPrizes(lines);
    // Find the max id
    var currentId = 1;
    if (prizes.isNotEmpty) {
      final sortedPrizes = [...prizes]..sort((a, b) => b.id.compareTo(a.id));
      currentId = sortedPrizes.first.id + 1;
    }
    prize.id = currentId;
    // Add the new record with the new id (max+1)
    prizes.add(prize);
    // Convert the prizes to List<String>
    // Save the strings to the text file
    await TextConnectionHelper.writeToPrizesFile(prizes, _PRIZES_FILE);

    return prize;
  }
}
