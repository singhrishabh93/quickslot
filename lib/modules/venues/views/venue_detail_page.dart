import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swades_hackathon_app/data/di/service_locator.dart';
import 'package:swades_hackathon_app/data/models/slot.dart';
import 'package:swades_hackathon_app/data/models/venue.dart';
import 'package:swades_hackathon_app/modules/venues/cubit/venue_detail_cubit.dart';
import 'package:swades_hackathon_app/modules/venues/cubit/venue_detail_state.dart';
import 'package:swades_hackathon_app/modules/venues/widgets/date_chips_row.dart';
import 'package:swades_hackathon_app/modules/venues/widgets/slot_grid.dart';
import 'package:swades_hackathon_app/modules/venues/widgets/venue_header.dart';

@RoutePage()
class VenueDetailPage extends StatelessWidget {
  const VenueDetailPage({super.key, required this.venue});

  final Venue venue;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VenueDetailCubit>(
      create: (_) => getIt<VenueDetailCubit>(param1: venue)..init(),
      child: _VenueDetailView(venue: venue),
    );
  }
}

class _VenueDetailView extends StatelessWidget {
  const _VenueDetailView({required this.venue});

  final Venue venue;

  void _onSlotTap(BuildContext context, Slot slot) {
    if (slot.isBooked) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Will open booking sheet in F9 · ${slot.displayRange}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(venue.name)),
      body: BlocBuilder<VenueDetailCubit, VenueDetailState>(
        builder: (context, state) {
          final cubit = context.read<VenueDetailCubit>();
          return RefreshIndicator(
            onRefresh: cubit.refresh,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: VenueHeader(venue: state.venue)),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _DateChipsDelegate(
                    DateChipsRow(
                      selectedDate: state.selectedDate,
                      onDateSelected: cubit.changeDate,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: _SlotsArea(state: state, onTap: _onSlotTap),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SlotsArea extends StatelessWidget {
  const _SlotsArea({required this.state, required this.onTap});

  final VenueDetailState state;
  final void Function(BuildContext, Slot) onTap;

  @override
  Widget build(BuildContext context) {
    return switch (state.status) {
      SlotsStatus.initial || SlotsStatus.loading => const Padding(
          padding: EdgeInsets.only(top: 48),
          child: Center(child: CircularProgressIndicator()),
        ),
      SlotsStatus.success => state.slots.isEmpty
          ? const _EmptyState()
          : SlotGrid(
              slots: state.slots,
              onSlotTap: (slot) => onTap(context, slot),
            ),
      SlotsStatus.error => _ErrorView(
          message: state.failure?.message ?? 'Failed to load slots',
          onRetry: context.read<VenueDetailCubit>().refresh,
        ),
    };
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 48),
      child: Center(child: Text('No slots for this date.')),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _DateChipsDelegate extends SliverPersistentHeaderDelegate {
  _DateChipsDelegate(this.child);
  final Widget child;

  @override
  double get minExtent => 72;
  @override
  double get maxExtent => 72;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
