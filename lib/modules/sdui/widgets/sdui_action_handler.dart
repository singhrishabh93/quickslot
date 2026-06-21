import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:swades_hackathon_app/app/theme/app_theme.dart';
import 'package:swades_hackathon_app/data/di/service_locator.dart';
import 'package:swades_hackathon_app/data/local/session_storage.dart';
import 'package:swades_hackathon_app/data/sdui/sdui_action.dart';
import 'package:swades_hackathon_app/data/sdui/sdui_api.dart';
import 'package:swades_hackathon_app/router/app_router.dart';

/// Dispatches `SduiAction` lists. Walks the parent chain for `reload`
/// so sheets/dialogs reload the underlying page.
class SduiActionHandler {
  SduiActionHandler({
    required this.context,
    required this.reload,
    this.parent,
  });

  final BuildContext context;
  final Future<void> Function() reload;
  final SduiActionHandler? parent;

  /// Renderer entry point — fires an on_tap chain.
  Future<void> dispatchAll(List<SduiAction> actions) async {
    for (final action in actions) {
      await _dispatchOne(action);
      if (!context.mounted) return;
    }
  }

  Future<void> _dispatchOne(SduiAction action) async {
    switch (action) {
      case SduiNavigate(:final to, :final params):
        final route = _routeFor(to, params);
        if (route != null) await context.router.push(route);

      case SduiReplaceAll(:final to, :final params):
        final route = _routeFor(to, params);
        if (route != null) await context.router.replaceAll([route]);

      case SduiNavigateBack():
        if (context.router.canPop()) context.router.maybePop();

      case SduiReload():
        var h = this;
        while (h.parent != null) {
          h = h.parent!;
        }
        await h.reload();

      case SduiSetSession(:final userId, :final name):
        await getIt<SessionStorage>().save(userId: userId, userName: name);

      case SduiClearSession():
        await getIt<SessionStorage>().clear();

      case SduiOpenSheet(:final url):
        await _showSheet(url);

      case SduiCloseSheet():
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }

      case SduiShowDialog(:final url):
        await _showDialog(url);

      case SduiShowSnackbar(:final text, :final tone):
        final bg = switch (tone) {
          SduiSnackbarTone.success => AppColors.courtGreen,
          SduiSnackbarTone.danger => AppColors.clay,
          SduiSnackbarTone.info => AppColors.ink,
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(text), backgroundColor: bg),
        );

      case SduiApiCall():
        await _runApiCall(action);

      case SduiUnknownAction(:final action):
        debugPrint('[SDUI] unknown action: $action');
    }
  }

  Future<void> _showSheet(String url) async {
    final outerHandler = this;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      builder: (sheetCtx) => _SduiModalScope(
        path: url,
        parentHandler: outerHandler,
      ),
    );
  }

  Future<void> _showDialog(String url) async {
    final outerHandler = this;
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: AppColors.cream,
        child: _SduiModalScope(
          path: url,
          parentHandler: outerHandler,
          isDialog: true,
        ),
      ),
    );
  }

  Future<void> _runApiCall(SduiApiCall action) async {
    final method = switch (action.method) {
      SduiHttpMethod.post => 'POST',
      SduiHttpMethod.put => 'PUT',
      SduiHttpMethod.patch => 'PATCH',
      SduiHttpMethod.delete => 'DELETE',
    };

    try {
      final response = await getIt<SduiApi>().exec(
        method: method,
        url: action.url,
        body: action.body,
      );
      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300) {
        await dispatchAll(action.onSuccess);
      } else if (status == 409) {
        await dispatchAll(action.onConflict);
      } else {
        await dispatchAll(action.onError);
      }
    } catch (_) {
      await dispatchAll(action.onError);
    }
  }

  PageRouteInfo? _routeFor(String path, Map<String, String> params) {
    switch (path) {
      case '/':
      case '/login':
        return const LoginRoute();
      case '/venues':
        return const VenuesRoute();
      case '/venue-detail':
        return VenueDetailRoute(
          venueId: params['venue_id'] ?? '',
          date: params['date'],
        );
      case '/my-bookings':
        return const MyBookingsRoute();
      default:
        debugPrint('[SDUI] unknown route: $path');
        return null;
    }
  }
}

/// Modal content widget — used inside `showModalBottomSheet` and
/// `showDialog` to host an SDUI subtree with its own cubit + handler.
///
/// Imported lazily here (rather than via sdui_screen_view.dart) so the
/// action handler doesn't pull a circular dep.
class _SduiModalScope extends StatelessWidget {
  const _SduiModalScope({
    required this.path,
    required this.parentHandler,
    this.isDialog = false,
  });

  final String path;
  final SduiActionHandler parentHandler;
  final bool isDialog;

  @override
  Widget build(BuildContext context) {
    // Defer to a builder defined in the screen view module to avoid
    // a hard import cycle. The view module sets this at startup.
    final builder = sduiModalContentBuilder;
    return builder(context, path, parentHandler, isDialog);
  }
}

/// Hook so the views layer can install its modal builder without
/// the action handler depending on it directly.
typedef SduiModalContentBuilder = Widget Function(
  BuildContext context,
  String path,
  SduiActionHandler parentHandler,
  bool isDialog,
);

SduiModalContentBuilder sduiModalContentBuilder =
    (_, _, _, _) => const SizedBox.shrink();
