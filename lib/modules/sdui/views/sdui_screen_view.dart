import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swades_hackathon_app/app/theme/app_theme.dart';
import 'package:swades_hackathon_app/app/widgets/empty_view.dart';
import 'package:swades_hackathon_app/data/di/service_locator.dart';
import 'package:swades_hackathon_app/data/sdui/sdui_repository.dart';
import 'package:swades_hackathon_app/modules/sdui/cubit/sdui_screen_cubit.dart';
import 'package:swades_hackathon_app/modules/sdui/cubit/sdui_screen_state.dart';
import 'package:swades_hackathon_app/modules/sdui/widgets/sdui_action_handler.dart';
import 'package:swades_hackathon_app/modules/sdui/widgets/sdui_renderer.dart';

/// Renders an SDUI tree for a given URL path.
/// Wraps the tree in pull-to-refresh + loading/error states.
class SduiScreenView extends StatelessWidget {
  const SduiScreenView({
    super.key,
    required this.path,
    this.parentHandler,
    this.scrollable = true,
  });

  final String path;
  final SduiActionHandler? parentHandler;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SduiScreenCubit>(
      create: (_) => SduiScreenCubit(
        repository: getIt<SduiRepository>(),
        path: path,
      )..load(),
      child: _SduiScreenBody(
          parentHandler: parentHandler, scrollable: scrollable),
    );
  }
}

class _SduiScreenBody extends StatelessWidget {
  const _SduiScreenBody({this.parentHandler, this.scrollable = true});

  final SduiActionHandler? parentHandler;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SduiScreenCubit, SduiScreenState>(
      builder: (context, state) {
        final cubit = context.read<SduiScreenCubit>();
        final handler = SduiActionHandler(
          context: context,
          reload: cubit.reload,
          parent: parentHandler,
        );

        return switch (state) {
          SduiScreenInitial() ||
          SduiScreenLoading() =>
            const Center(child: CircularProgressIndicator()),
          SduiScreenError(:final failure) => ErrorView(
              message: failure.message,
              onRetry: cubit.reload,
            ),
          SduiScreenSuccess(:final tree) => _buildContent(
              context,
              tree,
              handler,
              cubit,
            ),
        };
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    dynamic tree,
    SduiActionHandler handler,
    SduiScreenCubit cubit,
  ) {
    final rendered = SduiRenderer(tree: tree, handler: handler);
    if (!scrollable) return rendered;
    return RefreshIndicator(
      color: AppColors.ink,
      backgroundColor: AppColors.cream,
      onRefresh: cubit.reload,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: rendered,
      ),
    );
  }
}

/// Install the modal content builder so the action handler can spawn
/// sheets/dialogs that themselves contain SDUI subtrees, without a
/// circular import.
void registerSduiModalBuilder() {
  sduiModalContentBuilder = (context, path, parentHandler, isDialog) {
    if (isDialog) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: SduiScreenView(
          path: path,
          parentHandler: parentHandler,
          scrollable: false,
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SduiScreenView(
        path: path,
        parentHandler: parentHandler,
        scrollable: false,
      ),
    );
  };
}
