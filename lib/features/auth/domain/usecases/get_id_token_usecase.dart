import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class GetIdTokenUseCase implements UseCase<String, NoParams> {
  final AuthRepository repository;

  GetIdTokenUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) {
    return repository.getIdToken();
  }
}
