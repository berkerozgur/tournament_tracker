// ignore_for_file: constant_identifier_names

import 'data_access/data_connection.dart';
import 'data_access/text_connection.dart';

enum DbType { sqlite, textFile }

class GlobalConfig {
  GlobalConfig._();

  // TODO: use late init to not use nullables
  static DataConnection? _connection;
  static DataConnection? get connection => _connection;

  static void initConnection(DbType dbType) {
    switch (dbType) {
      case DbType.sqlite:
        // TODO: sqlite will be implemented at some point
        throw UnimplementedError();
      case DbType.textFile:
        _connection = TextConnection();
    }
  }
}
