// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;

import '../models/matchup.dart';
import '../models/matchup_entry.dart';
import '../models/person.dart';
import '../models/prize.dart';
import '../models/team.dart';
import '../models/tournament.dart';

import 'data_connection.dart';

class TextConnection extends DataConnection {
  // TODO: same constants in the GlobalConfig file, replace this
  static const _PEOPLE_FILE = 'People.csv';
  static const _PRIZES_FILE = 'Prizes.csv';
  static const _MATCHUPS_FILE = 'Matchups.csv';
  static const _MATCHUP_ENTRIES_FILE = 'MatchupEntries.csv';
  static const _TEAMS_FILE = 'Teams.csv';
  static const _TOURNAMENTS_FILE = 'Tournaments.csv';

  // UTILITY
  Future<void> createDirectory() async {
    await Directory(await _getDirPath()).create();
  }

  Future<String> _getDirPath() async {
    final docsDir = await path_provider.getApplicationDocumentsDirectory();
    return path.join(docsDir.path, 'TournamentTrackerData');
  }

  Future<String> _getFilePath(String fileName) async {
    final dirPath = await _getDirPath();
    return '$dirPath/$fileName';
  }

  Future<List<String>> _readLines(String filePath) async {
    var file = File(filePath);
    if (!await file.exists()) {
      return <String>[];
    }
    var lines = await file.readAsLines();
    return lines;
  }

  // CREATE
  @override
  Future<Person> createPerson(Person person) async {
    final people = await getAllPeople();

    var currentId = 1;
    if (people.isNotEmpty) {
      final sortedPeople = [...people]..sort((a, b) => b.id.compareTo(a.id));
      currentId = sortedPeople.first.id + 1;
    }
    person.id = currentId;
    people.add(person);
    await _writeToPeopleFile(people);

    return person;
  }

  @override
  Future<Prize> createPrize(Prize prize) async {
    // Load the text file and convert the text to List<Prize>
    final prizes = await getAllPrizes();
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
    await _writeToPrizesFile(prizes);

    return prize;
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
    teams.add(team);
    await _writeToTeamsFile(teams);

    return team;
  }

  @override
  Future<void> createTournament(Tournament tournament) async {
    final tournaments = await getAllTournaments();

    var currentId = 1;
    if (tournaments.isNotEmpty) {
      final sortedTeams = [...tournaments]
        ..sort((a, b) => b.id.compareTo(a.id));
      currentId = sortedTeams.first.id + 1;
    }
    tournament.id = currentId;
    await _writeRoundsToFiles(tournament);
    tournaments.add(tournament);
    await _writeToTournamentsFile(tournaments);
  }

  // GET
  @override
  Future<List<Person>> getAllPeople() async {
    final filePath = await _getFilePath(_PEOPLE_FILE);
    final lines = await _readLines(filePath);
    final people = _convertToPeople(lines);
    return people;
  }

  @override
  Future<List<Prize>> getAllPrizes() async {
    final filePath = await _getFilePath(_PRIZES_FILE);
    final lines = await _readLines(filePath);
    final prizes = _convertToPrizes(lines);
    return prizes;
  }

  @override
  Future<List<Team>> getAllTeams() async {
    final filePath = await _getFilePath(_TEAMS_FILE);
    final lines = await _readLines(filePath);
    final teams = await _convertToTeams(lines);
    return teams;
  }

  @override
  Future<List<Tournament>> getAllTournaments() async {
    final filePath = await _getFilePath(_TOURNAMENTS_FILE);
    final lines = await _readLines(filePath);
    final tournaments = _convertToTournaments(lines);
    return tournaments;
    // final filePath = await TextConnectionHelper.getFilePath(_TEAMS_FILE);
    // final lines = await TextConnectionHelper.readLines(filePath);
    // return TextConnectionHelper.convertToTournaments(
    //   lines,
    //   _PEOPLE_FILE,
    //   _PRIZES_FILE,
    //   _TEAMS_FILE,
    //   _MATCHUPS_FILE,
    // );
  }

  Future<List<Matchup>> _getAllMatchups() async {
    final filePath = await _getFilePath(_MATCHUPS_FILE);
    final lines = await _readLines(filePath);
    final matchups = await _convertToMatchups(lines);
    return matchups;
  }

  Future<List<MatchupEntry>> _getAllMatchupEntries() async {
    final filePath = await _getFilePath(_MATCHUP_ENTRIES_FILE);
    final lines = await _readLines(filePath);
    final matchupEntries = await _convertToMatchupEntries(lines);
    return matchupEntries;
  }

  Future<Matchup?> _getMatchupById(int? id) async {
    if (id == null) return null;
    final allMatchups = await _getAllMatchups();
    return allMatchups.where((matchup) => matchup.id == id).toList().first;
  }

  Future<List<MatchupEntry>> _getMatchupEntriesByIds(String ids) async {
    final idsSplitted = ids.split('|');
    final allEntries = await _getAllMatchupEntries();
    for (var id in idsSplitted) {
      allEntries.where((entry) => entry.id == int.parse(id)).toList();
    }
    return allEntries;
  }

  Future<Team> _getTeamById(int id) async {
    final allTeams = await getAllTeams();
    return allTeams.where((team) => team.id == id).toList().first;
  }

  // CONVERT
  Future<List<Matchup>> _convertToMatchups(List<String> lines) async {
    // id,entries (pipe delimited by id),winner id,round
    // 1,1|2|3,5,2
    final matchups = <Matchup>[];
    for (var line in lines) {
      final cols = line.split(',');
      final matchup = Matchup(
        id: int.parse(cols[0]),
        entries: await _getMatchupEntriesByIds(cols[1]),
        winner: await _getTeamById(int.parse(cols[2])),
        round: int.parse(cols[3]),
      );
      matchups.add(matchup);
    }
    return matchups;
  }

  Future<List<MatchupEntry>> _convertToMatchupEntries(
      List<String> lines) async {
    final entries = <MatchupEntry>[];
    for (var line in lines) {
      final cols = line.split(',');
      final entry = MatchupEntry(
        id: int.parse(cols[0]),
        competing: await _getTeamById(int.parse(cols[1])),
        score: double.parse(cols[2]),
        parent: await _getMatchupById(int.tryParse(cols[3])),
      );
      entries.add(entry);
    }
    return entries;
  }

  List<Person> _convertToPeople(List<String> lines) {
    final people = <Person>[];
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

  List<Prize> _convertToPrizes(List<String> lines) {
    final prizes = <Prize>[];
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

  Future<List<Team>> _convertToTeams(List<String> lines) async {
    final teams = <Team>[];
    final people = await getAllPeople();
    var teamMembers = <Person>[];
    for (var line in lines) {
      final cols = line.split(',');
      final memberIds = cols[2].split('|');
      for (var id in memberIds) {
        teamMembers =
            people.where((person) => person.id == int.parse(id)).toList();
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

  Future<List<Tournament>> _convertToTournaments(List<String> lines) async {
    // id,name,fee,team ids,prize ids,round ids
    // example: 1,Basketball,100,1|2|7,4|9,1^2^3|4^5^6|7^8^9
    final tournaments = <Tournament>[];
    final teams = await getAllTeams();
    final prizes = await getAllPrizes();
    final allMatchups = await _getAllMatchups();
    var enteredTeams = <Team>[];
    var tournamentPrizes = <Prize>[];

    for (var line in lines) {
      final cols = line.split(',');

      final teamIds = cols[3].split('|');
      for (var id in teamIds) {
        enteredTeams = teams.where((team) => team.id == int.parse(id)).toList();
      }

      final prizeIds = cols[4].split('|');
      for (var id in prizeIds) {
        tournamentPrizes =
            prizes.where((prize) => prize.id == int.parse(id)).toList();
      }

      // Capture rounds info
      final rounds = <List<Matchup>>[];
      final roundsStr = cols[5].split('|');
      for (var round in roundsStr) {
        final matchups = <Matchup>[];
        final matchupsStr = round.split('^');
        for (var matchupId in matchupsStr) {
          matchups.add(
            allMatchups
                .where((matchup) => matchup.id == int.parse(matchupId))
                .toList()
                .first,
          );
        }
        rounds.add(matchups);
      }
      final tournament = Tournament(
        id: int.parse(cols[0]),
        enteredTeams: enteredTeams,
        entryFee: Decimal.parse(cols[2]),
        name: cols[1],
        prizes: tournamentPrizes,
        rounds: rounds,
      );
      tournaments.add(tournament);
    }
    return tournaments;
  }

  // WRITE
  Future<void> _writeRoundsToFiles(Tournament tournament) async {
    // Loop through each round
    // Loop through each matchup
    // Get the id for the new matchup and save the record
    // Loop through each entry, get the id and save it
    for (var round in tournament.rounds) {
      for (var matchup in round) {
        // Load all of the matchups from the file
        // Get the top id and add one
        // Store the id
        // Save the matchup record
        await _writeToMatchupsFile(matchup);
      }
    }
  }

  Future<void> _writeToMatchupsFile(Matchup matchup) async {
    final lines = <String>[];
    final matchups = await _getAllMatchups();

    var currentId = 1;
    if (matchups.isNotEmpty) {
      final sortedMatchups = [...matchups]
        ..sort((a, b) => b.id.compareTo(a.id));
      currentId = sortedMatchups.first.id + 1;
    }
    matchup.id = currentId;
    matchups.add(matchup);

    var entryIds = '';
    for (var matchup in matchups) {
      for (var entry in matchup.entries) {
        entryIds += '${entry.id}|';
      }
      // Removes last pipe from the string
      entryIds = entryIds.substring(0, entryIds.length - 1);
      lines.add('${matchup.id},,${matchup.winner?.id},${matchup.round}');
    }

    var matchupsFile = File(await _getFilePath(_MATCHUPS_FILE));
    var sink = matchupsFile.openWrite();
    for (var line in lines) {
      sink.writeln(line);
    }
    await sink.flush();
    await sink.close();

    for (var entry in matchup.entries) {
      _writeToMatchupEntriesFile(entry);
    }

    // save to file
    entryIds = '';
    for (var matchup in matchups) {
      for (var entry in matchup.entries) {
        entryIds += '${entry.id}|';
      }
      // Removes last pipe from the string
      entryIds = entryIds.substring(0, entryIds.length - 1);
      lines.add(
          '${matchup.id},$entryIds,${matchup.winner?.id},${matchup.round}');
    }

    matchupsFile = File(await _getFilePath(_MATCHUPS_FILE));
    sink = matchupsFile.openWrite();
    for (var line in lines) {
      sink.writeln(line);
    }
    await sink.flush();
    await sink.close();
  }

  Future<void> _writeToMatchupEntriesFile(MatchupEntry entry) async {
    final allEntries = await _getAllMatchupEntries();

    var currentId = 1;
    if (allEntries.isNotEmpty) {
      final sortedEntries = [...allEntries]
        ..sort((a, b) => b.id.compareTo(a.id));
      currentId = sortedEntries.first.id + 1;
    }
    entry.id = currentId;
    allEntries.add(entry);

    final lines = <String>[];

    for (var entry in allEntries) {
      lines.add('${entry.id},${entry.competing},${entry.score}${entry.parent}');
    }

    var matchupEntriesFile = File(await _getFilePath(_MATCHUP_ENTRIES_FILE));
    var sink = matchupEntriesFile.openWrite();
    for (var line in lines) {
      sink.writeln(line);
    }
    await sink.flush();
    await sink.close();
  }

  Future<void> _writeToPeopleFile(List<Person> people) async {
    final lines = <String>[];

    for (var person in people) {
      lines.add('${person.id},${person.firstName},${person.lastName},'
          '${person.emailAddress},${person.phoneNumber}');
    }

    var peopleFile = File(await _getFilePath(_PEOPLE_FILE));
    var sink = peopleFile.openWrite();
    for (var line in lines) {
      sink.writeln(line);
    }
    await sink.flush();
    await sink.close();
  }

  Future<void> _writeToPrizesFile(List<Prize> prizes) async {
    final lines = <String>[];
    for (var prize in prizes) {
      lines.add(
          '${prize.id},${prize.placeNumber},${prize.placeName},${prize.amount},'
          '${prize.percentage}');
    }

    var prizesFile = File(await _getFilePath(_PRIZES_FILE));
    var sink = prizesFile.openWrite();
    for (var line in lines) {
      sink.writeln(line);
    }
    await sink.flush();
    await sink.close();
  }

  Future<void> _writeToTeamsFile(List<Team> teams) async {
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

    var teamsFile = File(await _getFilePath(_TEAMS_FILE));
    var sink = teamsFile.openWrite();
    for (var line in lines) {
      sink.writeln(line);
    }
    await sink.flush();
    await sink.close();
  }

  Future<void> _writeToTournamentsFile(List<Tournament> tournaments) async {
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

    var tournamentsFile = File(await _getFilePath(_TOURNAMENTS_FILE));
    var sink = tournamentsFile.openWrite();
    for (var line in lines) {
      sink.writeln(line);
    }
    await sink.flush();
    await sink.close();
  }
}
