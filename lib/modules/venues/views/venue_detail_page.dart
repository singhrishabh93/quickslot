import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swades_hackathon_app/app/theme/app_theme.dart';
import 'package:swades_hackathon_app/app/widgets/empty_view.dart';
import 'package:swades_hackathon_app/app/widgets/skeleton.dart';
import 'package:swades_hackathon_app/data/di/service_locator.dart';
import 'package:swades_hackathon_app/data/models/slot.dart';
import 'package:swades_hackathon_app/data/models/venue.dart';
import 'package:swades_hackathon_app/modules/bookings/widgets/confirm_booking_sheet.dart';
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

  Future<void> _onSlotTap(BuildContext context, Slot slot) async {
    if (slot.isBooked) return;
    final detailCubit = context.read<VenueDetailCubit>();

    final result = await showModalBottomSheet<BookingSheetResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      builder: (_) => ConfirmBookingSheet(venue: venue, slot: slot),
    );

    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);

    switch (result) {
      case BookingSheetResult.success:
        messenger.showSnackBar(
          const SnackBar(content: Text('Booking confirmed.')),
        );
        await detailCubit.refresh();
      case BookingSheetResult.slotTaken:
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Slot was just taken by someone else.'),
          ),
        );
        await detailCubit.refresh();
      case BookingSheetResult.failed:
        messenger.showSnackBar(
          const SnackBar(content: Text('Booking failed. Please try again.')),
        );
      case BookingSheetResult.cancelled:
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SLOTS')),
      body: BlocBuilder<VenueDetailCubit, VenueDetailState>(
        builder: (context, state) {
          final cubit = context.read<VenueDetailCubit>();
          return RefreshIndicator(
            color: AppColors.ink,
            backgroundColor: AppColors.cream,
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
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
  final Future<void> Function(BuildContext, Slot) onTap;

  @override
  Widget build(BuildContext context) {
    return switch (state.status) {
      SlotsStatus.initial || SlotsStatus.loading => const _SlotGridSkeleton(),
      SlotsStatus.success => state.slots.isEmpty
          ? const EmptyView(
              numeral: '00',
              label: 'No slots',
              caption: 'No hours available for this date.',
            )
          : SlotGrid(
              slots: state.slots,
              onSlotTap: (slot) => onTap(context, slot),
            ),
      SlotsStatus.error => ErrorView(
          message: state.failure?.message ?? 'Failed to load slots',
          onRetry: context.read<VenueDetailCubit>().refresh,
        ),
    };
  }
}

class _SlotGridSkeleton extends StatelessWidget {
  const _SlotGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return ShimmerScope(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.35,
        ),
        itemCount: 8,
        itemBuilder: (_, _) => Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class _DateChipsDelegate extends SliverPersistentHeaderDelegate {
  _DateChipsDelegate(this.child);
  final Widget child;

  @override
  double get minExtent => 96;
  @override
  double get maxExtent => 96;

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
