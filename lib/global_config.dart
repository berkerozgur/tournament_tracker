import 'data_connection.dart';
import 'text_connection.dart';

class GlobalConfig {
  GlobalConfig._();

  static final List<DataConnection> _connections = [];
  static List<DataConnection> get connections => _connections;

  static void initConnections(bool database, bool textFile) {
    if (database) {
      // TODO: Create sqlite connection
    }

    if (textFile) {
      // TODO: Create text file connection
      _connections.add(TextConnection());
    }
  }
}
