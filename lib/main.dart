import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'data_access/text_connection.dart';
import 'global_config.dart';
import 'models/team.dart';
import 'views/create_prize.dart';
import 'views/create_team.dart';
import 'views/create_tournament.dart';
import 'views/tournament_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // create text data directory
  await TextConnection().createDirectory();
  // init db connection
  GlobalConfig.initConnection(DbType.textFile);

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(1366, 768),
      minimumSize: Size(1366, 768),
      maximumSize: Size(1366, 768),
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
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/create-team':
            return MaterialPageRoute<Team>(
              builder: (context) => const CreateTeam(),
            );
          default:
            return null;
        }
      },
      home: const InitialView(),
    );
  }
}

class InitialView extends StatelessWidget {
  const InitialView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Initial View'),
      ),
      body: Column(
        children: [
          // TextButton(
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => const TournamentViewer(),
          //       ),
          //     );
          //   },
          //   child: const Text('Tournament Viewer'),
          // ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateTournament(),
                ),
              );
            },
            child: const Text('Create Tournament'),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateTeam(),
                ),
              );
            },
            child: const Text('Create Team'),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreatePrize(),
                ),
              );
            },
            child: const Text('Create Prize'),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TournamentDashboard(),
                ),
              );
            },
            child: const Text('Tournament Dashboard'),
          ),
        ],
      ),
    );
  }
}
