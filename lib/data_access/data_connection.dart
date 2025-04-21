import '../models/matchup.dart';
import '../models/person.dart';
import '../models/prize.dart';
import '../models/team.dart';
import '../models/tournament.dart';

abstract class DataConnection {
  Future<Person> createPerson(Person person);

  Future<Prize> createPrize(Prize prize);

  Future<Team> createTeam(Team team);

  Future<Tournament> createTournament(Tournament tournament);

  Future<List<Person>> getAllPeople();

  Future<List<Prize>> getAllPrizes();

  Future<List<Team>> getAllTeams();

  Future<List<Tournament>> getAllTournaments();

  Future<void> updateMatchup(Matchup matchup);
}
