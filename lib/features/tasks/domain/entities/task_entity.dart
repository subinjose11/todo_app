import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime createdAt;
  final String userId;

  const TaskEntity({
    required this.id,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.createdAt,
    required this.userId,
  });

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    String? userId,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, description, isCompleted, createdAt, userId];
}
