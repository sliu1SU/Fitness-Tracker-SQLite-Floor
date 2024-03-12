// required package imports
import 'dart:async';
import 'package:fitness_tracker_sqlite_floor/floor_model/workout_event_dao.dart';
import 'package:fitness_tracker_sqlite_floor/floor_model/workout_event_entity.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'diet_event_dao.dart';
import 'diet_event_entity.dart';
import 'emotion_event_dao.dart';
import 'emotion_event_entity.dart';
import 'point_record_entity.dart';
import 'point_record_dao.dart';

part 'database.g.dart';

@Database(
    version: 1,
    entities: [
      PointRecordEntity,
      EmotionEventEntity,
      DietEventEntity,
      WorkoutEventEntity
    ])
abstract class AppDatabase extends FloorDatabase {
  PointRecordDao get pointRecordDao;
  EmotionEventDao get emotionEventDao;
  DietEventDao get dietEventDao;
  WorkoutEventDao get workoutEventDao;
}