import 'data_access/data_connection.dart';
import 'data_access/text_connection.dart';

enum DbType { sqlite, textFile }

class GlobalConfig {
  GlobalConfig._();

  static late DataConnection _connection;
  static DataConnection get connection => _connection;

  static void initConnection(DbType dbType) {
    switch (dbType) {
      case DbType.sqlite:
        throw UnimplementedError();
      case DbType.textFile:
        _connection = TextConnection();
    }
  }
}
