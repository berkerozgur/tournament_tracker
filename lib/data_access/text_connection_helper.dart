import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;

import '../models/matchup.dart';
import '../models/person.dart';
import '../models/prize.dart';
import '../models/team.dart';
import '../models/tournament.dart';

// TODO: Implement methods to retrieve all objects within this file, making them callable from within the TextConnection class.

// TODO: Convert this class to a String extension
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

  // TODO: converting can be generic
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

  static List<Person> convertToPeople(List<String> lines) {
    final people = List<Person>.empty(growable: true);
    for (var line in lines) {
      final cols = line.split(',');
      final person = Person(
        id: int.parse(cols[0]),
        emailAddress: cols[3],
        firstName: cols[1],
        lastName: cols[2],
        phoneNumber: cols[4],
      );
      people.add(person);
    }
    return people;
  }

  static Future<List<Team>> convertToTeams(
    List<String> lines,
    String peopleFileName,
  ) async {
    // team id,team name,person ids separated by pipe
    // example: 1,Berker's Team,1|5|9
    final teams = <Team>[];
    final filePath = await TextConnectionHelper.getFilePath(peopleFileName);
    final peopleLines = await TextConnectionHelper.readLines(filePath);
    final people = TextConnectionHelper.convertToPeople(peopleLines);
    var teamMembers = <Person>[];
    for (var line in lines) {
      final cols = line.split(',');
      final personIds = cols[2].split('|');
      for (var id in personIds) {
        teamMembers =
            people.where((member) => member.id == int.parse(id)).toList();
      }
      final team = Team(
        id: int.parse(cols[0]),
        members: teamMembers,
        name: cols[1],
      );
      teams.add(team);
    }
    return teams;
  }

  static Future<List<Tournament>> convertToTournaments(
    List<String> lines,
    String peopleFileName,
    String prizesFileName,
    String teamsFileName,
  ) async {
    // id,name,fee,team ids,prize ids,round ids
    // example: 1,Basketball,100,1|2|7,4|9,1^2^3|4^5^6|7^8^9
    final tournaments = <Tournament>[];
    // get all teams
    final teamsFilePath = await TextConnectionHelper.getFilePath(teamsFileName);
    final teamsLines = await TextConnectionHelper.readLines(teamsFilePath);
    final allTeams = await TextConnectionHelper.convertToTeams(
      teamsLines,
      peopleFileName,
    );
    // get all prizes
    final prizesFilePath =
        await TextConnectionHelper.getFilePath(prizesFileName);
    final prizesLines = await TextConnectionHelper.readLines(prizesFilePath);
    final allPrizes = TextConnectionHelper.convertToPrizes(prizesLines);
    // Initialize lists to hold entered teams and prizes for the tournament
    var enteredTeams = <Team>[];
    var prizes = <Prize>[];
    for (var line in lines) {
      final cols = line.split(',');
      final teamIds = cols[3].split('|');
      for (var id in teamIds) {
        enteredTeams =
            allTeams.where((team) => team.id == int.parse(id)).toList();
      }
      final prizeIds = cols[4].split('|');
      for (var id in prizeIds) {
        prizes =
            allPrizes.where((element) => element.id == int.parse(id)).toList();
      }

      // TODO: Capture rounds info
      final tournament = Tournament(
        id: int.parse(cols[0]),
        enteredTeams: enteredTeams,
        entryFee: Decimal.parse(cols[2]),
        name: cols[1],
        prizes: prizes,

        // An empty list is passed for testing purposes to simulate the
        // functionality of pretend rounds.
        rounds: <List<Matchup>>[],
      );
      tournaments.add(tournament);
    }
    return tournaments;
  }

  // TODO: writing to files can be generic
  // TODO: Add column names for CSV files to ensure proper data organization and retrieval.
  static Future<void> writeToTeamsFile(
    List<Team> teams,
    String fileName,
  ) async {
    // team id,team name,person ids separated by pipe
    // example: 1,Berker's Team,1|5|9
    final lines = <String>[];
    var memberIds = '';
    for (var team in teams) {
      for (var member in team.members) {
        memberIds += '${member.id}|';
      }
      // Removes last pipe from the string
      memberIds = memberIds.substring(0, memberIds.length - 1);
      lines.add('${team.id},${team.name},$memberIds');
    }

    var teamsFile = File(await getFilePath(fileName));
    // file will be overwritten
    var sink = teamsFile.openWrite();
    for (var line in lines) {
      sink.writeln(line);
    }
    await sink.flush();
    await sink.close();
  }

  static Future<void> writeToTournamentsFile(
    List<Tournament> tournaments,
    String fileName,
  ) async {
    // id,name,fee,team ids,prize ids,round ids
    // example: 1,Basketball,100,1|2|7,4|9,1^2^3|4^5^6|7^8^9
    final lines = <String>[];
    var teamIds = '';
    var prizeIds = '';
    // TODO: dont forget to populate this
    var roundIds = '';
    var matchupIds = '';
    for (var tournament in tournaments) {
      for (var team in tournament.enteredTeams) {
        teamIds += '${team.id}|';
      }
      for (var prize in tournament.prizes) {
        prizeIds += '${prize.id}';
      }
      for (var round in tournament.rounds) {
        for (var matchup in round) {
          matchupIds += '${matchup.id}^';
        }
        // Removes last carrot from the string
        matchupIds = matchupIds.substring(0, matchupIds.length - 1);
        roundIds += '$matchupIds|';
      }
      // Removes last pipe from the string
      teamIds = teamIds.substring(0, teamIds.length - 1);
      prizeIds = prizeIds.substring(0, prizeIds.length - 1);
      lines.add(
          '${tournament.id},${tournament.name},${tournament.entryFee},$teamIds,'
          '$prizeIds,$roundIds');
    }

    var tournamentsFile = File(await getFilePath(fileName));
    // file will be overwritten
    var sink = tournamentsFile.openWrite();
    for (var line in lines) {
      sink.writeln(line);
    }
    await sink.flush();
    await sink.close();
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

  static Future<void> writeToPeopleFile(
    List<Person> people,
    String fileName,
  ) async {
    final lines = List<String>.empty(growable: true);
    for (var person in people) {
      lines.add('${person.id},${person.firstName},${person.lastName},'
          '${person.emailAddress},${person.phoneNumber}');
    }

    var peopleFile = File(await getFilePath(fileName));
    // file will be overwritten
    var sink = peopleFile.openWrite();
    for (var line in lines) {
      sink.writeln(line);
    }
    await sink.flush();
    await sink.close();
  }
}
