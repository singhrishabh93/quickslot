import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swades_hackathon_app/data/sdui/sdui_repository.dart';
import 'package:swades_hackathon_app/modules/sdui/cubit/sdui_screen_state.dart';

/// One cubit per SDUI screen instance. Holds the path it fetches and
/// the current tree state. Reload re-fetches the same path.
class SduiScreenCubit extends Cubit<SduiScreenState> {
  SduiScreenCubit({
    required SduiRepository repository,
    required this.path,
  })  : _repo = repository,
        super(const SduiScreenInitial());

  final SduiRepository _repo;
  final String path;

  Future<void> load() async {
    if (state is! SduiScreenSuccess) emit(const SduiScreenLoading());
    final result = await _repo.fetchTree(path);
    result.fold(
      (tree) => emit(SduiScreenSuccess(tree)),
      (failure) => emit(SduiScreenError(failure)),
    );
  }

  Future<void> reload() => load();
}
