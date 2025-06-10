import 'dart:math' as math;

import 'package:decimal/decimal.dart';

import 'email_logic.dart';
import 'global_config.dart';
import 'models/matchup.dart';
import 'models/matchup_entry.dart';
import 'models/person.dart';
import 'models/prize.dart';
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
    final startingRound = await _getCurrentRound(tournament);

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

    final endingRound = await _getCurrentRound(tournament);

    // Check if the tournament is now complete
    final isFinalRound = tournament.rounds.last.every((m) => m.winner != null);
    if (isFinalRound) {
      await completeTournament(tournament);
      return;
    }

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

  static Future<void> _alertMemberToNewRound(
    MatchupEntry? competitor,
    Person member,
  ) async {
    // TODO: Validate email
    final subject = competitor != null
        ? 'You have a new matchup with ${competitor.teamCompeting!.name}'
        : 'You have a bye this round';

    final htmlBody = StringBuffer();

    if (competitor != null) {
      htmlBody.write('''
        <h1>You have a new matchup</h1>
        <p><strong>Competitor:</strong> ${competitor.teamCompeting!.name}</p>
        <p>Have a great time!<br>~Tournament Tracker</p>
      ''');
    } else {
      htmlBody.write('''
        <p>Enjoy your round off</p>
        <p>~Tournament Tracker</p>
      ''');
    }

    await EmailLogic.sendEmail(
      body: htmlBody.toString().trim(),
      subject: subject,
      to: member.emailAddress,
    );
  }

  static void alertUsersToNewRound(Tournament tournament) async {
    final currentRound = await _getCurrentRound(tournament);
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
            await _alertMemberToNewRound(competitor, member);
          }
        }
      }
    }
  }

  static Decimal _calculatePrizePayout(Prize prize, Decimal totalIncome) {
    var payout = Decimal.zero;
    if (prize.amount != null) {
      if (prize.amount! > Decimal.zero) {
        payout = prize.amount!;
      } else {
        if (prize.percentage != null) {
          payout =
              totalIncome * Decimal.parse((prize.percentage! / 100).toString());
        }
      }
    }
    return payout;
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

  static Future<int> _getCurrentRound(
    Tournament tournament,
  ) async {
    var currRound = 1;
    for (var round in tournament.rounds) {
      if (round.every((matchup) => matchup.winner != null)) {
        currRound++;
      } else {
        return currRound;
      }
    }

    // await completeTournament(tournament);
    return currRound - 1;
  }

  static Future<void> completeTournament(
    Tournament tournament,
  ) async {
    GlobalConfig.connection.completeTournament(tournament);

    final finalMatchup = tournament.rounds.last.first;
    final winner = finalMatchup.winner;
    final runnerUp = finalMatchup.entries
        .where((entry) => entry.teamCompeting != winner)
        .first
        .teamCompeting;
    var winnerPrize = Decimal.zero;
    var runnerUpPrize = Decimal.zero;

    if (tournament.prizes.isNotEmpty) {
      final totalIncome =
          tournament.enteredTeams.length.toDecimal() * tournament.entryFee;
      final firstPlacePrize =
          tournament.prizes.where((prize) => prize.placeNumber == 1).first;
      final secondPlacePrize =
          tournament.prizes.where((prize) => prize.placeNumber == 2).first;
      winnerPrize = _calculatePrizePayout(firstPlacePrize, totalIncome);
      runnerUpPrize = _calculatePrizePayout(secondPlacePrize, totalIncome);
    }

    // Send email to all tournament
    final htmlBody = StringBuffer();
    final subject = 'In ${tournament.name}, ${winner!.name} has won!';

    htmlBody.write('''
        <h1>We have a winner!</h1>
        <p>Congratulations to our winner on a great tournament</p>
      ''');

    if (winnerPrize > Decimal.zero) {
      htmlBody.write('''
        <p>${winner.name} will receive $winnerPrize</p>
      ''');
    }
    if (runnerUpPrize > Decimal.zero) {
      htmlBody.write('''
        <p>${runnerUp!.name} will receive $runnerUpPrize</p>
      ''');
    }

    htmlBody.write('''
        <p>Thank you for participating</p>
        <p>~Tournament Tracker</p>
      ''');

    final bcc = <String>[];
    for (var enteredTeams in tournament.enteredTeams) {
      for (var member in enteredTeams.members) {
        bcc.add(member.emailAddress);
      }
    }
    print('BCC list: $bcc');

    await EmailLogic.sendEmail(
      subject: subject,
      body: htmlBody.toString().trim(),
      bcc: bcc,
    );

    // TODO: Complete tournament, go back to TournamentDashboard view
    tournament.onTournamentComplete?.call();
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
