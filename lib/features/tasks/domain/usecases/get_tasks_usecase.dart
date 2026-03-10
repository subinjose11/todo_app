import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTasksUseCase implements UseCase<List<TaskEntity>, GetTasksParams> {
  final TaskRepository repository;

  GetTasksUseCase(this.repository);

  @override
  Future<Either<Failure, List<TaskEntity>>> call(GetTasksParams params) {
    return repository.getTasks(params.userId, params.idToken);
  }
}

class GetTasksParams extends Equatable {
  final String userId;
  final String idToken;

  const GetTasksParams({required this.userId, required this.idToken});

  @override
  List<Object> get props => [userId, idToken];
}
