import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/usecases/get_id_token_usecase.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksUseCase _getTasks;
  final AddTaskUseCase _addTask;
  final UpdateTaskUseCase _updateTask;
  final DeleteTaskUseCase _deleteTask;
  final GetIdTokenUseCase _getIdToken;

  List<TaskEntity> _tasks = [];
  String? _userId;
  String? _idToken;

  TaskBloc({
    required GetTasksUseCase getTasks,
    required AddTaskUseCase addTask,
    required UpdateTaskUseCase updateTask,
    required DeleteTaskUseCase deleteTask,
    required GetIdTokenUseCase getIdToken,
  })  : _getTasks = getTasks,
        _addTask = addTask,
        _updateTask = updateTask,
        _deleteTask = deleteTask,
        _getIdToken = getIdToken,
        super(const TaskInitial()) {
    on<InitializeTasks>(_onInitializeTasks);
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<ToggleTaskCompletion>(_onToggleTaskCompletion);
    on<DeleteTask>(_onDeleteTask);
  }

  Future<String?> _fetchIdToken() async {
    final result = await _getIdToken(NoParams());
    return result.fold(
      (failure) => null,
      (token) => token,
    );
  }

  Future<void> _onInitializeTasks(
    InitializeTasks event,
    Emitter<TaskState> emit,
  ) async {
    _userId = event.userId;
    emit(const TaskLoading());

    _idToken = await _fetchIdToken();
    if (_idToken == null) {
      emit(const TaskError(message: 'Failed to authenticate. Please sign in again.'));
      return;
    }

    final result = await _getTasks(
      GetTasksParams(userId: _userId!, idToken: _idToken!),
    );
    result.fold(
      (failure) => emit(TaskError(message: failure.message)),
      (tasks) {
        _tasks = tasks;
        emit(TaskLoaded(tasks: tasks));
      },
    );
  }

  Future<void> _onLoadTasks(
    LoadTasks event,
    Emitter<TaskState> emit,
  ) async {
    if (_userId == null) {
      emit(const TaskError(message: 'User not initialized'));
      return;
    }

    emit(const TaskLoading());

    _idToken = await _fetchIdToken();
    if (_idToken == null) {
      emit(const TaskError(message: 'Failed to authenticate. Please sign in again.'));
      return;
    }

    final result = await _getTasks(
      GetTasksParams(userId: _userId!, idToken: _idToken!),
    );
    result.fold(
      (failure) => emit(TaskError(message: failure.message)),
      (tasks) {
        _tasks = tasks;
        emit(TaskLoaded(tasks: tasks));
      },
    );
  }

  Future<void> _onAddTask(
    AddTask event,
    Emitter<TaskState> emit,
  ) async {
    if (_userId == null || _idToken == null) {
      emit(const TaskError(message: 'User not authenticated'));
      return;
    }

    emit(const TaskLoading());

    final newTask = TaskEntity(
      id: '',
      title: event.title,
      description: event.description,
      isCompleted: false,
      createdAt: DateTime.now(),
      userId: _userId!,
    );

    final result = await _addTask(
      AddTaskParams(task: newTask, idToken: _idToken!),
    );

    result.fold(
      (failure) => emit(TaskError(message: failure.message)),
      (addedTask) {
        _tasks = [addedTask, ..._tasks];
        emit(TaskOperationSuccess(tasks: _tasks, message: 'Task added'));
      },
    );
  }

  Future<void> _onUpdateTask(
    UpdateTask event,
    Emitter<TaskState> emit,
  ) async {
    if (_idToken == null) {
      emit(const TaskError(message: 'User not authenticated'));
      return;
    }

    emit(const TaskLoading());
    final result = await _updateTask(
      UpdateTaskParams(task: event.task, idToken: _idToken!),
    );

    result.fold(
      (failure) => emit(TaskError(message: failure.message)),
      (updatedTask) {
        _tasks = _tasks
            .map((t) => t.id == updatedTask.id ? updatedTask : t)
            .toList();
        emit(TaskOperationSuccess(tasks: _tasks, message: 'Task updated'));
      },
    );
  }

  Future<void> _onToggleTaskCompletion(
    ToggleTaskCompletion event,
    Emitter<TaskState> emit,
  ) async {
    if (_idToken == null) {
      emit(const TaskError(message: 'User not authenticated'));
      return;
    }

    final updatedTask = event.task.copyWith(
      isCompleted: !event.task.isCompleted,
    );

    _tasks = _tasks.map((t) => t.id == updatedTask.id ? updatedTask : t).toList();
    emit(TaskLoaded(tasks: _tasks));

    final result = await _updateTask(
      UpdateTaskParams(task: updatedTask, idToken: _idToken!),
    );

    result.fold(
      (failure) {
        _tasks = _tasks
            .map((t) => t.id == event.task.id ? event.task : t)
            .toList();
        emit(TaskError(message: failure.message));
      },
      (_) {},
    );
  }

  Future<void> _onDeleteTask(
    DeleteTask event,
    Emitter<TaskState> emit,
  ) async {
    if (_userId == null || _idToken == null) {
      emit(const TaskError(message: 'User not authenticated'));
      return;
    }

    final deletedTask = _tasks.firstWhere((t) => t.id == event.taskId);
    final originalIndex = _tasks.indexOf(deletedTask);

    _tasks = _tasks.where((t) => t.id != event.taskId).toList();
    emit(TaskLoaded(tasks: _tasks));

    final result = await _deleteTask(
      DeleteTaskParams(
        taskId: event.taskId,
        userId: _userId!,
        idToken: _idToken!,
      ),
    );

    result.fold(
      (failure) {
        _tasks.insert(originalIndex, deletedTask);
        emit(TaskError(message: failure.message));
      },
      (_) {
        emit(TaskOperationSuccess(tasks: _tasks, message: 'Task deleted'));
      },
    );
  }
}
