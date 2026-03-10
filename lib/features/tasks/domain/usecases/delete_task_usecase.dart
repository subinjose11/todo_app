import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/task_repository.dart';

class DeleteTaskUseCase implements UseCase<void, DeleteTaskParams> {
  final TaskRepository repository;

  DeleteTaskUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteTaskParams params) {
    return repository.deleteTask(params.taskId, params.userId, params.idToken);
  }
}

class DeleteTaskParams extends Equatable {
  final String taskId;
  final String userId;
  final String idToken;

  const DeleteTaskParams({
    required this.taskId,
    required this.userId,
    required this.idToken,
  });

  @override
  List<Object> get props => [taskId, userId, idToken];
}
