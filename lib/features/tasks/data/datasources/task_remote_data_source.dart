import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks(String userId, String idToken);
  Future<TaskModel> addTask(TaskModel task, String idToken);
  Future<TaskModel> updateTask(TaskModel task, String idToken);
  Future<void> deleteTask(String taskId, String userId, String idToken);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final http.Client client;

  TaskRemoteDataSourceImpl({required this.client});

  @override
  Future<List<TaskModel>> getTasks(String userId, String idToken) async {
    try {
      final url = AppConstants.getTasksUrl(userId, idToken);
      final response = await client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data == null) {
          return [];
        }

        final Map<String, dynamic> tasksMap = data as Map<String, dynamic>;
        final tasks = tasksMap.entries.map((entry) {
          return TaskModel.fromJson(
            entry.value as Map<String, dynamic>,
            entry.key,
          );
        }).toList();

        tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return tasks;
      } else {
        throw ServerException(
          message: 'Failed to fetch tasks: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to fetch tasks: $e');
    }
  }

  @override
  Future<TaskModel> addTask(TaskModel task, String idToken) async {
    try {
      final url = AppConstants.addTaskUrl(task.userId, idToken);
      final response = await client.post(
        Uri.parse(url),
        body: json.encode(task.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final newId = data['name'] as String;
        return task.copyWith(id: newId);
      } else {
        throw ServerException(
          message: 'Failed to add task: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to add task: $e');
    }
  }

  @override
  Future<TaskModel> updateTask(TaskModel task, String idToken) async {
    try {
      final url = AppConstants.updateTaskUrl(task.userId, task.id, idToken);
      final response = await client.put(
        Uri.parse(url),
        body: json.encode(task.toJson()),
      );

      if (response.statusCode == 200) {
        return task;
      } else {
        throw ServerException(
          message: 'Failed to update task: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to update task: $e');
    }
  }

  @override
  Future<void> deleteTask(
      String taskId, String userId, String idToken) async {
    try {
      final url = AppConstants.deleteTaskUrl(userId, taskId, idToken);
      final response = await client.delete(Uri.parse(url));

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to delete task: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to delete task: $e');
    }
  }
}
