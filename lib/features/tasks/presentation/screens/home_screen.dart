import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../widgets/task_form.dart';
import '../widgets/task_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabScale;

  @override
  void initState() {
    super.initState();
    print('DEBUG: HomeScreen initState called');
    _initializeTasks();
    print('DEBUG: HomeScreen _initializeTasks completed');
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _fabController.forward();
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _initializeTasks() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<TaskBloc>().add(InitializeTasks(userId: authState.user.id));
    }
  }

  void _refreshTasks() {
    context.read<TaskBloc>().add(const LoadTasks());
  }

  void _onAddTask() {
    showTaskForm(
      context: context,
      onSave: (title, description) {
        Navigator.of(context).pop();
        context.read<TaskBloc>().add(
              AddTask(title: title, description: description),
            );
      },
    );
  }

  void _onEditTask(TaskEntity task) {
    showTaskForm(
      context: context,
      task: task,
      onSave: (title, description) {
        Navigator.of(context).pop();
        context.read<TaskBloc>().add(
              UpdateTask(
                task: task.copyWith(title: title, description: description),
              ),
            );
      },
    );
  }

  void _onToggleTask(TaskEntity task) {
    context.read<TaskBloc>().add(ToggleTaskCompletion(task: task));
  }

  void _onDeleteTask(String taskId) {
    context.read<TaskBloc>().add(DeleteTask(taskId: taskId));
  }

  void _onSignOut() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => Container(
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
                Icons.logout_rounded,
                color: AppColors.errorDark,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to sign out?',
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
                    onTap: () => Navigator.of(dialogContext).pop(),
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
                    onTap: () {
                      Navigator.of(dialogContext).pop();
                      context.read<AuthBloc>().add(const SignOutRequested());
                    },
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.errorDark,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          'Sign Out',
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
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const LoginScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocConsumer<TaskBloc, TaskState>(
            listener: (context, state) {
              if (state is TaskError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(child: Text(state.message)),
                      ],
                    ),
                    backgroundColor: AppColors.errorDark,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              } else if (state is TaskOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(state.message),
                      ],
                    ),
                    backgroundColor: AppColors.successDark,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(16),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            builder: (context, state) {
              List<TaskEntity> tasks = [];
              if (state is TaskLoaded) {
                tasks = state.tasks;
              } else if (state is TaskOperationSuccess) {
                tasks = state.tasks;
              }

              final completedCount = tasks.where((t) => t.isCompleted).length;
              final pendingCount = tasks.length - completedCount;

              return Column(
                children: [
                  _buildHeader(tasks.length, completedCount, pendingCount),
                  Expanded(
                    child: state is TaskLoading || state is TaskInitial
                        ? _buildLoadingState()
                        : tasks.isEmpty
                            ? _buildEmptyState()
                            : _buildTaskList(tasks),
                  ),
                ],
              );
            },
          ),
        ),
        floatingActionButton: ScaleTransition(
          scale: _fabScale,
          child: FloatingActionButton.extended(
            onPressed: _onAddTask,
            elevation: 8,
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add_rounded, size: 24),
            label: const Text(
              'Add Task',
              style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int total, int completed, int pending) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'My Tasks',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _onSignOut,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildStatCard('Total', total, AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Pending', pending, AppColors.secondary)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Done', completed, AppColors.successDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading tasks...',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<TaskEntity> tasks) {
    return RefreshIndicator(
      onRefresh: () async => _refreshTasks(),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: TaskTile(
              task: task,
              onToggle: () => _onToggleTask(task),
              onEdit: () => _onEditTask(task),
              onDelete: () => _onDeleteTask(task.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.secondary.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(70),
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                size: 70,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No tasks yet',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap the button below to create\nyour first task',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
