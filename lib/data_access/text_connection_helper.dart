import '../global_config.dart';
import '../models/matchup.dart';
import '../models/matchup_entry.dart';
import '../models/person.dart';
import '../models/prize.dart';
import '../models/team.dart';
import '../models/tournament.dart';

class TextConnectionHelper {
  TextConnectionHelper._();

  static Future<Directory> createDirectory() async {
    final dirPath = await _getDirPath();
    return await Directory(dirPath).create(recursive: true);
  }

  static Future<List<Person>> getAllPeople() async {
    final lines = await readLines(GlobalConfig.PEOPLE_FILE);
    return convertToPeople(lines);
  }

  static Future<List<Prize>> getAllPrizes() async {
    final lines = await readLines(GlobalConfig.PRIZES_FILE);
    return convertToPrizes(lines);
  }

  static Future<List<Team>> getAllTeams() async {
    final lines = await readLines(GlobalConfig.TEAMS_FILE);
    return convertToTeams(lines);
  }

  // TODO: Add column names for CSV files to ensure proper data organization and retrieval.
  // write to file methods

  static Future<void> writeRoundsToFiles(
    Tournament tournament,
    String matchupsFileName,
    String matchupEntriesFileName,
  ) async {
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
        await writeToMatchupsFile(
          matchup,
          matchupsFileName,
          matchupEntriesFileName,
        );
      }
    }
  }

  static Future<void> writeToMatchupsFile(
    Matchup matchup,
    String matchupsFileName,
    String matchupEntriesFileName,
  ) async {
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

    var matchupsFile = File(await getFilePath(matchupsFileName));
    var sink = matchupsFile.openWrite();
    for (var line in lines) {
      sink.writeln(line);
    }
    await sink.flush();
    await sink.close();
    for (var entry in matchup.entries) {
      writeToMatchupEntriesFile(entry, matchupEntriesFileName);
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

    matchupsFile = File(await getFilePath(matchupsFileName));
    sink = matchupsFile.openWrite();
    for (var line in lines) {
      sink.writeln(line);
    }
    await sink.flush();
    await sink.close();
  }

  static Future<void> writeToMatchupEntriesFile(
    MatchupEntry entry,
    String fileName,
  ) async {
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

    var matchupEntriesFile = File(await getFilePath(fileName));
    var sink = matchupEntriesFile.openWrite();
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
}
