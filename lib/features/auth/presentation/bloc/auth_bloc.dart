import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signIn;
  final SignUpUseCase signUp;
  final SignInWithGoogleUseCase signInWithGoogle;
  final SignOutUseCase signOut;
  final GetCurrentUserUseCase getCurrentUser;

  AuthBloc({
    required this.signIn,
    required this.signUp,
    required this.signInWithGoogle,
    required this.signOut,
    required this.getCurrentUser,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await getCurrentUser(NoParams());
    result.fold(
      (failure) => emit(const Unauthenticated()),
      (user) {
        if (user != null) {
          emit(Authenticated(user: user));
        } else {
          emit(const Unauthenticated());
        }
      },
    );
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('DEBUG: Sign in requested for ${event.email}');
    emit(const AuthLoading());
    final result = await signIn(
      SignInParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) {
        print('DEBUG: Sign in FAILED - ${failure.message}');
        emit(AuthError(message: failure.message));
      },
      (user) {
        print('DEBUG: Sign in SUCCESS - ${user.email}');
        emit(Authenticated(user: user));
      },
    );
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await signUp(
      SignUpParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await signInWithGoogle(NoParams());
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await signOut(NoParams());
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const Unauthenticated()),
    );
  }
}
