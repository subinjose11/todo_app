import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/task_entity.dart';

class TaskTile extends StatefulWidget {
  final TaskEntity task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.error.withValues(alpha: 0.8), AppColors.errorDark],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showModalBottomSheet<bool>(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.errorDark,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Delete Task',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to delete this task?',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(false),
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(true),
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            color: AppColors.errorDark,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Text(
                              'Delete',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
      onDismissed: (direction) => widget.onDelete(),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: widget.onEdit,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: widget.task.isCompleted
                  ? Border.all(color: AppColors.success.withValues(alpha: 0.3), width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: widget.task.isCompleted
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.cardShadow,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onToggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: widget.task.isCompleted
                            ? AppColors.successGradient
                            : null,
                        color: widget.task.isCompleted ? null : Colors.transparent,
                        border: widget.task.isCompleted
                            ? null
                            : Border.all(color: AppColors.divider, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: widget.task.isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              size: 20,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.task.title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: widget.task.isCompleted
                                ? AppColors.textTertiary
                                : AppColors.textPrimary,
                            decoration: widget.task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: AppColors.textTertiary,
                          ),
                        ),
                        if (widget.task.description != null &&
                            widget.task.description!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            widget.task.description!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                              decoration: widget.task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
