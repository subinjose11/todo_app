import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<TaskEntity>>> getTasks(
      String userId, String idToken);
  Future<Either<Failure, TaskEntity>> addTask(TaskEntity task, String idToken);
  Future<Either<Failure, TaskEntity>> updateTask(
      TaskEntity task, String idToken);
  Future<Either<Failure, void>> deleteTask(
      String taskId, String userId, String idToken);
}
