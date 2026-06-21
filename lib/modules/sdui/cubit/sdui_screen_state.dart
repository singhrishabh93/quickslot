import 'package:equatable/equatable.dart';
import 'package:swades_hackathon_app/data/sdui/sdui_component.dart';
import 'package:swades_hackathon_app/data/utils/failure.dart';

sealed class SduiScreenState extends Equatable {
  const SduiScreenState();
  @override
  List<Object?> get props => [];
}

class SduiScreenInitial extends SduiScreenState {
  const SduiScreenInitial();
}

class SduiScreenLoading extends SduiScreenState {
  const SduiScreenLoading();
}

class SduiScreenSuccess extends SduiScreenState {
  const SduiScreenSuccess(this.tree);
  final SduiComponent tree;
  @override
  List<Object?> get props => [tree];
}

class SduiScreenError extends SduiScreenState {
  const SduiScreenError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
