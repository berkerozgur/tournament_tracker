import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tournament_tracker/app_window_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'data_access/text_connection.dart';
import 'global_config.dart';
import 'models/tournament.dart';
import 'views/create_tournament.dart';
import 'views/tournament_dashboard.dart';
import 'views/tournament_viewer.dart';

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

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  // create text data directory
  await TextConnection().createDirectory();
  // init db connection
  GlobalConfig.initConnection(DbType.textFile);

  // TODO: put this in a class named like WindowManager
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    if (args.firstOrNull == 'multi_window') {
      // This is a sub-window launched by desktop_multi_window
      final argument = args[2].isEmpty
          ? const {}
          : jsonDecode(args[2]) as Map<String, dynamic>;

      final view = argument['view'];

      switch (view) {
        case 'tournament_viewer':
          final tournament = Tournament.fromJson(argument['tournament']);
          runApp(NewWindow(home: TournamentViewer(tournament: tournament)));
          AppWindowManager.setupSubWindow();
          break;
        case 'create_tournament':
          runApp(const NewWindow(home: CreateTournament()));
          AppWindowManager.setupSubWindow();
          break;
        default:
          print('default');
      }
    } else {
      // This is the main window
      runApp(const NewWindow(home: TournamentDashboard()));
      AppWindowManager.setupMainWindow();
    }
  }
}
