import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:window_manager/window_manager.dart';

import 'app_routes.dart';
import 'data_access/text_connection.dart';
import 'global_config.dart';
import 'models/tournament.dart';
import 'views/create_tournament.dart';
import 'views/tournament_dashboard.dart';
import 'views/tournament_viewer.dart';

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();

  // create text data directory
  await TextConnection().createDirectory();
  // init db connection
  GlobalConfig.initConnection(DbType.textFile);

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      minimumSize: Size(1366, 768),
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      initialRoute: AppRoutes.home,
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.tournamentViewer) {
          final tournament = settings.arguments as Tournament;
          return MaterialPageRoute(
            builder: (context) => TournamentViewer(tournament: tournament),
          );
        }
        return null;
      },
      routes: {
        AppRoutes.home: (context) => const TournamentDashboard(),
        AppRoutes.createTournament: (context) => const CreateTournament(),
      },
    );
  }
}
