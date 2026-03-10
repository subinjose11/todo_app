import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class UpdateTaskUseCase implements UseCase<TaskEntity, UpdateTaskParams> {
  final TaskRepository repository;

  UpdateTaskUseCase(this.repository);

  @override
  Future<Either<Failure, TaskEntity>> call(UpdateTaskParams params) {
    return repository.updateTask(params.task, params.idToken);
  }
}

class UpdateTaskParams extends Equatable {
  final TaskEntity task;
  final String idToken;

  const UpdateTaskParams({required this.task, required this.idToken});

  @override
  List<Object> get props => [task, idToken];
}
