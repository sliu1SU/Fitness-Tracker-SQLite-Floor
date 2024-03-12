import 'package:fitness_tracker_sqlite_floor/floor_model/workout_event_entity.dart';
import 'package:floor/floor.dart';

@dao
abstract class WorkoutEventDao {
  @insert
  Future<void> addOneWorkoutEvent(WorkoutEventEntity workoutEvent);

  @Query('SELECT * FROM WorkoutEvents WHERE id = :id')
  Future<WorkoutEventEntity?> getOneWorkoutEvent(int id);

  @Query('SELECT * FROM WorkoutEvents')
  Future<List<WorkoutEventEntity>> getAllWorkoutEvents();

  // Delete one Workout event entry by ID
  @Query('DELETE FROM WorkoutEvents WHERE id = :id')
  Future<void> deleteOneWorkoutEventById(int id);

  // Delete all Workout event entries
  @Query('DELETE FROM WorkoutEvents')
  Future<void> deleteAllWorkoutEvents();
}