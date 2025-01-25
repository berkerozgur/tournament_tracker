import 'package:tournament_tracker/models/prize.dart';

import 'data_connection.dart';

class TextConnection extends DataConnection {
  // TODO: make this method actually work
  @override
  Prize createPrize(Prize prize) {
    // for testing purposes
    prize.id = 1;
    return prize;
  }
}
