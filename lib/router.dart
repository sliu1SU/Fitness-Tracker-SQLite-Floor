import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'workout_recorder.dart';

import 'diet_recorder.dart';
import 'emotion_recorder.dart';
import 'home_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return Home(
            child: child
        );
      },
      routes: [
        // This screen is displayed on the ShellRoute's Navigator.
        GoRoute(
          path: '/',
          builder: (context, state) {
            return const EmotionRecorder();
          },
          parentNavigatorKey: _shellNavigatorKey,
        ),

        GoRoute(
          path: '/diet',
          builder: (context, state) {
            return const DietRecorder();
          },
          parentNavigatorKey: _shellNavigatorKey,
        ),

        GoRoute(
          path: '/workout',
          builder: (context, state) {
            return const WorkoutRecorder();
          },
          parentNavigatorKey: _shellNavigatorKey,
        ),
      ],
    ),
  ],
);