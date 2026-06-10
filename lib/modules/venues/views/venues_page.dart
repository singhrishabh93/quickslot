import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swades_hackathon_app/data/di/service_locator.dart';
import 'package:swades_hackathon_app/data/local/session_storage.dart';
import 'package:swades_hackathon_app/data/models/venue.dart';
import 'package:swades_hackathon_app/modules/venues/cubit/venues_list_cubit.dart';
import 'package:swades_hackathon_app/modules/venues/cubit/venues_list_state.dart';
import 'package:swades_hackathon_app/modules/venues/widgets/venue_card.dart';
import 'package:swades_hackathon_app/router/app_router.dart';

@RoutePage()
class VenuesPage extends StatelessWidget {
  const VenuesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VenuesListCubit>(
      create: (_) => getIt<VenuesListCubit>()..load(),
      child: const _VenuesView(),
    );
  }
}

class _VenuesView extends StatelessWidget {
  const _VenuesView();

  Future<void> _logout(BuildContext context) async {
    await getIt<SessionStorage>().clear();
    if (!context.mounted) return;
    await context.router.replaceAll([const LoginRoute()]);
  }

  void _openVenue(BuildContext context, Venue venue) {
    context.router.push(VenueDetailRoute(venue: venue));
  }

  @override
  Widget build(BuildContext context) {
    final session = getIt<SessionStorage>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Venues · ${session.userName ?? ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Switch user',
          ),
        ],
      ),
      body: BlocBuilder<VenuesListCubit, VenuesListState>(
        builder: (context, state) {
          return switch (state) {
            VenuesListInitial() || VenuesListLoading() =>
              const Center(child: CircularProgressIndicator()),
            VenuesListSuccess(:final venues) => venues.isEmpty
                ? const _EmptyState()
                : RefreshIndicator(
                    onRefresh: context.read<VenuesListCubit>().refresh,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: venues.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => VenueCard(
                        venue: venues[i],
                        onTap: () => _openVenue(context, venues[i]),
                      ),
                    ),
                  ),
            VenuesListError(:final failure) => _ErrorView(
                message: failure.message,
                onRetry: context.read<VenuesListCubit>().refresh,
              ),
          };
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('No venues yet.'),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
