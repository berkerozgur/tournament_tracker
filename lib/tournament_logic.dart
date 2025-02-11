import 'models/matchup.dart';
import 'models/matchup_entry.dart';
import 'models/team.dart';
import 'models/tournament.dart';

class TournamentLogic {
  // Order list randomly of teams
  // Check if the list is big enough, if not add in byes - 2^n
  // Create first round of matchups
  // Create every round after that
  //   if 8 matchups -> 4 -> 2 -> 1
  static List<Team> _randomizeTeams(List<Team> teams) => teams..shuffle();

  static int _findNumberOfByes(int rounds, int numberOfTeams) {
    var totalTeams = 1;

    for (var i = 1; i <= rounds; i++) {
      totalTeams *= 2;
    }

    return totalTeams - numberOfTeams;
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

  static List<Matchup> _createFirstRound(int byes, List<Team> teams) {
    final matchups = <Matchup>[];
    var currMatchup = Matchup.empty();

    for (var team in teams) {
      currMatchup.entries.add(
        MatchupEntry(competing: team),
      );
      if (byes > 0 || currMatchup.entries.length > 1) {
        currMatchup.round = 1;
        matchups.add(currMatchup);
        currMatchup = Matchup.empty();
        if (byes > 1) byes -= 1;
      }
    }

    return matchups;
  }

  static void _createOtherRounds(Tournament tournament, int rounds) {
    var round = 2;
    var prevRound = tournament.rounds.first;
    var currRound = <Matchup>[];
    var currMatchup = Matchup.empty();

    while (round <= rounds) {
      for (var matchup in prevRound) {
        currMatchup.entries.add(MatchupEntry(parent: matchup));
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

  static void createRounds(Tournament tournament) {
    final randomizedTeams = _randomizeTeams(tournament.enteredTeams);
    final rounds = _findNumberOfRounds(randomizedTeams.length);
    final byes = _findNumberOfByes(rounds, randomizedTeams.length);
    final firstRound = _createFirstRound(byes, randomizedTeams);
    tournament.rounds.add(firstRound);
    _createOtherRounds(tournament, rounds);
  }
}
