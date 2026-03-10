import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class AddTaskUseCase implements UseCase<TaskEntity, AddTaskParams> {
  final TaskRepository repository;

  AddTaskUseCase(this.repository);

  @override
  Future<Either<Failure, TaskEntity>> call(AddTaskParams params) {
    return repository.addTask(params.task, params.idToken);
  }
}

class AddTaskParams extends Equatable {
  final TaskEntity task;
  final String idToken;

  const AddTaskParams({required this.task, required this.idToken});

  @override
  List<Object> get props => [task, idToken];
}
