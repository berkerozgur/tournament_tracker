import '../models/person.dart';
import '../models/prize.dart';

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

  /// Retrieves all people from the data source.
  ///
  /// Returns a [List] of [Person] objects representing all people.
  Future<List<Person>> getAllPeople();
}
