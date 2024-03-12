/*
Homework 4
Sizhe Liu
Please read the README.md
 */

import 'package:fitness_tracker_sqlite_floor/router.dart';
import 'package:fitness_tracker_sqlite_floor/view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'app_options.dart';
import 'floor_model/database.dart';
import 'floor_model/floor_repository.dart';
import 'locale_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppDatabase db = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  runApp(MyApp(db));
}

class MyApp extends StatelessWidget {
  final AppDatabase db;
  const MyApp(this.db, {super.key}); // ctor here

  // static void setLocale(BuildContext context, Locale value) {
  //   _MyApp? state = context.findAncestorStateOfType<_MyApp>();
  //   state?.setLocale(value);
  // }

// This widget is the root of your application.
  @override
  // original build method
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ViewModel(FloorRepository(db)),
        ),
        ChangeNotifierProvider(
          create: (context) => LocaleOptions(const Locale('en')),
        ),
        Provider(
          create: (context) => AppOptions(WidgetStyle.cupertino),
        ),
      ],
      child: Builder(
        builder: (BuildContext context) {
          return MaterialApp.router(
            routerConfig: router,
            title: 'Flutter Demo',
            //locale: curLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate, // Add this line
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('es'), // Spanish
            ],
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
          );
        },
      )

      // child: MaterialApp.router(
      //   routerConfig: router,
      //   title: 'Flutter Demo',
      //   //locale: curLocale,
      //   localizationsDelegates: const [
      //     AppLocalizations.delegate, // Add this line
      //     GlobalMaterialLocalizations.delegate,
      //     GlobalWidgetsLocalizations.delegate,
      //     GlobalCupertinoLocalizations.delegate,
      //   ],
      //   supportedLocales: const [
      //     Locale('en'), // English
      //     Locale('es'), // Spanish
      //   ],
      //   theme: ThemeData(
      //     colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      //     useMaterial3: true,
      //   ),
      // ),
    );
  }
}