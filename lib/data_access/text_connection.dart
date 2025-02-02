// ignore_for_file: constant_identifier_names

import '../models/person.dart';
import '../models/prize.dart';
import '../models/team.dart';
import 'data_connection.dart';
import 'text_connection_helper.dart';

// TODO: Document this class
// TODO: This class requires refactoring to eliminate repetitive code and improve maintainability.
class TextConnection extends DataConnection {
  static const _PRIZES_FILE = 'Prizes.csv';
  static const _PEOPLE_FILE = 'People.csv';
  static const _TEAMS_FILE = 'Teams.csv';

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
    final people = await getAllPeople();

    var currentId = 1;
    if (people.isNotEmpty) {
      final sortedPeople = [...people]..sort((a, b) => b.id.compareTo(a.id));
      currentId = sortedPeople.first.id + 1;
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
  Future<Team> createTeam(Team team) async {
    final teams = await getAllTeams();

    var currentId = 1;
    if (teams.isNotEmpty) {
      final sortedTeams = [...teams]..sort((a, b) => b.id.compareTo(a.id));
      currentId = sortedTeams.first.id + 1;
    }
    team.id = currentId;
    // Add the new record with the new id (max+1)
    teams.add(team);
    // Convert the prizes to List<String>
    // Save the strings to the text file
    await TextConnectionHelper.writeToTeamsFile(teams, _TEAMS_FILE);

    return team;
  }

  @override
  Future<List<Person>> getAllPeople() async {
    final filePath = await TextConnectionHelper.getFilePath(_PEOPLE_FILE);
    final lines = await TextConnectionHelper.readLines(filePath);
    return TextConnectionHelper.convertToPeople(lines);
  }

  @override
  Future<List<Team>> getAllTeams() async {
    final filePath = await TextConnectionHelper.getFilePath(_TEAMS_FILE);
    final lines = await TextConnectionHelper.readLines(filePath);
    return TextConnectionHelper.convertToTeams(lines, _PEOPLE_FILE);
  }
}
