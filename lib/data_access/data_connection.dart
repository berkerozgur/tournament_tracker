import '../models/person.dart';
import '../models/prize.dart';

/// Abstract class representing a connection to a data source for managing prize data.
///
/// This class defines the contract for creating and managing prize records in a
/// data storage system. Implementations of this class should handle the specific
/// details of how prizes are stored and retrieved.
abstract class DataConnection {
  /// Creates a new prize record in the data storage.
  ///
  /// Takes a [Prize] object and persists it to the underlying storage system.
  /// Returns the created [Prize], which may include additional data or modifications
  /// made during the storage process.
  Future<Prize> createPrize(Prize prize);
  Future<Person> createPerson(Person person);
}
