import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../domain/entities/task_entity.dart';

class TaskForm extends StatefulWidget {
  final TaskEntity? task;
  final Function(String title, String? description) onSave;
  final bool isLoading;

  const TaskForm({
    super.key,
    this.task,
    required this.onSave,
    this.isLoading = false,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSave(
        _titleController.text.trim(),
        _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isEditing ? Icons.edit_rounded : Icons.add_task_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditing ? 'Edit Task' : 'New Task',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isEditing ? 'Update your task details' : 'What do you need to do?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),
              CustomTextField(
                controller: _titleController,
                hintText: 'Enter task title',
                labelText: 'Title',
                prefixIcon: const Icon(Icons.title_rounded, size: 22),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _descriptionController,
                hintText: 'Add some details (optional)',
                labelText: 'Description',
                prefixIcon: const Icon(Icons.notes_rounded, size: 22),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      isOutlined: true,
                      onPressed: widget.isLoading
                          ? null
                          : () {
                              _animationController.reverse().then((_) {
                                Navigator.of(context).pop();
                              });
                            },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: isEditing ? 'Update' : 'Add Task',
                      onPressed: widget.isLoading ? null : _onSave,
                      isLoading: widget.isLoading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

void showTaskForm({
  required BuildContext context,
  TaskEntity? task,
  required Function(String title, String? description) onSave,
  bool isLoading = false,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TaskForm(
      task: task,
      onSave: onSave,
      isLoading: isLoading,
    ),
  );
}
