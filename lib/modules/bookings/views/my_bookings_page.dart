import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swades_hackathon_app/app/theme/app_theme.dart';
import 'package:swades_hackathon_app/app/widgets/empty_view.dart';
import 'package:swades_hackathon_app/app/widgets/skeleton.dart';
import 'package:swades_hackathon_app/data/di/service_locator.dart';
import 'package:swades_hackathon_app/data/models/booking.dart';
import 'package:swades_hackathon_app/modules/bookings/cubit/my_bookings_cubit.dart';
import 'package:swades_hackathon_app/modules/bookings/cubit/my_bookings_state.dart';
import 'package:intl/intl.dart';
import 'package:swades_hackathon_app/modules/bookings/widgets/booking_tile.dart';

@RoutePage()
class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MyBookingsCubit>(
      create: (_) => getIt<MyBookingsCubit>()..load(),
      child: const _MyBookingsView(),
    );
  }
}

class _MyBookingsView extends StatelessWidget {
  const _MyBookingsView();

  Future<bool> _confirmCancel(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('CANCEL BOOKING?'),
        content: const Text(
          'This frees the slot for someone else to book.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('KEEP'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _onCancel(BuildContext context, Booking booking) async {
    final cubit = context.read<MyBookingsCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await _confirmCancel(context);
    if (!confirmed) return;

    final ok = await cubit.cancelBooking(booking.id);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Booking cancelled.' : 'Cancel failed. Try again.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('MY BOOKINGS')),
      body: BlocBuilder<MyBookingsCubit, MyBookingsState>(
        builder: (context, state) {
          return RefreshIndicator(
            color: AppColors.ink,
            backgroundColor: AppColors.cream,
            onRefresh: context.read<MyBookingsCubit>().refresh,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YOUR SCHEDULE',
                          style: theme.textTheme.labelMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _countLine(state),
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontSize: 40,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (state.isFromCache) _OfflineBanner(stamp: state.cacheStamp),
                        const SizedBox(height: 8),
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

  String _countLine(MyBookingsState state) {
    if (state.status != MyBookingsStatus.success) return '—';
    final confirmed = state.bookings
        .where((b) => b.status == BookingStatus.confirmed)
        .length;
    return '$confirmed ACTIVE';
  }

  Widget _buildBody(BuildContext context, MyBookingsState state) {
    return switch (state.status) {
      MyBookingsStatus.initial || MyBookingsStatus.loading => SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.separated(
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, _) => const _BookingSkeleton(),
          ),
        ),
      MyBookingsStatus.success => state.bookings.isEmpty
          ? const SliverToBoxAdapter(
              child: EmptyView(
                numeral: '00',
                label: 'Nothing booked',
                caption: 'Pick a slot from any venue to fill this page.',
              ),
            )
          : SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.separated(
                itemCount: state.bookings.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final b = state.bookings[i];
                  return BookingTile(
                    booking: b,
                    isCancelling: state.cancellingId == b.id,
                    onCancel: () => _onCancel(context, b),
                  );
                },
              ),
            ),
      MyBookingsStatus.error => SliverToBoxAdapter(
          child: ErrorView(
            message: state.failure?.message ?? 'Failed to load bookings',
            onRetry: context.read<MyBookingsCubit>().refresh,
          ),
        ),
    };
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.stamp});

  final DateTime? stamp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stampStr = stamp == null
        ? ''
        : ' · LAST SYNC ${DateFormat('d MMM, HH:mm').format(stamp!.toLocal()).toUpperCase()}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.clay, width: 1),
        color: AppColors.clayWash,
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_outlined,
              size: 16, color: AppColors.clay),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'OFFLINE · CACHED VIEW$stampStr',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.clay,
                letterSpacing: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingSkeleton extends StatelessWidget {
  const _BookingSkeleton();

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
            Skeleton(width: 100, height: 10),
            SizedBox(height: 12),
            Skeleton(width: 220, height: 26),
            SizedBox(height: 24),
            Skeleton(width: double.infinity, height: 48),
          ],
        ),
      ),
    );
  }
}
