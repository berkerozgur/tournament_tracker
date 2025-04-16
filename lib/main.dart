import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'data_access/text_connection.dart';
import 'global_config.dart';
import 'models/tournament.dart';
import 'views/create_team.dart';
import 'views/create_tournament.dart';
import 'views/tournament_dashboard.dart';
import 'views/tournament_viewer.dart';

void _setUpMainWindow() async {
  runApp(const NewWindow(home: TournamentDashboard()));

  const windowOptions = WindowOptions(
    center: true,
    maximumSize: Size(533.3, 400),
    minimumSize: Size(533.3, 400),
    size: Size(533.3, 400),
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

void _setupSubWindow(Widget view) async {
  runApp(NewWindow(home: view));
  await windowManager.setResizable(false);
  await windowManager.setSize(const Size(1366, 768));
  await windowManager.show();
}

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  // create text data directory
  await TextConnection().createDirectory();
  // init db connection
  GlobalConfig.initConnection(DbType.textFile);

  // TODO: Separate desktop init and mobile init
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    if (args.firstOrNull == 'multi_window') {
      // This is a sub-window launched by desktop_multi_window
      final argument = args[2].isEmpty
          ? const {}
          : jsonDecode(args[2]) as Map<String, dynamic>;

      final view = argument['view'];

      switch (view) {
        case 'create_team':
          _setupSubWindow(const CreateTeam());
          break;
        case 'create_tournament':
          _setupSubWindow(const CreateTournament());
          break;
        case 'tournament_viewer':
          final tournament = Tournament.fromJson(argument['tournament']);
          _setupSubWindow(TournamentViewer(tournament: tournament));
          break;
        default:
          dev.log('Reached default case somehow');
      }
    } else {
      // This is the main window
      _setUpMainWindow();
    }
  }
}

class NewWindow extends StatelessWidget {
  final Widget home;

  const NewWindow({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: home,
    );
  }
}
