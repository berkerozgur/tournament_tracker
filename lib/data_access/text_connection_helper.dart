import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;

import '../models/prize.dart';

// Convert this class to a String extension
class TextConnectionHelper {
  TextConnectionHelper._();

  static Future<String> _getDirPath() async {
    final docsDir = await path_provider.getApplicationDocumentsDirectory();
    return path.join(docsDir.path, 'TournamentTrackerData');
  }

  static Future<Directory> createDirectory() async {
    final dirPath = await _getDirPath();
    return await Directory(dirPath).create(recursive: true);
  }

  static Future<String> getFilePath(String fileName) async {
    final dirPath = await _getDirPath();
    return '$dirPath/$fileName';
  }

  static Future<List<String>> readLines(String filePath) async {
    var file = File(filePath);
    if (!await file.exists()) {
      return List<String>.empty();
    }
    var lines = await file.readAsLines();
    return lines;
  }

  static List<Prize> convertToPrizes(List<String> lines) {
    final prizes = List<Prize>.empty(growable: true);
    for (var line in lines) {
      final cols = line.split(',');
      final prize = Prize(
        id: int.parse(cols[0]),
        amount: Decimal.tryParse(cols[3]) ?? Decimal.zero,
        percentage: double.tryParse(cols[4]) ?? 0,
        placeName: cols[2],
        placeNumber: int.parse(cols[1]),
      );
      prizes.add(prize);
    }
    return prizes;
  }

  static Future<void> writeToPrizesFile(
    List<Prize> prizes,
    String fileName,
  ) async {
    final lines = List<String>.empty(growable: true);
    for (var prize in prizes) {
      lines.add(
          '${prize.id},${prize.placeNumber},${prize.placeName},${prize.amount},'
          '${prize.percentage}');
    }

    var prizesFile = File(await getFilePath(fileName));
    // file will be overwritten
    var sink = prizesFile.openWrite();
    for (var line in lines) {
      sink.writeln(line);
    }
    await sink.flush();
    await sink.close();
  }
}
