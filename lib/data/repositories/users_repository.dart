import 'package:swades_hackathon_app/data/api/users_api.dart';
import 'package:swades_hackathon_app/data/models/user.dart';
import 'package:swades_hackathon_app/data/repositories/_dio_failure_mapper.dart';
import 'package:swades_hackathon_app/data/utils/result.dart';

class UsersRepository {
  UsersRepository({required UsersApi usersApi}) : _api = usersApi;

  final UsersApi _api;

  Future<Result<List<User>>> listUsers() async {
    try {
      final raw = await _api.listUsers();
      return Success(raw.map(User.fromJson).toList());
    } catch (e) {
      return FailureResult(mapDioError(e));
    }
  }
}
