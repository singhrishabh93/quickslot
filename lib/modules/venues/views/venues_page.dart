import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swades_hackathon_app/app/theme/app_theme.dart';
import 'package:swades_hackathon_app/app/widgets/empty_view.dart';
import 'package:swades_hackathon_app/app/widgets/skeleton.dart';
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
    final theme = Theme.of(context);
    final userName = (session.userName ?? '').toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('VENUES'),
        actions: [
          IconButton(
            icon: const Icon(Icons.event_note_outlined),
            onPressed: () => context.router.push(const MyBookingsRoute()),
            tooltip: 'My bookings',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Switch user',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<VenuesListCubit, VenuesListState>(
        builder: (context, state) {
          return RefreshIndicator(
            color: AppColors.ink,
            backgroundColor: AppColors.cream,
            onRefresh: context.read<VenuesListCubit>().refresh,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName.isEmpty
                              ? 'PLAYER'
                              : 'PLAYER · $userName',
                          style: theme.textTheme.labelMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'TONIGHT?',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontSize: 44,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pick a venue, pick a slot.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.subtle,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                _buildBody(context, state),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, VenuesListState state) {
    return switch (state) {
      VenuesListInitial() || VenuesListLoading() => SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.separated(
            itemCount: 4,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, _) => const _VenueCardSkeleton(),
          ),
        ),
      VenuesListSuccess(:final venues) => venues.isEmpty
          ? const SliverToBoxAdapter(
              child: EmptyView(
                numeral: '00',
                label: 'No venues',
                caption: 'Nothing seeded yet. Re-run the seed in Supabase.',
              ),
            )
          : SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.separated(
                itemCount: venues.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) => VenueCard(
                  venue: venues[i],
                  onTap: () => _openVenue(context, venues[i]),
                ),
              ),
            ),
      VenuesListError(:final failure) => SliverToBoxAdapter(
          child: ErrorView(
            message: failure.message,
            onRetry: context.read<VenuesListCubit>().refresh,
          ),
        ),
    };
  }
}

class _VenueCardSkeleton extends StatelessWidget {
  const _VenueCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ShimmerScope(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.paper,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Skeleton(width: 80, height: 10),
            SizedBox(height: 14),
            Skeleton(width: 220, height: 28),
            SizedBox(height: 10),
            Skeleton(width: 160, height: 12),
            SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Skeleton(width: 90, height: 20),
                Skeleton(width: 72, height: 28),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
