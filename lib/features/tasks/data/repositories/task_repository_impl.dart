import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks(
      String userId, String idToken) async {
    try {
      final tasks = await remoteDataSource.getTasks(userId, idToken);
      return Right(tasks);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> addTask(
      TaskEntity task, String idToken) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      final addedTask = await remoteDataSource.addTask(taskModel, idToken);
      return Right(addedTask);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTask(
      TaskEntity task, String idToken) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      final updatedTask = await remoteDataSource.updateTask(taskModel, idToken);
      return Right(updatedTask);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(
      String taskId, String userId, String idToken) async {
    try {
      await remoteDataSource.deleteTask(taskId, userId, idToken);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
