import 'package:equatable/equatable.dart';

/// Mirror of `SduiAction` in server/src/sdui/sdui.types.ts.
///
/// Sealed so the renderer's switch is exhaustive — adding a new
/// action type forces every dispatch site to be updated.
sealed class SduiAction extends Equatable {
  const SduiAction();

  factory SduiAction.fromJson(Map<String, dynamic> json) {
    return switch (json['action'] as String?) {
      'navigate' => SduiNavigate.fromJson(json),
      'reload' => const SduiReload(),
      _ => SduiUnknownAction(action: json['action'] as String? ?? 'unknown'),
    };
  }

  @override
  List<Object?> get props => [];
}

class SduiNavigate extends SduiAction {
  const SduiNavigate({required this.to, this.params = const {}});

  factory SduiNavigate.fromJson(Map<String, dynamic> json) {
    final rawParams = json['params'];
    final params = rawParams is Map<String, dynamic>
        ? rawParams.map((k, v) => MapEntry(k, v.toString()))
        : <String, String>{};
    return SduiNavigate(to: json['to'] as String, params: params);
  }

  final String to;
  final Map<String, String> params;

  @override
  List<Object?> get props => [to, params];
}

class SduiReload extends SduiAction {
  const SduiReload();
}

/// Forward-compat fallback when the server sends an action the client
/// doesn't know yet. Renderer ignores it (or logs).
class SduiUnknownAction extends SduiAction {
  const SduiUnknownAction({required this.action});
  final String action;

  @override
  List<Object?> get props => [action];
}
