// ignore_for_file: constant_identifier_names

import '../models/person.dart';
import '../models/prize.dart';
import 'data_connection.dart';
import 'text_connection_helper.dart';

// TODO: Document this class
class TextConnection extends DataConnection {
  static const _PRIZES_FILE = 'Prizes.csv';
  static const _PEOPLE_FILE = 'People.csv';
  // TODO: these methods also can be generic?
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

  @override
  Future<Person> createPerson(Person person) async {
    final filePath = await TextConnectionHelper.getFilePath(_PEOPLE_FILE);
    final lines = await TextConnectionHelper.readLines(filePath);
    final people = TextConnectionHelper.convertToPeople(lines);

    var currentId = 1;
    if (people.isNotEmpty) {
      final sortedPrizes = [...people]..sort((a, b) => b.id.compareTo(a.id));
      currentId = sortedPrizes.first.id + 1;
    }
    person.id = currentId;
    // Add the new record with the new id (max+1)
    people.add(person);
    // Convert the prizes to List<String>
    // Save the strings to the text file
    await TextConnectionHelper.writeToPeopleFile(people, _PEOPLE_FILE);

    return person;
  }

  @override
  Future<List<Person>> getAllPeople() async {
    final filePath = await TextConnectionHelper.getFilePath(_PEOPLE_FILE);
    final lines = await TextConnectionHelper.readLines(filePath);
    return TextConnectionHelper.convertToPeople(lines);
  }
}
