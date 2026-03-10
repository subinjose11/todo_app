import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class InitializeTasks extends TaskEvent {
  final String userId;

  const InitializeTasks({required this.userId});

  @override
  List<Object> get props => [userId];
}

class LoadTasks extends TaskEvent {
  const LoadTasks();
}

class AddTask extends TaskEvent {
  final String title;
  final String? description;

  const AddTask({
    required this.title,
    this.description,
  });

  @override
  List<Object?> get props => [title, description];
}

class UpdateTask extends TaskEvent {
  final TaskEntity task;

  const UpdateTask({required this.task});

  @override
  List<Object> get props => [task];
}

class ToggleTaskCompletion extends TaskEvent {
  final TaskEntity task;

  const ToggleTaskCompletion({required this.task});

  @override
  List<Object> get props => [task];
}

class DeleteTask extends TaskEvent {
  final String taskId;

  const DeleteTask({required this.taskId});

  @override
  List<Object> get props => [taskId];
}
