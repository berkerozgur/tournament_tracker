import 'dart:math' as math;

import 'email_logic.dart';
import 'global_config.dart';
import 'models/matchup.dart';
import 'models/matchup_entry.dart';
import 'models/person.dart';
import 'models/team.dart';
import 'models/tournament.dart';

class TournamentLogic {
  TournamentLogic._();
  static final _instance = TournamentLogic._();
  factory TournamentLogic() => _instance;

  // Order list randomly of teams
  // Check if the list is big enough, if not add in byes - 2^n
  // Create first round of matchups
  // Create every round after that
  //   if 8 matchups -> 4 -> 2 -> 1

  static void createRounds(Tournament tournament) {
    final randomizedTeams = _randomizeTeams(tournament.enteredTeams);
    final rounds = _findNumberOfRounds(randomizedTeams.length);
    final byes = _findNumberOfByes(rounds, randomizedTeams.length);
    final firstRound = _createFirstRound(byes, randomizedTeams);
    tournament.rounds.add(firstRound);
    _createOtherRounds(tournament, rounds);
  }

  static Future<void> updateTournamentResults(Tournament tournament) async {
    List<Matchup> matchupsToScore = [];
    final startingRound = _getCurrentRound(tournament);

    for (var round in tournament.rounds) {
      for (var matchup in round) {
        // TODO: with this we can't score more than one
        bool hasNoWinner = matchup.winner == null;
        bool hasScoredEntry = matchup.entries.any((entry) => entry.score != 0);
        bool isSingleEntryMatchup = matchup.entries.length == 1;
        bool bothHaveZeroScore = matchup.entries.every(
          (entry) => entry.score == 0,
        );
        if (bothHaveZeroScore) {
          throw Exception('Single-elimination does not handle ties');
        }
        if (hasNoWinner && (hasScoredEntry || isSingleEntryMatchup)) {
          matchupsToScore.add(matchup);
        }
      }
    }

    _markWinnersInMatchups(matchupsToScore);
    await _advanceWinners(matchupsToScore, tournament);
    for (var matchup in matchupsToScore) {
      await GlobalConfig.connection.updateMatchup(matchup);
    }

    final endingRound = _getCurrentRound(tournament);
    if (endingRound > startingRound) {
      alertUsersToNewRound(tournament);
    }
  }

  static Future<void> _advanceWinners(
    List<Matchup> matchups,
    Tournament tournament,
  ) async {
    // TODO: Variable names in these n^4 loops can be better
    for (var m in matchups) {
      for (var round in tournament.rounds) {
        for (var matchup in round) {
          for (var entry in matchup.entries) {
            if (entry.parent != null) {
              if (entry.parent!.id == m.id) {
                entry.teamCompeting = m.winner;
                await GlobalConfig.connection.updateMatchup(matchup);
              }
            }
          }
        }
      }
    }
  }

  static void _alertMemberToNewRound(
    MatchupEntry? competitor,
    Person member,
    String teamName,
  ) {
    // TODO: Validate email
    final body = StringBuffer();
    var subject = '';

    if (competitor != null) {
      subject = 'You have a new matchup with ${competitor.teamCompeting!.name}';
      body.writeln('<h1>You have a new matchup</h1>');
      body.write('<strong>Competitor: </strong>');
      body.write(competitor.teamCompeting!.name);
      body.writeln();
      body.writeln();
      body.writeln('Have a great time!');
      body.writeln('~Tournament Tracker');
    } else {
      subject = 'You have a bye this round';
      body.writeln('Enjoy your round off');
      body.writeln('~Tournament Tracker');
    }

    EmailLogic.sendEmail(body.toString(), member.emailAddress, subject);
  }

  static void alertUsersToNewRound(Tournament tournament) {
    final currentRound = _getCurrentRound(tournament);
    final round = tournament.rounds
        .where((matchup) => matchup.first.round == currentRound)
        .first;

    for (var matchup in round) {
      for (var entry in matchup.entries) {
        if (entry.teamCompeting != null) {
          final competitor = matchup.entries
              .where((matchupEntry) =>
                  matchupEntry.teamCompeting != entry.teamCompeting)
              .firstOrNull;
          for (var member in entry.teamCompeting!.members) {
            _alertMemberToNewRound(
              competitor,
              member,
              entry.teamCompeting!.name,
            );
          }
        }
      }
    }
  }

  static List<Matchup> _createFirstRound(int byes, List<Team> teams) {
    final firstRound = <Matchup>[];
    var currMatchup = Matchup.empty();

    for (var team in teams) {
      currMatchup.entries.add(MatchupEntry(id: -1, teamCompeting: team));
      if (byes > 0 || currMatchup.entries.length > 1) {
        currMatchup.round = 1;
        firstRound.add(currMatchup);
        currMatchup = Matchup.empty();
        if (byes > 0) byes -= 1;
      }
    }

    return firstRound;
  }

  static void _createOtherRounds(Tournament tournament, int numberOfRounds) {
    var round = 2;
    var prevRound = tournament.rounds.first;
    var currRound = <Matchup>[];
    var currMatchup = Matchup.empty();

    while (round <= numberOfRounds) {
      for (var matchup in prevRound) {
        currMatchup.entries.add(MatchupEntry(id: -1, parent: matchup));
        if (currMatchup.entries.length > 1) {
          currMatchup.round = round;
          currRound.add(currMatchup);
          currMatchup = Matchup.empty();
        }
      }
      tournament.rounds.add(currRound);
      prevRound = currRound;
      currRound = [];
      round++;
    }
  }

  static int _findNumberOfByes(int rounds, int numberOfTeams) {
    final totalTeams = math.pow(2, rounds).toInt();
    // var totalTeams = 1;

    // for (var i = 1; i <= rounds; i++) {
    //   totalTeams *= 2;
    // }
    final byes = totalTeams - numberOfTeams;
    return byes;
  }

  static int _findNumberOfRounds(int numberOfTeams) {
    var rounds = 1;
    var teamsPerRound = 2;

    while (teamsPerRound < numberOfTeams) {
      rounds++;
      teamsPerRound *= 2;
    }

    return rounds;
  }

  static int _getCurrentRound(Tournament tournament) {
    var currRound = 1;
    for (var round in tournament.rounds) {
      if (round.every((matchup) => matchup.winner != null)) {
        currRound++;
      }
    }
    return currRound;
  }

  static void _markWinnersInMatchups(List<Matchup> matchups) {
    // TODO: Handle low score or high score wins.
    // In order to do that I need to change a lot in model and UI, I will skip
    // this for unknown future date.

    // High score wins
    for (var matchup in matchups) {
      final entryOne = matchup.entries[0];
      // Checks for the bye entry
      if (matchup.entries.length == 1) {
        matchup.winner = entryOne.teamCompeting;
        continue;
      }
      final entryTwo = matchup.entries[1];
      if (entryOne.score != null && entryTwo.score != null) {
        if (entryOne.score! > entryTwo.score!) {
          matchup.winner = entryOne.teamCompeting;
        } else if (entryTwo.score! > entryOne.score!) {
          matchup.winner = entryTwo.teamCompeting;
        } else {
          throw Exception('Single-elimination does not handle ties');
        }
      }
    }
  }

  static List<Team> _randomizeTeams(List<Team> teams) => teams..shuffle();
}
