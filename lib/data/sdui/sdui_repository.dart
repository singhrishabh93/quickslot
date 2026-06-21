import 'package:swades_hackathon_app/data/repositories/_dio_failure_mapper.dart';
import 'package:swades_hackathon_app/data/sdui/sdui_api.dart';
import 'package:swades_hackathon_app/data/sdui/sdui_component.dart';
import 'package:swades_hackathon_app/data/utils/result.dart';

class SduiRepository {
  SduiRepository({required SduiApi api}) : _api = api;

  final SduiApi _api;

  Future<Result<SduiComponent>> fetchTree(String path) async {
    try {
      final raw = await _api.fetchTree(path);
      return Success(SduiComponent.fromJson(raw));
    } catch (e) {
      return FailureResult(mapDioError(e));
    }
  }
}
