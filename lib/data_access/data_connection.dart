import '../models/person.dart';
import '../models/prize.dart';
import '../models/team.dart';
import '../models/tournament.dart';

/// Abstract class representing a connection to a data source for managing prize data.
///
/// This class defines the contract for creating and managing prize records in a
/// data storage system. Implementations of this class should handle the specific
/// details of how prizes are stored and retrieved.
abstract class DataConnection {
  /// Creates a new prize in the data source.
  ///
  /// Takes a [Prize] object as a parameter and returns a [Future] that
  /// completes with the created [Prize] object.
  Future<Prize> createPrize(Prize prize);

  /// Creates a new person in the data source.
  ///
  /// Takes a [Person] object as a parameter and returns a [Future] that
  /// completes with the created [Person] object.
  Future<Person> createPerson(Person person);

  /// Creates a new team in the data source.
  ///
  /// Takes a [Team] object as a parameter and returns a [Future] that
  /// completes with the created [Team] object.
  Future<Team> createTeam(Team team);

  /// Creates a new tournament in the data store.
  ///
  /// Takes a [Tournament] object as a parameter and saves it to the data store.
  ///
  /// [tournament] - The tournament object to be created.
  Future<void> createTournament(Tournament tournament);

  /// Retrieves all people from the data source.
  ///
  /// Returns a [List] of [Person] objects representing all people.
  Future<List<Person>> getAllPeople();

  /// Retrieves all prizes from the data source.
  ///
  /// Returns a [Future] that completes with a list of [Prize] objects.
  Future<List<Prize>> getAllPrizes();

  /// Retrieves a list of all teams.
  ///
  /// This method fetches all the teams from the data source and returns them
  /// as a list of [Team] objects.
  ///
  /// Returns:
  ///   A [Future] that completes with a list of [Team] objects.
  Future<List<Team>> getAllTeams();

  /// Retrieves a list of all tournaments.
  ///
  /// Returns a [Future] that completes with a list of [Tournament] objects.
  Future<List<Tournament>> getAllTournaments();
}
