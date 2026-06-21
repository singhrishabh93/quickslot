import 'package:equatable/equatable.dart';

/// Mirror of `SduiAction` in server/src/sdui/sdui.types.ts.
///
/// Every `on_tap`, `on_success`, `on_conflict`, `on_error` field is a
/// LIST of actions — even if there's only one. The handler dispatches
/// them sequentially.
sealed class SduiAction extends Equatable {
  const SduiAction();

  factory SduiAction.fromJson(Map<String, dynamic> json) {
    return switch (json['action'] as String?) {
      'navigate' => SduiNavigate.fromJson(json),
      'replace_all' => SduiReplaceAll.fromJson(json),
      'navigate_back' => const SduiNavigateBack(),
      'reload' => const SduiReload(),
      'set_session' => SduiSetSession.fromJson(json),
      'clear_session' => const SduiClearSession(),
      'open_sheet' => SduiOpenSheet.fromJson(json),
      'close_sheet' => const SduiCloseSheet(),
      'show_dialog' => SduiShowDialog.fromJson(json),
      'show_snackbar' => SduiShowSnackbar.fromJson(json),
      'api_call' => SduiApiCall.fromJson(json),
      _ => SduiUnknownAction(action: json['action'] as String? ?? 'unknown'),
    };
  }

  /// Parse a JSON value that's either a list of action maps or a single
  /// action map into a `List<SduiAction>`. Tolerates null/missing.
  static List<SduiAction> parseList(Object? raw) {
    if (raw == null) return const [];
    if (raw is Map<String, dynamic>) return [SduiAction.fromJson(raw)];
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(SduiAction.fromJson)
          .toList(growable: false);
    }
    return const [];
  }

  @override
  List<Object?> get props => [];
}

Map<String, String> _parseParams(Object? raw) {
  if (raw is Map<String, dynamic>) {
    return raw.map((k, v) => MapEntry(k, v.toString()));
  }
  return const {};
}

class SduiNavigate extends SduiAction {
  const SduiNavigate({required this.to, this.params = const {}});

  factory SduiNavigate.fromJson(Map<String, dynamic> json) => SduiNavigate(
        to: json['to'] as String,
        params: _parseParams(json['params']),
      );

  final String to;
  final Map<String, String> params;

  @override
  List<Object?> get props => [to, params];
}

class SduiReplaceAll extends SduiAction {
  const SduiReplaceAll({required this.to, this.params = const {}});

  factory SduiReplaceAll.fromJson(Map<String, dynamic> json) => SduiReplaceAll(
        to: json['to'] as String,
        params: _parseParams(json['params']),
      );

  final String to;
  final Map<String, String> params;

  @override
  List<Object?> get props => [to, params];
}

class SduiNavigateBack extends SduiAction {
  const SduiNavigateBack();
}

class SduiReload extends SduiAction {
  const SduiReload();
}

class SduiSetSession extends SduiAction {
  const SduiSetSession({required this.userId, required this.name});

  factory SduiSetSession.fromJson(Map<String, dynamic> json) => SduiSetSession(
        userId: json['user_id'] as String,
        name: json['name'] as String,
      );

  final String userId;
  final String name;

  @override
  List<Object?> get props => [userId, name];
}

class SduiClearSession extends SduiAction {
  const SduiClearSession();
}

class SduiOpenSheet extends SduiAction {
  const SduiOpenSheet({required this.url});

  factory SduiOpenSheet.fromJson(Map<String, dynamic> json) =>
      SduiOpenSheet(url: json['url'] as String);

  final String url;

  @override
  List<Object?> get props => [url];
}

class SduiCloseSheet extends SduiAction {
  const SduiCloseSheet();
}

class SduiShowDialog extends SduiAction {
  const SduiShowDialog({required this.url});

  factory SduiShowDialog.fromJson(Map<String, dynamic> json) =>
      SduiShowDialog(url: json['url'] as String);

  final String url;

  @override
  List<Object?> get props => [url];
}

enum SduiSnackbarTone { info, success, danger }

SduiSnackbarTone _parseSnackbarTone(Object? raw) => switch (raw) {
      'success' => SduiSnackbarTone.success,
      'danger' => SduiSnackbarTone.danger,
      _ => SduiSnackbarTone.info,
    };

class SduiShowSnackbar extends SduiAction {
  const SduiShowSnackbar({required this.text, this.tone = SduiSnackbarTone.info});

  factory SduiShowSnackbar.fromJson(Map<String, dynamic> json) =>
      SduiShowSnackbar(
        text: json['text'] as String,
        tone: _parseSnackbarTone(json['tone']),
      );

  final String text;
  final SduiSnackbarTone tone;

  @override
  List<Object?> get props => [text, tone];
}

enum SduiHttpMethod { post, put, patch, delete }

SduiHttpMethod _parseMethod(Object? raw) => switch (raw) {
      'PUT' => SduiHttpMethod.put,
      'PATCH' => SduiHttpMethod.patch,
      'DELETE' => SduiHttpMethod.delete,
      _ => SduiHttpMethod.post,
    };

class SduiApiCall extends SduiAction {
  const SduiApiCall({
    required this.method,
    required this.url,
    this.body,
    this.onSuccess = const [],
    this.onConflict = const [],
    this.onError = const [],
  });

  factory SduiApiCall.fromJson(Map<String, dynamic> json) => SduiApiCall(
        method: _parseMethod(json['method']),
        url: json['url'] as String,
        body: json['body'] as Map<String, dynamic>?,
        onSuccess: SduiAction.parseList(json['on_success']),
        onConflict: SduiAction.parseList(json['on_conflict']),
        onError: SduiAction.parseList(json['on_error']),
      );

  final SduiHttpMethod method;
  final String url;
  final Map<String, dynamic>? body;
  final List<SduiAction> onSuccess;
  final List<SduiAction> onConflict;
  final List<SduiAction> onError;

  @override
  List<Object?> get props =>
      [method, url, body, onSuccess, onConflict, onError];
}

class SduiUnknownAction extends SduiAction {
  const SduiUnknownAction({required this.action});
  final String action;

  @override
  List<Object?> get props => [action];
}
