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
  static const _MATCHUPS_FILE = 'Matchups.csv';
  static const _MATCHUP_ENTRIES_FILE = 'MatchupEntries.csv';
  static const _PEOPLE_FILE = 'People.csv';
  static const _PRIZES_FILE = 'Prizes.csv';
  static const _TEAMS_FILE = 'Teams.csv';
  static const _TOURNAMENTS_FILE = 'Tournaments.csv';
  static const _MATCHUPS_COL_NAMES = 'id, entry ids, winner id, round';
  static const _MATCHUP_ENTRIES_COL_NAMES =
      'id, team competing id, score, parent matchup id';
  static const _PEOPLE_COL_NAMES =
      'id, first name, last name, email address, phone number';
  static const _PRIZES_COL_NAMES =
      'id, place number, place name, amount, percentage';
  static const _TEAMS_COL_NAMES = 'id, team name, member ids';
  static const _TOURNAMENTS_COL_NAMES =
      'id, tournament name, entry fee, team ids, prize ids, matchup ids';

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
    return lines.skip(1).toList();
  }

  Future<void> _writeLines(String fileName, List<String> lines) async {
    final sink = File(await _getFilePath(fileName)).openWrite();
    for (var line in lines) {
      sink.writeln(line);
    }
    await sink.flush();
    await sink.close();
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
    if (id != null) {
      final filePath = await _getFilePath(_MATCHUPS_FILE);
      final matchups = await _readLines(filePath);
      for (var matchup in matchups) {
        final cols = matchup.split(',');
        if (cols[0] == id.toString()) {
          final matchingMatchups = <String>[];
          matchingMatchups.add(matchup);
          return (await _convertToMatchups(matchingMatchups)).first;
        }
      }
    }
    return null;
  }

  Future<List<MatchupEntry>> _getMatchupEntriesByIds(String ids) async {
    final filePath = await _getFilePath(_MATCHUP_ENTRIES_FILE);
    final entries = await _readLines(filePath);
    final idsSplit = ids.split('|');
    final matchingEntries = <String>[];
    for (var id in idsSplit) {
      for (var entry in entries) {
        final cols = entry.split(',');
        if (cols[0] == id) {
          matchingEntries.add(entry);
        }
      }
    }
    return await _convertToMatchupEntries(matchingEntries);
  }

  Future<Team?> _getTeamById(int? id) async {
    if (id != null) {
      final filePath = await _getFilePath(_TEAMS_FILE);
      final teams = await _readLines(filePath);
      for (var team in teams) {
        final cols = team.split(',');
        if (cols[0] == id.toString()) {
          final matchingTeams = <String>[];
          matchingTeams.add(team);
          return (await _convertToTeams(matchingTeams)).first;
        }
      }
    }
    return null;
  }

  // UPDATE
  @override
  Future<void> updateMatchup(Matchup matchup) async {
    final matchups = await _getAllMatchups();
    Matchup? oldMatchup;

    for (var m in matchups) {
      if (m.id == matchup.id) {
        oldMatchup = m;
      }
    }

    matchups.remove(oldMatchup);
    matchups.add(matchup);

    for (var entry in matchup.entries) {
      await _updateMatchupEntry(entry);
    }

    // write to file
    // id, entry ids, winner id, round
    final lines = <String>[];
    lines.add(_MATCHUPS_COL_NAMES);
    for (var matchup in matchups) {
      final entryIds = _convertIdsToString(
        matchup.entries,
        (matchup) => matchup.id,
      );
      var winnerId = 'null';
      if (matchup.winner != null) {
        winnerId = matchup.winner!.id.toString();
      }
      lines.add('${matchup.id},$entryIds,$winnerId,${matchup.round}');
    }

    await _writeLines(_MATCHUPS_FILE, lines);
  }

  Future<void> _updateMatchupEntry(MatchupEntry entry) async {
    final entries = await _getAllMatchupEntries();
    MatchupEntry? oldEntry;

    for (var e in entries) {
      if (e.id == entry.id) {
        oldEntry = e;
      }
    }

    entries.remove(oldEntry);
    entries.add(entry);

    // id, team competing id, score, parent matchup id
    final lines = <String>[];
    lines.add(_MATCHUP_ENTRIES_COL_NAMES);
    for (var entry in entries) {
      var parentId = 'null';
      if (entry.parent != null) {
        parentId = entry.parent!.id.toString();
      }
      var competingId = 'null';
      if (entry.teamCompeting != null) {
        competingId = entry.teamCompeting!.id.toString();
      }
      lines.add('${entry.id},$competingId,${entry.score},$parentId');
    }
    await _writeLines(_MATCHUP_ENTRIES_FILE, lines);
  }

  // CONVERT
  String _convertIdsToString<T>(
    List<T> items, [
    int Function(T item)? idSelector,
  ]) {
    if (items.isEmpty) return '';

    var ids = '';
    for (var item in items) {
      if (item is List<Matchup>) {
        var matchupIds = '';
        for (var matchup in item) {
          matchupIds += '${matchup.id}^';
        }
        // Remove last caret if needed
        if (matchupIds.isNotEmpty) {
          matchupIds = matchupIds.substring(0, matchupIds.length - 1);
        }
        ids += '$matchupIds|';
      } else {
        if (idSelector != null) ids += '${idSelector(item)}|';
      }
    }

    // Remove last pipe if needed
    return ids.isNotEmpty ? ids.substring(0, ids.length - 1) : '';
  }

  Future<List<Matchup>> _convertToMatchups(List<String> lines) async {
    // id, entry ids, winner id, round
    final matchups = <Matchup>[];
    for (var line in lines) {
      final cols = line.split(',');
      final matchup = Matchup(
        id: int.parse(cols[0]),
        entries: await _getMatchupEntriesByIds(cols[1]),
        round: int.parse(cols[3]),
        winner: await _getTeamById(int.tryParse(cols[2])),
      );
      matchups.add(matchup);
    }
    return matchups;
  }

  Future<List<MatchupEntry>> _convertToMatchupEntries(
    List<String> lines,
  ) async {
    // id, team competing id, score, parent matchup id
    final entries = <MatchupEntry>[];
    for (var line in lines) {
      final cols = line.split(',');
      final entry = MatchupEntry(
        id: int.parse(cols[0]),
        teamCompeting: await _getTeamById(int.tryParse(cols[1])),
        parent: await _getMatchupById(int.tryParse(cols[3])),
        score: double.tryParse(cols[2]),
      );
      entries.add(entry);
    }
    return entries;
  }

  List<Person> _convertToPeople(List<String> lines) {
    // id, first name, last name, email address, phone number
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
    // id, place number, place name, amount, percentage
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
    // id, team name, member ids
    final teams = <Team>[];
    final people = await getAllPeople();
    for (var line in lines) {
      var teamMembers = <Person>[];
      final cols = line.split(',');
      final memberIds = cols[2].split('|');
      for (var id in memberIds) {
        teamMembers.add(
          people.firstWhere((person) => person.id == int.parse(id)),
        );
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
    // id, tournament name, entry fee, team ids, prize ids, matchup ids
    final tournaments = <Tournament>[];
    final teams = await getAllTeams();
    final prizes = await getAllPrizes();
    final matchups = await _getAllMatchups();

    for (var line in lines) {
      final cols = line.split(',');

      var enteredTeams = <Team>[];
      final teamIds = cols[3].split('|');
      for (var id in teamIds) {
        enteredTeams.add(teams.firstWhere((team) => team.id == int.parse(id)));
      }

      var tournamentPrizes = <Prize>[];
      if (cols[4].isNotEmpty) {
        final prizeIds = cols[4].split('|');
        for (var id in prizeIds) {
          tournamentPrizes.add(
            prizes.firstWhere((prize) => prize.id == int.parse(id)),
          );
        }
      }

      // Capture rounds info
      final roundIds = cols[5].split('|');
      final rounds = <List<Matchup>>[];
      for (var roundId in roundIds) {
        final tournamentMatchups = <Matchup>[];
        final matchupIds = roundId.split('^');
        for (var matchupId in matchupIds) {
          tournamentMatchups.add(
            matchups.firstWhere(
              (matchup) => matchup.id == int.parse(matchupId),
            ),
          );
        }
        rounds.add(tournamentMatchups);
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
    final matchups = await _getAllMatchups();

    var currentId = 1;
    if (matchups.isNotEmpty) {
      final sortedMatchups = [...matchups]
        ..sort((a, b) => b.id.compareTo(a.id));
      currentId = sortedMatchups.first.id + 1;
    }
    matchup.id = currentId;
    matchups.add(matchup);

    // populate matchup entries
    for (var entry in matchup.entries) {
      await _writeToMatchupEntriesFile(entry);
    }

    // write to file
    // id, entry ids, winner id, round
    final lines = <String>[];
    lines.add(_MATCHUPS_COL_NAMES);
    for (var matchup in matchups) {
      final entryIds = _convertIdsToString(
        matchup.entries,
        (matchup) => matchup.id,
      );
      var winnerId = 'null';
      if (matchup.winner != null) {
        winnerId = matchup.winner!.id.toString();
      }
      lines.add('${matchup.id},$entryIds,$winnerId,${matchup.round}');
    }

    await _writeLines(_MATCHUPS_FILE, lines);
  }

  Future<void> _writeToMatchupEntriesFile(MatchupEntry entry) async {
    final entries = await _getAllMatchupEntries();

    var currentId = 1;
    if (entries.isNotEmpty) {
      final sortedEntries = [...entries]..sort((a, b) => b.id.compareTo(a.id));
      currentId = sortedEntries.first.id + 1;
    }
    entry.id = currentId;
    entries.add(entry);

    // id, team competing id, score, parent matchup id
    final lines = <String>[];
    lines.add(_MATCHUP_ENTRIES_COL_NAMES);
    for (var entry in entries) {
      var parentId = 'null';
      if (entry.parent != null) {
        parentId = entry.parent!.id.toString();
      }
      var competingId = 'null';
      if (entry.teamCompeting != null) {
        competingId = entry.teamCompeting!.id.toString();
      }
      lines.add('${entry.id},$competingId,${entry.score},$parentId');
    }
    await _writeLines(_MATCHUP_ENTRIES_FILE, lines);
  }

  Future<void> _writeToPeopleFile(List<Person> people) async {
    // id, first name, last name, email address, phone number
    final lines = <String>[];
    lines.add(_PEOPLE_COL_NAMES);

    for (var person in people) {
      lines.add('${person.id},${person.firstName},${person.lastName},'
          '${person.emailAddress},${person.phoneNumber}');
    }

    await _writeLines(_PEOPLE_FILE, lines);
  }

  Future<void> _writeToPrizesFile(List<Prize> prizes) async {
    // id, place number, place name, amount, percentage
    final lines = <String>[];
    lines.add(_PRIZES_COL_NAMES);

    for (var prize in prizes) {
      lines.add(
          '${prize.id},${prize.placeNumber},${prize.placeName},${prize.amount},'
          '${prize.percentage}');
    }

    await _writeLines(_PRIZES_FILE, lines);
  }

  Future<void> _writeToTeamsFile(List<Team> teams) async {
    // id, team name, member ids
    final lines = <String>[];
    lines.add(_TEAMS_COL_NAMES);

    for (var team in teams) {
      final memberIds =
          _convertIdsToString(team.members, (person) => person.id);
      lines.add('${team.id},${team.name},$memberIds');
    }

    await _writeLines(_TEAMS_FILE, lines);
  }

  Future<void> _writeToTournamentsFile(List<Tournament> tournaments) async {
    // id, tournament name, entry fee, team ids, prize ids, matchup ids
    final lines = <String>[];
    lines.add(_TOURNAMENTS_COL_NAMES);

    for (var tournament in tournaments) {
      final teamIds = _convertIdsToString(
        tournament.enteredTeams,
        (team) => team.id,
      );
      final prizeIds = _convertIdsToString(
        tournament.prizes,
        (prize) => prize.id,
      );
      final matchupIds = _convertIdsToString(tournament.rounds);
      lines.add(
          '${tournament.id},${tournament.name},${tournament.entryFee},$teamIds,'
          '$prizeIds,$matchupIds');
    }
    await _writeLines(_TOURNAMENTS_FILE, lines);
  }
}
