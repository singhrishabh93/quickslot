import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swades_hackathon_app/data/di/service_locator.dart';
import 'package:swades_hackathon_app/data/models/booking.dart';
import 'package:swades_hackathon_app/modules/bookings/cubit/my_bookings_cubit.dart';
import 'package:swades_hackathon_app/modules/bookings/cubit/my_bookings_state.dart';
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
        title: const Text('Cancel booking?'),
        content: const Text(
          'This will free the slot for someone else to book.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cancel booking'),
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
          ok ? 'Booking cancelled' : 'Cancel failed. Please try again.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: BlocBuilder<MyBookingsCubit, MyBookingsState>(
        builder: (context, state) {
          return switch (state.status) {
            MyBookingsStatus.initial || MyBookingsStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            MyBookingsStatus.success => state.bookings.isEmpty
                ? const _EmptyState()
                : RefreshIndicator(
                    onRefresh: context.read<MyBookingsCubit>().refresh,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
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
            MyBookingsStatus.error => _ErrorView(
                message: state.failure?.message ?? 'Failed to load bookings',
                onRetry: context.read<MyBookingsCubit>().refresh,
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
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text('No bookings yet', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Bookings you make will show up here.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
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
